//
//  AdView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/12.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
class AdView: UIView, SFSafariViewControllerDelegate {
    
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
                print ("Request Ad From \(url)")
                Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                    DispatchQueue.main.async { () -> Void in
                        guard let data = data , error == nil, let adCode = String(data: data, encoding: .utf8) else {
                            print ("Fail: Request Ad From \(url)")
                            self?.handleAdModel()
                            return
                        }
                        print ("Success: Request Ad From \(url)")
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
        if let adModel = self.adModel {
            if let imageString = adModel.imageString {
                // TODO: If the asset is already downloaded, no need to request from the Internet
                if let data = Download.readFile(imageString, for: .cachesDirectory, as: nil) {
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
                        Download.saveFile(data, filename: imageString, to: .cachesDirectory, as: nil)
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
        //reportImpressions()
        if let impressions = adModel?.impressions {
            Impressions.report(impressions)
        }
        
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
            self.backgroundColor = UIColor(hex: Color.Content.background)
        } else {
            self.loadWebView()
        }
        addTap()
    }
    
    private func addTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let link = self.adModel?.link, let url = URL(string: link) {
            openLink(url)
        }
    }
    
    fileprivate func openLink(_ url: URL) {
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        if let topController = UIApplication.topViewController() {
            topController.present(webVC, animated: true, completion: nil)
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
            webView.navigationDelegate = self
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

}

extension AdView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if navigationAction.navigationType == .linkActivated{
                if urlString.range(of: "mailto:") != nil{
                    UIApplication.shared.openURL(url)
                } else {
                    openLink(url)
                }
                decisionHandler(.cancel)
            }  else {
                decisionHandler(.allow)
            }
        }
    }
}
