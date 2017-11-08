//
//  columnViewController.swift
//  Page
//
//  Created by huiyun.he on 21/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//
import UIKit
import Foundation
import WebKit
class ColumnViewController: UIViewController, UINavigationControllerDelegate,WKScriptMessageHandler,WKNavigationDelegate {
    private lazy var webView: WKWebView? = nil
    override func viewDidLoad() {
        renderWebView()
    }
    override func loadView() {
        super.loadView()
        let contentController = WKUserContentController();
        let jsCode = "window.gConnectionType = '\(Connection.current())';window.gNoImageWithData='\(Setting.getSwitchStatus("no-image-with-data"))';"
        let userScript = WKUserScript(
            source: jsCode,
            injectionTime: WKUserScriptInjectionTime.atDocumentStart,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        // MARK: - Use a LeakAvoider to avoid leak
        contentController.add(
            LeakAvoider(delegate:self),
            name: "callbackHandler"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        view = webView
        view.clipsToBounds = true
        let webViewBG = UIColor(hex: Color.Content.background)
        webView?.isOpaque = true
        webView?.backgroundColor = webViewBG
        webView?.scrollView.backgroundColor = webViewBG
        self.webView?.scrollView.bounces = false
        self.webView?.navigationDelegate = self
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationController?.delegate = self
    }
    func renderWebView(){
        let url = URL(string:"http://www.ftchinese.com/?webview=ftcapp&newad=yes")
        if let url = url {
            print ("url is now \(url)")
            let request = URLRequest(url: url)
            webView?.load(request)
        }
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

    }
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
