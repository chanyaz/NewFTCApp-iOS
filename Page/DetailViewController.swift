//
//  DetailViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class DetailViewController: PagesViewController, UINavigationControllerDelegate/*, UIGestureRecognizerDelegate*/ {
    
    var contentPageData = [ContentItem]()
    var currentPageIndex = 0
    var languages: UISegmentedControl?
    var audioButton: UIBarButtonItem?
    var themeColor: String?
    
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var bookMark: UIBarButtonItem!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBAction func actionSheet(_ sender: Any) {
        let item = contentPageData[currentPageIndex]
        //launchActionSheet(for: item, from: sender)
        launchShareAction(for: item, from: sender)
    }
    
    @IBAction func launchComment(_ sender: Any) {
        let item = contentPageData[currentPageIndex]
        if let contentItemViewController = storyboard?.instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
            //print(dataViewController.view.frame)
            contentItemViewController.dataObject = item
            contentItemViewController.pageTitle = item.headline
            contentItemViewController.isFullScreen = true
            contentItemViewController.subType = .UserComments
            //contentItemViewController.themeColor = self.pageThemeColor
            navigationController?.pushViewController(contentItemViewController, animated: true)
        }
    }
    fileprivate var isSaved = false
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func save(_ sender: Any) {
        let item = contentPageData[currentPageIndex]
        let action: String
        if isSaved == false {
            isSaved = true
            saveButton.image = UIImage(named: "Delete")
            action = "save"
        } else {
            isSaved = false
            saveButton.image = UIImage(named: "Clip")
            action = "delete"
        }
        Download.save(item, to: "clip", uplimit: 50, action: action)
        // MARK: Sync to the server
        if let viewControllers = pageViewController?.viewControllers {
            for viewController in viewControllers {
                if let currentContentItemView = viewController as? ContentItemViewController,
                    currentContentItemView.dataObject?.id == item.id,
                    let jsCode = APIs.clip(item.id, type: item.type, action: action),
                    let webView = currentContentItemView.webView {
                    webView.evaluateJavaScript(jsCode) { (result, error) in
                        if result != nil {
                            print (result ?? "unprintable JS result")
                        }
                    }
                    break
                }
            }
        }
        
        
        //            getDataFromUrl(url) {(data, response, error)  in
        //                if error == nil,
        //                    let data = data,
        //                    let returnedString = String(data: data, encoding: .utf8){
        //                    print ("return string: \(returnedString)")
        //                    print ("\(type)/\(id): \(action) done! ")
        //                    Track.event(category: "\(action) \(type)", action: "Success", label: id)
        //                    return
        //                }
        //                print ("\(type)/\(id): \(action) failed! ")
        //                Track.event(category: "\(action) \(type)", action: "Fail", label: id)
        //            }
    }
    
    @IBOutlet weak var fontButton: UIBarButtonItem!
    
    
    @IBAction func openSetting(_ sender: UIBarButtonItem) {
        if let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
            let topController = UIApplication.topViewController() {
            //                contentItemViewController.dataObject = itemCell
            //                contentItemViewController.hidesBottomBarWhenPushed = true
            //                contentItemViewController.themeColor = themeColor
            //                contentItemViewController.action = "buy"
            settingsController.dataObject = [
                "type": "setting",
                "id": "setting",
                "compactLayout": "",
                "title": "设置"
            ]
            settingsController.pageTitle = "设置"
            topController.navigationController?.pushViewController(settingsController, animated: true)
        }
        
    }
    
    var isFullScreenAdOn = false
    var showBottomBar = true
    
    override var prefersStatusBarHidden: Bool {
        if isFullScreenAdOn {
            return true
        } else {
            return false
        }
    }
    
    // @IBOutlet weak var bottomBar: UIToolbar!
    var modelController: DetailModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            if let t = tabName {
                print ("detail view get the tab name of \(t)")
                _modelController = DetailModelController(
                    tabName: t,
                    pageData: contentPageData
                )
                _modelController?.currentPageIndex = currentPageIndex
            }
        }
        return _modelController!
    }
    
    var _modelController: DetailModelController? = nil
    
    var bottomBarHeight: CGFloat?
    var fullPageViewRect: CGRect?
    
    
    fileprivate func setPageViewFrame() {
        if let fullPageViewRect = fullPageViewRect {
            let pageViewHeight: CGFloat
            pageViewHeight = fullPageViewRect.height
            let pageViewRect = CGRect(x: 0, y: 0, width: fullPageViewRect.width, height: pageViewHeight)
            self.pageViewController!.view.frame = pageViewRect
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Delegate Step 4: Set the delegate to self
        modelController.delegate = self
        
        // MARK: - Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        if showBottomBar == true {
            bottomBarHeight = toolBar.frame.height + 1
        } else {
            bottomBarHeight = 0
            toolBar.isHidden = true
        }
        fullPageViewRect = self.view.bounds
        setPageViewFrame()
        let startingViewController: ContentItemViewController = self.modelController.viewControllerAtIndex(currentPageIndex, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        self.pageViewController!.dataSource = self.modelController
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParentViewController: self)
        
        //toolBar.layer.zPosition = 1
        toolBar.superview?.bringSubview(toFront: toolBar)
        
        // MARK: - Set the navigation item title as an empty string.
        self.navigationItem.title = ""
        
        var audioIcon: UIImage?
        
        if Color.NavButton.isAudio {
            //let audioButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(listen))
            audioIcon = UIImage(named: "Audio")
            audioButton = UIBarButtonItem(image: audioIcon, style: .plain, target: self, action: #selector(listen))
        } else {
            audioIcon = UIImage(named: "Share")
            audioButton = UIBarButtonItem(image: audioIcon, style: .plain, target: self, action: #selector(actionSheet))
            navigationController?.setNavigationBarHidden(false, animated: false)
            toolBar.isHidden = true
        }
        self.navigationItem.rightBarButtonItem = audioButton
        
        // MARK: - Segmented Control
        let items = ["中文", "英文", "对照"]
        languages = UISegmentedControl(items: items)
        languages?.selectedSegmentIndex = 0
        
        // MARK: Add target action method
        languages?.addTarget(self, action: #selector(switchLanguage(_:)), for: .valueChanged)
        
        self.navigationItem.titleView = languages
        
        // Add this custom Segmented Control to our view
        //self.view.addSubview(customSC)
        
        
        updateEnglishStatus()
        
        // MARK: - Notification For English Status Change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateEnglishStatus),
            name: Notification.Name(rawValue: Event.englishStatusChange),
            object: nil
        )
        
        // MARK: - Notification For English Status Change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nightModeChanged),
            name: Notification.Name(rawValue: Event.nightModeChanged),
            object: nil
        )
        
        // MARK: - Color Scheme for the view
        initStyle()
        
        /*
         // MARK: - Delegate navigation controller to self
         navigationController?.delegate = self
         
         let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handler))
         gestureRecognizer.delegate = self
         view.addGestureRecognizer(gestureRecognizer)
         */
    }
    
    deinit {
        // MARK: - Notification For English Status Change
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.englishStatusChange), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.nightModeChanged), object: nil)
        print ("detail view controller removed! ")
    }
    
    @objc public func listen() {
        // MARK: Prepare for speech body data
        let currentContentItemView = modelController.viewControllerAtIndex(currentPageIndex, storyboard: self.storyboard!)
        if let dataObject = currentContentItemView?.dataObject {
            let title: String
            let language: String
            let text: String
            let eventCategory = "Listen To Story"

            // MARK: 0 means Chinese
            if actualLanguageIndex == 0 {
                title = dataObject.headline
                language = "ch"
                text = dataObject.cbody ?? ""
            } else {
                title = dataObject.eheadline ?? ""
                language = "en"
                text = dataObject.ebody ?? ""
            }
            
            let audioFileUrl: String?
            
            var audioLanguage: String? = nil
            var audioScreenName: String? = nil
            
            // MARK: Check if the user has the privilege for the content itself
            if let privilege = dataObject.privilegeRequirement {
                if !PrivilegeHelper.isPrivilegeIncluded(privilege, in: Privilege.shared) {
                    // MARK: Show an alert so that the user can buy
                    let alert = UIAlertController(title: "订阅用户专享内容", message: "您好，本内容是订户专享，请先完成订阅", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
                    if let topViewController = UIApplication.topViewController() {
                        topViewController.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                print ("User is allowed to listen to a premium content: \(dataObject.type)/\(dataObject.id)")
                // MARK: A subscriber is reading a piece of paid content
                let eventLabel = PrivilegeHelper.getLabel(prefix: privilege.rawValue, type: dataObject.type, id: dataObject.id, suffix: "")
                Track.eventToAll(category: "Privileges", action: "Listen", label: eventLabel)
            }
            
            // MARK: Check if there's audio file attached to this item
            if let caudio = dataObject.caudio,
                caudio != "",
                language == "ch"{
                print ("There is chinese audio: \(caudio) for this item, handle it later. ")
                //                    PlayerAPI.sharedInstance.getSingletonItem(item: dataObject)
                //                    PlayerAPI.sharedInstance.openPlay()
                audioFileUrl = caudio
                audioLanguage = "ch"
                audioScreenName = "audio/\(audioLanguage ?? "")/story/\(dataObject.id)"

                
            } else if let eaudio = dataObject.eaudio,
                eaudio != "",
                language == "en" || dataObject.type == "interactive" {
                print ("There is english audio: \(eaudio) for this item, handle it later. ")
                audioFileUrl = eaudio
                audioLanguage = "en"
                audioScreenName = "audio/\(audioLanguage ?? "")/\(dataObject.type)/\(dataObject.id)"
                // MARK: If the user doesn't have the necessary privilege to listen to English audio, present membership options to him
                // MARK: If a user bought the eBook, he should be able to listen to it without membership privilege
                if Privilege.shared.englishAudio == false && dataObject.isDownloaded == false {
                    // MARK: Only if membership subscription view is correctly displayed
                    let audioDataObject = ContentItem(id: dataObject.id, image: "", headline: dataObject.headline, lead: dataObject.lead, type: "EnglishAudio", preferSponsorImage: "", tag: dataObject.tag, customLink: "", timeStamp: 0, section: 0, row: 0)
                    if PrivilegeViewHelper.showSubscriptionView(for: .EnglishAudio, with: audioDataObject) {
                        return
                    }
                }
            } else {
                audioFileUrl = nil
            }
            
            if let audioFileUrl = audioFileUrl {
                if let audioPlayer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayer") as? AudioPlayer {
                    AudioContent.sharedInstance.body["title"] = title
                    AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                    AudioContent.sharedInstance.body["interactiveUrl"] = APIs.getUrl(dataObject.id, type: dataObject.type, isSecure: false, isPartial: false)
                    audioPlayer.item = dataObject
                    audioPlayer.themeColor = themeColor
                    audioPlayer.screenName = audioScreenName
                    audioPlayer.language = audioLanguage
                    navigationController?.pushViewController(audioPlayer, animated: true)
                }
            } else {
                let body = [
                    "title": title,
                    "language": language,
                    "eventCategory": eventCategory,
                    "text": text,
                    "id": dataObject.id
                ]
                SpeechContent.sharedInstance.body = body
                if let playSpeechViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaySpeech") as? PlaySpeech {
                    navigationController?.pushViewController(playSpeechViewController, animated: true)
                }
            }
            
        }
    }
    
    private var actualLanguageIndex = 0
    
    //MARK: This is only triggerd when user actual taps the UISegmentedControl
    @objc public func switchLanguage(_ sender: UISegmentedControl) {
        // MARK: Save Language Preference
        let languageIndex = sender.selectedSegmentIndex
        UserDefaults.standard.set(languageIndex, forKey: Key.languagePreference)
        actualLanguageIndex = languageIndex
        print ("language is switched manually to \(languageIndex)")
        // MARK: Posting a notification is the best way to update content as there might be more than one ContentItemController that needs to update display
        let object = languageIndex
        let name = Notification.Name(rawValue: Event.languagePreferenceChanged)
        NotificationCenter.default.post(name: name, object: object)
    }
    
    @objc public func updateEnglishStatus() {
        //print ("English Status Change Received: \(English.sharedInstance.has)")
        let item = contentPageData[currentPageIndex]
        let id = item.id
        let type = item.type
        //print ("English shared instance is now: \(English.sharedInstance)")
        if ["story", "premium"].contains(type),
            let hasEnglish = English.sharedInstance.has[id],
            hasEnglish == true {
            print ("Language: current view should display English Switch")
            languages?.isHidden = false
            actualLanguageIndex = UserDefaults.standard.integer(forKey: Key.languagePreference)
        } else {
            print ("Language: current view should hide English Switch")
            languages?.isHidden = true
            actualLanguageIndex = 0
        }
        languages?.selectedSegmentIndex = actualLanguageIndex
        
        // MARK: Update right nav button
        checkRightNavButton(item)
        
    }
    
    @objc public override func nightModeChanged() {
        super.nightModeChanged()
        updateColorScheme()        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateColorScheme() {
        let tabBackGround = UIColor(hex: Color.Tab.background)
        let buttonTint = UIColor(hex: Color.Button.tint)
        toolBar.backgroundColor = tabBackGround
        toolBar.barTintColor = tabBackGround
        toolBar.isTranslucent = false
        
        // MARK: Set style for the language switch
        var isLightContent = false
        
        if let nav = navigationController as? CustomNavigationController {
            isLightContent = nav.isLightContent
        }
        
        // Mark: Set themeColor based on whether it is lightcontent
        if let themeColor = themeColor,
            isLightContent == true {
            languages?.backgroundColor = UIColor(hex: themeColor)
            languages?.tintColor = UIColor(hex: Color.Content.background)
        } else if let navTintColor = navigationController?.navigationBar.barTintColor,
            isLightContent == true {
            languages?.backgroundColor = navTintColor
            languages?.tintColor = UIColor(hex: Color.Content.background)
        } else {
            languages?.backgroundColor = UIColor(hex: Color.Content.background)
            languages?.tintColor = buttonTint
        }
        
        // MARK: Set style for the bottom buttons
        actionButton.tintColor = buttonTint
        bookMark.tintColor = buttonTint
        saveButton.tintColor = buttonTint
        fontButton.tintColor = buttonTint
    }
    
    private func initStyle() {
        updateColorScheme()
        checkSaveButton()
    }
    
    fileprivate func checkSaveButton() {
        let item = contentPageData[currentPageIndex]
        let key = "Saved clip"
        let savedItems = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? [[String: String]]()
        for savedItem in savedItems {
            if item.id == savedItem["id"] && item.type == savedItem["type"] {
                isSaved = true
                break
            }
        }
        if isSaved == true {
            saveButton.image = UIImage(named: "Delete")
        } else {
            saveButton.image = UIImage(named: "Clip")
        }
    }
    
    fileprivate func checkRightNavButton(_ item: ContentItem?) {
        // MARK: Update Right Bar Button Item
        if let type = item?.type {
            if ["story", "premium"].contains(type) || (item?.eaudio != nil && item?.eaudio != "") {
                navigationItem.rightBarButtonItem = audioButton
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
}

extension DetailViewController: DetailModelDelegate {
    //MARK: Delegate Step 5: implement the methods in protocol. Make sure the class implement the delegate
    func didChangePage(_ item: ContentItem?, index: Int) {
        currentPageIndex = index
        //print ("DetailModelDelegate: current item \(index): \(String(describing: item?.headline))")
        
        if ToolBarStatus.shouldHide == true {
            navigationController?.setNavigationBarHidden(false, animated: true)
            toolBar.isHidden = true
        } else {
            if item?.type == "ad" {
                navigationController?.setNavigationBarHidden(true, animated: true)
                toolBar.isHidden = true
                isFullScreenAdOn = true
            } else {
                navigationController?.setNavigationBarHidden(false, animated: true)
                // MARK: If a user tapped from a page like Editor's Choice, bottom bar should be hidden, at least for now, so that he/she won't be able to share it.
                if showBottomBar == true {
                    toolBar.isHidden = false
                } else {
                    toolBar.isHidden = true
                }
                isFullScreenAdOn = false
            }
        }
        
        checkSaveButton()
        
        // MARK: Update right nav button
        checkRightNavButton(item)
        
        // MARK: Ask the view controller to hide or show status bar
        setNeedsStatusBarAppearanceUpdate()
    }
    
}
