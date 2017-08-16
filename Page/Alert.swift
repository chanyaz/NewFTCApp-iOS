//
//  Alert.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/16.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Alert {
    static func present(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.default, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
