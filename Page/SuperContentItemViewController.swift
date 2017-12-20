//
//  ContentItemViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/19.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
//import UIKit.NSTextAttachment
import WebKit



class SuperContentItemViewController: UIViewController, UINavigationControllerDelegate {
    var dataObject: ContentItem?
    var pageTitle = ""
    var pageId = ""
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
    
//    let adMPU = "<script type=\"text/javascript\">document.write (writeAdNew({devices:['iPhoneWeb','iPhoneApp'],pattern:'MPU',position:'Middle1',container:'mpuInStroy'}));</script>"
//    let adMPU2 = "<script type=\"text/javascript\">document.write (writeAdNew({devices:['iPhoneWeb','iPhoneApp'],pattern:'MPU',position:'Middle2',container:'mpuInStroy'}));</script>"
    
    @IBOutlet weak var containerView: UIView!
    // MARK: - Web View is the best way to render larget amount of content with rich layout. It is much much easier than textview, tableview or any other combination.
    override func loadView() {
        super.loadView()
        if ContentItemRenderContent.addPersonInfo == false{
            if dataObject?.type == "ad" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "LaunchScreen") as? LaunchScreen {
                    // MARK: add as a childviewcontroller
                    controller.showCloseButton = false
                    controller.isBetweenPages = true
                    addChildViewController(controller)
                    // MARK: Add the child's View as a subview
                    self.view.addSubview(controller.view)
                    controller.view.frame = view.bounds
                    //controller.view.frame = UIApplication.shared.keyWindow?.bounds ?? view.bounds
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
                contentController.add(LeakAvoider(delegate:self), name: "clip")
                contentController.add(LeakAvoider(delegate:self), name: "listen")
                contentController.add(LeakAvoider(delegate:self), name: "mySetting")
                
                config.userContentController = contentController
                config.allowsInlineMediaPlayback = true
                if dataObject?.type == "video" {
                    if #available(iOS 10.0, *) {
                        config.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
                    }
                } else if dataObject?.type == "manual" {
                    isFullScreen = true
                } else if dataObject?.isDownloaded == true && dataObject?.type == "story" {
                    // MARK: If you open a story from a downloaded eBook.
                    isFullScreen = true
                }
                
                // MARK: Add the webview as a subview of containerView
                if isFullScreen == false {
                    webView = WKWebView(frame: containerView.bounds, configuration: config)
                    containerView.addSubview(webView!)
                    containerView.clipsToBounds = true
                } else {
                    webView = WKWebView(frame: self.view.bounds, configuration: config)
                    view = webView
                    view.clipsToBounds = false
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

                let typeString = dataObject?.type ?? ""
                // MARK: If the sub type is a user comment, render web view directly
                if subType == .UserComments || ["webpage", "ebook", "htmlbook", "html", "manual", "register", "image"].contains(typeString)  {
                    renderWebView()
                } else {
                    getDetailInfo()
                }
                navigationController?.delegate = self
            }
        }
        
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
        
