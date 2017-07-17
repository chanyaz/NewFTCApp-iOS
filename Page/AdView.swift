//
//  AdView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/12.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import WebKit
class AdView: UIView {
    
    private var adid: String?
    private var adWidth: String?
    private var adModel: AdModel?
    
    public var contentSection: ContentSection? = nil {
        didSet {
            updateUI()
        }
    }
    
    public func updateUI() {
        if let adType = contentSection?.type, adType == "MPU" {
            adWidth = "300px"
        } else {
            adWidth = "100%"
        }
        //TODO: - We should preload the ad information to avoid decreasing our ad inventory
        if let adid = contentSection?.adid {
            self.adid = adid
            if let url = AdParser.getAdUrlFromDolphin(adid) {
                clean()
                Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                    DispatchQueue.main.async { () -> Void in
                        guard let data = data , error == nil, let adCode = String(data: data, encoding: .utf8) else {
                            self?.handleAdModel()
                            return
                        }
                        let adModel = AdParser.parseAdCode(adCode)
                        self?.adModel = adModel
                        self?.handleAdModel()
                    }
                }
            }
        }
    }
    
    private func clean() {
        // MARK: remove subviews before loading new creatives
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func handleAdModel() {
        //loadWebView()
        if let adModel = self.adModel {
            if let imageString = adModel.imageString {
                // TODO: If the asset is already downloaded, no need to request from the Internet
                if let data = Download.readFile(imageString, for: .cachesDirectory) {
                    showAdImage(data)
                    print ("image already in cache:\(imageString)")
                    return
                }
                print ("continue to get the image file")
                if let url = URL(string: imageString) {
                    Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                        guard let data = data else {
                            self?.loadWebView()
                            return
                        }
                        DispatchQueue.main.async { () -> Void in
                            self?.showAdImage(data)
                        }
                        Download.saveFile(data, filename: imageString, to: .cachesDirectory)
                    }
                }
            } else {
                loadWebView()
            }
        } else {
            loadWebView()
        }
    }
    
    private func showAdImage(_ data: Data) {
        // MARK: Report Impressions First
        reportImpressions()
        
        let frameWidth = self.frame.width
        let frameHeight = self.frame.height
        if let image = UIImage(data: data),
            let adWidth = self.adWidth {
            let imageWidth: CGFloat
            if adWidth.hasSuffix("px") {
                let adWidthString = adWidth.replacingOccurrences(of: "px", with: "")
                if let adWidthInt = Int(adWidthString) {
                    imageWidth = CGFloat(adWidthInt)
                } else {
                    imageWidth = frameWidth
                }
            } else {
                imageWidth = frameWidth
            }
            let imageX = min(max((frameWidth - imageWidth)/2,0), frameWidth)
            let imageFrame = CGRect(x: imageX, y: 0, width: imageWidth, height: frameHeight)
            let imageView = UIImageView(frame: imageFrame)
            imageView.image = image
            self.addSubview(imageView)
        } else {
            self.loadWebView()
        }
    }
    
    private func loadWebView() {
        if let adid = self.adid, let adWidth = self.adWidth {
            let config = WKWebViewConfiguration()
            config.allowsInlineMediaPlayback = true
            let webView = WKWebView(frame: self.frame, configuration: config)
            webView.isOpaque = true
            webView.backgroundColor = UIColor.clear
            webView.scrollView.backgroundColor = UIColor.clear
            self.addSubview(webView)
            let urlString = AdParser.getAdPageUrlForAdId(adid)
            if let url = URL(string: urlString) {
                let req = URLRequest(url:url)
                if let adHTMLPath = Bundle.main.path(forResource: "ad", ofType: "html"),
                    let gaJSPath = Bundle.main.path(forResource: "ga", ofType: "js"){
                    do {
                        let adHTML = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let gaJS = try NSString(contentsOfFile:gaJSPath, encoding:String.Encoding.utf8.rawValue)
                        let adHTMLFinal = (adHTML as String)
                            .replacingOccurrences(of: "{google-analytics-js}", with: gaJS as String)
                            .replacingOccurrences(of: "{adbodywidth}", with: adWidth)
                        webView.loadHTMLString(adHTMLFinal, baseURL:url)
                    } catch {
                        webView.load(req)
                    }
                } else {
                    webView.load(req)
                }
            }
        }
    }
    
    // MARK: report ad impressions
    private func reportImpressions() {
        if let impressions = adModel?.impressions {
            //print ("found \(impressions.count) impressions callings")
            let deviceType = DeviceInfo.checkDeviceType()
            let unixDateStamp = Date().timeIntervalSince1970
            let timeStamp = String(unixDateStamp).replacingOccurrences(of: ".", with: "")
            for impressionUrlString in impressions {
                let impressionUrlStringWithTimestamp = impressionUrlString.replacingOccurrences(of: "[timestamp]", with: timeStamp)
                print ("send to \(impressionUrlStringWithTimestamp)")
                if var urlComponents = URLComponents(string: impressionUrlStringWithTimestamp) {
                    let newQuery = URLQueryItem(name: "fttime", value: timeStamp)
                    if urlComponents.queryItems != nil {
                        urlComponents.queryItems?.append(newQuery)
                    } else {
                        urlComponents.queryItems = [newQuery]
                    }
                    if let url = urlComponents.url {
                        Download.getDataFromUrl(url) { (data, response, error)  in
                            DispatchQueue.main.async { () -> Void in
                                guard let _ = data , error == nil else {
                                    // MARK: Use the original impressionUrlString for Google Analytics
                                    //let jsCode = "try{ga('send','event', '\(deviceType) Launch Ad', 'Fail', '\(impressionUrlString)', {'nonInteraction':1});}catch(ignore){}"
                                    //self.webView.evaluateJavaScript(jsCode) { (result, error) in
                                    //}
                                    // MARK: The string should have the parameter
                                    print ("Fail to send impression to \(deviceType) \(url.absoluteString)")
                                    return
                                }
                                //let jsCode = "try{ga('send','event', '\(deviceType) Launch Ad', 'Sent', '\(impressionUrlString)', {'nonInteraction':1});}catch(ignore){}"
                                //self.webView.evaluateJavaScript(jsCode) { (result, error) in
                                //}
                                print("sent impression to \(deviceType) \(url.absoluteString)")
                            }
                        }
                    }
                }
            }
        }
    }
    
}
