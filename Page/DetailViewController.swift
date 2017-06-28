//
//  DetailViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class DetailViewController: PagesViewController, UINavigationControllerDelegate {

    var contentPageData = [ContentItem]()
    
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
        let startingViewController: ContentItemViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        self.pageViewController!.dataSource = self.modelController
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParentViewController: self)
        
        // MARK: - Set the navigation item title as an empty string.
        self.navigationItem.title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

}

extension DetailViewController: DetailModelDelegate {
    //MARK: Delegate Step 5: implement the methods in protocol. Make sure the class implement the delegate
    func didChangePage(_ item: ContentItem?) {
        // TODO: There might not be enough space for story title. Consider doing some other things when page is changed
        //self.navigationItem.title = title
        print ("should do something to update item information in view controller")
    }
}
