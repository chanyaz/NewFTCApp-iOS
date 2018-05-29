//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import WebKit
import StoreKit
import MediaPlayer


enum DataViewRender {
    case collectionView
    case webView
}

class SuperDataViewController: UICollectionViewController, UINavigationControllerDelegate, UICollectionViewDataSourcePrefetching {
    var refreshContr: CustomRefreshConrol?
    var isLandscape = false
    //    var refreshControl = UIRefreshControl()
    let flowLayout = PageCollectionViewLayoutV()
    let flowLayoutH = PageCollectionViewLayoutH()
    let columnNum: CGFloat = 1 //use number of columns instead of a static maximum cell width
    var cellWidth: CGFloat = 0
    var themeColor: String? = nil
    var coverTheme: String?
    var layoutStrategy: String?
    var isVisible = false
    let maxWidth: CGFloat = 768
    var adchId = AdLayout.homeAdChId
    var withPrivilege: PrivilegeType?
    var privilegeDescriptionBody: String?
    var isLoadingForTheFirstTime = true
    var dataViewRender = DataViewRender.collectionView
    
    // MARK: If it's the first time web view loading, no need to record PV and refresh ad iframes
    // var isWebViewFirstLoading = true
    
    fileprivate let itemsPerRowForRegular: CGFloat = 3
    fileprivate let itemsPerRowForCompact: CGFloat = 1
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    // MARK: Search
    fileprivate lazy var searchBar: UISearchBar? = nil
    fileprivate var searchKeywords: String? = nil {
        didSet {
            search()
        }
    }
    fileprivate var fetches = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    fileprivate let contentAPI = ContentFetch()
    var dataObject = [String: String]()
    // MARK: Don't change pageTitle if you are in a page view controller. 
    var pageTitle: String = ""
    var pageIndex: Int?
    
    public lazy var webView: WKWebView? = nil
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let requestStatus = UIButton()
    private var requestStatusAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // MARK: - Update membership status
        PrivilegeHelper.updateFromDevice()
        let dataObjectType = dataObject["type"] ?? ""
        // MARK: - Request Data from Server
        if dataObject["api"] != nil || ["follow", "read", "iap", "setting", "options"].contains(dataObjectType){
            
            // MARK: - Get Layout Strategy
            let layoutKey = layoutType()
            if let layoutValue = dataObject[layoutKey] {
                layoutStrategy = layoutValue
            } else {
                layoutStrategy = nil
            }
            
            collectionView?.dataSource = self
            collectionView?.delegate = self
            if #available(iOS 10.0, *) {
                collectionView?.isPrefetchingEnabled = true
                collectionView?.prefetchDataSource = self
            }
            
            if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumInteritemSpacing = 0
                flowLayout.minimumLineSpacing = 0
                //FIXME: Why does this break scrolling?
                //flowLayout.sectionHeadersPinToVisibleBounds = true
                //flowLayout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
                
