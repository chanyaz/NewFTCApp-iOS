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
    
    override var prefersStatusBarHidden : Bool {
        if AppLaunch.sharedInstance.fullScreenDismissed == false {
            return true
        } else {
            return false
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
        // MARK: Set up nativation title
        if let currentTabName = tabName {
            let tabTitle = AppNavigation.getNavigationProperty(for: currentTabName, of: "title")
            if let tabTitleImage = AppNavigation.getNavigationProperty(for: currentTabName, of: "title-image") {
                if let image = UIImage(named: tabTitleImage) {
                    let width: CGFloat = 124
                    let height: CGFloat = 26
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    imageView.contentMode = .center
                    imageView.image = image
                    navigationItem.titleView = imageView
                }
            } else {
                navigationItem.title = GB2Big5.convert(tabTitle ?? "")
            }
            if let navTintColor = AppNavigation.getNavigationProperty(for: currentTabName, of: "navBackGroundColor") {
                navigationController?.navigationBar.barTintColor = UIColor(hex: navTintColor)
                navigationController?.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor(hex: navTintColor)), for: .default)
            }
            if let navBorderColor = AppNavigation.getNavigationProperty(for: currentTabName, of: "navBorderColor"),
                let navBorderWidth = AppNavigation.getNavigationProperty(for: currentTabName, of: "navBorderWidth")
            {
                let borderColor = UIColor(hex: navBorderColor)
                let thickness: CGFloat
                if let doubleValue = Double(navBorderWidth) {
                    thickness = CGFloat(doubleValue)
                } else {
                    thickness = 0
                }
                navigationController?.navigationBar.layer.addBorder(edge: .bottom, color: borderColor, thickness: thickness)
            }
            
            if let navColor = AppNavigation.getNavigationProperty(for: currentTabName, of: "navColor") {
                navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: navColor)]
                navigationController?.navigationBar.tintColor = UIColor(hex: navColor)
            }
            navigationController?.navigationBar.isTranslucent = false
        }
        self.view.backgroundColor = UIColor(hex: Color.Content.background)
    }
}

