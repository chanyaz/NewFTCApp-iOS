//
//  WKWebPage.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/11.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import WebKit
class WKWebPage {
    // MARK: - Use singleton pattern to pass speech data between view controllers.
    var sharedInstance = WKWebPage()
    static let webConfiguration = WKWebViewConfiguration()
    var webView = WKWebView(frame: .zero, configuration: webConfiguration)
    
    
    
//            webConfiguration.allowsInlineMediaPlayback = true
//            webView = WKWebView(frame: .zero, configuration: webConfiguration)

}