                let collectionViewInsets = UIEdgeInsetsMake(14, 0, 0, 0)
                collectionView?.contentInset = collectionViewInsets;
                collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(collectionViewInsets.top, 0, collectionViewInsets.bottom, 0);
                let availableWidth = min(view.frame.width, maxWidth)
                if #available(iOS 10.0, *) {
                    flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
                } else {
                    flowLayout.estimatedItemSize = CGSize(width: availableWidth, height: 250)
                }
                cellWidth = availableWidth
            }
            
            
            collectionView?.register(UINib.init(nibName: "ChannelCell", bundle: nil), forCellWithReuseIdentifier: "ChannelCell")
            collectionView?.register(UINib.init(nibName: "CoverCell", bundle: nil), forCellWithReuseIdentifier: "CoverCell")
            collectionView?.register(UINib.init(nibName: "ThemeCoverCell", bundle: nil), forCellWithReuseIdentifier: "ThemeCoverCell")
            collectionView?.register(UINib.init(nibName: "VideoCoverCell", bundle: nil), forCellWithReuseIdentifier: "VideoCoverCell")
            collectionView?.register(UINib.init(nibName: "ClassicCoverCell", bundle: nil), forCellWithReuseIdentifier: "ClassicCoverCell")
            collectionView?.register(UINib.init(nibName: "SmoothCoverCell", bundle: nil), forCellWithReuseIdentifier: "SmoothCoverCell")
            collectionView?.register(UINib.init(nibName: "OutOfBoxCoverCell", bundle: nil), forCellWithReuseIdentifier: "OutOfBoxCoverCell")
            collectionView?.register(UINib.init(nibName: "IconCell", bundle: nil), forCellWithReuseIdentifier: "IconCell")
            collectionView?.register(UINib.init(nibName: "BigImageCell", bundle: nil), forCellWithReuseIdentifier: "BigImageCell")
            //collectionView?.register(UINib.init(nibName: "LineCell", bundle: nil), forCellWithReuseIdentifier: "LineCell")
            //collectionView?.register(UINib.init(nibName: "PaidPostCell", bundle: nil), forCellWithReuseIdentifier: "PaidPostCell")
            collectionView?.register(UINib.init(nibName: "FollowCell", bundle: nil), forCellWithReuseIdentifier: "FollowCell")
            collectionView?.register(UINib.init(nibName: "SettingCell", bundle: nil), forCellWithReuseIdentifier: "SettingCell")
            collectionView?.register(UINib.init(nibName: "OptionCell", bundle: nil), forCellWithReuseIdentifier: "OptionCell")
            collectionView?.register(UINib.init(nibName: "BookCell", bundle: nil), forCellWithReuseIdentifier: "BookCell")
            collectionView?.register(UINib.init(nibName: "MembershipCell", bundle: nil), forCellWithReuseIdentifier: "MembershipCell")
            collectionView?.register(UINib.init(nibName: "FinePrintCell", bundle: nil), forCellWithReuseIdentifier: "FinePrintCell")
            collectionView?.register(UINib.init(nibName: "HeadlineCell", bundle: nil), forCellWithReuseIdentifier: "HeadlineCell")
            collectionView?.register(UINib.init(nibName: "Ad", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Ad")
            collectionView?.register(UINib.init(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
            collectionView?.register(UINib.init(nibName: "SimpleHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SimpleHeaderView")
            
            // MARK: - Update Styles
            view.backgroundColor = UIColor(hex: Color.Content.background)
            collectionView?.backgroundColor = UIColor(hex: Color.Content.background)
            // MARK: - show refresh controll only when there is api
            if dataObject["api"] != nil || ["follow", "iap"].contains(dataObjectType) {
                if #available(iOS 10.0, *) {
                    refreshContr = CustomRefreshConrol(target: self, refreshAction: #selector(refreshControlDidFire))
                    collectionView?.refreshControl = refreshContr
                    refreshContr?.delegate = self
                }
            }
            
            // MARK: - Get Content Data for the Page
            requestNewContent()
        } else if let urlStringOriginal = dataObject["url"] {
            let urlString = APIs.convert(urlStringOriginal)
            self.view.backgroundColor = UIColor(hex: Color.Content.background)
            //            self.edgesForExtendedLayout = []
            //            self.extendedLayoutIncludesOpaqueBars = false
            let config = WKWebViewConfiguration()
            
            // MARK: Tell the web view what kind of connection the user is currently on
            let contentController = WKUserContentController();
            let jsCode = "window.gConnectionType = '\(Connection.current())';window.gNoImageWithData='\(Setting.getSwitchStatus("no-image-with-data"))';window.gPrivileges=\(PrivilegeHelper.getPrivilegesForWeb());"
            let userScript = WKUserScript(
                source: jsCode,
                injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                forMainFrameOnly: true
            )
            contentController.addUserScript(userScript)
            // MARK: This is Very Important! Use LeadAvoider so that ARC kicks in correctly.
            contentController.add(LeakAvoider(delegate:self), name: "alert")
            contentController.add(LeakAvoider(delegate:self), name: "items")
            contentController.add(LeakAvoider(delegate:self), name: "sponsors")
            contentController.add(LeakAvoider(delegate:self), name: "user")
            contentController.add(LeakAvoider(delegate:self), name: "selectItem")
            contentController.add(LeakAvoider(delegate:self), name: "sharePageFromApp")
            contentController.add(LeakAvoider(delegate:self), name: "card")
            
            config.userContentController = contentController
            config.allowsInlineMediaPlayback = true
            
            // MARK: Add the webview as a subview of containerView
            webView = WKWebView(frame: self.view.bounds, configuration: config)
            view = webView
            view.clipsToBounds = true
            webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // MARK: Use this so that I don't have to calculate the frame of the webView, which can be tricky.
            //            webView = WKWebView(frame: self.view.bounds, configuration: config)
            //            self.view = self.webView
            let webViewBG = UIColor(hex: Color.Content.background)
            webView?.isOpaque = true
            webView?.backgroundColor = webViewBG
            webView?.scrollView.backgroundColor = webViewBG
            
            // MARK: This makes the web view scroll like native
            // MARK: Under iOS 9, this will eventually cause the follow error:
            /*
             objc[5112]: Cannot form weak reference to instance (0x13fa0fa00) of class Page.DataViewController. It is possible that this object was over-released, or is in the process of deallocation.
             */
            webView?.scrollView.delegate = self
            webView?.navigationDelegate = self
            webView?.clipsToBounds = true
            webView?.scrollView.bounces = true
            refreshContr = CustomRefreshConrol(target: self, refreshAction: #selector(refreshWebView))
            // MARK: Delegate Step 4: Set the delegate to self
            refreshContr?.delegate = self
            dataViewRender = .webView
            if let refreshContr = refreshContr {
                webView?.scrollView.addSubview(refreshContr)
            }
            if dataObjectType == "Search" {
                searchBar = UISearchBar()
                searchBar?.sizeToFit()
                searchBar?.showsScopeBar = true
                // MARK: use this so that search bar doesn't enlarge navigation bar height
                if #available(iOS 11.0, *) {
                    searchBar?.heightAnchor.constraint(equalToConstant: 44).isActive = true
                }
                navigationItem.titleView = searchBar
                searchBar?.becomeFirstResponder()
                searchBar?.delegate = self
                let urlStringSearch = APIs.convert(APIs.searchUrl)
                if let url = URL(string: urlStringSearch) {
                    let request = URLRequest(url: url)
                    let fileName = GB2Big5.convertHTMLFileName("search")
                    if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html"){
                        do {
                            let searchHTML = getSearchHistoryHTML()
                            let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                                .replacingOccurrences(of: "{search-html}", with: searchHTML)
                            let storyHTML = storyTemplate as String
                            self.webView?.loadHTMLString(storyHTML, baseURL:url)
                        } catch {
                            //self.webView?.load(request)
                        }
                    } else {
                        self.webView?.load(request)
                    }
                }
            } else if dataObjectType == "account" {
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    let fileName = GB2Big5.convertHTMLFileName("account")
                    if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html"){
                        do {
                            let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                            var storyHTML = GB2Big5.convert(storyTemplate as String)
                            var availableSocialLogins = [String]()
                            if WXApi.isWXAppInstalled() {
                                availableSocialLogins.append("wechat")
                            }
                            let availableSocialLoginsString = availableSocialLogins.joined(separator: ",")
                            storyHTML = storyHTML.replacingOccurrences(of: "{showSocialLogins}", with: availableSocialLoginsString)
                            self.webView?.loadHTMLString(storyHTML, baseURL:url)
                        } catch {
                            //self.webView?.load(request)
                        }
                    } else {
                        self.webView?.load(request)
                    }
                }
            } else if dataObjectType == "htmlbook" {
                // MARK: - Open HTML Body Content from the html-book.html local file
                let url = URL(string: APIs.getUrl("htmlbook", type: "htmlbook", isSecure: false, isPartial: false))
                if let contentHTMLPath = dataObject["id"],
                    let url = url {
                    do {
                        let contentNSString = try NSString(contentsOfFile:contentHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let content = contentNSString as String
                        let resourceFileNameString: String
                        // MARK: Two types of HTML books
                        let replaceString: String
                        if content.range(of: "item-container") != nil {
                            resourceFileNameString = "list"
                            replaceString = "{list-content}"
                        } else {
                            resourceFileNameString = "html-book"
                            replaceString = "{html-book-content}"
                        }
                        let resourceFileName = GB2Big5.convertHTMLFileName(resourceFileNameString)
                        if let templateHTMLPath = Bundle.main.path(forResource: resourceFileName, ofType: "html") {
                            let templateNSString = try NSString(contentsOfFile:templateHTMLPath, encoding:String.Encoding.utf8.rawValue)
                            let template = templateNSString as String
                            var contentHTML = template.replacingOccurrences(of: replaceString, with: content)
                            if let productId = dataObject["headline"]?.replacingOccurrences(of: "^try.", with: "", options: .regularExpression),
                                contentHTMLPath.range(of: "try.") != nil {
                                contentHTML = contentHTML.replacingOccurrences(of: "试读结束，如您对本书感兴趣，请返回之后购买。", with: "试读结束，如您对本书感兴趣，请<a href=\"buyproduct://\(productId)\">点击此处购买。</a>")
                            }
                            self.webView?.loadHTMLString(contentHTML, baseURL:url)
                        }
                    } catch {
                        print ("cannot open the html book file")
                    }
                }
            }  else if dataObjectType == "clip" {
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    let fileName = GB2Big5.convertHTMLFileName("myft")
                    if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html"){
                        do {
                            let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                            let storyHTML = GB2Big5.convert(storyTemplate as String)
                            let listContentString = APIs.getHTMLCode("clip")
                            let clipHTML = storyHTML.replacingOccurrences(of: "{list-content}", with: listContentString)
                            self.webView?.loadHTMLString(clipHTML, baseURL:url)
                        } catch {
                            self.webView?.load(request)
                        }
                    } else {
                        self.webView?.load(request)
                    }
                }
            } else if let listAPI = dataObject["listapi"] {
                let fileExtension = "html"
                requestNewContentForWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
                renderWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
            } else if let url = URL(string: urlString) {
                print ("Open url: \(urlString)")
                let request = URLRequest(url: url)
                webView?.load(request)
            }
        }
        
        
        // MARK: Only update the navigation title when it is pushed
        navigationItem.title = pageTitle.removingPercentEncoding
        
        // MARK: - Notification For English Status Change
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

        // MARK: listen to in-app purchase receipt validation notification. This is useful to provide immediate visual feedback when user buys or renews a product.
        // MARK: Only do this is when the type of the data object is iap, otherwise it fetches data.
        if dataObjectType == "iap" {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleReceiptValidationNotification(_:)),
                name: Notification.Name(rawValue: IAPHelper.receiptValidatedNotification),
                object: nil
            )
        }
        
        
        
    }
    
    @objc public func refreshWebView(_ sender: Any) {
        if let listAPI = dataObject["listapi"],
            let urlStringOriginal = dataObject["url"] {
            let urlString = APIs.convert(urlStringOriginal)
            let fileExtension = "html"
            requestNewContentForWebview(
                listAPI,
                urlString: urlString,
                fileExtension: fileExtension
            )
            RequestMessage.update(.Hidden, with: self.requestStatus, in: self.view)
        } else {
            activityIndicator.removeFromSuperview()
            refreshContr?.endRefreshing()
        }
    }
    
    private func requestNewContentForWebview(_ listAPI: String, urlString: String, fileExtension: String) {
        DispatchQueue.main.async {
            if self.requestStatusAdded == false {
                RequestMessage.add(.Pending, with: self.requestStatus, in: self.view)
                self.requestStatusAdded = true
            }
            if self.refreshContr?.currentStatus == .normal {
                RequestMessage.update(.Pending, with: self.requestStatus, in: self.view)
            }
        }
        let listAPIString = APIs.convert(Download.addVersionAndTimeStamp(listAPI))
        //print ("requesting api from: \(listAPIString)")
        if let url = URL(string: listAPIString) {
            Download.getDataFromUrl(url) {[weak self] (data, response, error)  in
                DispatchQueue.global().async {
                    var status: RequestStatus? = nil
                    if error != nil {
                        Download.handleServerError(listAPIString, error: error)
                        let statusType = Connection.current()
                        if statusType == "no" {
                            status = .NoConnection
                        } else {
                            status = .ConnectionFailed
                        }
                    }
                    if let data = data,
                        error == nil {
                        if HTMLValidator.validate(data, of: listAPIString, for: .List) != nil {
                            if APIs.noRepeatForSameContent(listAPI) == true,
                                let currentData = Download.readFile(listAPI, for: .cachesDirectory, as: fileExtension),
                                currentData == data {
                                status = .ContentUnchanged
                            } else {
                                Download.saveFile(data, filename: listAPI, to: .cachesDirectory, as: fileExtension)
                                status = .Success
                            }
                        } else {
                            status = .ValidationFaild
                        }
                    }
                    DispatchQueue.main.async {
                        if status == .Success {
                            self?.renderWebview (listAPI, urlString: urlString, fileExtension: fileExtension)
                        }
                        // MARK: Show a message in the view controller, which disappears in 2 seconds.
                        RequestMessage.update(status, with: self?.requestStatus, in: self?.view)
                    }
                }
            }
        }
    }
    
    private func renderWebview (_ listAPI: String, urlString: String, fileExtension: String) {
        DispatchQueue.global().async {
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                let fileName = GB2Big5.convertHTMLFileName("list")
                if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html") {
                    do {
                        // MARK: If there's backupfile parameter in the url string, try to render the local backup content file
                        let defaultString: String
                        if listAPI.range(of:"backupfile=") != nil,
                            let backupHTMLPath = Bundle.main.path(forResource: listAPI.replacingOccurrences(of: "^.*backupfile=([a-zA-Z0-9]+).*$", with: "$1", options: .regularExpression), ofType: "html") {
                            let localbackupNSString = try NSString(contentsOfFile:backupHTMLPath, encoding:String.Encoding.utf8.rawValue)
                            let localbackupString = localbackupNSString as String
                            defaultString = localbackupString
                        } else {
                            //defaultString  = ErrorMessages.Loading.loadingMessage
                            defaultString = ErrorMessages.Loading.getExplainationHTML(with: urlString)
                        }
                        let listContentString: String
                        if let listContentData = Download.readFile(listAPI, for: .cachesDirectory, as: fileExtension) {
                            listContentString = String(data: listContentData, encoding: String.Encoding.utf8) ?? defaultString
                        } else {
                            listContentString = defaultString
                        }
                        let listTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let nightClass = Setting.getNightClass()
                        var listHTML = (listTemplate as String)
                            .replacingOccurrences(of: "{list-content}", with: listContentString)
                            .replacingOccurrences(of: "{night-class}", with: nightClass)
                        var iapCode = ""
                        if let jsCode = IAPs.shared.jsCodes,
                            listAPI.range(of: "showIAP=yes") != nil {
                            iapCode = jsCode
                        }
                        let userLoginJsCode = JSCodes.getUserLoginJsCode()
                        listHTML = listHTML.replacingOccurrences(
                            of: "{iap-js-code}",
                            with: "\(iapCode)\(userLoginJsCode)"
                        )
                        DispatchQueue.main.async {
                            self.webView?.loadHTMLString(listHTML, baseURL:url)
                            self.refreshContr?.endRefreshing()
                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            self.webView?.load(request)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.webView?.load(request)
                    }
                }
                // MARK: Display IAP Products on List Page, only for the first time
                if listAPI.range(of: "showIAP=yes") != nil && IAPs.shared.jsCodes == nil {
                    DispatchQueue.main.async {
                        self.loadProductsHTML(for: "ebook")
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        // MARK: - Update membership status
        PrivilegeHelper.updateFromDevice()
        
        if let screeName = dataObject["screenName"] {
            Track.screenView("/\(DeviceInfo.checkDeviceType())/\(screeName)", trackEngagement: true)
        }
        filterDataWithAudioUrl()
        // MARK: In setting page, you might need to update UI to reflected change in preference
        if let type = dataObject["type"],
            type == "setting" {
            loadSettings()
        }
        
        // MARK: - Update privilege lock class in HTML when coming back from another view. If you do this with notification, you won't be able to access the correct value in the class.
        if isLoadingForTheFirstTime == false,
            webView != nil {
            let jsCode = "window.gPrivileges=\(PrivilegeHelper.getPrivilegesForWeb());updateHeadlineLocks();"
            webView?.evaluateJavaScript(jsCode) { (result, error) in
            }
        }
        
        // MARK: - Update User Name Prompt Based on User Name
        let jsCode = JSCodes.getUserLoginJsCode()
        webView?.evaluateJavaScript(jsCode) { (result, error) in
            //print ("\(jsCode) excuted! ")
        }
        
        isLoadingForTheFirstTime = false
    }

    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //print ("view did disappear called. ")
        isVisible = false
        // MARK: if web view is not used, no need to do anything
        if webView == nil {
            return
        }
        // MARK: if a user is a subscriber, no need to refresh the data page web view as it causes problem sometimes
        if Privilege.shared.exclusiveContent {
            return
        }
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] timer in
                if self?.isVisible == false {
                    if let listAPI = self?.dataObject["listapi"],
                        let urlStringOriginal = self?.dataObject["url"] {
                        let fileExtension = "html"
                        let urlString = APIs.convert(urlStringOriginal)
                        self?.webViewScrollPoint = self?.webView?.scrollView.contentOffset
                        self?.renderWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
                        //print ("the view is not visible, render web view called")
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
                            if let webViewScrollPoint = self?.webViewScrollPoint {
                                self?.webView?.scrollView.setContentOffset(webViewScrollPoint, animated: false)
                            }
                        }
                    }
                } else {
                   //print ("the view is visible, nothing called")
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //print("view will transition called. ")//第一次启动不运行，转屏出现一次
        collectionView?.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.nightModeChanged), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: nil)
        
        if let dataObjectType = dataObject["type"],
            dataObjectType == "iap" {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: IAPHelper.receiptValidatedNotification), object: nil)
        }
        
        // MARK: release all the delegate to avoid crash in iOS 9
        webView?.scrollView.delegate = nil
        webView?.navigationDelegate = nil
        searchBar?.delegate = nil
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
        //print ("Data View Controller of \(pageTitle) removed successfully")
    }
    
    @objc public func nightModeChanged() {
        view.backgroundColor = UIColor(hex: Color.Content.background)
        collectionView?.backgroundColor = UIColor(hex: Color.Content.background)
        collectionView?.reloadData()
        let webViewBG = UIColor(hex: Color.Content.background)
        webView?.backgroundColor = webViewBG
        webView?.scrollView.backgroundColor = webViewBG
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
    
    private func getAPI(_ urlString: String) {
        //        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
        //        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        view.addSubview(activityIndicator)
        // activityIndicator.frame = view.bounds
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        // MARK: Check the local file
        if let data = Download.readFile(urlString, for: .cachesDirectory, as: "json") {
            //print ("found \(urlString) in caches directory. ")
            if let resultsDictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            {
                let contentSections = contentAPI.formatJSON(resultsDictionary)
                let results = ContentFetchResults(apiUrl: urlString, fetchResults: contentSections)
                print ("update UI from local")
                updateUI(with: results)
                //print ("update UI from local file with \(urlString)")
            }
        }
        
        // MARK: Get the API with the correct language and server
        let acturalUrlString = APIs.convert(urlString)
        contentAPI.fetchContentForUrl(acturalUrlString, fetchUpdate: .Always) {
            [weak self] results, error in
            DispatchQueue.main.async {
                self?.activityIndicator.removeFromSuperview()
                self?.refreshContr?.endRefreshing()
                if let error = error {
                    //print("Error searching : \(error)")
                    Download.handleServerError(acturalUrlString, error: error)
                    return
                }
                if let results = results {
                    // MARK: When updating UI from the internet, the viewable ad will be updated too, which makes sense
                    print ("update UI from the internet with \(acturalUrlString)")
                    self?.updateUI(with: results)
                    // FIXME: It is important to reload Data here, not inside the updateUI. But Why? What's the difference?
                    self?.collectionView?.reloadData()
                    self?.prefetch()
                }
            }
        }
    }
    
    
    private func prefetch() {
        let statusType = IJReachability().connectedToNetworkOfType()
        if statusType == .wiFi {
            //print ("User is on Wifi, Continue to prefetch content")
            let sections = fetches.fetchResults
            for section in sections {
                let items = section.items
                for item in items {
                    //print ("prefetch item: \(item.type)/\(item.id)")
                    if ["story","premium"].contains(item.type) {
                        let apiUrl = APIs.get(item.id, type: item.type, forceDomain: nil)
                        //print ("read story json: \(apiUrl)")
                        if Download.readFile(apiUrl, for: .cachesDirectory, as: "json") == nil {
                            //print ("File needs to be downloaded. id: \(item.id), type: \(item.type), api url is \(apiUrl)")
                        } else {
                            //print ("File already exists. id: \(item.id), type: \(item.type), api url is \(apiUrl)")
                        }
                        Download.downloadUrl(apiUrl, to: .cachesDirectory, as: "json")
                        
                        if Download.readFile(item.image, for: .cachesDirectory, as: "cover") == nil {
                            item.loadImage(
                                type:"cover",
                                width: ImageSize.cover.width,
                                height: ImageSize.cover.height,
                                completion:{ (cellContentItem, error) in
                            }
                            )
                        }
                        if Download.readFile(item.image, for: .cachesDirectory, as: "thumbnail") == nil {
                            item.loadImage(
                                type:"thumbnail",
                                width: ImageSize.thumbnail.width,
                                height: ImageSize.thumbnail.height,
                                completion:{ (cellContentItem, error) in
                            }
                            )
                        }
                    } else if item.type == "manual" {
                        let apiUrl: String
                        if let contentId = item.id.matchingStrings(regexes: LinkPattern.pagemaker) {
                            //apiUrl = APIs.get(contentId, type: "pagemaker")
                            apiUrl = APIs.getUrl(contentId, type: "pagemaker", isSecure: true, isPartial: true)
                        } else {
                            apiUrl = item.id
                        }
                        if Download.readFile(apiUrl, for: .cachesDirectory, as: "html") == nil {
                            //print ("File needs to be downloaded. id: \(item.id), type: \(item.type), api url is \(apiUrl)")
                        }
                        Download.downloadUrl(apiUrl, to: .cachesDirectory, as: "html")
                    } else if ["video"].contains(item.type) {
                        let apiUrl = APIs.getUrl(item.id, type: item.type, isSecure: true, isPartial: false)
                        //(item.id, type: item.type)
                        if Download.readFile(apiUrl, for: .cachesDirectory, as: "html") == nil {
                            //print ("Video Prefetch: File needs to be downloaded. id: \(item.id), type: \(item.type), api url is \(apiUrl)")
                        } else {
                            //print ("Video Prefetch: File already downloaded. id: \(item.id), type: \(item.type), api url is \(apiUrl)")
                        }
                        Download.downloadUrl(apiUrl, to: .cachesDirectory, as: "html")
                    }
                }
            }
        }
    }
    
    
    fileprivate func updateUI(with results: ContentFetchResults) {
        // MARK: - Insert Ads into the fetch results
        let layoutWay:String
        layoutWay = dataObject["compactLayout"] ?? "home"
        // MARK: Insert Content
        let fetchResultsWithContent: [ContentSection]
        if let insertContentLayoutWay = dataObject["Insert Content"] {
            fetchResultsWithContent = SupplementContent.insertContent(insertContentLayoutWay, to: results.fetchResults)
        } else {
            fetchResultsWithContent = results.fetchResults
        }
        
        // MARK: Insert Ads
        let fetchResultsWithAds = AdLayout.insertAds(layoutWay, to: fetchResultsWithContent)
        
        let resultsWithAds = ContentFetchResults(
            apiUrl: results.apiUrl,
            fetchResults: fetchResultsWithAds
        )
        if resultsWithAds.fetchResults.count > 0 {
            self.fetches = resultsWithAds
            self.collectionView?.reloadData()
        }
        activityIndicator.removeFromSuperview()
        refreshContr?.endRefreshing()
        
    }
    
    private func requestNewContent() {
        if let api = dataObject["api"] {
            getAPI(api)
        } else if let type = dataObject["type"] {
            if ["read"].contains(type) {
                let contentSections = ContentSection(
                    title: "",
                    items: Download.get(type),
                    type: "List",
                    adid: ""
                )
                let results = ContentFetchResults(apiUrl: "", fetchResults: [contentSections])
                updateUI(with: results)
            } else if type == "iap" {
                loadProducts(isCalledFromReceiptValidation: false)
            } else if type == "setting" {
                loadSettings()
            } else if type == "options" {
                loadOptions()
            } else if type == "follow" {
                let urlString = Download.addVersionAndTimeStamp(APIs.get("follow", type: type, forceDomain: nil))
                getAPI(urlString)
            } else {
                let urlString = APIs.get("", type: type, forceDomain: nil)
                getAPI(urlString)
            }
        } else {
            //MARK: Report to GA if there's no api to get
            Track.event(category: "CatchError", action: "no API or Type for dataObject", label: String(describing: dataObject))
            Track.catchError("no API or Type for dataObject: \(String(describing: dataObject))", withFatal: 1)
            //print("results : error")
        }
    }
    
    @objc func refreshControlDidFire(sender:AnyObject) {
        print ("pull to refresh fired")
        // MARK: Handle Pull to Refresh
        requestNewContent()
    }
    
    private var webViewScrollPoint: CGPoint?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetches.fetchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetches.fetchResults[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = getReuseIdentifierForCell(indexPath)
        let cellItem = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        //print ("cell life: cell for item at section: \(indexPath.section), row: \(indexPath.row)")
        switch reuseIdentifier {
        case "CoverCell":
            if let cell = cellItem as? CoverCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "ThemeCoverCell":
            if let cell = cellItem as? ThemeCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "VideoCoverCell":
            if let cell = cellItem as? VideoCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "SmoothCoverCell", "ClassicCoverCell":
            if let cell = cellItem as? SmoothCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "OutOfBoxCoverCell":
            if let cell = cellItem as? OutOfBoxCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "IconCell":
            if let cell = cellItem as? IconCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "BigImageCell":
            if let cell = cellItem as? BigImageCell {
                cell.cellWidth = cellWidth
                cell.themeColor = self.themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.soundButton.addTarget(self, action: #selector(self.openPlay), for: UIControlEvents.touchUpInside)
                cell.updateUI()
                return cell
            }
        case "HeadlineCell":
            if let cell = cellItem as? HeadlineCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "CoverCellRegular":
            if let cell = cellItem as? CoverCellRegular {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "ChannelCellRegular":
            if let cell = cellItem as? ChannelCellRegular {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "AdCellRegular":
            if let cell = cellItem as? AdCellRegular {
                cell.cellWidth = cellWidth
                cell.updateUI()
                return cell
            }
        case "HotArticleCellRegular":
            if let cell = cellItem as? HotArticleCellRegular {
                cell.cellWidth = cellWidth
                cell.updateUI()
                //              cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        case "BookCell":
            if let cell = cellItem as? BookCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.pageTitle = pageTitle
                cell.themeColor = themeColor
                cell.updateUI()
                return cell
            }
        case "MembershipCell":
            if let cell = cellItem as? MembershipCell {
                cell.buyState = .New
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.pageTitle = pageTitle
                cell.themeColor = themeColor
                cell.updateUI()
                return cell
            }
        case "FinePrintCell":
            if let cell = cellItem as? FinePrintCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.pageTitle = pageTitle
                cell.themeColor = themeColor
                cell.updateUI()
                return cell
            }
        case "FollowCell":
            if let cell = cellItem as? FollowCell {
                cell.cellWidth = cellWidth
                cell.themeColor = themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "SettingCell":
            if let cell = cellItem as? SettingCell {
                cell.cellWidth = cellWidth
                cell.themeColor = themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "OptionCell":
            if let cell = cellItem as? OptionCell {
                cell.cellWidth = cellWidth
                cell.themeColor = themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "EmptyCell":
            return cellItem
        default:
            if let cell = cellItem as? ChannelCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.pageTitle = pageTitle
                cell.updateUI()
                return cell
            }
        }
        return cellItem
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        //print ("cell life: prefetch")
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let reuseIdentifier = getReuseIdentifierForSectionHeader(indexPath.section).reuseId ?? ""
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: reuseIdentifier,
                for: indexPath
            )
            
            // MARK: - a common tag gesture for all kinds of headers
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
            headerView.isUserInteractionEnabled = true
            headerView.addGestureRecognizer(tapGestureRecognizer)
            switch reuseIdentifier {
            case "Ad":
                let ad = headerView as! Ad
                ad.contentSection = fetches.fetchResults[indexPath.section]
                ad.updateUI()
                return ad
            case "HeaderView":
                let headerView = headerView as! HeaderView
                headerView.headerWidth = cellWidth
                headerView.themeColor = themeColor
                headerView.contentSection = fetches.fetchResults[indexPath.section]
                return headerView
            case "SimpleHeaderView":
                let headerView = headerView as! SimpleHeaderView
                headerView.headerWidth = cellWidth
                headerView.themeColor = themeColor
                headerView.contentSection = fetches.fetchResults[indexPath.section]
                return headerView
            default:
                assert(false, "Unknown Identifier")
            }
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        let reuseIdentifier = getReuseIdentifierForSectionHeader(indexPath.section).reuseId ?? ""
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        return headerView
    }
    
    // Calculate Height for Headers
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if getReuseIdentifierForSectionHeader(section).reuseId != nil {
            return getReuseIdentifierForSectionHeader(section).sectionSize
        }
        return CGSize.zero
    }
    
    // MARK: - Use different cell based on different strategy
    fileprivate func getReuseIdentifierForCell(_ indexPath: IndexPath) -> String {
        // MARK: - Check if the IndexPath is out of range
        if fetches.fetchResults.count < indexPath.section + 1 {
            return "EmptyCell"
        }
        
        let section = fetches.fetchResults[indexPath.section]
        if section.items.count < indexPath.row + 1 {
            print ("\(section.title) out of range, item count is \(section.items.count) and row is \(indexPath.row)")
            return "EmptyCell"
        }
        
        // MARK: Go on if the IndexPath is in range
        let item = section.items[indexPath.row]
        let sectionTitle = section.title
        let isCover = ((indexPath.row == 0 && sectionTitle != "") || item.isCover == true)
        
        let reuseIdentifier: String
        
        if layoutStrategy == "Simple Headline" {
            if isCover {
                reuseIdentifier = "CoverCell"
            } else {
                reuseIdentifier = "HeadlineCell"
            }
        } else if layoutStrategy == "All Cover" {
            reuseIdentifier = "BigImageCell"
        } else if layoutStrategy == "Video" {
            reuseIdentifier = "VideoCoverCell"
        } else if layoutStrategy?.hasPrefix("OutOfBox") == true {
            reuseIdentifier = "OutOfBoxCoverCell"
        } else if layoutStrategy?.hasPrefix("SmoothCover") == true {
            reuseIdentifier = "SmoothCoverCell"
        } else if layoutStrategy == "Icons" {
            reuseIdentifier = "IconCell"
        } else {
            if item.type == "ebook" {
                reuseIdentifier = "BookCell"
            } else if item.type == "membership" {
                reuseIdentifier = "MembershipCell"
            } else if item.type == "fineprint" {
                reuseIdentifier = "FinePrintCell"
            } else if item.type == "follow" {
                reuseIdentifier = "FollowCell"
            } else if item.type == "setting" {
                reuseIdentifier = "SettingCell"
            } else if item.type == "option" {
                reuseIdentifier = "OptionCell"
            } else if isCover {
                if let coverTheme = coverTheme {
                    reuseIdentifier = Color.Theme.getCellIndentifier(coverTheme)
                } else {
                    reuseIdentifier = "CoverCell"
                }
            } else {
                reuseIdentifier = "ChannelCell"
            }
        }
        return reuseIdentifier
    }
    
    private func getReuseIdentifierForSectionHeader(_ sectionIndex: Int) -> (reuseId: String?, sectionSize: CGSize) {
        var reuseIdentifier: String? = nil
        var sectionSize: CGSize = .zero
        if fetches.fetchResults.count > sectionIndex {
            let sectionType = fetches.fetchResults[sectionIndex].type
            switch sectionType {
            case "Banner":
                reuseIdentifier = "Ad"
                sectionSize = CGSize(width: view.frame.width, height: view.frame.width/4)
            case "MPU":
                reuseIdentifier = "Ad"
                sectionSize = CGSize(width: 300, height: 250)
            case "HalfPage":
                reuseIdentifier = "Ad"
                sectionSize = CGSize(width: 300, height: 600)
            case "List", "Group":
                if ![""].contains(fetches.fetchResults[sectionIndex].title) {
                    switch sectionType {
                    case "Group":
                        reuseIdentifier = "SimpleHeaderView"
                        sectionSize = CGSize(width: view.frame.width, height: 44)
                    default:
                        reuseIdentifier = "HeaderView"
                        sectionSize = CGSize(width: view.frame.width, height: 60)
                    }
                } else {
                    reuseIdentifier = nil
                    sectionSize = CGSize.zero
                }
            default:
                reuseIdentifier = nil
                sectionSize = CGSize.zero
            }
        }
        return (reuseId: reuseIdentifier, sectionSize: sectionSize)
    }
    
    @objc func openPlay(sender: UIButton?){
        PlayerAPI.sharedInstance.openPlay()
    }
    
    func filterDataWithAudioUrl(){
        var resultsWithAudioUrl = [ContentSection]()
        let results = fetches.fetchResults
        for (_, section) in results.enumerated() {
            
            //print("TabBarAudioContent section.items.count \(section.items.count)")
            for i in 0 ..< section.items.count {
                
                if section.items[i].caudio != nil || section.items[i].eaudio != nil{
                    resultsWithAudioUrl.append(section)
                }
            }
        }
        TabBarAudioContent.sharedInstance.fetchResults = resultsWithAudioUrl
    }
    
    
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    
    // MARK: - Handle user tapping on a cell
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return handleItemSelect(indexPath)
    }
    
    // MARK: - Move the handle cell selection to a function so that it can be used in different cases
    fileprivate func handleItemSelect(_ indexPath: IndexPath) -> Bool {
        // MARK: Check the fetchResults to make sure there's no out-of-range error
        if fetches.fetchResults.count <= indexPath.section || fetches.fetchResults.count == 0 || indexPath.section < 0 {
            Track.event(category: "CatchError", action: "Out of Range", label: "handleItemSelect 1")
            //print ("There is not enough sections in fetchResults")
            return false
        }
        if fetches.fetchResults[indexPath.section].items.count <= indexPath.row || fetches.fetchResults[indexPath.section].items.count == 0 || indexPath.row < 0 {
            Track.event(category: "CatchError", action: "Out of Range", label: "handleItemSelect 2")
            //print ("Row is \(indexPath.row). There is not enough rows in fetchResults Section")
            return false
        }
        let selectedItem = fetches.fetchResults[indexPath.section].items[indexPath.row]
        if layoutStrategy == "Icons"{
            return false
        }
        // MARK: For a normal cell, allow the action to go through. For special types of cell, such as advertisment in a wkwebview, do not take any action and let wkwebview handle tap.
        // MARK: if it is an audio file, push the audio view controller
        if let audioFileUrl = selectedItem.audioFileUrl {
            // MARK: If the user doesn't have the necessary privilege to listen to English audio, present membership options to him
            // MARK: If a user bought the eBook, he should be able to listen to it without membership privilege
            if Privilege.shared.editorsChoice == false && APIs.isEditorChoice(dataObject) {
                // MARK: Only if membership subscription view is correctly displayed
                if PrivilegeViewHelper.showSubscriptionView(for: .EditorsChoice, with: selectedItem) {
                    return false
                }
            }
            if let audioPlayer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayer") as? AudioPlayer {
                AudioContent.sharedInstance.body["title"] = selectedItem.headline
                AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                AudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(selectedItem.id)"
                audioPlayer.item = AdLayout.addPrivilegeRequirement(in: selectedItem, with: dataObject)
                //selectedItem
                
                //let pageDataRaw = AdLayout.addPrivilegeRequirements(in: pageData1, with: dataObject)
                
                audioPlayer.themeColor = themeColor
                navigationController?.pushViewController(audioPlayer, animated: true)
            }
        } else if let contentId = selectedItem.id.matchingStrings(regexes: LinkPattern.pagemaker) {
            openManualPage(contentId, of: "pagemaker", with: selectedItem.headline)
        } else {
            switch selectedItem.type {
            case "membership", "fineprint":
                return false
            case "column":
                if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
                    dataViewController.dataObject = [
                        "title": selectedItem.headline,
                        //"api":"https://d37m993yiqhccr.cloudfront.net/channel/lifestyle.html?type=json",
                        "listapi":"https://danla2f5eudt1.cloudfront.net/column/\(selectedItem.id)?webview=ftcapp&bodyonly=yes",
                        "url":"http://www.ftchinese.com/column/\(selectedItem.id)",
                        "screenName":"homepage/column/\(selectedItem.id)",
                        "compactLayout": "OutOfBox",
                        "coverTheme": "OutOfBox-LifeStyle"
                    ]
                    dataViewController.pageTitle = selectedItem.headline
                    navigationController?.pushViewController(dataViewController, animated: true)
                    return false
                }
            case "setting":
                let optionInfo = Setting.get(selectedItem.id)
                if let optionType = optionInfo.type {
                    if optionType == "switch" {
                        return false
                    } else {
                        Setting.handle(selectedItem.id, type: optionType, title: selectedItem.headline)
                    }
                } else {
                    return false
                }
            case "option":
                if let optionsId = dataObject["id"] {
                    let selectedIndex = indexPath.row
                    fetches = ContentFetchResults(
                        apiUrl: fetches.apiUrl,
                        fetchResults: Setting.updateOption(optionsId, with: selectedIndex, from: fetches.fetchResults)
                    )
                    collectionView?.reloadData()
                }
                return true
            case "ad", "follow":
                print ("Tap an ad. Let the cell handle it by itself. ")
                return false
            case "ebook":
                if let contentItemViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
                    contentItemViewController.dataObject = selectedItem
                    contentItemViewController.hidesBottomBarWhenPushed = true
                    contentItemViewController.themeColor = themeColor
                    navigationController?.pushViewController(contentItemViewController, animated: true)
                }
            case "TryBook":
                Alerts.tryBook()
                break
                
            case "ViewController":
                if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                    navigationController?.pushViewController(chatViewController, animated: true)
                }
                break
                
            default:
                //MARK: if it is a story, video or other types of HTML based content, push the detailViewController
                if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
                    var pageData1 = [ContentItem]()
                    var currentPageIndex = 0
                    var pageIndexCount = 0
                    for (sectionIndex, section) in fetches.fetchResults.enumerated() {
                        for (itemIndex, item) in section.items.enumerated() {
                            if sectionIndex == indexPath.section && itemIndex == indexPath.row {
                                currentPageIndex = pageIndexCount
                            }
                            // MARK: radio should not be swiped to as it behaves differently
                            if ["story", "premium", "video", "interactive", "photo", "manual"].contains(item.type),
                                !["radio"].contains(item.subType) {
                                pageData1.append(item)
                                pageIndexCount += 1
                            }
                        }
                    }
                    // MARK: Check the membership privilege type for the content
                    let pageDataRaw = AdLayout.addPrivilegeRequirements(in: pageData1, with: dataObject)
                    let pageData: [ContentItem]
                    if selectedItem.type == "manual" || APIs.shouldHideAd(dataObject) == true {
                        // MARK: For manual html pages in ebooks, hide bottom bar and ads
                        let pageData1 = AdLayout.removeAds(in: pageDataRaw)
                        pageData = AdLayout.markAsDownloaded(in: pageData1)
                        detailViewController.showBottomBar = false
                    } else {
                        let withAd = AdLayout.insertFullScreenAd(to: pageDataRaw, for: currentPageIndex)
                        pageData = AdLayout.insertAdId(to: withAd.contentItems, with: adchId)
                        currentPageIndex = withAd.pageIndex
                    }
                    if pageData.count <= currentPageIndex {
                        print ("current page index is \(currentPageIndex), which is higer or equal to page data count of \(pageData.count)")
                        return false
                    }
                    pageData[currentPageIndex].isLandingPage = true
                    detailViewController.themeColor = themeColor
                    detailViewController.contentPageData = pageData
                    
                    // MARK: - It is important to pass information about the source so that we can get the correct privileges for htmlbook and other types of service
                    detailViewController.sourceDataObject = dataObject
                    detailViewController.currentPageIndex = currentPageIndex
                    navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
        }
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        //        print ("prepare for segue here")
        
    }
    
    @objc open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        //navigationController?.performSegue(withIdentifier: "Show News Detail", sender: self)
        //performSegue(withIdentifier: "Show Detail Content", sender: self)
        //        print ("header view tapped")
        
        
    }
    
}


