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
            deviceType = "iPhone"
        }
        return deviceType
    }
    
//    public static func checkSafeAreaTop() {
//        // MARK: Get the safe area top so that full screen launch ad can display close button in the right place
//        if #available(iOS 11.0, *) {
//
//            if let safeAreaTop = window?.safeAreaInsets.top{
//                DeviceStyle.shared.safeAreaTop = safeAreaTop
//                print ("Safe Area Top is Now \(safeAreaTop)")
//            }
//        }
//    }
}

struct DeviceStyle {
    static var shared = DeviceStyle()
    var safeAreaTop: CGFloat = 0
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
