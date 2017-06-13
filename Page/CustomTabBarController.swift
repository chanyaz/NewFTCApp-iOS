//
//  ViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/7.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Customize Tab Bar Styles
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor(hex: AppNavigation.sharedInstance.normalTabFontColor)
        } else {
            // Fallback on earlier versions
        }
        //self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.green], for:.normal)
        self.tabBar.tintColor = UIColor(hex: AppNavigation.sharedInstance.highlightedTabFontColor)
        self.tabBar.barTintColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor))
        self.tabBar.shadowImage = UIImage.colorForNavBar(color: UIColor(hex: AppNavigation.sharedInstance.defaultBorderColor))
        self.tabBar.isTranslucent = false
        
        
//        if let items = tabBarController?.tabBar.items {
//            let tabBarImages = getTabBarImages() // tabBarImages: [UIImage]
//            for i in 0..<items.count {
//                let tabBarItem = items[i]
//                let tabBarImage = tabBarImages[i]
//                tabBarItem.image = tabBarImage.withRenderingMode(.alwaysOriginal)
//                tabBarItem.selectedImage = tabBarImage
//            }
//        }
        
        if let items = self.tabBar.items {
            let tabBarImages = getTabBarImages() // tabBarImages: [UIImage]
            for i in 0..<items.count {
                let tabBarItem = items[i]
                let tabBarImage = tabBarImages[i]
                tabBarItem.image = tabBarImage?.withRenderingMode(.alwaysOriginal)
                //tabBarItem.selectedImage = tabBarImage
                //tabBarItem.image = tabBarImage
            }
        }

    }
    
    
    func getTabBarImages() -> [UIImage?] {
        let imageNames = ["NewsDim", "EnglishDim", "AcademyDim", "VideoDim", "MyFTDim"]
        let images = imageNames.map { (value: String) -> UIImage? in
            return UIImage(named: value)
        }
        return images
    }
    
    
    
    
    // MARK: On mobile phone, lock the screen to portrait only
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.all
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override var shouldAutorotate : Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
    }
    
    
}
