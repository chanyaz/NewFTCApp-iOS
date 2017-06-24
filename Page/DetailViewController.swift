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
        
        //        let segment: UISegmentedControl = UISegmentedControl(items: ["First", "Second"])
        //        segment.sizeToFit()
        //        segment.tintColor = UIColor(red:0.99, green:0.00, blue:0.25, alpha:1.00)
        //        segment.selectedSegmentIndex = 0;
        //        segment.setTitleTextAttributes([NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)],
        //                                       for: UIControlState.normal)
        //        self.navigationItem.titleView = segment
        
        self.navigationItem.title = contentPageData[0].headline
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

}

extension DetailViewController: DetailModelDelegate {
    //MARK: Delegate Step 5: implement the methods in protocol. Make sure the class implement the delegate
    func didChangePage(_ title: String) {
        self.navigationItem.title = title
    }
}
