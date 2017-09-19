//
//  DeviceInfo.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

struct DeviceInfo {
    public static func checkDeviceType() -> String {
        let deviceType: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceType = "iPad"
        } else {
            deviceType  = "iPhone"
        }
        return deviceType
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        // MARK: If a PagesViewController is returned, get its top view controller
        if let pagesViewController = controller as? PagesViewController,
            let pageViewControllers = pagesViewController.pageViewController?.viewControllers,
            pageViewControllers.count > 0 {
            let currentViewController = pageViewControllers[0]
            return currentViewController
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension Date {
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: self)
        return dateString
    }
}
