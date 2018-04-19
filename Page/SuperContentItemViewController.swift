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
    var sourceDataObject = [String: String]()
    var pageTitle = ""
    var pageId = ""
    var themeColor: String?
    var currentLanguageIndex: Int?
    var action: String?
    var isLoadingForTheFirstTime = true
    var isPrivilegeViewForAllLanguages = false
    var isPrivilegeViewForAllLanguagesChecked = false
    // MARK: show in full screen
    var isFullScreen = false
    
    // MARK: sub type such as user comments
    var subType: ContentSubType = .None
    
    private var detailDisplayed = false
    public lazy var webView: WKWebView? = nil
    fileprivate let contentAPI = ContentFetch()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private var currentActualLanguage: (index: Int, suffix: String)?

    @IBOutlet weak var containerView: UIView!
    // MARK: - Web View is the best way to render larget amount of content with rich layout. It is much much easier than textview, tableview or any other combination.
    override func loadView() {
        super.loadView()
        // MARK: - Update membership status
        PrivilegeHelper.updateFromDevice()
        if ContentItemRenderContent.addPersonInfo == false {
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
                let webViewBG = UIColor(hex: Color.Content.background)
                view.backgroundColor = webViewBG
                let config = WKWebViewConfiguration()
                // MARK: Tell the web view what kind of connection the user is currently on
                let contentController = WKUserContentController();
                if let type = dataObject?.type {
                    let jsCode: String
                    if type == "video" && dataObject?.isLandingPage == true {
                        jsCode = JSCodes.get(JSCodes.autoPlayVideoType)
                    } else if type == "interactive" && dataObject?.eaudio != nil {
                        jsCode = JSCodes.get(JSCodes.englishAudioType)
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
                contentController.add(LeakAvoider(delegate:self), name: "user")
                contentController.add(LeakAvoider(delegate:self), name: "mySetting")
                contentController.add(LeakAvoider(delegate:self), name: "ebody")
                config.userContentController = contentController
                config.allowsInlineMediaPlayback = true
                if let dataObjectType = dataObject?.type {
                    if dataObjectType == "video" {
                        if #available(iOS 10.0, *) {
                            config.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
                        }
                    } else if dataObjectType == "manual" {
                        isFullScreen = true
                    } else if dataObject?.isDownloaded == true && ["story","premium"].contains(dataObjectType) {
                        // MARK: If you open a story from a downloaded eBook.
                        isFullScreen = true
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
                    view.clipsToBounds = false
                }
                webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        
        
        // MARK: listen to in-app purchase transaction notification. There's no need to remove it in code after iOS 9 as the system will do that for you. https://useyourloaf.com/blog/unregistering-nsnotificationcenter-observers-in-ios-9/
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseNotification(_:)),
            name: Notification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
            object: nil
        )
        
        
        // MARK: Check if the user have the required privilege to view this content
        //print (dataObject?.privilegeRequirement as Any)
        checkPrivileForContent()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: - Update membership status
        PrivilegeHelper.updateFromDevice()
        
        if let type = dataObject?.type,
            let id = dataObject?.id {
            trackScreenView(type: type, id: id)
            if type != "video" {
                let jsCode = JSCodes.get(type)
                //print ("View will Appear, about to excute this javascript code: \(jsCode)")
                self.webView?.evaluateJavaScript(jsCode) { (result, error) in
                    if error != nil {
                        print ("something is wrong with js code in content item view controller: \(String(describing: error))")
                    } else {
                        //print ("js code is executed successfully! ")
                    }
                }
            }
        }
        // MARK: If there's a PrivilegeView in the view, check if it should be removed
        if isLoadingForTheFirstTime == false && isPrivilegeViewForAllLanguages {
            if let privilege = dataObject?.privilegeRequirement,
                PrivilegeHelper.isPrivilegeIncluded(privilege, in: Privilege.shared)  {
                PrivilegeViewHelper.removePrivilegeView(from: view)
                isPrivilegeViewForAllLanguages = false
            }
        } else {
            checkPrivilegeFor(.EnglishText)
        }
        // MARK: At the end of viewWillAppear, set isLoadingForTheFirstTime to false so that when user's are back from another view, the privilege block will be checked again.
        isLoadingForTheFirstTime = false
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
        checkPrivilegeFor(.EnglishText)
        trackScreenView(type: dataObject?.type, id: dataObject?.id)
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
        if let id = dataObject?.id,
            let type = dataObject?.type,
            ["story", "premium"].contains(type) {
            //MARK: if it is a story, get the API
            let urlString = APIs.get(id, type: type, forceDomain: nil)
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
                    //print ("update content UI from local file with \(urlString), no need to connect to internet again")
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
                    if error != nil {
                        //print("Error searching : \(error)")
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
            if ["story", "premium"].contains(type) {
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
            dataObject?.timeStamp = item.timeStamp
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
            // MARK: Check if you should pop out privilege view after content is available
            checkPrivilegeFor(.EnglishText)
        }
    }
    
    private func postEnglishStatusChange() {
        let object = ""
        let name = Notification.Name(rawValue: Event.englishStatusChange)
        NotificationCenter.default.post(name: name, object: object)
        //print ("Language: Post English Status Change")
    }
    
    public func updatePageContent() {
        // MARK: https://makeapppie.com/2016/07/05/using-attributed-strings-in-swift-3-0/
        // MARK: Convert HTML to NSMutableAttributedString https://stackoverflow.com/questions/36427442/nsfontattributename-not-applied-to-nsattributedstring
        if let type = dataObject?.type {
            switch type {
            case "video", "interactive", "photonews", "photo", "gym", "special", "html":
                renderWebView()
            case "story", "premium":
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

    
    private func renderWebView() {
        if let type = dataObject?.type,
            ["story", "premium", "ebook"].contains(type) || subType == .UserComments {
            // MARK: If it is a story
            if let dataObject = dataObject {
                self.dataObject = AdLayout.addPrivilegeRequirement(in: dataObject, with: sourceDataObject)
                //print ("New Privilege Requirement: \(newDataObject.privilegeRequirement)")
                checkPrivileForContent()
            }
            WebviewHelper.renderStory(type, subType: subType, dataObject: dataObject, webView: webView)
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
            if let urlString = dataObject?.id{
                WebviewHelper.loadContent(url: urlString, base: urlString, webView: webView)
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
                WebviewHelper.loadContent(url: urlString, base: baseUrlString, webView: webView)
            }
        }
    }
    
    
    
    private func updateAcutualLanguage() {
        if let itemId = dataObject?.id {
            let actualLanguage: Int
            if let hasEnglish = English.sharedInstance.has[itemId],
                hasEnglish == true {
                actualLanguage = UserDefaults.standard.integer(forKey: Key.languagePreference)
            } else {
                actualLanguage = 0
            }
            let languageSuffix: String
            switch actualLanguage {
            case 1:
                languageSuffix = "/en"
            case 2:
                languageSuffix = "/ce"
            default:
                languageSuffix = ""
            }
            currentActualLanguage = (actualLanguage, languageSuffix)
        }
    }
    
    private func checkPrivilegeFor(_ privilege: PrivilegeType) {
        if let itemType = dataObject?.type,
            let itemId = dataObject?.id,
            ["story"].contains(itemType),
            isPrivilegeViewForAllLanguages == false,
            isPrivilegeViewForAllLanguagesChecked == true {
            if privilege == .EnglishText {
                // MARK: Check the actual displayed language
                updateAcutualLanguage()
                let suffix = currentActualLanguage?.suffix ?? ""
                // print ("Language: \(actualLanguage); isPrivilegeViewOn: \(isPrivilegeViewForAllLanguages)")
                if !PrivilegeHelper.isPrivilegeIncluded(privilege, in: Privilege.shared) && currentActualLanguage != nil && currentActualLanguage?.index != 0 && dataObject?.isDownloaded == false {
                    PrivilegeViewHelper.insertPrivilegeView(to: view, with: privilege, from: dataObject, endWith: suffix)
                } else {
                    PrivilegeViewHelper.removePrivilegeView(from: view)
                    // MARK: A subscriber is reading a piece of paid content
                    if suffix != "" {
                        let eventLabel = PrivilegeHelper.getLabel(prefix: privilege.rawValue, type: itemType, id: itemId, suffix: suffix)
                        Track.eventToAll(category: "Privileges", action: "Read", label: eventLabel)
                    }
                }
            }
        }
    }
    
    private func checkPrivileForContent() {
        if let privilege = dataObject?.privilegeRequirement {
            if !PrivilegeHelper.isPrivilegeIncluded(privilege, in: Privilege.shared) {
                PrivilegeViewHelper.insertPrivilegeView(to: view, with: privilege, from: dataObject, endWith: "")
                isPrivilegeViewForAllLanguages = true
            } else {
                if let dataObject = dataObject {
                    updateAcutualLanguage()
                    let eventLabel = PrivilegeHelper.getLabel(prefix: privilege.rawValue, type: dataObject.type, id: dataObject.id, suffix: currentActualLanguage?.suffix ?? "")
                    Track.eventToAll(category: "Privileges", action: "Read", label: eventLabel)
                }
            }
        }
        isPrivilegeViewForAllLanguagesChecked = true
    }
    
    
    private func trackScreenView(type: String?, id: String?) {
        updateAcutualLanguage()
        if let type = type,
            let id = id {
            let headline: String
            if currentActualLanguage?.index == 1 {
                headline = dataObject?.eheadline ?? ""
            } else {
                headline = dataObject?.headline ?? ""
            }
            // MARK: Check if the user is tapping from editor choice, speedreading, or archive
            let tapFrom: String
            if let privilege = dataObject?.privilegeRequirement {
                switch privilege {
                case .EditorsChoice:
                    tapFrom = "EditorChoice/"
                case .SpeedReading:
                    tapFrom = "SpeedReading/"
                case .Archive:
                    tapFrom = "Archive/"
                case .Book:
                    tapFrom = "Book/"
                default:
                    tapFrom = ""
                }
            } else {
                tapFrom = ""
            }
            let languageSuffix = currentActualLanguage?.suffix ?? ""
            let screenName = "/\(DeviceInfo.checkDeviceType())/\(tapFrom)\(type)/\(id)\(languageSuffix)/\(headline)"
            Track.screenView(screenName, trackEngagement: true)
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
            case "ebody":
                //print ("ebody received");
                if let ebody = body["ebody"] {
                    dataObject?.ebody = ebody
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
            case "user":
                // MARK: Get user information
                if let body = message.body as? [String: String] {
                    UserInfo.updateUserInfo(with: body)
                    // MARK: - Update membership status
                    PrivilegeHelper.updateFromDevice()
                    checkPrivileForContent()
                }
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
    
    // MARK: Handle Subscription Related Actions
    @objc public func handlePurchaseNotification(_ notification: Notification) {
        
        // MARK: If purchase or restore is successful while the current page is showing an error, refresh the page with new domain

        
        let typeString = dataObject?.type ?? ""
        // MARK: If the story type is premium, render the story again.
        if ["premium"].contains(typeString) {
            getDetailInfo()
        }
        
        
        
    }
    
    
}
