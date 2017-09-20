//
//  Web.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/27.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import SafariServices
import StoreKit

extension UIViewController: SFSafariViewControllerDelegate{
    // MARK: Handle All the Recogizable Links Here
    func openLink(_ url: URL) {
        if let urlScheme = url.scheme {
            switch urlScheme {
            case "http", "https":
                let webVC = SFSafariViewController(url: url)
                webVC.delegate = self
                let urlString = url.absoluteString
                var id: String? = nil
                var type: String? = nil
                // MARK: If the link pattern is recognizable, open it using native method
                if let contentId = urlString.matchingStrings(regexes: LinkPattern.story) {
                    id = contentId
                    type = "story"
                } else if let contentId = urlString.matchingStrings(regexes: LinkPattern.video) {
                    id = contentId
                    type = "video"
                } else if let contentId = urlString.matchingStrings(regexes: LinkPattern.interactive) {
                    id = contentId
                    type = "interactive"
                } else if let contentId = urlString.matchingStrings(regexes: LinkPattern.tag) {
                    id = contentId
                    type = "tag"
                } else if urlString.matchingStrings(regexes: LinkPattern.other) != nil {
                    id = urlString
                    type = "webpage"
                }
                if let type = type, type == "tag" {
                    if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
                        if let id = id {
                            dataViewController.dataObject = ["title": id,
                                                             "api": APIs.get(id, type: type),
                                                             "url":"",
                                                             "screenName":"tag/\(id)"]
                            dataViewController.pageTitle = id
                            self.navigationController?.pushViewController(dataViewController, animated: true)
                            return
                        }
                    }
                }
                if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
                    if let id = id,
                        let type = type {
                        let customLink: String
                        if type == "webpage" {
                            customLink = id
                        } else {
                            customLink = ""
                        }
                        detailViewController.contentPageData = [ContentItem(
                            id: id,
                            image: "",
                            headline: "",
                            lead: "",
                            type: type,
                            preferSponsorImage: "",
                            tag: "",
                            customLink: customLink,
                            timeStamp: 0,
                            section: 0,
                            row: 0)]
                        self.navigationController?.pushViewController(detailViewController, animated: true)
                        return
                    }
                }
                self.present(webVC, animated: true, completion: nil)
            case "ftcregister":
                print ("register page")
                let item = ContentItem(
                    id: "register",
                    image: "",
                    headline: "",
                    lead: "",
                    type: "register",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0
                )
                if let contentItemViewController = storyboard?.instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
                    contentItemViewController.dataObject = item
                    contentItemViewController.pageTitle = item.headline
                    contentItemViewController.isFullScreen = true
                    contentItemViewController.subType = .UserComments
                    navigationController?.pushViewController(contentItemViewController, animated: true)
                }
            case "weixinlogin":
                let req = SendAuthReq()
                req.scope = "snsapi_userinfo"
                req.state = "weliveinfinancialtimes"
                WXApi.send(req)
            case "ftchinese":
                // MARK: Handle tapping from today extension
                let action = url.host
                let id = url.lastPathComponent
                NotificationHelper.open(action, id: id, title: "title")
            case "itms-apps":
                // MARK: Link to App Store
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    UIApplication.shared.openURL(url)
                }
            default:
                break
            }
        }
    }
}