        // MARK: - Notification For Night Mode Status Change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nightModeChanged),
            name: Notification.Name(rawValue: Event.nightModeChanged),
            object: nil
        )
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
                //print ("View will Appear, about to excute this javascript code: \(jsCode)")
                self.webView?.evaluateJavaScript(jsCode) { (result, error) in
                    if error != nil {
                        print ("something is wrong with js code in content item view controller: \(String(describing: error))")
                    } else {
                        print ("js code is executed successfully! ")
                    }
                }
            }
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.languagePreferenceChanged), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.changeFont), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.nightModeChanged), object: nil)
        
        // MARK: - Stop loading and remove message handlers to avoid leak
        webView?.stopLoading()
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
        webView?.configuration.userContentController.removeAllUserScripts()
        
        // MARK: - Remove delegate to deal with crashes on iOS 9
        webView?.navigationDelegate = nil
        webView?.scrollView.delegate = nil
        
        print ("deinit content item view controller of \(pageTitle) successfully! ")
    }
    
    @objc public func handleLanguagePreferenceChange() {
        let headlineBody = WebviewHelper.getHeadlineBody(dataObject)
        let headline = headlineBody.headline.cleanHTMLTags()
        let finalBody = headlineBody.finalBody
            .replacingOccurrences(of: JSCodes.adMPU, with: "")
            .replacingOccurrences(of: JSCodes.adMPU2, with: "")
            .cleanHTMLTags()
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
    
    @objc public func nightModeChanged() {
        let webViewBG = UIColor(hex: Color.Content.background)
        view.backgroundColor = webViewBG
        let isNightMode = Setting.isSwitchOn("night-reading-mode")
        let jsCode: String
        if isNightMode {
            jsCode = JSCodes.turnOnNightClass
        } else {
            jsCode = JSCodes.turnOffNightClass
        }
        webView?.evaluateJavaScript(jsCode) { (result, error) in
            if result != nil {
                print (result ?? "unprintable JS result")
            }
        }
    }
    
    private func getDetailInfo() {
        if let id = dataObject?.id, let type = dataObject?.type, type == "story" {
            //MARK: if it is a story, get the API
            let urlString = APIs.get(id, type: "story")
            view.addSubview(activityIndicator)
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            
            // MARK: Check the local file
            if let data = Download.readFile(urlString, for: .cachesDirectory, as: "json") {
                //print ("found \(urlString) in caches directory. ")
                if let resultsDictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
                    let contentSections = contentAPI.formatJSON(resultsDictionary)
                    let results = ContentFetchResults(apiUrl: urlString, fetchResults: contentSections)
                    updateUI(of: id, with: results)
                    print ("update content UI from local file with \(urlString), no need to connect to internet again")
                    activityIndicator.removeFromSuperview()
                    return
                } else {
                    // MARK: If the json file is not valid, remove the file and render web page
                    Download.removeFile(urlString, for: .cachesDirectory, as: "json")
                }
            }
            
            contentAPI.fetchContentForUrl(urlString, fetchUpdate: .OnlyOnWifi) {[weak self] results, error in
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
                    if let results = results {
                        self?.updateUI(of: id, with: results)
                    } else {
                        // MARK: If the result is empty, render the page with the base url
                        let publicUrl = APIs.getUrl(id, type: type, isSecure: false, isPartial: false)
                        if let url = URL(string: publicUrl) {
                            let request = URLRequest(url: url)
                            self?.webView?.load(request)
                        }
                        Track.event(category: "CatchError", action: "Content Fetch is Empty", label: urlString)
                    }
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
            dataObject?.keywords = item.keywords
            
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
            case "video", "interactive", "photonews", "photo", "gym", "special", "html":
                renderWebView()
            case "story":
                if (dataObject?.cbody) != nil {
                    renderWebView()
                }
            default:
                return
            }
        }
        if let dataObject = dataObject,
            dataObject.headline != "",
            dataObject.lead != "",
            dataObject.image != "" {
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
        if let type = dataObject?.type,
            ["story", "ebook"].contains(type) || subType == .UserComments {
            // MARK: If it is a story
            WebviewHelper.renderWebviewForStory(type, subType: subType, dataObject: dataObject, webView: webView)
            if subType == .UserComments {
                navigationItem.title = WebviewHelper.getHeadlineBody(dataObject).headline
            } else if type == "ebook" {
                let restoreButton = UIBarButtonItem(title: "恢复购买", style: .plain, target: self, action: #selector(restore))
                navigationItem.rightBarButtonItem = restoreButton
                insertIAPView()
            }
        } else if dataObject?.type == "register"{
            let fileName = GB2Big5.convertHTMLFileName("register")
            if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html"){
                let url = URL(string: APIs.getUrl("register", type: "register", isSecure: false, isPartial: false))
                do {
                    let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                    let storyHTML = (storyTemplate as String)
                    self.webView?.loadHTMLString(storyHTML, baseURL:url)
                } catch {
                    print ("register page is not loaded correctly")
                }
            }
        } else if dataObject?.type == "htmlfile"{
            // MARK: - If there's a need to open just the HTML file
            if let adHTMLPath = dataObject?.id {
                let url = URL(string: APIs.getUrl("htmlfile", type: "htmlfile", isSecure: false, isPartial: false))
                do {
                    let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                    let storyHTML = (storyTemplate as String)
                    self.webView?.loadHTMLString(storyHTML, baseURL:url)
                } catch {
                    print ("html file is not loaded correctly")
                }
            }
        }  else if dataObject?.type == "manual"{
            // MARK: - If it's a url that might be saved
            if let urlString = dataObject?.id,
                let url = URL(string: urlString) {
                if let data = Download.readFile(urlString, for: .cachesDirectory, as: "html"),
                    let htmlString = String(data: data, encoding: .utf8){
                    print ("found file \(htmlString)")
                    webView?.loadHTMLString(htmlString, baseURL:url)
                } else {
                    print ("did not find file")
                    Download.downloadUrl(urlString, to: .cachesDirectory, as: "html")
                    let request = URLRequest(url: url)
                    webView?.load(request)
                }
            }
        } else if dataObject?.type == "html"{
            // MARK: - If there's a need to open just the HTML file
            if let htmlFileName = dataObject?.id {
                let url = URL(string: APIs.getUrl(htmlFileName, type: "html", isSecure: false, isPartial: false))
                let resourceFileName = GB2Big5.convertHTMLFileName(htmlFileName)
                if let templateHTMLPath = Bundle.main.path(forResource: resourceFileName, ofType: "html") {
                    do {
                        let htmlNSString = try NSString(contentsOfFile:templateHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let htmlString = htmlNSString as String
                        self.webView?.loadHTMLString(htmlString, baseURL:url)
                    } catch {
                        print ("html file is not loaded correctly")
                    }
                }
            }
        } else if dataObject?.type == "image"{
            // TODO: - Display the image in the middle of page
            if let imageUrlString = dataObject?.id {
                let url = URL(string: imageUrlString)
                let resourceFileName = "list"
                if let templateHTMLPath = Bundle.main.path(forResource: resourceFileName, ofType: "html") {
                    do {
                        let htmlNSString = try NSString(contentsOfFile:templateHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let htmlString = htmlNSString as String
                        let htmlStringWithImage = htmlString
                            .replacingOccurrences(
                                of: "{list-content}",
                                with: "<img src=\"\(imageUrlString)\">")
                            .replacingOccurrences(
                                of: "{night-class}",
                                with: " night image-view")
                            .replacingOccurrences(
                                of: "{iap-js-code}",
                                with: "")
                        self.webView?.loadHTMLString(htmlStringWithImage, baseURL:url)
                    } catch {
                        print ("html file is not loaded correctly")
                    }
                }
            }
        } else {
            // MARK: - If it is other types of content such video and interactive features
            if let id = dataObject?.id, let type = dataObject?.type {
                let urlStringOriginal: String
                let baseUrlString: String
                if  dataObject?.audioFileUrl != nil && type == "interactive" {
                    // MARK: - Radio should use a different combination or url than other types of interactives
                    urlStringOriginal = APIs.getUrl(id, type: "radio", isSecure: false, isPartial: false)
                    baseUrlString = urlStringOriginal
                } else if let customLink = dataObject?.customLink,
                    customLink != "" {
                    urlStringOriginal = customLink
                    baseUrlString = urlStringOriginal
                } else {
                    urlStringOriginal = APIs.getUrl(id, type: type, isSecure: true, isPartial: false)
                    baseUrlString = APIs.getUrl(id, type: type, isSecure: false, isPartial: false)
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
                    if let url = urlComponents.url,
                        let baseUrl = URL(string: baseUrlString) {
                        // MARK: - If it's a url that might be saved
                        if url.scheme == "https" {
                            if let data = Download.readFile(urlString, for: .cachesDirectory, as: "html"),
                                let htmlString = String(data: data, encoding: .utf8) {
                                webView?.loadHTMLString(htmlString, baseURL:baseUrl)
                                Download.downloadUrl(urlString, to: .cachesDirectory, as: "html")
                            } else {
                                // MARK: If the file has not been downloaded yet
                                Download.getDataFromUrl(url, completion: {[weak self] (data, response, error) in
                                    if let data = data {
                                        if let htmlString = String(data: data, encoding: .utf8) {
                                            DispatchQueue.main.async {
                                                self?.webView?.loadHTMLString(htmlString, baseURL:baseUrl)
                                            }
                                            Download.saveFile(data, filename: urlString, to: .cachesDirectory, as: "html")
                                        }
                                    }
                                })
                            }
                        } else {
                            print ("Not HTTPS, Load Directly in Browser")
                            let request = URLRequest(url: url)
                            webView?.load(request)
                        }

                    }
                }
            }
        }
    }
    
    @objc open func restore() {
        IAPProducts.store.restorePurchases()
        Track.event(category: "IAP", action: "restore", label: "All")
    }
    

    
    
    
    
    
}

// MARK: Handle links here
extension SuperContentItemViewController: WKNavigationDelegate {
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
extension SuperContentItemViewController: WKScriptMessageHandler {
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
            case "listen":
                if let audioUrlString = body["audio"] {
                    print ("should do something to call out the audio view for this url: \(audioUrlString)")
                    PlayerAPI.sharedInstance.getSingletonItem(item: dataObject)
                    PlayerAPI.sharedInstance.openPlay()
                }
            case "clip":
                print ("clip this: \(body)")
            case "mySetting":
                if let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
                    let topController = UIApplication.topViewController() {
                    
                    settingsController.dataObject = [
                        "type": "setting",
                        "id": "setting",
                        "compactLayout": "",
                        "title": "设置"
                    ]
                    settingsController.pageTitle = "设置"
                    topController.navigationController?.pushViewController(settingsController, animated: true)
                }
                print ("mySetting this: \(body)")
            default:
                break
            }
        }
    }
}

extension SuperContentItemViewController: UIScrollViewDelegate {
    // MARK: - There's a bug on iOS 9 so that you can't set decelerationRate directly on webView
    // MARK: - http://stackoverflow.com/questions/31369538/cannot-change-wkwebviews-scroll-rate-on-ios-9-beta
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
}

extension SuperContentItemViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool
    {
        return true
    }
}

// MARK: Buy and Download Buttons
extension SuperContentItemViewController {
    fileprivate func insertIAPView() {
        let verticalPadding: CGFloat = 10
        let buttonHeight: CGFloat = 34
        let iapView = IAPView()
        let containerViewFrame = containerView.frame
        let width: CGFloat = view.frame.width
        let height: CGFloat = buttonHeight + 2 * verticalPadding
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
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width))
        view.addConstraint(NSLayoutConstraint(item: iapView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: height))
    }
}
