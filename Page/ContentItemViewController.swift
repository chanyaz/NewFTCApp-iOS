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
    var dataObject: ContentItem?
    var pageTitle: String = ""
    var themeColor: String?
    private var detailDisplayed = false
    fileprivate lazy var webView: WKWebView? = nil
    fileprivate var isWebViewAdded = false
    
    fileprivate let contentAPI = ContentFetch()
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var topBanner: UIView!
    
    @IBOutlet weak var tag: UILabel!
    
    @IBOutlet weak var headline: UILabel!
    
    @IBOutlet weak var lead: UILabel!
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var byline: UILabel!
    
    @IBOutlet weak var bodyTextView: UITextView!
    // TODO: https://stackoverflow.com/questions/38948904/calculating-contentsize-for-uiscrollview-when-using-auto-layout
    
    
    //@IBOutlet weak var textView: UITextView!
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
    
    deinit {
        //MARK: Some of the deinit might b e useful in the future
//        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
//        self.webView?.removeObserver(self, forKeyPath: "canGoBack")
//        self.webView?.removeObserver(self, forKeyPath: "canGoForward")
//        
//        // MARK: - Stop loading and remove message handlers to avoid leak
//        self.webView?.stopLoading()
//        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
//        self.webView?.configuration.userContentController.removeAllUserScripts()
//        
//        // MARK: - Remove delegate to deal with crashes on iOS 8
//        self.webView?.navigationDelegate = nil
        self.webView?.scrollView.delegate = nil
        print ("deinit web view successfully")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print ("view did layout subviews")
        headline.text = ""
        tag.text = ""
        lead.text = ""
        byline.text = ""
        updatePageContent()
        
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
                    let item = results.fetchResults[0].items[0]
                    self?.dataObject?.cbody = item.cbody
                    self?.dataObject?.ebody = item.ebody
                    self?.dataObject?.publishTime = item.publishTime
                    self?.dataObject?.chineseByline = item.chineseByline
                    self?.dataObject?.englishByline = item.englishByline
                    self?.updatePageContent()
                }
            }
        }
    }
    
    private func initStyle() {
        self.view.backgroundColor = UIColor(hex: Color.Content.background)
        topBanner.backgroundColor = UIColor(hex: Color.Ad.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
        headline.font = headline.font.bold()
        tag.textColor = UIColor(hex: Color.Content.tag)
        tag.font = tag.font.bold()
        byline.textColor = UIColor(hex: Color.Content.time)
        lead.textColor = UIColor(hex: Color.Content.lead)
        bodyTextView.backgroundColor = UIColor(hex: Color.Content.background)
    }
    
    private func updatePageContent() {
        // MARK: https://makeapppie.com/2016/07/05/using-attributed-strings-in-swift-3-0/
        // MARK: Convert HTML to NSMutableAttributedString https://stackoverflow.com/questions/36427442/nsfontattributename-not-applied-to-nsattributedstring
        if let bodyString = dataObject?.cbody {
            // MARK: There are three ways to convert HTML body text into NSMutableAttributedString. Each has its merits and limits.
            if let body = htmlToAttributedString(bodyString){
                // MARK: If we can handle all the HTML tags confidantly
                renderTextview(body)
            } else {
                // MARK: Use WKWebView to display story
                renderWebView()
            }
        }
    }
    
    private func renderTextview(_ body: NSMutableAttributedString) {
        print ("render the text view with native code")


        
        // MARK: Ad View
        
        // MARK: Image View
        if let loadedImage = dataObject?.detailImage {
            coverImage.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            let imageWidth = Int(view.frame.width)
            let imageHeight = imageWidth * 9 / 16
            dataObject?.loadImage(type: "detail", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.coverImage.image = cellContentItem.thumbnailImage
            })
        }
        
        // MARK: the outlets may not exist so "?" is necessary
        headline?.text = dataObject?.headline ?? ""
        
        // MARK: Get the first tag using regular expression
        let tagString = dataObject?.tag ?? ""
        let firstTag = tagString.replacingOccurrences(of: "[,，].*$", with: "", options: .regularExpression)
        tag?.text = firstTag
        
        
        // MARK: Use NSMutableAttributedString to display byline
        let publishingTime = dataObject?.publishTime ?? ""
        let publishingTimeAttributedString = NSMutableAttributedString(string: publishingTime, attributes:nil)
        
        
        // MARK: Set the author text style
        let authorColor = UIColor(hex: Color.Content.body)
        let authorAttributes:[String:AnyObject] = [
            NSForegroundColorAttributeName: authorColor
        ]
        
        
        let bylineString = dataObject?.chineseByline ?? ""
        let bylineAttrString = NSMutableAttributedString(string: " \(bylineString)", attributes:authorAttributes)
        
        
        let bylineAttributedString = NSMutableAttributedString()
        bylineAttributedString.append(publishingTimeAttributedString)
        bylineAttributedString.append(bylineAttrString)
        
        byline?.attributedText = bylineAttributedString
        
        //byline?.text = dataObject?.publishTime ?? ""
        
        //paragraphStyle.paragraphSpacing = 12.0
        let paragraphStyle = NSMutableParagraphStyle()
        //paragraphStyle.paragraphSpacing = 12.0
        paragraphStyle.lineHeightMultiple = 1.0
        paragraphStyle.lineSpacing = 5.0
        //paragraphStyle.paragraphSpacing = 100.0
        
        let leadAttributes:[String:AnyObject] = [
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        let leadString = dataObject?.lead ?? ""
        let leadAttrString = NSMutableAttributedString(string: leadString, attributes:leadAttributes)
        lead?.attributedText = leadAttrString
        //lead?.backgroundColor = UIColor.yellow
        //lead?.text = dataObject?.lead ?? ""
        
        
        let text = NSMutableAttributedString()
        text.append(body)
        bodyTextView?.attributedText = text
        bodyTextView?.isScrollEnabled = false
        
        
        // FIXME: There's something wrong with this text, comment it for now
//        if let content = dataObject {
//            let attributedArticle = AttributedArticle(content: content, contentWidth: bodyTextView.contentSize.width)
//            // attributedArticle.chineseBody
//            // attributedArticle.englishBody
//            // attributedArticle.bilingualBody
//            // print ("chinese body is: \(attributedArticle.chineseBody)")
//            bodyTextView.attributedText = attributedArticle.chineseBody
//        }
    }
    
    private func renderWebView() {
        print ("there are HTML tags that cannot be handled, use webview to handle it instead")
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webViewFrame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        webView = WKWebView(frame: webViewFrame, configuration: config)
        webView?.isOpaque = true
        webView?.backgroundColor = UIColor.clear
        webView?.scrollView.backgroundColor = UIColor.clear
        
        // MARK: This makes the web view scroll like native
        webView?.scrollView.delegate = self
        
        // MARK: Get values for the content
        let headline = dataObject?.headline ?? ""
        let body = dataObject?.cbody ?? ""

        let lead = dataObject?.lead ?? ""
        let tag = (dataObject?.tag ?? "")
            .replacingOccurrences(of: "[,，].*$", with: "", options: .regularExpression)
        let imageHTML:String
        if let image = dataObject?.image {
            imageHTML = "<div class=\"story-image image\"><figure data-url=\"\(image)\" class=\"loading\"></figure></div>"
        } else {
            imageHTML = ""
        }
    
        // MARK: story byline
        let byline = dataObject?.chineseByline ?? ""
        
        // MARK: Story Time
        let timeStamp = dataObject?.publishTime ?? ""
        
        
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
                        let storyHTML = (storyTemplate as String).replacingOccurrences(of: "{story-body}", with: body)
                            .replacingOccurrences(of: "{story-headline}", with: headline)
                            .replacingOccurrences(of: "{story-byline}", with: byline)
                            .replacingOccurrences(of: "{story-time}", with: timeStamp)
                            .replacingOccurrences(of: "{story-lead}", with: lead)
                            .replacingOccurrences(of: "{story-tag}", with: tag)
                            .replacingOccurrences(of: "{story-image}", with: imageHTML)
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



extension ContentItemViewController: UIScrollViewDelegate {
    // MARK: - There's a bug on iOS 9 so that you can't set decelerationRate directly on webView
    // MARK: - http://stackoverflow.com/questions/31369538/cannot-change-wkwebviews-scroll-rate-on-ios-9-beta
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
}


//extension String {
//    func htmlAttributedString() -> NSMutableAttributedString? {
//        print ("use html attributed string extension for: ")
//        print (self)
//        let storyHTML: String?
//        if let adHTMLPath = Bundle.main.path(forResource: "storybody", ofType: "html"){
//            do {
//                let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
//                storyHTML = (storyTemplate as String).replacingOccurrences(of: "{story-body-text}", with: self)
//            } catch {
//                return nil
//            }
//        } else {
//            return nil
//        }
//        guard let text = storyHTML else {
//            return nil
//        }
//        guard let data = text.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
//        guard let html = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) else { return nil }
//        return html
//    }
//}
