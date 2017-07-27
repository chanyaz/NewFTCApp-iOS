//
//  Web.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/27.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import SafariServices

extension UIViewController: SFSafariViewControllerDelegate{
    func openLink(_ url: URL) {
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        if let topController = UIApplication.topViewController() {
            topController.present(webVC, animated: true, completion: nil)
        }
    }
}

