//
//  RootViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/5/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

// MARK: - PagesViewContoller is a horizonal pages layout which supports panning from page to page. This is commonly seen in channel page and story page.
class PagesViewController: UIViewController, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController?
    
    var tabName: String? {
        get {
            if let k = navigationController as? CustomNavigationController {
                return k.tabName
            }
            return nil
        }
        set {
            // Do Nothing
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        applyStyles()
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParentViewController: self)
        // MARK: To avoid pageview controller behind the navigation and bottom bar, just uncheck Under Top Bars for both: UIPageViewController and your custom PageContentViewController: https://stackoverflow.com/questions/18202475/content-pushed-down-in-a-uipageviewcontroller-with-uinavigationcontroller
        // self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        
        if _modelController == nil {
            if let t = tabName {
                _modelController = ModelController(tabName: t)
            }
        }
        return _modelController!
    }
    
    var _modelController: ModelController? = nil
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
            self.pageViewController!.isDoubleSided = false
            return .min
    }
    
    func applyStyles() {
        if let currentTabName = tabName {
            let tabTitle = AppNavigation.sharedInstance.getNavigationProperty(for: currentTabName, of: "title")
            self.navigationItem.title = tabTitle
            if let navTintColor = AppNavigation.sharedInstance.getNavigationProperty(for: currentTabName, of: "navBackGroundColor") {
                navigationController?.navigationBar.barTintColor = UIColor(hex: navTintColor)
            }
            if let navColor = AppNavigation.sharedInstance.getNavigationProperty(for: currentTabName, of: "navColor") {
                navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: navColor)]
                navigationController?.navigationBar.tintColor = UIColor(hex: navColor)
            }
            
            navigationController?.navigationBar.isTranslucent = false
        }
        self.view.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
    }

    
}

