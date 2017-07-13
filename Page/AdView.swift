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
    
    var adid: String?
    var adWidth: String?
    var adModel: AdModel?

    public func loadAdView() {

        if let adModel = self.adModel {
            if let imageString = adModel.imageString {
                // TODO: If the asset is already downloaded, no need to request from the Internet
                if let data = Download.readFile(imageString, for: .cachesDirectory) {
                    showAdImage(data)
                    print ("image already in cache:\(imageString)")
                    return
                }
                if let url = URL(string: imageString) {
                Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                    guard let data = data else {
                        self?.loadAdWebView()
                        return
                    }
                    DispatchQueue.main.async { () -> Void in
                        self?.showAdImage(data)
                    }
                    Download.saveFile(data, filename: imageString, to: .cachesDirectory)
                }
                }
            } else {
                loadAdWebView()
            }
        } else {
            loadAdWebView()
        }
    }
    
    private func showAdImage(_ data: Data) {
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
            self.subviews.forEach {
                $0.removeFromSuperview()
            }
            self.addSubview(imageView)
        } else {
            self.loadAdWebView()
        }
    }
    
    private func loadAdWebView() {
        if let adid = self.adid, let adWidth = self.adWidth {
            let config = WKWebViewConfiguration()
            config.allowsInlineMediaPlayback = true
            let webView = WKWebView(frame: self.frame, configuration: config)
            webView.isOpaque = true
            webView.backgroundColor = UIColor.clear
            webView.scrollView.backgroundColor = UIColor.clear
            self.subviews.forEach {
                $0.removeFromSuperview()
            }
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
