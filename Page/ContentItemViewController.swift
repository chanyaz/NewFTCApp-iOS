//
//  ContentItemViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/19.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ContentItemViewController: UIViewController {
    
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
    
    fileprivate let contentAPI = ContentFetch()
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var languageSwitch: UISegmentedControl!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var bookMark: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDetailInfo()
        initStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print ("view did layout subviews")
        initText()
    }
    
    private func getDetailInfo() {
        let urlString = "https://m.ftimg.net/index.php/jsapi/get_story_more_info/\(dataObject?.id ?? "")"
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
        toolBar.backgroundColor = UIColor(hex: Color.Tab.background)
        toolBar.barTintColor = UIColor(hex: Color.Tab.background)
        toolBar.isTranslucent = false
        
        let buttonTint = UIColor(hex: Color.Button.tint)
        
        // MARK: Set style for the language switch
        languageSwitch.backgroundColor = UIColor(hex: Color.Content.background)
        languageSwitch.tintColor = buttonTint
        
        // MARK: Set style for the bottom buttons
        
        actionButton.tintColor = buttonTint
        bookMark.tintColor = buttonTint
    }
    
    private func initText() {
        
        
        // MARK: https://makeapppie.com/2016/07/05/using-attributed-strings-in-swift-3-0/
        // MARK: Convert HTML to NSMutableAttributedString https://stackoverflow.com/questions/36427442/nsfontattributename-not-applied-to-nsattributedstring
        
        
        let text = NSMutableAttributedString()
        
        let headlineStyle = NSMutableParagraphStyle()
        headlineStyle.paragraphSpacing = 12.0
        let headlineString = dataObject?.headline ?? ""
        let headline = NSMutableAttributedString(
            string: "\(headlineString)\n",
            attributes: [
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title1).bold(),
                NSParagraphStyleAttributeName: headlineStyle,
                NSForegroundColorAttributeName: UIColor.blue
            ]
        )
        
        let bodyAttributes:[String:AnyObject] = [
            NSFontAttributeName:UIFont.preferredFont(forTextStyle: .body),
            NSForegroundColorAttributeName:UIColor.blue
        ]
        
        let bodyString = dataObject?.cbody ?? dataObject?.lead ?? "body"
        //let cbody = NSAttributedString(string: cBodyString, attributes: bodyAttributes)
        let body: NSMutableAttributedString
        
        let cbodyTest = bodyString.htmlToAttributedString()
        
        if let htmlBody = bodyString.htmlAttributedString() {
            body = htmlBody
        } else {
            body = NSMutableAttributedString(string: bodyString, attributes: nil)
        }
        body.addAttributes(bodyAttributes, range: NSMakeRange(0, body.length))
        
        
        
        
        text.append(headline)
        text.append(body)
        //Apply to the label
        textView?.attributedText = text
        
        // MARK: - a workaround for the myterious scroll view bug
        textView?.isScrollEnabled = false
        textView?.isScrollEnabled = true
        textView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        
        
        
        
        
        
        /*
         
         let finalText = NSMutableAttributedString()
         
         
         
         
         
         // MARK: headline
         let headlineStyle = NSMutableParagraphStyle()
         headlineStyle.paragraphSpacing = 12.0
         let headlineFont = UIFont.preferredFont(forTextStyle: .title1)
         let headlineString = dataObject?.headline ?? ""
         let headline = NSMutableAttributedString(
         string: "\(headlineString)\n",
         attributes: [
         NSParagraphStyleAttributeName: headlineStyle,
         //NSFontAttributeName: headlineFont,
         NSForegroundColorAttributeName: UIColor.blue
         ]
         )
         headline.addAttributes([NSFontAttributeName : headlineFont], range: NSRange(location: 0, length: headline.length))
         
         
         
         let myMutableString = NSMutableAttributedString(
         string: "a test from oliver",
         attributes: [NSFontAttributeName:UIFont(
         name: "Georgia",
         size: 50.0)!])
         //Add more attributes here
         
         //Apply to the label
         
         
         // MARK: body
         let bodyStyle = NSMutableParagraphStyle()
         bodyStyle.paragraphSpacing = 12.0
         let bodyString = dataObject?.cbody ?? dataObject?.lead ?? "body"
         let body = NSAttributedString(string: bodyString, attributes: [NSParagraphStyleAttributeName: bodyStyle])
         
         // MARK: put all things together
         finalText.append(myMutableString)
         
         finalText.append(headline)
         finalText.append(body)
         
         textView?.attributedText = myMutableString
         
         textView?.attributedText = finalText
         textView?.font = UIFont.preferredFont(forTextStyle: .body)
         
         // MARK: - a workaround for the myterious scroll view bug
         textView?.isScrollEnabled = false
         textView?.isScrollEnabled = true
         textView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
         */
    }
    
    
}

extension String {
    func htmlAttributedString() -> NSMutableAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil) else { return nil }
        return html
    }
    func htmlToAttributedString() -> NSMutableAttributedString? {
        let text = self.replacingOccurrences(of: "<[pP]>", with: "\n", options: .regularExpression)
        print (text)
        return nil
    }
}
