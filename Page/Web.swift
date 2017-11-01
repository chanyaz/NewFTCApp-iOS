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
                    openDataView(id, of: type)
                    return
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
                        let urlString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
                        let adchId = Download.getQueryStringParameter(url: urlString, param: "adchannelID")
                        let contentItem = ContentItem(
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
                            row: 0)
                        contentItem.adchId = adchId
                        detailViewController.contentPageData = [contentItem]
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
            case "fileinbundle":
                if let fileName = url.host {
                    let title = url.lastPathComponent
                    openHTMLInBundle(
                        fileName,
                        title: title,
                        isFullScreen: true,
                        hidesBottomBar: true
                    )
                }
            case "itms-apps":
                // MARK: Link to App Store
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    UIApplication.shared.openURL(url)
                }
            case "buyproduct":
                // MARK: open the product page
                let productId = url.host
                let products = IAP.get(IAPs.shared.products, in: "ebook")
                for product in products {
                    if productId == product.id {
                        if let contentItemViewController = storyboard?.instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
                            contentItemViewController.dataObject = product
                            contentItemViewController.hidesBottomBarWhenPushed = true
                            navigationController?.isNavigationBarHidden = false
                            navigationController?.pushViewController(contentItemViewController, animated: true)
                        }
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    func openHTMLBook(_ fileLocation: String, productId: String) {
        print ("open html file from location: \(fileLocation)")
        //        if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
        //            detailViewController.contentPageData = [ContentItem(
        //                id: fileLocation,
        //                image: "",
        //                headline: "",
        //                lead: "",
        //                type: "htmlfile",
        //                preferSponsorImage: "",
        //                tag: "",
        //                customLink: "",
        //                timeStamp: 0,
        //                section: 0,
        //                row: 0)]
        //            detailViewController.showBottomBar = false
        //            self.navigationController?.pushViewController(detailViewController, animated: true)
        //            return
        //        }
        if let contentItemViewController = storyboard?.instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
            //print(dataViewController.view.frame)
            contentItemViewController.dataObject = ContentItem(
                id: fileLocation,
                image: "",
                headline: productId,
                lead: "",
                type: "htmlbook",
                preferSponsorImage: "",
                tag: "",
                customLink: "",
                timeStamp: 0,
                section: 0,
                row: 0)
            contentItemViewController.pageTitle = "FT电子书"
            contentItemViewController.isFullScreen = true
            contentItemViewController.hidesBottomBarWhenPushed = true
            //contentItemViewController.themeColor = self.pageThemeColor
            navigationController?.pushViewController(contentItemViewController, animated: true)
        }
    }
    
    
    func openHTMLInBundle(_ fileName: String, title: String, isFullScreen: Bool, hidesBottomBar: Bool) {
        if let contentItemViewController = storyboard?.instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
            //print(dataViewController.view.frame)
            contentItemViewController.dataObject = ContentItem(
                id: fileName,
                image: "",
                headline: "",
                lead: "",
                type: "html",
                preferSponsorImage: "",
                tag: "",
                customLink: "",
                timeStamp: 0,
                section: 0,
                row: 0)
            contentItemViewController.pageTitle = title
            contentItemViewController.isFullScreen = isFullScreen
            contentItemViewController.hidesBottomBarWhenPushed = hidesBottomBar
            contentItemViewController.navigationItem.title = title
            navigationController?.pushViewController(contentItemViewController, animated: true)
            
        }
    }
    
    
    func openDataView(_ id: String?, of type: String) {
        if let id = id,
            let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
            let listAPI = APIs.convert("https://danla2f5eudt1.cloudfront.net/tag/\(id.addUrlEncoding())?webview=ftcapp&bodyonly=yes&001")
            let urlString = APIs.convert("http://www.ftchinese.com/tag/\(id)")
            dataViewController.dataObject = [
                "title": id,
                //"api": APIs.get(id, type: type),
                "listapi": listAPI,
                "url": urlString,
                "screenName":"\(type)/\(id)"
            ]
            dataViewController.pageTitle = id
            self.navigationController?.pushViewController(dataViewController, animated: true)
        }
    }
}