extension SuperDataViewController {
    
    // MARK: - load IAP products and update UI.
    fileprivate func loadProducts(isCalledFromReceiptValidation: Bool) {
        // MARK: only be executed when data object type is iap
        guard let dataObjectType = dataObject["type"],
            dataObjectType == "iap" else {
                print ("loadProducts() should only be executed when data object type is iap! ")
                return
        }
        IAPs.shared.products = []
        IAPProducts.store.requestProducts{[weak self] success, products in
            if success {
                if let products = products {
                    //self?.products = products
                    IAPs.shared.products = products
                    // MARK: - Use isCalledFromReceiptValidation to avoid a infinite call loop.
                    if isCalledFromReceiptValidation == false {
                        ReceiptHelper.receiptValidation(with: APIs.getiOSReceiptValidationUrlString())
                    }
                }
            }
            // MARK: - Get product regardless of the request result
            //print ("product loaded: \(String(describing: IAPs.shared.products))")
            let dataObjectSubType = self?.dataObject["subtype"] ?? "membership"
            let purchaseStatus: PurchaseStatus
            if let include = self?.dataObject["include"] {
                if include == "purchased" {
                    purchaseStatus = .Purchased
                } else if include == "notpurchased" {
                    purchaseStatus = .NotPurchased
                } else {
                    purchaseStatus = .All
                }
            } else {
                purchaseStatus = .All
            }
            var items = IAP.get(IAPs.shared.products, in: dataObjectSubType, with: self?.withPrivilege, include: purchaseStatus)
            if items.count == 0 {
                items = IAP.get(IAPs.shared.products, in: dataObjectSubType, with: self?.withPrivilege, include: .All)
            }
            
            //print("IAP Product Display \(items.count) items. ")
            let contentSections = ContentSection(
                title: self?.privilegeDescriptionBody ?? "",
                items: items,
                type: "List",
                adid: ""
            )
            let finalContentSections: [ContentSection]
            if dataObjectSubType == "membership" {                
                var finePrintItems: [ContentItem] = []
                for item in IAPProducts.finePrintItems {
                    let oneItem = ContentItem(id: "", image: "", headline: item.headline, lead: item.lead, type: "fineprint", preferSponsorImage: "", tag: "", customLink: "", timeStamp: 0, section: 0, row: 0)
                    finePrintItems.append(oneItem)
                }
                let finePrints = ContentSection(
                    title: "订阅说明与注意事项",
                    items: finePrintItems,
                    type: "List",
                    adid: ""
                )
                let links = ContentSection(
                    title: "更多服务与信息",
                    items: [
                        ContentItem(
                            id: "privacy",
                            image: "",
                            headline: "隐私声明",
                            lead: "",
                            type: "setting",
                            preferSponsorImage: "",
                            tag: "",
                            customLink: "",
                            timeStamp: 0,
                            section: 0,
                            row: 0),
                        ContentItem(
                            id: "user-term",
                            image: "",
                            headline: "用户协议",
                            lead: "",
                            type: "setting",
                            preferSponsorImage: "",
                            tag: "",
                            customLink: "",
                            timeStamp: 0,
                            section: 0,
                            row: 0),
                        ContentItem(
                            id: "feedback",
                            image: "",
                            headline: "反馈",
                            lead: "",
                            type: "setting",
                            preferSponsorImage: "",
                            tag: "",
                            customLink: "",
                            timeStamp: 0,
                            section: 0,
                            row: 0)
                    ],
                    type: "Group",
                    adid: nil
                )
                finalContentSections = [contentSections, finePrints, links]
            } else {
                finalContentSections = [contentSections]
            }
            let results = ContentFetchResults(apiUrl: "", fetchResults: finalContentSections)
            self?.updateUI(with: results)
        }
    }
    
