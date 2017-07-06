//
//  Ad.swift
//  Page
//
//  Created by ZhangOliver on 2017/6/15.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class Ad: UICollectionReusableView {
    
    // MARK: - Use lazy var for webView as we might later switch to native ad and use web view only as fallback
    fileprivate lazy var webView: WKWebView? = nil
    var contentSection: ContentSection? = nil {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //nibSetup()
    }
    
    // MARK: Use WKWebview to migrate current display ads.
    func updateUI() {
        print ("update UI now")
        self.backgroundColor = UIColor(hex: Color.Ad.background)
        //self.backgroundColor = UIColor.red
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webViewFrame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        webView = WKWebView(frame: webViewFrame, configuration: config)
        
        webView?.isOpaque = true
        webView?.backgroundColor = UIColor.clear
        webView?.scrollView.backgroundColor = UIColor.clear
        //webView.backgroundColor = UIColor.yellow
        
        
        
        if let wv = self.webView {
            self.addSubview(wv)
            
            
            self.clipsToBounds = true
            webView?.scrollView.bounces = false
            webView?.configuration.allowsInlineMediaPlayback = true
            let adWidth: String
            if let adType = contentSection?.type,
                adType == "MPU" {
                adWidth = "300px"
            } else {
                adWidth = "100%"
            }
            //TODO: - We should preload the ad information to avoid decreasing our ad inventory
            if let adid = contentSection?.adid {
                if let url = AdParser.getAdUrlFromDolphin(adid) {
                    Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                        DispatchQueue.main.async { () -> Void in
                            guard let data = data , error == nil, let adCode = String(data: data, encoding: .utf8) else {
                                self?.loadAdWebView(adid, adWidth: adWidth)
                                return
                            }
                            let adModel = AdParser.parseAdCode(adCode)
                            print (adModel.image ?? "")
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func loadAdWebView(_ adid: String, adWidth: String) {

        
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
                    self.webView?.loadHTMLString(adHTMLFinal, baseURL:url)
                } catch {
                    self.webView?.load(req)
                }
            } else {
                self.webView?.load(req)
            }

        }
    }
    // TODO: Need to implement url click in wkwebview
    
    // TODO: Upgrade to native for default templates
    
    
}
