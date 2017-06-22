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
    
    func getDetailInfo() {
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
    
    func initStyle() {
        textView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        toolBar.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        toolBar.barTintColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        toolBar.isTranslucent = false
    }
    
    func initText() {
        let finalText = NSMutableAttributedString()
        
        // MARK: headline
        let headlineStyle = NSMutableParagraphStyle()
        headlineStyle.paragraphSpacing = 12.0
        let headlineString = dataObject?.headline ?? ""
        let headline = NSAttributedString(string: "\(headlineString)\n", attributes: [NSParagraphStyleAttributeName: headlineStyle])
        
        // MARK: body
        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.paragraphSpacing = 12.0
        let bodyString = dataObject?.cbody ?? dataObject?.lead ?? "body"
        let body = NSAttributedString(string: bodyString, attributes: [NSParagraphStyleAttributeName: bodyStyle])
        
        // MARK: put all things together
        finalText.append(headline)
        finalText.append(body)
        
        textView?.attributedText = finalText
        textView?.font = UIFont.preferredFont(forTextStyle: .body)
        
        // MARK: - a workaround for the myterious scroll view bug
        textView?.isScrollEnabled = false
        textView?.isScrollEnabled = true
        textView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
}
