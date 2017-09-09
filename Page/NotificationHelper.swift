//
//  NotificationHelper.swift
//  Page
//
//  Created by ZhangOliver on 2017/9/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit



struct NotificationHelper {
    static func handle(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        // if launched from a tap on a notification
        AppLaunch.sharedInstance.from = "notification"
        if let launchOptions = launchOptions {
            if let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                let action = userInfo["action"] as? String
                let id = userInfo["id"] as? String
                guard let aps = userInfo["aps"] as? NSDictionary else {
                    return
                }
                let title = (aps["alert"] as? NSDictionary)?["title"] as? String
                print ("notification title is \(String(describing: title))")
                //                if let rootViewController = self.window?.rootViewController as? ViewController {
                //                    rootViewController.openNotification(action, id: id, title: title)
                //                }
                if UIApplication.topViewController() != nil {
                    // MARK: If the top view controller is already there, for example, when the app is activated from background
                    open(action, id: id, title: title)
                } else {
                    // MARK: When an app is launched rather than awakened, should wait for several seconds before topViewController is not nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000)) {
                        open(action, id: id, title: title)
                    }
                }
            }
        }
    }
    
    static func handle(_ url: URL) {
        if let topController = UIApplication.topViewController() {
            // MARK: If the top view controller is already there, for example, when the app is activated from background
            topController.openLink(url)        } else {
            // MARK: When an app is launched rather than awakened, should wait for several seconds before topViewController is not nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000)) {
                if let topController = UIApplication.topViewController() {
                    topController.openLink(url)
                }
            }
        }
    }
    
    
    // MARK: User tap on a remote notification. This should be public.
    public static func open(_ action: String?, id: String?, title: String?) {
        if let action = action,
            let id = id,
            let topController = UIApplication.topViewController() {
            switch(action) {
            case "tag":
                if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
                    dataViewController.dataObject = ["title": id,
                                                     "api": APIs.get(id, type: action),
                                                     "url":"",
                                                     "screenName":"tag/\(id)"]
                    dataViewController.pageTitle = id
                    topController.navigationController?.pushViewController(dataViewController, animated: true)
                    return
                }
            case "story", "video", "photo", "gym", "special":
                if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
                    detailViewController.contentPageData = [ContentItem(
                        id: id,
                        image: "",
                        headline: "",
                        lead: "",
                        type: action,
                        preferSponsorImage: "",
                        tag: "",
                        customLink: "",
                        timeStamp: 0,
                        section: 0,
                        row: 0)]
                    topController.navigationController?.pushViewController(detailViewController, animated: true)
                    return
                }
            case "page":
                if let url = URL(string: id) {
                    topController.openLink(url)
                    return
                }
            case "channel":
                if let url = URL(string: "http://www.ftchinese.com/channel/\(id).html") {
                    topController.openLink(url)
                    return
                }
            default:
                break
            }
            Track.event(category: "Tap Notification", action: action, label: "\(id): \(title ?? "")")
        }
    }
}
