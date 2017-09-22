//
//  ContentItemViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/19.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import UIKit.NSTextAttachment
import WebKit

enum ContentSubType {
    case UserComments
    case None
}

class ContentItemViewController: UIViewController, UINavigationControllerDelegate {
    var dataObject: ContentItem?
    var pageTitle: String = ""
    var themeColor: String?
    var currentLanguageIndex: Int?
    var action: String?
    
    // MARK: show in full screen
    var isFullScreen = false
    
    
    
    // MARK: sub type such as user comments
    var subType: ContentSubType = .None
    
    private var detailDisplayed = false
    public lazy var webView: WKWebView? = nil
    fileprivate let contentAPI = ContentFetch()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var containerView: UIView!
    // MARK: - Web View is the best way to render larget amount of content with rich layout. It is much much easier than textview, tableview or any other combination.
    override func loadView() {
        super.loadView()
        
        if dataObject?.type == "ad" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "LaunchScreen") as? LaunchScreen {
                //additionalSafeAreaInsets = UIEdgeInsetsMake(44, 0, 44, 0)
                //                edgesForExtendedLayout = UIRectEdge.all
                //                extendedLayoutIncludesOpaqueBars = true
                // MARK: add as a childviewcontroller
                controller.showCloseButton = false
                controller.isBetweenPages = true
                addChildViewController(controller)
                // MARK: Add the child's View as a subview
                self.view.addSubview(controller.view)
                controller.view.frame = view.bounds
                controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                // MARK: tell the childviewcontroller it's contained in it's parent
                controller.didMove(toParentViewController: self)
            }
        } else {
            //            self.navigationController?.isNavigationBarHidden = false
            //            self.tabBarController?.tabBar.isHidden = false
            let webViewBG = UIColor(hex: Color.Content.background)
            view.backgroundColor = webViewBG
            //            self.edgesForExtendedLayout = []
            //            self.extendedLayoutIncludesOpaqueBars = false
            
            
            let config = WKWebViewConfiguration()
            
            // MARK: Tell the web view what kind of connection the user is currently on
            let contentController = WKUserContentController();
            if let type = dataObject?.type {
                let jsCode: String
                if type == "video" && dataObject?.isLandingPage == true {
                    jsCode = JSCodes.get(JSCodes.autoPlayVideoType)
                } else {
                    jsCode = JSCodes.get(type)
                }
                let userScript = WKUserScript(
                    source: jsCode,
                    injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                    forMainFrameOnly: true
                )
                contentController.addUserScript(userScript)
            }
            
            // MARK: This is Very Important! Use LeadAvoider so that ARC kicks in correctly.
            contentController.add(LeakAvoider(delegate:self), name: "alert")
            contentController.add(LeakAvoider(delegate:self), name: "follow")
            
            config.userContentController = contentController
            config.allowsInlineMediaPlayback = true
            if dataObject?.type == "video" {
                if #available(iOS 10.0, *) {
                    config.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
                } else {
                    // Fallback on earlier versions
                }
            }
            
            // MARK: Add the webview as a subview of containerView
            if isFullScreen == false {
                webView = WKWebView(frame: containerView.bounds, configuration: config)
                containerView.addSubview(webView!)
                containerView.clipsToBounds = true
            } else {
                webView = WKWebView(frame: self.view.bounds, configuration: config)
                view = webView
                view.clipsToBounds = true
            }
            
            webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            
            // MARK: Use this so that I don't have to calculate the frame of the webView, which can be tricky.
            //            webView = WKWebView(frame: self.view.bounds, configuration: config)
            //            self.view = self.webView
            
            // MARK: set the web view opaque to avoid white screen during loading
            webView?.isOpaque = false
            webView?.backgroundColor = webViewBG
            webView?.scrollView.backgroundColor = webViewBG
            
            // MARK: This makes the web view scroll like native
            webView?.scrollView.delegate = self
            webView?.navigationDelegate = self
            webView?.clipsToBounds = true
            webView?.scrollView.bounces = false
            
            // MARK: - Notification For User Tapping Navigation Title View to Change Language Preference
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleLanguagePreferenceChange),
                name: Notification.Name(rawValue: Event.languagePreferenceChanged),
                object: nil
            )
            
            // MARK: - Notification For User Tapping Navigation Title View to Change Language Preference
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(changeFont(_:)),
                name: Notification.Name(rawValue: Event.changeFont),
                object: nil
            )
            
            
            
            // MARK: If the sub type is a user comment, render web view directly
            if subType == .UserComments || dataObject?.type == "webpage" || dataObject?.type == "ebook" {
                renderWebView()
            } else {
                getDetailInfo()
            }
            navigationController?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let id = dataObject?.id, let type = dataObject?.type, let headline = dataObject?.headline {
            let screenName = "/\(DeviceInfo.checkDeviceType())/\(type)/\(id)/\(headline)"
            Track.screenView(screenName)
            
            if type != "video" {
                let jsCode = JSCodes.get(type)
                print ("View will Appear, about to excute this javascript code: \(jsCode)")
                self.webView?.evaluateJavaScript(jsCode) { (result, error) in
                    if error != nil {
                        print ("something is wrong with js code: \(String(describing: error))")
                    } else {
                        print ("js code is executed successfully! ")
                    }
                }
            }

        }
        
    }
    
    deinit {
        //MARK: Some of the deinit might be useful in the future
        //        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        //        self.webView?.removeObserver(self, forKeyPath: "canGoBack")
        //        self.webView?.removeObserver(self, forKeyPath: "canGoForward")
        
        // MARK: - Stop loading and remove message handlers to avoid leak
        self.webView?.stopLoading()
        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
        self.webView?.configuration.userContentController.removeAllUserScripts()
        
        // MARK: - Remove delegate to deal with crashes on iOS 8
        self.webView?.navigationDelegate = nil
        self.webView?.scrollView.delegate = nil
        print ("deinit content item view controller of \(pageTitle) successfully! ")
    }
    
    @objc public func handleLanguagePreferenceChange() {
        let headlineBody = getHeadlineBody(dataObject)
        let headline = headlineBody.headline.cleanHTMLTags()
        let finalBody = headlineBody.finalBody.cleanHTMLTags()
        let jsCodeHeadline = "updateHeadline('\(headline)');"
        let jsCodeBody = "updateBody('\(finalBody)');"
        let jsCode = jsCodeHeadline + jsCodeBody
        //print (jsCode)
        self.webView?.evaluateJavaScript(jsCode) { (result, error) in
            if error != nil {
                print ("some thing wrong with javascript: \(String(describing: error))")
            } else {
                print ("javascript result is \(String(describing: result))")
            }
        }
    }
    
    @objc public func changeFont(_ notification: Notification) {
        if let currentItem = notification.object as? ContentItem,
            currentItem.id == dataObject?.id {
            let jsCode = "showOverlay('font-setting');"
            webView?.evaluateJavaScript(jsCode) { (result, error) in
                if error != nil {
                    print ("some thing wrong with javascript: \(String(describing: error))")
                } else {
                    print ("javascript result is \(String(describing: result))")
                }
            }
        }
    }
    
    //    func paidPostUpdate(_ notification: Notification) {
    //        if let itemCell = notification.object as? ContentItem {
    //            let section = itemCell.section
    //            let row = itemCell.row
    //            if fetches.fetchResults.count > section {
    //                if fetches.fetchResults[section].items.count > row {
    //                    if itemCell.adModel?.headline != nil{
    //                        print ("Paid Post: The adModel has headline. Update data source and reload. ")
    //                        fetches.fetchResults[section].items[row].adModel = itemCell.adModel
    //                        collectionView?.reloadData()
    //                    } else {
    //                        print ("Paid Post: The adModel has no headline")
    //                    }
    //                }
    //            }
    //        }
    //    }
    //
    
    private func getDetailInfo() {
        if let id = dataObject?.id, dataObject?.type == "story" {
            //MARK: if it is a story, get the API
            let urlString = APIs.get(id, type: "story")
            view.addSubview(activityIndicator)
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            
            // MARK: Check the local file
            if let data = Download.readFile(urlString, for: .cachesDirectory, as: "json") {
                //print ("found \(urlString) in caches directory. ")
                if let resultsDictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                {
                    let contentSections = contentAPI.formatJSON(resultsDictionary)
                    let results = ContentFetchResults(apiUrl: urlString, fetchResults: contentSections)
                    updateUI(of: id, with: results)
                    print ("update content UI from local file with \(urlString), no need to connect to internet again")
                    activityIndicator.removeFromSuperview()
                    return
                }
            }
            
            contentAPI.fetchContentForUrl(urlString, fetchUpdate: .OnlyOnWifi) {
                [weak self] results, error in
                DispatchQueue.main.async {
                    self?.activityIndicator.removeFromSuperview()
                    if let error = error {
                        print("Error searching : \(error)")
                        //MARK: When something is wrong, check the user's internet connection and display a friendly message
                        let statusType = IJReachability().connectedToNetworkOfType()
                        let errorMessageString: String
                        if statusType == .notConnected {
                            errorMessageString = ErrorMessages.NoInternet.gb
                        } else {
                            errorMessageString = ErrorMessages.Unknown.gb
                        }
                        self?.dataObject?.cbody = errorMessageString
                        self?.updatePageContent()
                        return
                    }
                    self?.updateUI(of: id, with: results)
                    print ("update content UI from internet with \(urlString)")
                }
            }
        } else {
            // MARK: If it's not a story, no need to get the API
            updatePageContent()
        }
    }
    
    private func updateUI(of id: String, with results: ContentFetchResults?) {
        if let results = results {
            let item = results.fetchResults[0].items[0]
            let eBody = item.ebody
            // MARK: Whether eBody is empty string
            let type = item.type
            if type == "story" {
                if let eBody = eBody, eBody != "" {
                    English.sharedInstance.has[id] = true
                } else {
                    English.sharedInstance.has[id] = false
                }
                // MARK: Post a notification about English status change
                postEnglishStatusChange()
                //print ("post english status change of \(String(describing: English.sharedInstance.has[id]))")
            }
            dataObject?.ebody = eBody
            dataObject?.cbody = item.cbody
            dataObject?.eheadline = item.eheadline
            dataObject?.publishTime = item.publishTime
            dataObject?.chineseByline = item.chineseByline
            dataObject?.englishByline = item.englishByline
            dataObject?.relatedStories = item.relatedStories
            dataObject?.relatedVideos = item.relatedVideos
            dataObject?.headline = item.headline
            dataObject?.lead = item.lead
            dataObject?.tag = item.tag
            dataObject?.image = item.image
            
            if let caudio = item.caudio, caudio != "" {
                dataObject?.caudio = caudio
            }
            
            if let eaudio = item.eaudio, eaudio != "" {
                dataObject?.eaudio = eaudio
            }
            
            updatePageContent()
        }
    }
    
    private func postEnglishStatusChange() {
        let object = ""
        let name = Notification.Name(rawValue: Event.englishStatusChange)
        NotificationCenter.default.post(name: name, object: object)
        print ("Language: Post English Status Change")
    }
    
    public func updatePageContent() {
        // MARK: https://makeapppie.com/2016/07/05/using-attributed-strings-in-swift-3-0/
        // MARK: Convert HTML to NSMutableAttributedString https://stackoverflow.com/questions/36427442/nsfontattributename-not-applied-to-nsattributedstring
        if let type = dataObject?.type {
            switch type {
            case "video", "interactive", "photonews", "photo", "gym", "special":
                renderWebView()
            case "story":
                if (dataObject?.cbody) != nil {
                    renderWebView()
                }
            default:
                return
            }
        }
        if let dataObject = dataObject {
            Download.save(dataObject, to: "read", uplimit: 30, action: "save")
        }
    }
    
    // create our NSTextAttachment
    let coverImageAttachment = NSTextAttachment()
    
    // wrap the attachment in its own attributed string so we can append it
    var coverImageString: NSAttributedString = NSAttributedString(string: "")
    
    //    private func renderTextview(_ body: NSMutableAttributedString) {
    //        print ("render the text view with native code")
    //        // MARK: Ad View
    //
    //
    //
    //
    //        // MARK: Image View
    //
    //        // = NSAttributedString(attachment: coverImageAttachment)
    //        if let loadedImage = dataObject?.detailImage {
    //            //coverImage.image = loadedImage
    //            coverImageAttachment.image = loadedImage
    //            coverImageString = NSAttributedString(attachment: coverImageAttachment)
    //        } else {
    //            let imageWidth = Int(bodyTextView.frame.width - bodyTextView.textContainer.lineFragmentPadding * 2)
    //            let imageHeight = imageWidth * 9 / 16
    //            if let imageString = dataObject?.image {
    //                let imageURL = dataObject?.getImageURL(imageString, width: imageWidth, height: imageHeight)
    //                let attachment = AsyncTextAttachment(imageURL: imageURL)
    //                let imageSize = CGSize(width: imageWidth, height: imageHeight)
    //                attachment.displaySize = imageSize
    //                //attachment.image = UIImage.placeholder(UIColor.gray, size: imageSize)
    //                coverImageString = NSAttributedString(attachment: attachment)
    //            }
    //
    //        }
    //
    //        // MARK: paragraph styles
    //        let paragraphStyle = NSMutableParagraphStyle()
    //        //paragraphStyle.paragraphSpacing = 12.0
    //        paragraphStyle.lineHeightMultiple = 1.0
    //        paragraphStyle.lineSpacing = 8.0
    //        //paragraphStyle.paragraphSpacing = 100.0
    //
    //        // MARK: Get the first tag using regular expression
    //        let tagParagraphStyle = NSMutableParagraphStyle()
    //        tagParagraphStyle.lineHeightMultiple = 1.4
    //        tagParagraphStyle.lineSpacing = 5.0
    //        let tagColor = UIColor(hex: Color.Content.tag)
    //        let tagAttributes:[String:AnyObject] = [
    //            NSForegroundColorAttributeName: tagColor,
    //            NSParagraphStyleAttributeName: tagParagraphStyle,
    //            NSFontAttributeName:UIFont.preferredFont(forTextStyle: .title3)
    //        ]
    //        let tagString = dataObject?.tag ?? ""
    //        let firstTag = tagString.replacingOccurrences(of: "[,，].*$", with: "", options: .regularExpression)
    //        let tagAttrString = NSMutableAttributedString(
    //            string: "\(firstTag)\r\n",
    //            attributes:tagAttributes
    //        )
    //        //tag?.text = firstTag
    //
    //        // MARK: Handle Headline
    //        let headlineColor = UIColor(hex: Color.Content.headline)
    //        let headlineAttributes:[String:AnyObject] = [
    //            NSForegroundColorAttributeName: headlineColor,
    //            NSParagraphStyleAttributeName: paragraphStyle,
    //            NSFontAttributeName:UIFont.preferredFont(forTextStyle: .title2)
    //        ]
    //        let headlineString = dataObject?.headline ?? ""
    //        let headlineAttrString = NSMutableAttributedString(
    //            string: "\(headlineString)\r\n",
    //            attributes:headlineAttributes
    //        )
    //
    //        // MARK: Lead
    //        let leadColor = UIColor(hex: Color.Content.lead)
    //        let leadAttributes:[String:AnyObject] = [
    //            NSForegroundColorAttributeName: leadColor,
    //            NSParagraphStyleAttributeName: paragraphStyle,
    //            NSFontAttributeName:UIFont.preferredFont(forTextStyle: .title3)
    //        ]
    //        let leadString = dataObject?.lead ?? ""
    //        let leadAttrString = NSMutableAttributedString(
    //            string: "\(leadString)\r\n",
    //            attributes:leadAttributes
    //        )
    //
    //        // MARK: Publishing Time
    //        let bylineParagraphStyle = NSMutableParagraphStyle()
    //        bylineParagraphStyle.lineHeightMultiple = 1.4
    //        bylineParagraphStyle.lineSpacing = 5.0
    //        let timeColor = UIColor(hex: Color.Content.time)
    //        let timeAttributes:[String:AnyObject] = [
    //            NSForegroundColorAttributeName: timeColor,
    //            NSParagraphStyleAttributeName: bylineParagraphStyle,
    //            NSFontAttributeName:UIFont.preferredFont(forTextStyle: .footnote)
    //        ]
    //        let publishingTime = dataObject?.publishTime ?? ""
    //        let publishingTimeAttributedString = NSMutableAttributedString(
    //            string: "\r\n\(publishingTime) ",
    //            attributes:timeAttributes
    //        )
    //
    //
    //        // MARK: Set the byline/author text style
    //        let authorColor = UIColor(hex: Color.Content.body)
    //        let authorAttributes:[String:AnyObject] = [
    //            NSForegroundColorAttributeName: authorColor,
    //            NSParagraphStyleAttributeName: bylineParagraphStyle,
    //            NSFontAttributeName:UIFont.preferredFont(forTextStyle: .footnote)
    //        ]
    //        let bylineString = dataObject?.chineseByline ?? ""
    //        let bylineAttrString = NSMutableAttributedString(
    //            string: "\(bylineString)\r\n",
    //            attributes:authorAttributes
    //        )
    //        let bylineAttributedString = NSMutableAttributedString()
    //        bylineAttributedString.append(publishingTimeAttributedString)
    //        bylineAttributedString.append(bylineAttrString)
    //        //byline?.attributedText = bylineAttributedString
    //
    //
    //        let text = NSMutableAttributedString()
    //        text.append(tagAttrString)
    //        text.append(headlineAttrString)
    //        text.append(leadAttrString)
    //        text.append(coverImageString)
    //        text.append(publishingTimeAttributedString)
    //        text.append(bylineAttrString)
    //        text.append(body)
    //        bodyTextView?.attributedText = text
    //
    //    }
    
    private func renderWebView() {
        if let type = dataObject?.type, ["story", "ebook"].contains(type) {
            // MARK: If it is a story
            if let id = dataObject?.id {
                let urlString = APIs.getUrl(id, type: type)
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    let lead: String
                    let tags = dataObject?.tag ?? ""
                    let tag: String
                    var imageHTML:String
                    
                    
                    // MARK: story byline
                    let byline: String
                    var relatedStories = ""
                    if let relatedStoriesData = dataObject?.relatedStories {
                        for (index, story) in relatedStoriesData.enumerated() {
                            if let id = story["id"] as? String,
                                let headline = story["cheadline"] as? String {
                                relatedStories += "<li class=\"mp\(index+1)\"><a target=\"_blank\" href=\"/story/\(id)\">\(headline)</a></li>"
                            }
                        }
                    }
                    
                    if relatedStories != "" {
                        relatedStories = "<div class=\"story-box\"><h2 class=\"box-title\"><a>相关文章</a></h2><ul class=\"top10\">\(relatedStories)</ul></div>"
                    }
                    
                    let tagsArray = tags.components(separatedBy: ",")
                    var relatedTopics = ""
                    for (index, tag) in tagsArray.enumerated() {
                        relatedTopics += "<li class=\"story-theme mp\(index+1)\"><a target=\"_blank\" href=\"/tag/\(tag)\">\(tag)</a><div class=\"icon-right\"><button class=\"myft-follow plus\" data-tag=\"\(tag)\" data-type=\"tag\">关注</button></div></li>"
                    }
                    
                    let headlineBody = getHeadlineBody(dataObject)
                    let headline = headlineBody.headline
                    
                    let finalBody: String
                    // MARK: Story Time
                    let timeStamp: String
                    let userCommentsOrder: String
                    let styleContainerStyle: String
                    var adBanner = ""
                    var adMPU = ""
                    var storyTheme = ""
                    let fontClass = Setting.getFontClass()
                    
                    if subType == .UserComments {
                        finalBody = ""
                        byline = ""
                        relatedStories = ""
                        relatedTopics = ""
                        tag = ""
                        imageHTML = ""
                        timeStamp = ""
                        lead = ""
                        navigationItem.title = headline
                        userCommentsOrder = "storyall1"
                        styleContainerStyle = " style=\"display:none;\""
                    } else if type == "ebook" {
                        finalBody = "<p>\(headlineBody.finalBody.replacingOccurrences(of: "\n", with: "</p><p>", options: .regularExpression))</p>"
                        byline = ""
                        relatedStories = ""
                        relatedTopics = ""
                        tag = ""
                        imageHTML = ""
                        timeStamp = ""
                        lead = ""
                        userCommentsOrder = "story"
                        styleContainerStyle = ""
                        storyTheme = "电子书"
                        if let image = dataObject?.image {
                            imageHTML = "<div class=\"leftPic image portrait-img ebook-image-container\" style=\"margin-bottom:0;\"><div class=\"ebook-image-inner\"><figure data-url=\"\(image)\" class=\"loading\"></figure></div></div>"
                        } else {
                            imageHTML = ""
                        }
                    } else {
                        finalBody = headlineBody.finalBody
                        byline = dataObject?.chineseByline ?? ""
                        tag = tags.replacingOccurrences(of: "[,，].*$", with: "", options: .regularExpression)
                        storyTheme = "<div class=\"story-theme\"><a target=\"_blank\" href=\"/tag/\(tag)\">\(tag)</a><button class=\"myft-follow plus\" data-tag=\"\(tag)\" data-type=\"tag\">关注</button></div>"
                        if let image = dataObject?.image {
                            imageHTML = "<div class=\"story-image image\" style=\"margin-bottom:0;\"><figure data-url=\"\(image)\" class=\"loading\"></figure></div>"
                        } else {
                            imageHTML = ""
                        }
                        timeStamp = dataObject?.publishTime ?? ""
                        lead = dataObject?.lead ?? ""
                        userCommentsOrder = "story"
                        styleContainerStyle = ""
                        adBanner = "<div class=\"bn-ph\"><div class=\"banner-container\"><div class=\"banner-inner\"><div class=\"banner-content\"><script type=\"text/javascript\">document.write (writeAd('banner'));</script></div></div></div></div>"
                        adMPU = "<div class=\"mpu-container\"><script type=\"text/javascript\">document.write (writeAd('storympu'));</script></div>"
                    }
                    
                    let followTags = getFollow("tag")
                    let followTopics = getFollow("topic")
                    let followAreas = getFollow("area")
                    let followIndustries = getFollow("industry")
                    let followAuthors = getFollow("author")
                    let followColumns = getFollow("column")
                    
                    let resourceFileName: String
                    switch type {
                    case "ebook":
                        resourceFileName = "ebook"
                        insertIAPView()
                    default:
                        resourceFileName = "story"
                    }
                    if let adHTMLPath = Bundle.main.path(forResource: resourceFileName, ofType: "html"){
                        do {
                            let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                            let storyHTML = (storyTemplate as String).replacingOccurrences(of: "{story-body}", with: finalBody)
                                .replacingOccurrences(of: "{story-headline}", with: headline)
                                .replacingOccurrences(of: "{story-byline}", with: byline)
                                .replacingOccurrences(of: "{story-time}", with: timeStamp)
                                .replacingOccurrences(of: "{story-lead}", with: lead)
                                .replacingOccurrences(of: "{story-theme}", with: storyTheme)
                                .replacingOccurrences(of: "{story-tag}", with: tag)
                                .replacingOccurrences(of: "{story-id}", with: id)
                                .replacingOccurrences(of: "{story-image}", with: imageHTML)
                                .replacingOccurrences(of: "{related-stories}", with: relatedStories)
                                .replacingOccurrences(of: "{related-topics}", with: relatedTopics)
                                .replacingOccurrences(of: "{comments-order}", with: userCommentsOrder)
                                .replacingOccurrences(of: "{story-container-style}", with: styleContainerStyle)
                                .replacingOccurrences(of: "['{follow-tags}']", with: followTags)
                                .replacingOccurrences(of: "['{follow-topics}']", with: followTopics)
                                .replacingOccurrences(of: "['{follow-industries}']", with: followIndustries)
                                .replacingOccurrences(of: "['{follow-areas}']", with: followAreas)
                                .replacingOccurrences(of: "['{follow-authors}']", with: followAuthors)
                                .replacingOccurrences(of: "['{follow-columns}']", with: followColumns)
                                .replacingOccurrences(of: "{ad-banner}", with: adBanner)
                                .replacingOccurrences(of: "{ad-mpu}", with: adMPU)
                                .replacingOccurrences(of: "{font-class}", with: fontClass)
                            self.webView?.loadHTMLString(storyHTML, baseURL:url)
                        } catch {
                            self.webView?.load(request)
                        }
                    } else {
                        self.webView?.load(request)
                    }
                }
            }
        } else if dataObject?.type == "register"{
            if let adHTMLPath = Bundle.main.path(forResource: "register", ofType: "html"){
                let url = URL(string: APIs.getUrl("register", type: "register"))
                do {
                    let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                    let storyHTML = (storyTemplate as String)
                    self.webView?.loadHTMLString(storyHTML, baseURL:url)
                } catch {
                    print ("register page is not loaded correctly")
                }
            }
        } else {
            // MARK: - If it is other types of content such video and interacrtive features
            if let id = dataObject?.id, let type = dataObject?.type {
                let urlStringOriginal: String
                if let customLink = dataObject?.customLink, customLink != "" {
                    urlStringOriginal = customLink
                } else {
                    urlStringOriginal = APIs.getUrl(id, type: type)
                }
                let urlString = APIs.convert(urlStringOriginal)
                print ("loading \(urlString)")
                if var urlComponents = URLComponents(string: urlString) {
                    let newQuery = APIs.newQueryForWebPage()
                    if urlComponents.queryItems != nil {
                        urlComponents.queryItems?.append(newQuery)
                    } else {
                        urlComponents.queryItems = [newQuery]
                    }
                    if let url = urlComponents.url {
                        print ("url is now \(url)")
                        let request = URLRequest(url: url)
                        webView?.load(request)
                    }
                }
            }
        }
    }
    
    private func getFollow(_ type: String) -> String {
        let follows = UserDefaults.standard.array(forKey: "follow \(type)") as? [String] ?? [String]()
        var followString = ""
        for (index, value) in follows.enumerated() {
            if index == 0 {
                followString += "'\(value)'"
            } else {
                followString += ",'\(value)'"
            }
        }
        return "[\(followString)]"
    }
    
    private func getHeadlineBody(_ dataObject: ContentItem?) -> (headline: String, finalBody: String) {
        // MARK: Get values for the story content
        let headline: String
        let body: String
        let languagePreference = UserDefaults.standard.integer(forKey: Key.languagePreference)
        let eHeadline = dataObject?.eheadline ?? ""
        let eBody = dataObject?.ebody ?? ""
        let cBody = dataObject?.cbody ?? ""
        //let languageChoice: Int
        let cHeadline = dataObject?.headline ?? ""
        if eBody != "" && languagePreference == 1 {
            headline = eHeadline
            body = eBody
            //languageChoice = 1
        } else if eBody != "" && languagePreference == 2 {
            headline = "<div>\(eHeadline)</div><div>\(cHeadline)</div>"
            body = getCEbodyHTML(eBody: eBody, cBody: cBody)
            //languageChoice = 2
        } else {
            headline = cHeadline
            body = cBody
            //languageChoice = 0
        }
        // postLanguageChoice(languageChoice)
        //print ("language choice posted as \(languageChoice)")
        let bodyWithMPU = body.replacingOccurrences(
            of: "[\r\t\n]",
            with: "",
            options: .regularExpression
            ).replacingOccurrences(
                of: "^(<p>.*?<p>.*?<p>.*?<p>.*?)<p>",
                with: "$1<div id=story_main_mpu><script type=\"text/javascript\">document.write (writeAd('storympu'));</script></div><p>",
                options: .regularExpression
        )
        
        // TODO: Premium user will not need to see the MPU ads
        let finalBody: String
        finalBody = bodyWithMPU.replacingOccurrences(
            of: "^(<p>.*?<p>.*?<p>.*?<p>.*?<p>.*?<p>.*?<p>.*?<p>.*?<p>.*?)<p>",
            with: "$1<div class=story_main_mpu_vw><script type=\"text/javascript\">document.write (writeAd('storympuVW'));</script></div><p>",
            options: .regularExpression
        )
        return (headline, finalBody)
        
    }
    
    private func getCEbodyHTML(eBody ebody: String, cBody cbody: String) -> String {
        func getHTML(_ htmls:[String], for index: Int, in className: String) -> String {
            let text: String
            if index < htmls.count {
                text = htmls[index]
            } else {
                text = ""
            }
            let html = "<div class=\(className)><p>\(text)</p></div>"
            return html
        }
        let paragraphPattern = "<p>(.*)</p>"
        let ebodyParapraphs = ebody.matchingArrays(regex: paragraphPattern)
        let cbodyParapraphs = cbody.matchingArrays(regex: paragraphPattern)
        let ebodyLength = ebodyParapraphs?.count ?? 0
        let cbodyLength = cbodyParapraphs?.count ?? 0
        let contentLength = max(ebodyLength, cbodyLength)
        var combinedText = ""
        
        // MARK: Use the pure text in the matching array. Filter out paragraphs that has html tags like img and div
        let ebodysHTML = ebodyParapraphs?.map { (value) -> String in
            let text = value[1]
            return text
            }.filter{
                !$0.contains("<img") && !$0.contains("<div")
        }
        
        let cbodysHTML = cbodyParapraphs?.map { (value) -> String in
            let text = value[1]
            return text
            }.filter{
                !$0.contains("<img") && !$0.contains("<div")
        }
        
        if let ebodysHTML = ebodysHTML, let cbodysHTML = cbodysHTML {
            for i in 0..<contentLength {
                let ebodyHTML = getHTML(ebodysHTML, for: i, in: "leftp")
                let cbodyHTML = getHTML(cbodysHTML, for: i, in: "rightp")
                combinedText += "\(ebodyHTML)\(cbodyHTML)<div class=clearfloat></div>"
            }
        }
        return combinedText
    }
    
    
    /*
    
    fileprivate func htmlToAttributedString(_ htmltext: String) -> NSMutableAttributedString? {
        // MARK: remove p tags in text
        let text = htmltext.replacingOccurrences(of: "(</[pP]>[\n\r]*<[pP]>)+", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "(^<[pP]>)+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "(</[pP]>)+$", with: "", options: .regularExpression)
        // text = "some text"
        // MARK: Set the overall text style
        let bodyColor = UIColor(hex: Color.Content.body)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12.0
        paragraphStyle.lineHeightMultiple = 1.2
        
        let defaultBodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let bodySize = defaultBodyDescriptor.pointSize + FontSize.bodyExtraSize
        let bodyFont = UIFont(descriptor: defaultBodyDescriptor, size: bodySize)
        
        let bodyAttributes:[String:AnyObject] = [
            NSAttributedStringKey.font.rawValue: bodyFont,
            //NSFontAttributeName:UIFont.preferredFont(forTextStyle: .body),
            NSAttributedStringKey.foregroundColor.rawValue: bodyColor,
            NSAttributedStringKey.paragraphStyle.rawValue: paragraphStyle
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
            //NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body).bold(),
            NSAttributedStringKey.font.rawValue: bodyFont.bold(),
            NSAttributedStringKey.paragraphStyle.rawValue: boldParagraphStyle
        ]
        
        if let matches = regex?.matches(in: text, options: [], range: range) {
            print(matches.count)
            //Iterate over regex matches
            for match in matches.reversed() {
                //Properly print match range
                print(match.range)
                let value = attrString.attributedSubstring(from: match.range(at: 1)).string
                print (value)
                //attrString.addAttribute(NSLinkAttributeName, value: "http://www.ft.com/", range: match.rangeAt(0))
                attrString.addAttributes(boldAttributes, range: match.range(at: 0))
                attrString.replaceCharacters(in: match.range(at: 0), with: "\(value)")
            }
        }
        
        // MARK: if there are unhandled tags, use WebView to open the content
        if attrString.string.contains("<") && attrString.string.contains(">") {
            return nil
        }
        return attrString
    }
    */
    
}

