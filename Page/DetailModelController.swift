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


class DetailModelController: ModelController {
    var pageData = [ContentItem]()
    var currentPageTitle: String? = nil {
        didSet {
            print ("current page title: \(String(describing: currentPageTitle))")
        }
    }
    
    init(tabName: String, pageData: [ContentItem]) {
        super.init()
        self.pageData = pageData
        updateThemeColor(for: tabName)
        self.pageTitles = pageData.map { (value: ContentItem) -> String in
            return value.headline
        }
        self.currentPageTitle = self.pageTitles[0]
    }
    
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> ContentItemViewController? {
        // Return the data view controller for the given index.
        print ("Return the data view controller for \(index)")
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        // Create a new view controller and pass suitable data.
        let contentItemViewController = storyboard.instantiateViewController(withIdentifier: "ContentItemViewController") as! ContentItemViewController
        //print(dataViewController.view.frame)
        contentItemViewController.dataObject = self.pageData[index]
        contentItemViewController.pageTitle = self.pageTitles[index]
        contentItemViewController.themeColor = self.pageThemeColor
        return contentItemViewController
    }
    
    func indexOfViewController(_ viewController: ContentItemViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        if let currentPageIndex = pageTitles.index(of: viewController.pageTitle) {
            print ("index Of ViewController: \(currentPageIndex)")
            // TODO: Post a notification that the current page index is changed. And also make clear that it comes from user panning pages
            currentPageTitle = pageTitles[currentPageIndex]
            return currentPageIndex
        }
        return NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ContentItemViewController)
        print ("preparing the prev page")
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ContentItemViewController)
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

