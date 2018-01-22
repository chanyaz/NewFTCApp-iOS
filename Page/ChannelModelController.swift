//
//  ChannelModelController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/19.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//
import UIKit
import Foundation
class ChannelModelController: ModelController{
    var pageData = [[String: String]]()
    //weak var delegate: ChannelModelDelegate?
    // MARK: - If it's a channel view
    init(tabName: String) {
        super.init()
        // Create the data model
        if let p = AppNavigation.getNavigationPropertyData(for: tabName, of: "Channels" ) {
            pageData = p
        }

        updateThemeColor(for: tabName)
        pageTitles = pageData.map { (value: [String: String]) -> String in
            return value["title"] ?? ""
        }
        coverThemes = pageData.map { (value: [String: String]) -> String? in
            return value["coverTheme"]
        }
        //print ("coverThemes is \(coverThemes)")
        self.tabName = tabName
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        print ("Return the data view controller for \(index)")
        // print (pageData)
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        // Create a new view controller and pass suitable data.
        if let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
            //print(dataViewController.view.frame)
            dataViewController.dataObject = self.pageData[index]
            dataViewController.pageTitle = self.pageTitles[index]
            dataViewController.coverTheme = self.coverThemes[index]
            dataViewController.themeColor = self.pageThemeColor
            dataViewController.pageIndex = index
            return dataViewController
        }
        return nil
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        if let currentPageIndex = pageTitles.index(of: viewController.pageTitle) {
            print ("index Of ViewController: \(currentPageIndex)")
            // MARK: In this case, notification is not the best way to pass data from model to controller. Use Delegate instead.
//            let pageInfoObject = (
//                index: currentPageIndex,
//                title: viewController.pageTitle
//            )
            //print ("should run delegate for panning to \(pageInfoObject.title)")
            //delegate?.pagePanningEnd(pageInfoObject)
            return currentPageIndex
        }
        return NSNotFound
    }
    
    
    // MARK: - Page View Controller Data Source
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        print ("preparing the prev page")
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
