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

    lazy var webView = WKWebView()
//    var frame: CGRect
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        self.backgroundColor = UIColor.red
        webView = WKWebView(frame: self.frame, configuration: config)
        self.addSubview(self.webView)
        self.clipsToBounds = true
        webView.scrollView.bounces = false
        webView.configuration.allowsInlineMediaPlayback = true
        let webPageUrl = "http://www.ftchinese.com/"
        if let url = URL(string:webPageUrl) {
            let req = URLRequest(url:url)
            webView.load(req)
        }
    }
    
    
    // TODO: 1. Use WKWebview to migrate current display ads. 2. Upgrade to native for default templates
    
    
}
