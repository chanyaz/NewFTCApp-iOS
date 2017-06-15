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
    lazy var webView = WKWebView()
    var urlString: String? = nil {
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
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        self.backgroundColor = UIColor.red
        let webViewFrame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        webView = WKWebView(frame: webViewFrame, configuration: config)
        print (webViewFrame)
        
        self.addSubview(self.webView)
        self.clipsToBounds = true
        webView.scrollView.bounces = false
        webView.configuration.allowsInlineMediaPlayback = true
        if let urlString = urlString,
            let url = URL(string: urlString) {
            let req = URLRequest(url:url)
            
            if let adHTMLPath = Bundle.main.path(forResource: "ad", ofType: "html"),
                let gaJSPath = Bundle.main.path(forResource: "ga", ofType: "js"){
                do {
                    let adHTML = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                    let gaJS = try NSString(contentsOfFile:gaJSPath, encoding:String.Encoding.utf8.rawValue)
                    let adHTMLFinal = (adHTML as String).replacingOccurrences(of: "{google-analytics-js}", with: gaJS as String)
                    self.webView.loadHTMLString(adHTMLFinal, baseURL:url)
                } catch {
                    webView.load(req)
                }
            } else {
                webView.load(req)
            }
            
        }
    }
    
    
    // TODO: Upgrade to native for default templates
    
    
}