// MARK: Handle links here
extension ContentItemViewController: WKNavigationDelegate {
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

// MARK: Handle Message from Web View
extension ContentItemViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let body = message.body as? [String: String] {
            switch message.name {
            case "alert":
                if let title = body["title"], let lead = body["message"] {
                    Alert.present(title, message: lead)
                }
            case "follow":
                if let type = body["type"], let keyword = body["tag"], let action = body["action"] {
                    var follows = UserDefaults.standard.array(forKey: "follow \(type)") as? [String] ?? [String]()
                    follows = follows.filter{
                        $0 != keyword
                    }
                    if action == "follow" {
                        follows.insert(keyword, at: 0)
                    }
                    UserDefaults.standard.set(follows, forKey: "follow \(type)")
                }
            default:
                break
            }
        }
    }
}

extension ContentItemViewController: UIScrollViewDelegate {
    // MARK: - There's a bug on iOS 9 so that you can't set decelerationRate directly on webView
    // MARK: - http://stackoverflow.com/questions/31369538/cannot-change-wkwebviews-scroll-rate-on-ios-9-beta
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
}

extension ContentItemViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool
    {
        return true
    }
}

// MARK: Buy and Download Buttons
extension ContentItemViewController {
    fileprivate func insertIAPView() {
        let verticalPadding: CGFloat = 10
        let iapView = IAPView()
        let containerViewFrame = containerView.frame
        let width: CGFloat = view.frame.width
        let height: CGFloat = 44
        iapView.frame = CGRect(x: 0, y: containerViewFrame.height - height, width: width, height: height)
        iapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // MARK: This is important for autolayout constraints to kick in properly
        iapView.translatesAutoresizingMaskIntoConstraints = false
        iapView.themeColor = themeColor
        iapView.dataObject = dataObject
        iapView.verticalPadding = verticalPadding
        iapView.action = self.action
        iapView.initUI()
        
        view.addSubview(iapView)
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -verticalPadding))
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width))
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: height))
        
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

// Done: 1. MPU ads in story page;
// TODO: 2. Sponsorship Ads in story page;

