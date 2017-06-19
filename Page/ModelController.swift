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
    var pageData = [[String: String]]()
    var pageTitles: [String] = []
    var pageThemeColor: String? = nil
    
    init(tabName: String) {
        super.init()
        // Create the data model
        if let p = AppNavigation.sharedInstance.getNavigationPropertyData(for: tabName, of: "Channels" ) {
            pageData = p
        }
        if let themeColor = AppNavigation.sharedInstance.getNavigationProperty(for: tabName, of: "navBackGroundColor") {
            let isNavLightContent = AppNavigation.sharedInstance.isNavigationPropertyTrue(for: tabName, of: "isNavLightContent")
            if isNavLightContent == true {
                pageThemeColor = themeColor
            } else {
                pageThemeColor = AppNavigation.sharedInstance.highlightedTabFontColor
            }
        }
        pageTitles = pageData.map { (value: [String: String]) -> String in
            return value["title"] ?? ""
        }
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        print ("Return the data view controller for \(index)")
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        //print(dataViewController.view.frame)
        dataViewController.dataObject = self.pageData[index]
        dataViewController.pageTitle = self.pageTitles[index]
        dataViewController.themeColor = self.pageThemeColor
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        if let currentPageIndex = pageTitles.index(of: viewController.pageTitle) {
            print ("index Of ViewController: \(currentPageIndex)")
            // TODO: Post a notification that the current page index is changed. And also make clear that it comes from user panning pages
            let pageInfoObject = (
                index: currentPageIndex,
                title: viewController.pageTitle
            )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppNavigation.sharedInstance.pagePanningEndNotification), object: pageInfoObject)
            
            return currentPageIndex
        }
        
        return NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        print ("preparing the prev page")
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        print ("preparing the next page")
        if index == NSNotFound {
            return nil
        }
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}