    // MARK: - load IAP products and update UI
    fileprivate func loadProductsHTML(for type: String) {
        IAPs.shared.products = []
        IAPProducts.store.requestProducts{[weak self] success, products in
            if success {
                if let products = products {
                    IAPs.shared.products = products
                    
                    // MARK: - Save product price so that you can use when you launch next time if connection to app store is bad
                    IAP.savePriceInfo(products)
                    
                    // MARK: Update privilege from network
                    PrivilegeHelper.updateFromNetwork()
                }
            }
            // MARK: - Get product regardless of the request result
            
            // MARK: - Get only the type of products needed
            let jsCode = IAPProducts.updateHome(for: type)
            DispatchQueue.main.async {
                self?.webView?.evaluateJavaScript(jsCode) { (result, error) in
                    if result != nil {
                        print (result ?? "unprintable JS result")
                    }
                }
            }
        }
    }
    
    // MARK: Handle Subscription Related Actions
    @objc public func handlePurchaseNotification(_ notification: Notification) {
        // MARK: If the view controller is not an iap page, no need to update UI
        if dataObject["type"] != "iap" {
            return
        }
        if let notificationObject = notification.object as? [String: Any?]{
            // MARK: only user interface-related actions should be done here because the viewcontroller might not be active. 
            if let productID = notificationObject["id"] as? String,
                let actionType = notificationObject["actionType"] as? String {
                var newStatus = "new"
                for (_, product) in IAPs.shared.products.enumerated() {
                    guard product.productIdentifier == productID else { continue }
                    if ["buy success", "restore success"].contains(actionType) {
                        // MARK: If it's a buy or restore action, mark the item as success
                        newStatus = "success"
                    }
                    DispatchQueue.main.async {
                        self.switchUI(newStatus)
                    }
                }
            } else if let errorObject = notification.object as? [String : String?] {
                // MARK: - When there is an error
                if let productId = errorObject["id"]{
                    let errorMessage = (errorObject["error"] ?? "") ?? ""
                    let productIdForTracking = productId ?? ""
                    // MARK: - If user cancel buying, no need to pop out alert
                    if errorMessage == "usercancel" {
                        IAP.trackIAPActions("cancel buying", productId: productIdForTracking)
                    } else {
                        let alert = UIAlertController(title: "交易失败，您的钱还在口袋里", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
                        if let topViewController = UIApplication.topViewController() {
                            topViewController.present(alert, animated: true, completion: nil)
                        }
                        IAP.trackIAPActions("buy or restore error", productId: "\(productIdForTracking): \(errorMessage)")
                    }
                    // MARK: update the buy button
                    DispatchQueue.main.async(execute: {
                        self.switchUI("fail")
                    })
                }
            }
        } else {
            // MARK: When the transaction fail without any error message (NSError)
            let alert = UIAlertController(title: "交易失败，您的钱还在口袋里", message: "未知错误", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
            if let topViewController = UIApplication.topViewController() {
                topViewController.present(alert, animated: true, completion: nil)
            }
            DispatchQueue.main.async(execute: {
                self.switchUI("fail")
            })
            IAP.trackIAPActions("buy or restore error", productId: "")
        }
    }
    
    // MARK: Handle Subscription Related Actions
    @objc public func handleReceiptValidationNotification(_ notification: Notification) {
        print ("receipt notification received: \(notification)")
        // MARK: Only when data object type is iap
        if let dataObjectType = dataObject["type"],
            dataObjectType == "iap" {
            loadProducts(isCalledFromReceiptValidation: true)
        } else {
            print ("No need to update UI in the dataview controller as it is not a type iap data object. ")
        }
    }
    
    
    public func switchUI(_ actionType: String) {
        loadProducts(isCalledFromReceiptValidation: false)
    }
    
}

extension SuperDataViewController {
    
    // MARK: - load settings and update UI
    fileprivate func loadSettings() {
        let settingsPage:[ContentSection] // = Settings.page
        if Privilege.shared.exclusiveContent == true {
            settingsPage = Settings.subscriberContact + Settings.page
        } else {
            settingsPage = Settings.page
        }
        let contentSections = GB2Big5.convert(settingsPage)
        let results = ContentFetchResults(apiUrl: "", fetchResults: contentSections)
        //        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
        //        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        updateUI(with: results)
    }
    
    // MARK: load options and update UI
    fileprivate func loadOptions() {
        if let id = dataObject["id"] {
            let contentSections = GB2Big5.convert(Setting.getContentSections(id))
            let results = ContentFetchResults(apiUrl: "", fetchResults: contentSections)
            //            let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
            //            let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
            updateUI(with: results)
        }
    }
    
}

extension SuperDataViewController : UICollectionViewDelegateFlowLayout {
    
    func getSizeInfo() -> (sizeClass: UIUserInterfaceSizeClass, itemsPerRow: CGFloat) {
        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        let itemsPerRow: CGFloat
        let currentSizeClass: UIUserInterfaceSizeClass
        if horizontalClass != .regular || verticalCass != .regular {
            itemsPerRow = 1
            currentSizeClass = .compact
        } else {
            itemsPerRow = 3
            currentSizeClass = .regular
        }
        return (currentSizeClass, itemsPerRow)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeInfo = getSizeInfo()
        let itemsPerRow = sizeInfo.itemsPerRow
        let currentSizeClass = sizeInfo.sizeClass
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem: CGFloat
        let heightPerItem: CGFloat
        // MARK:
        let reuseIdentifier = getReuseIdentifierForCell(indexPath)
        if reuseIdentifier == "MembershipCell" {
            // MARK: Important setting to avoid header view of next section being displayed over the current cell.
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = widthPerItem * 4
        } else if reuseIdentifier == "SettingCell" || reuseIdentifier == "OptionCell" {
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = 44
        } else if reuseIdentifier == "BookCell" {
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = 160 + 14 + 14
        }  else if reuseIdentifier == "IconCell" {
            widthPerItem = availableWidth / 3
            heightPerItem = availableWidth / 3 + 60
        } else if indexPath.row == 0 && indexPath.section == 1{
            if currentSizeClass == .regular {
                widthPerItem = (availableWidth / itemsPerRow) * 2
                heightPerItem = widthPerItem * 0.618
            } else {
                widthPerItem = availableWidth
                heightPerItem = widthPerItem * 2
            }
        } else {
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = widthPerItem * 0.618
        }
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

// MARK: Handle links here
extension SuperDataViewController: WKNavigationDelegate {
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
extension SuperDataViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "items" {
            fetches = ContentFetchResults(
                apiUrl: "",
                fetchResults: contentAPI.formatJSON(message.body)
            )
            prefetch()
            // MARK: Extract Adid
            // print ("message body is: \(message.body)")
            if let body = message.body as? [String: Any],
                let meta = body["meta"] as? [String: String] {
                if let adId = meta["adid"] {
                    adchId = adId
                }
                if let title = meta["title"] {
                    // MARK: - Set the navigation title to the page title, if applicable
                    navigationItem.title = title
                }
            }
        } else if message.name == "sponsors" {
            // MARK: Get sponsor information
            if let body = message.body as? [[String: String]] {
                var sponsors = [Sponsor]()
                for item in body {
                    let sponsor = Sponsor(
                        tag: item["tag"] ?? "",
                        title: item["title"] ?? "",
                        adid: item["adid"] ?? "",
                        channel: item["channel"] ?? "",
                        hideAd: item["hideAd"]
                    )
                    sponsors.append(sponsor)
                }
                if sponsors.count > 0 {
                    Sponsors.shared.sponsors = sponsors
                    //print ("adch id: update sponsors: \(sponsors)")
                }
            }
        } else if message.name == "user" {
            // MARK: Get user information
            if let body = message.body as? [String: String] {
                UserInfo.updateUserInfo(with: body)
                // MARK: - Update membership status
                PrivilegeHelper.updateFromDevice()
            }
        } else if message.name == "selectItem" {
            if let rowString = message.body as? String,
                let row = Int(rowString) {
                let indexPath = IndexPath(row: row, section: 0)
                _ = handleItemSelect(indexPath)
            } else {
                print ("item row is not an int: \(message.body)")
            }
        } else if message.name == "sharePageFromApp" {
            if let body = message.body as? [String: String],
                let urlString = body["url"] {
                    let title = body["title"] ?? ""
                let lead = body["lead"] ?? ""
                let imageUrl = body["image"] ?? ""
                let item = ContentItem(id: "", image: imageUrl, headline: title, lead: lead, type: "page", preferSponsorImage: "", tag: "", customLink: urlString, timeStamp: 0, section: 0, row: 0)
                if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                    rootViewController.launchActionSheet(for: item, from: self, with: .Default)
                }
            }
        } else if message.name == "card" {
            if let body = message.body as? [String: String] {
                if let cardType = body["cardType"] {
                    let originalCardStatus = UserInfo.shared.card
                    let newCardStatus: CardType
                    switch cardType {
                    case "red":
                        newCardStatus = .Red
                    case "yellow":
                        newCardStatus = .Yellow
                    default:
                        newCardStatus = .Clear
                    }
                    if originalCardStatus != newCardStatus {
                        UserInfo.shared.card = newCardStatus
                        PrivilegeHelper.updateFromDevice()
                    }
                }
            }
        } else if let body = message.body as? [String: String] {
            if message.name == "alert" {
                if let title = body["title"], let lead = body["message"] {
                    Alert.present(title, message: lead)
                }
            }
        }
    }
}


//extension DataViewController {
//    // MARK: - There's a bug on iOS 9 so that you can't set decelerationRate directly on webView
//    // MARK: - http://stackoverflow.com/questions/31369538/cannot-change-wkwebviews-scroll-rate-on-ios-9-beta
//    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
//    }
//}

// MARK: Search Related Functions. As FTC don't have a well-structured https search API yet, use web to render search.
extension SuperDataViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        searchKeywords = searchBar.text
    }
    
