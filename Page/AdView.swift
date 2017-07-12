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
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    var adid: String?
    var adWidth: String?
    var adModel: AdModel?
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        loadAdView()
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        loadAdView()
//    }
    
//    // MARK: If Ad Parser can not get the correct adModel
//    init(adid: String, adWidth: String, adFrame: CGRect) {
//        self.adid = adid
//        self.adWidth = adWidth
//        super.init(frame: adFrame)
//        loadAdWebView()
//    }
//    
//    // MARK: If Ad Parser gets the correct adModel
//    init(adModel: AdModel, adid: String, adWidth: String, adFrame: CGRect) {
//        self.adModel = adModel
//        self.adid = adid
//        self.adWidth = adWidth
//        super.init(frame: adFrame)
//        loadAdView()
//    }
    

    public func loadAdView() {
        let frameWidth = self.frame.width
        let frameHeight = self.frame.height
        if let adModel = self.adModel {
            if let imageString = adModel.imageString {
                // TODO: If the asset is already downloaded, no need to request from the Internet
                
                if let url = URL(string: imageString) {
                Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                    guard let data = data else {
                        self?.loadAdWebView()
                        return
                    }
                    DispatchQueue.main.async { () -> Void in
                        if let image = UIImage(data: data),
                            let adWidth = self?.adWidth {
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
                            self?.subviews.forEach {
                                $0.removeFromSuperview()
                            }
                            self?.addSubview(imageView)
                        } else {
                            self?.loadAdWebView()
                        }
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
