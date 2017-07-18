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
    
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var languageSwitch: UISegmentedControl!
    @IBOutlet weak var bookMark: UIBarButtonItem!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBAction func actionSheet(_ sender: Any) {
        let item = contentPageData[currentPageIndex]
        self.launchActionSheet(for: item)
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
            }
        }
        return _modelController!
    }
    
    var _modelController: DetailModelController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Delegate Step 4: Set the delegate to self
        modelController.delegate = self
        
        // MARK: Set up pages for the content detail view
        // TODO: Add the bottom bar here instead of in the
        
        // MARK: - Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let bottomBarHeight = toolBar.frame.height + 1
        let fullPageViewRect = self.view.bounds
        let pageViewRect = CGRect(x: 0, y: 0, width: fullPageViewRect.width, height: fullPageViewRect.height - bottomBarHeight)
        self.pageViewController!.view.frame = pageViewRect
        
        let startingViewController: ContentItemViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        self.pageViewController!.dataSource = self.modelController
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParentViewController: self)
        
        // MARK: - Set the navigation item title as an empty string.
        self.navigationItem.title = ""
        
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = actionButton
        
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
    
    public func share() {
//        print ("share")
//        let itemToShare = contentPageData[currentPageIndex]
//        print ("share the item: \(itemToShare.headline), id: \(itemToShare.id)")
//        let share = ShareHelper()
//        let url = share.getUrl("iosaction://?title=OliverTest&url=http://www.ft.com&description=daf&img=http://www.ft.ocm")
//        share.popupActionSheet(self as UIViewController, url: url)
        let item = contentPageData[currentPageIndex]
        self.launchActionSheet(for: item)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initStyle() {
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
        
        
        //        self.view.backgroundColor = UIColor.clear
        //        self.view.isOpaque = false
        
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
        print ("current item is \(String(describing: item?.headline))")
    }
}
