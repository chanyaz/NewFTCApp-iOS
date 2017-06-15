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
        webView = WKWebView(frame: self.frame, configuration: config)
        self.addSubview(self.webView)
        self.clipsToBounds = true
        webView.scrollView.bounces = false
        webView.configuration.allowsInlineMediaPlayback = true
        if let urlString = urlString,
            let url = URL(string: urlString) {
            let req = URLRequest(url:url)
            
            if let templatepath = Bundle.main.path(forResource: "a", ofType: "html") {
                do {
                    let s = try NSString(contentsOfFile:templatepath, encoding:String.Encoding.utf8.rawValue)
                    self.webView.loadHTMLString(s as String, baseURL:url)
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
