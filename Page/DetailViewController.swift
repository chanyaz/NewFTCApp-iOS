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
    var themeColor: String?
    
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var bookMark: UIBarButtonItem!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBAction func actionSheet(_ sender: Any) {
        let item = contentPageData[currentPageIndex]
        self.launchActionSheet(for: item)
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
        if isSaved == false {
            Download.save(item, to: "clip", uplimit: 50, action: "save")
            isSaved = true
            saveButton.image = UIImage(named: "Delete")
        } else {
            Download.save(item, to: "clip", uplimit: 50, action: "delete")
            isSaved = false
            saveButton.image = UIImage(named: "Clip")
        }
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
        
        // MARK: Set up pages for the content detail view
        // TODO: Add the bottom bar here instead of in the
        
        // MARK: - Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        bottomBarHeight = toolBar.frame.height + 1
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
        
        //let audioButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(listen))
        let audioIcon = UIImage(named: "Audio")
        let audioButton = UIBarButtonItem(image: audioIcon, style: .plain, target: self, action: #selector(listen))
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
    
    @objc public func listen() {
        if let playSpeechViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaySpeech") as? PlaySpeech {
            // MARK: Prepare for speech body data
            let currentContentItemView = modelController.viewControllerAtIndex(currentPageIndex, storyboard: self.storyboard!)
            if let dataObject = currentContentItemView?.dataObject {
                let title: String
                let language: String
                let text: String
                let eventCategory = "Listen To Story"
                
                
                // TODO: Check if there's audio file attached to this item
                if let caudio = dataObject.caudio, caudio != "" {
                    print ("There is chinese audio: \(caudio) for this item, handle it later. ")
                }
                // TODO: Check if there's audio file attached to this item
                if let eaudio = dataObject.eaudio, eaudio != "" {
                    print ("There is english audio: \(eaudio) for this item, handle it later. ")
                }
                
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
                let body = [
                    "title": title,
                    "language": language,
                    "eventCategory": eventCategory,
                    "text": text,
                    "id": dataObject.id
                ]
                SpeechContent.sharedInstance.body = body
                navigationController?.pushViewController(playSpeechViewController, animated: true)
            }
        } else {
            print ("cannot play the speech")
        }
    }
    
    private var actualLanguageIndex = 0
    
    //MARK: This is only triggerd when user actual taps the UISegmentedControl
    @objc public func switchLanguage(_ sender: UISegmentedControl) {
        // MARK: Save Language Preference
        let languageIndex = sender.selectedSegmentIndex
        UserDefaults.standard.set(languageIndex, forKey: Key.languagePreference)
        print ("language is switched manually to \(languageIndex)")
        // MARK: Posting a notification is the best way to update content as there might be more than one ContentItemController that needs to update display
        let object = languageIndex
        let name = Notification.Name(rawValue: Event.languagePreferenceChanged)
        NotificationCenter.default.post(name: name, object: object)
        
    }
    
    @objc public func updateEnglishStatus() {
        //print ("English Status Change Received: \(English.sharedInstance.has)")
        let id = contentPageData[currentPageIndex].id
        let type = contentPageData[currentPageIndex].type
        //print ("English shared instance is now: \(English.sharedInstance)")
        if type == "story", let hasEnglish = English.sharedInstance.has[id], hasEnglish == true {
            print ("Language: current view should display English Switch")
            languages?.isHidden = false
            actualLanguageIndex = UserDefaults.standard.integer(forKey: Key.languagePreference)
        } else {
            print ("Language: current view should hide English Switch")
            languages?.isHidden = true
            actualLanguageIndex = 0
        }
        languages?.selectedSegmentIndex = actualLanguageIndex
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initStyle() {
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
        } else {
            languages?.backgroundColor = UIColor(hex: Color.Content.background)
            languages?.tintColor = buttonTint
        }
        
        // MARK: Set style for the bottom buttons
        actionButton.tintColor = buttonTint
        bookMark.tintColor = buttonTint
        saveButton.tintColor = buttonTint
        fontButton.tintColor = buttonTint
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
    
    
    /*
     // TODO: - For now, our mastery of iOS is not enough for us to come up with the proper code to let users pop the current view by swiping from anywhere in the screen, not just from the edge of the screen. It's totally achievable though, as can be seen in countless other apps.
     // MARK: - https://stackoverflow.com/questions/28949537/uipageviewcontroller-detecting-pan-gestures
     // MARK: Test custom popping
     var interactivePopTransition: UIPercentDrivenInteractiveTransition!
     
     
     
     func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
     print ("the operation is \(operation)")
     if (operation == .pop) {
     print ("the operation is pop")
     return CustomPopTransition()
     } else {
     print ("the operation is not pop")
     return nil
     }
     }
     
     func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
     print ("check the animationController type")
     if animationController is CustomPopTransition {
     print ("animationController is custom pop transition")
     return interactivePopTransition
     } else {
     print ("animationController is not custom pop transition")
     return nil
     }
     }
     
     
     
     
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
     
     return true
     }
     
     
     func handler(_ recognizer: UIPanGestureRecognizer) {
     var progress = recognizer.translation(in: self.view).x / self.view.bounds.size.width
     progress = min(1, max(0, progress))
     
     print ("currentPageIndex is \(currentPageIndex)")
     // MARK: if user is in the first story page, enable swipe back function
     if currentPageIndex == 0 && recognizer.state == .ended && progress > 0.5 {
     self.navigationController?.popViewController(animated: true)
     }
     
     //        if (recognizer.state == .began) {
     //            // Create a interactive transition and pop the view controller
     //
     //            print ("current recognizer state is .began")
     //            return
     //                self.interactivePopTransition = UIPercentDrivenInteractiveTransition()
     //            self.navigationController?.popViewController(animated: true)
     //        } else if (recognizer.state == .changed) {
     //            // Update the interactive transition's progress
     //            print ("current recognizer state is .changed")
     //            return
     //                interactivePopTransition.update(progress)
     //        } else if (recognizer.state == .ended || recognizer.state == .cancelled) {
     //            // Finish or cancel the interactive transition
     //            print ("current recognizer state is .ended or .cancelled")
     //            return
     //
     //            if (progress > 0.5) {
     //                interactivePopTransition.finish()
     //            }
     //            else {
     //                interactivePopTransition.cancel()
     //            }
     //            interactivePopTransition = nil
     //        }
     }
     
     // MARK: test custom popping end
     
     */
    
}

extension DetailViewController: DetailModelDelegate {
    //MARK: Delegate Step 5: implement the methods in protocol. Make sure the class implement the delegate
    func didChangePage(_ item: ContentItem?, index: Int) {
        // TODO: There might not be enough space for story title. Consider doing some other things when page is changed
        //self.navigationItem.title = title
        currentPageIndex = index
        print ("DetailModelDelegate: current item \(index): \(String(describing: item?.headline))")
        if item?.type == "ad" {
            navigationController?.setNavigationBarHidden(true, animated: true)
            toolBar.isHidden = true
            isFullScreenAdOn = true
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            toolBar.isHidden = false
            isFullScreenAdOn = false
        }
        checkSaveButton()
        // MARK: Ask the view controller to hide or show status bar
        setNeedsStatusBarAppearanceUpdate()
    }
}
