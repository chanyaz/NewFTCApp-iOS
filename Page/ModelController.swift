//
//  ModelController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/5/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */



class ModelController: NSObject, UIPageViewControllerDataSource {
    var pageTitles: [String] = []
    var coverThemes: [String?] = []
    var pageThemeColor: String? = nil
    var tabName: String?
    

    func updateThemeColor(for tabName: String) {
        if let themeColor = AppNavigation.getNavigationProperty(for: tabName, of: "navBackGroundColor") {
            let isNavLightContent = AppNavigation.isNavigationPropertyTrue(for: tabName, of: "isNavLightContent")
            if isNavLightContent == true {
                pageThemeColor = themeColor
            } else {
                pageThemeColor = Color.Tab.highlightedText
            }
        }
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }

    

}

