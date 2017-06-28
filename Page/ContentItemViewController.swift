//
//  ContentItemViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/19.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import WebKit

class ContentItemViewController: UIViewController, UINavigationControllerDelegate{
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var dataObject: ContentItem? {
        didSet {
            //            print ("data object changed")
            //            print ("id: \(dataObject?.id) type: \(dataObject?.type) body: \(dataObject?.cbody)")
            initText()
        }
    }
    var pageTitle: String = ""
    var themeColor: String?
    private var detailDisplayed = false
    fileprivate lazy var webView: WKWebView? = nil
    fileprivate var isWebViewAdded = false
    
    fileprivate let contentAPI = ContentFetch()
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var toolBar: UIToolbar!
//    
//    @IBOutlet weak var languageSwitch: UISegmentedControl!
//    @IBOutlet weak var actionButton: UIBarButtonItem!
//    @IBOutlet weak var bookMark: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDetailInfo()
        initStyle()
        
        navigationController?.delegate = self
        navigationItem.title = "another test from oliver"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print ("view did layout subviews")
        initText()
    }
    
    private func getDetailInfo() {
        let urlString = "\(APIs.story)\(dataObject?.id ?? "")"
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        contentAPI.fetchContentForUrl(urlString) {
            [weak self] results, error in
            DispatchQueue.main.async {
                self?.activityIndicator.removeFromSuperview()
                if let error = error {
                    print("Error searching : \(error)")
                    return
                }
                if let results = results {
                    self?.dataObject?.cbody = results.fetchResults[0].items[0].cbody
                    self?.dataObject?.ebody = results.fetchResults[0].items[0].ebody
                }
            }
        }
    }
    
    private func initStyle() {
        textView.backgroundColor = UIColor(hex: Color.Content.background)
        // MARK: Make the text view uneditable
        textView.isEditable = false
    }
    
    
    
    private func initText() {
        // MARK: https://makeapppie.com/2016/07/05/using-attributed-strings-in-swift-3-0/
        // MARK: Convert HTML to NSMutableAttributedString https://stackoverflow.com/questions/36427442/nsfontattributename-not-applied-to-nsattributedstring
        let bodyString = dataObject?.cbody ?? dataObject?.lead ?? "body"
        // MARK: There are three ways to convert HTML body text into NSMutableAttributedString. Each has its merits and limits. 
        if let body = htmlToAttributedString(bodyString) {
            // MARK: If we can handle all the HTML tags confidantly
            renderTextview(body)
        } else if let body = bodyString.htmlAttributedString() {
            // MARK: The above uses the string extension to convert string to data then to NSMutableAttributedString. Not sure if this is expensive in terms of computing resource. If there are images in the HTML, there might be delay after tapping as the image is not downloaded asyn.
            renderTextview(body)
        } else {
            // MARK: Use WKWebView to display story
            renderWebView()
        }
    }
    
    private func renderTextview(_ body: NSMutableAttributedString) {
        let headlineColor = UIColor(hex: Color.Content.headline)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12.0
        
        // MARK: Headline Style and Text
        let headlineString = dataObject?.headline ?? ""
        let headline = NSMutableAttributedString(
            string: "\(headlineString)\n",
            attributes: [
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title1).bold(),
                NSParagraphStyleAttributeName: paragraphStyle,
                NSForegroundColorAttributeName: headlineColor
            ]
        )
        
        let text = NSMutableAttributedString()
        text.append(headline)
        text.append(body)
        textView?.attributedText = text
        // MARK: - a workaround for the myterious scroll view bug
        textView?.isScrollEnabled = false
        textView?.isScrollEnabled = true
        textView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    private func renderWebView() {
        print ("there are HTML tags that cannot be handled, use webview to handle it instead")
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webViewFrame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height - 44)
        webView = WKWebView(frame: webViewFrame, configuration: config)
        webView?.isOpaque = true
        webView?.backgroundColor = UIColor.clear
        webView?.scrollView.backgroundColor = UIColor.clear
        if let wv = self.webView {
            //self.textView.removeFromSuperview()
            // FIXME: add subview is not safe. What happens if there already is a webview?
            if isWebViewAdded == false {
                self.view.addSubview(wv)
                isWebViewAdded = true
            }
            self.view.clipsToBounds = true
            webView?.scrollView.bounces = false
            let urlString: String
            if dataObject?.type == "story" {
                if let id = dataObject?.id {
                    urlString = "http://www.ftchinese.com/story/\(id)?full=y"
                } else {
                    urlString = "http://www.ftchinese.com/"
                }
            } else {
                urlString = "http://www.ftchinese.com/"
            }
            
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                
                if let adHTMLPath = Bundle.main.path(forResource: "story", ofType: "html"){
                    do {
                        let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let storyHTML = storyTemplate as String
                        self.webView?.loadHTMLString(storyHTML, baseURL:url)
                    } catch {
                        self.webView?.load(request)
                    }
                } else {
                    self.webView?.load(request)
                }
                
            }
        }
    }
    
    
    fileprivate func htmlToAttributedString(_ htmltext: String) -> NSMutableAttributedString? {
        // MARK: remove p tags in text
        let text = htmltext.replacingOccurrences(of: "(</[pP]>[\n\r]*<[pP]>)+", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "(^<[pP]>)+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "(</[pP]>)+$", with: "", options: .regularExpression)
        
        // MARK: Set the overall text style
        let bodyColor = UIColor(hex: Color.Content.body)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12.0
        paragraphStyle.lineHeightMultiple = 1.2
        let bodyAttributes:[String:AnyObject] = [
            NSFontAttributeName:UIFont.preferredFont(forTextStyle: .body),
            NSForegroundColorAttributeName: bodyColor,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        let attrString = NSMutableAttributedString(string: text, attributes:nil)
        // MARK: Handle bold tag
        let pattern = "<[bi]>(.*)</[bi]>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSMakeRange(0, text.characters.count)
        attrString.addAttributes(bodyAttributes, range: NSMakeRange(0, attrString.length))
        let boldParagraphStyle = NSMutableParagraphStyle()
        boldParagraphStyle.paragraphSpacing = 6.0
        let boldAttributes:[String:AnyObject] = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body).bold(),
            NSParagraphStyleAttributeName: boldParagraphStyle
        ]
        
        if let matches = regex?.matches(in: text, options: [], range: range) {
            print(matches.count)
            //Iterate over regex matches
            for match in matches.reversed() {
                //Properly print match range
                print(match.range)
                let value = attrString.attributedSubstring(from: match.rangeAt(1)).string
                print (value)
                //attrString.addAttribute(NSLinkAttributeName, value: "http://www.ft.com/", range: match.rangeAt(0))
                attrString.addAttributes(boldAttributes, range: match.rangeAt(0))
                attrString.replaceCharacters(in: match.rangeAt(0), with: "\(value)")
            }
        }
        
        // MARK: if there are unhandled tags, use WebView to open the content
        if attrString.string.contains("<") && attrString.string.contains(">") {
            return nil
        }
        return attrString
    }
    
    
}


extension String {
    func htmlAttributedString() -> NSMutableAttributedString? {
        print ("use html attributed string extension for: ")
        print (self)
        let storyHTML: String?
        if let adHTMLPath = Bundle.main.path(forResource: "storybody", ofType: "html"){
            do {
                let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                storyHTML = (storyTemplate as String).replacingOccurrences(of: "{story-body-text}", with: self)
            } catch {
                return nil
            }
        } else {
            return nil
        }
        guard let text = storyHTML else {
            return nil
        }
        guard let data = text.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) else { return nil }
        return html
    }
}
