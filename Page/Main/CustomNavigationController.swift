//
//  CustomNavigationController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/7.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit



class CustomNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var tabName: String? = nil
    var isLightContent = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        updateColorScheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Notification For English Status Change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nightModeChanged),
            name: Notification.Name(rawValue: Event.nightModeChanged),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.nightModeChanged), object: nil)
    }
    
    @objc public func nightModeChanged() {
        updateColorScheme()
    }
    
    func updateColorScheme() {
        tabBarController?.tabBar.tintColor = AppNavigation.getThemeColor(for: tabName)
    }
    
    // MARK: - This has to be here, otherwise it won't work on iPhone X
    // MARK: - https://forums.developer.apple.com/thread/88962
    override var prefersStatusBarHidden: Bool {
        if AppLaunch.sharedInstance.fullScreenDismissed == false {
            return true
        } else {
            return false
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let currentTabName = tabName {
            isLightContent = AppNavigation.isNavigationPropertyTrue(for: currentTabName, of: "isNavLightContent")
            let isNightMode = Setting.isSwitchOn("night-reading-mode")
            if isLightContent == true || isNightMode == true {
                return UIStatusBarStyle.lightContent
            }
        }
        return UIStatusBarStyle.default
    }
    
}