    fileprivate func search() {
        if let keywords = searchKeywords, keywords != "" {
            let jsCode = APIs.jsForSearch(keywords)
            webView?.evaluateJavaScript(jsCode) { (result, error) in
                if result != nil {
                    print (result ?? "unprintable JS result")
                }
            }
            searchBar?.resignFirstResponder()
            // MARK: Remember My Last Search Key Words
            let searchHistoryMaxLength = 10
            var searchHistory = UserDefaults.standard.array(forKey: Key.searchHistory) as? [String] ?? [String]()
            searchHistory = searchHistory.filter{
                $0 != keywords
            }
            searchHistory.insert(keywords, at: 0)
            var searchHistoryNew = [String]()
            for (index, value) in searchHistory.enumerated() {
                if index < searchHistoryMaxLength {
                    searchHistoryNew.append(value)
                }
            }
            UserDefaults.standard.set(searchHistoryNew, forKey: Key.searchHistory)
        }
    }
    
    fileprivate func getSearchHistoryHTML() -> String {
        let searchHistory = UserDefaults.standard.array(forKey: Key.searchHistory) as? [String] ?? [String]()
        var searchHistoryHTML = ""
        for (index, keyword) in searchHistory.enumerated() {
            let firstChildClass: String
            if index == 0 {
                firstChildClass = " first-child"
            } else {
                firstChildClass = ""
            }
            searchHistoryHTML += "<div onclick=\"search('\(keyword)')\" class=\"oneStory story\(firstChildClass)\"><div class=\"headline\">\(keyword)</div></div>"
        }
        if searchHistoryHTML != "" {
            searchHistoryHTML = "<a class=\"section\"><span>\(GB2Big5.convert("搜索历史"))</span></a>" + searchHistoryHTML
        } else {
            searchHistoryHTML = "<div class=\"oneStory story first-child\"><div class=\"headline\">\(GB2Big5.convert("输入关键字开始搜索"))</div></div>"
        }
        return searchHistoryHTML
    }
    
}

extension SuperDataViewController: CustomRefreshConrolDelegate {
    //MARK: Delegate Step 5: implement the methods in protocol. Make sure the class implement the delegate
    func refreshSuperDataView() {
        if dataViewRender == .webView {
            refreshWebView(refreshContr as Any)
        } else {
            refreshControlDidFire(sender: refreshContr as AnyObject)
        }
    }
}

// MARK: - Private
//private extension DataViewController {
//    func itemForIndexPath(indexPath: IndexPath) -> ContentItem {
//        return fetches[(indexPath as NSIndexPath).section].fetchResults[(indexPath as IndexPath).row]
//    }
//}

/*
 extension DataViewController {
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
 return true
 }
 
 override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
 return true
 }
 
 override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
 
 print ("performAction called! ")
 }
 
 }
 */

