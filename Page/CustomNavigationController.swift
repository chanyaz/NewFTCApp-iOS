//
//  CustomNavigationController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/7.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    var tabName: String? = nil
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if let currentTabName = tabName {
            if let tabBackGroundColor = AppNavigation.sharedInstance.getNavigationProperty(for: currentTabName, of: "navBackGroundColor") {
                let isNavLightContent = AppNavigation.sharedInstance.isNavigationPropertyTrue(for: currentTabName, of: "isNavLightContent")
                if isNavLightContent == true {
                    tabBarController?.tabBar.tintColor = UIColor(hex: tabBackGroundColor)
                } else {
                    tabBarController?.tabBar.tintColor = UIColor(hex: AppNavigation.sharedInstance.highlightedTabFontColor)
                }
            }
        }
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let currentTabName = tabName {
            let isLightContent = AppNavigation.sharedInstance.isNavigationPropertyTrue(for: currentTabName, of: "isNavLightContent")
            if isLightContent == true {
                return UIStatusBarStyle.lightContent
            }
        }
        return UIStatusBarStyle.default
    }
    
    
    
    
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //
    //        print ("seguage is called")
    ////        let tableVC = navVC?.viewControllers.first as! YourTableViewControllerClass
    ////
    ////        tableVC.yourTableViewArray = localArrayValue
    //
    //    }
    
    
}
