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

// MARK: Delegate Step 1: Create Protocol. Follow the steps to learn how to use protocol and delegate. How to pass data from model to controller https://medium.com/ios-os-x-development/ios-three-ways-to-pass-data-from-model-to-controller-b47cc72a4336

protocol DetailModelDelegate: class {
    // MARK: When user panning to change page title, the navigation item title should change accordingly
    func didChangePage(_ item: ContentItem?, index: Int)
}


class DetailModelController: ModelController {
    // MARK: Delegate Step 2: initiate the delegate of protocol
    // MARK: The class keyword in the Swift protocol definition limits protocol adoption to class types (and not structures or enums). This is important if we want to use a weak reference to the delegate. We need be sure we do not create a retain cycle between the delegate and the delegating objects, so we use a weak reference to delegate (see below).
    weak var delegate: DetailModelDelegate?

    var pageData = [ContentItem]()
    var sourceDataObject = [String: String]()
    var currentPageIndex = 0
    var currentItem: ContentItem? = nil {
        didSet {
            // MARK: Delegate Step 3: let the delegate execute what's supposed to do
            delegate?.didChangePage(currentItem, index: currentPageIndex)
        }
    }
    
    init(tabName: String, pageData: [ContentItem]) {
        super.init()
        self.pageData = pageData
        updateThemeColor(for: tabName)
        pageTitles = pageData.map { (value: ContentItem) -> String in
            return value.headline
        }
        pageIds = pageData.map { (value: ContentItem) -> String in
            return "\(value.type)\(value.id)"
        }
    }
    
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> ContentItemViewController? {
        // Return the data view controller for the given index.
        //print ("Return the data view controller for \(index)")
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        // Create a new view controller and pass suitable data.
        let contentItemViewController = storyboard.instantiateViewController(withIdentifier: "ContentItemViewController") as! ContentItemViewController
        //print(dataViewController.view.frame)
        contentItemViewController.dataObject = self.pageData[index]
        contentItemViewController.sourceDataObject = self.sourceDataObject
        contentItemViewController.pageTitle = self.pageTitles[index]
        contentItemViewController.pageId = self.pageIds[index]
        contentItemViewController.themeColor = self.pageThemeColor
        return contentItemViewController
    }
    
    func indexOfViewController(_ viewController: ContentItemViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        if let currentPageIndex = pageIds.index(of: viewController.pageId) {
            // print ("index Of ViewController: \(currentPageIndex)")
            // TODO: Post a notification that the current page index is changed. And also make clear that it comes from user panning pages
            //currentPageTitle = pageTitles[currentPageIndex]
            self.currentPageIndex = currentPageIndex as Int
            currentItem = pageData[currentPageIndex]
            return currentPageIndex
        }
        return NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ContentItemViewController)
        //print ("preparing the prev page")
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ContentItemViewController)
        //print ("preparing the next page")
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

