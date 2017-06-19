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
    var pageData:[[String : String]] = []
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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

