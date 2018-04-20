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

extension UIViewController: SFSafariViewControllerDelegate {
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
                if urlString.matchingStrings(regexes: LinkPattern.subscription) != nil,
                    let linkUrl = URL(string: "screen://\(IAPProducts.membershipScreenName)") {
                    openLink(linkUrl)
                    return
                } else if let contentId = urlString.matchingStrings(regexes: LinkPattern.image) {
                    id = contentId
                    type = "image"
                } else if let contentId = urlString.matchingStrings(regexes: LinkPattern.story) {
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
                } else if let contentId = urlString.matchingStrings(regexes: LinkPattern.archiver) {
                    id = contentId
                    type = "archiver"
                } else if let contentId = urlString.matchingStrings(regexes: LinkPattern.channel) {
                    id = contentId
                    type = "channel"
                }  else if urlString.matchingStrings(regexes: LinkPattern.search) != nil {
                    id = urlString
                    type = "searchpage"
                } else if urlString.matchingStrings(regexes: LinkPattern.other) != nil {
                    id = urlString
                    type = "webpage"
                }
                let linkSource = (urlString.matchingStrings(regexes: LinkPattern.xiaobingStoryLink) != nil) ? "xiaobing" : nil
                if let type = type,
                    ["tag", "archiver", "channel"].contains(type) == true {
                    openDataView(id, of: type, in: urlString)
                    return
                }
                if let type = type,
                    ["image"].contains(type) == true,
                    let id = id {
                    let item = ContentItem(
                        id: id,
                        image: "",
                        headline: "",
                        lead: "",
                        type: type,
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
                        //contentItemViewController.subType = .UserComments
                        navigationController?.pushViewController(contentItemViewController, animated: true)
                    }
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
                        contentItem.linkSource = linkSource
                        detailViewController.contentPageData = [contentItem]
                        self.navigationController?.pushViewController(detailViewController, animated: true)
                        return
                    }
                }
                self.present(webVC, animated: true, completion: nil)
            case "ftcregister":
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
                    //contentItemViewController.subType = .UserComments
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
                NotificationHelper.open(action, id: id, title: "")
            case "screen":
                if let hostString = url.host {
                    let screenName = hostString + url.path
                    if let dataObject = AppNavigation.getChannelData(of: screenName),
                        let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
                        let topViewController = UIApplication.topViewController() {
                        dataViewController.dataObject = dataObject
                        dataViewController.hidesBottomBarWhenPushed = true
                        dataViewController.pageTitle = dataObject["title"] ?? ""
                        
                        topViewController.navigationController?.pushViewController(dataViewController, animated: true)
                        topViewController.navigationController?.setNavigationBarHidden(false, animated: true)
                    }
                }
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
                openProductStoreFront(url.host)
            case "speak":
                // MARK: Text to Speech
                if let word = url.host {
                    SpeakWord.speak(word)
                }
            default:
                break
            }
        }
    }
    
    func openHTMLBook(_ fileLocation: String, productId: String) {
        print ("open html file from location: \(fileLocation)")
        if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController  {
            //print(dataViewController.view.frame)
            dataViewController.dataObject = [
                "id": fileLocation,
                "headline": productId,
                "type": "htmlbook",
                "screenName":"htmlbook/\(productId)",
                "url":  APIs.get(productId, type: "htmlbook", forceDomain: nil)
            ]
            let title = IAP.findProductInfoById(productId)?["title"] as? String ?? "FT电子书"
            dataViewController.pageTitle = title
            //dataViewController.isFullScreen = true
            dataViewController.hidesBottomBarWhenPushed = true
            //contentItemViewController.themeColor = self.pageThemeColor
            navigationController?.pushViewController(dataViewController, animated: true)
        }
        
        
        
        //        if let id = id,
        //            let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
        //            let listAPI = APIs.convert("https://danla2f5eudt1.cloudfront.net/\(type)/\(id.addUrlEncoding())?webview=ftcapp&bodyonly=yes&001")
        //            let urlString = APIs.convert("http://www.ftchinese.com/\(type)/\(id)")
        //            dataViewController.dataObject = [
        //                "title": id,
        //                //"api": APIs.get(id, type: type),
        //                "listapi": listAPI,
        //                "url": urlString,
        //                "screenName":"\(type)/\(id)"
        //            ]
        //            dataViewController.pageTitle = id
        //            self.navigationController?.pushViewController(dataViewController, animated: true)
        //        }
        
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
    
    
    func openDataView(_ id: String?, of type: String, in url: String?) {
        if let id = id,
            let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
            let listAPI = APIs.getUrl(id, type: type, isSecure: true, isPartial: true)
            let urlString = APIs.getUrl(id, type: type, isSecure: false, isPartial: false)
            let finalListAPI = combineParameters(listAPI, with: url)
            let finalUrlString = combineParameters(urlString, with: url)
            dataViewController.dataObject = [
                "title": id,
                "listapi": finalListAPI,
                "url": finalUrlString,
                "screenName":"\(type)/\(id)"
            ]
            dataViewController.pageTitle = id
            self.navigationController?.pushViewController(dataViewController, animated: true)
        }
    }
    
    private func combineParameters(_ firstUrl: String, with secondUrl: String?) -> String {
        let secondUrlParameter: String
        if let secondUrl = secondUrl,
            secondUrl.range(of: "?") != nil {
            secondUrlParameter = secondUrl.replacingOccurrences(of: "^[^?]+\\?", with: "", options: .regularExpression)
        } else {
            secondUrlParameter = ""
        }
        let connector = (firstUrl.range(of: "?") == nil) ? "?": "&"
        let finalUrl = "\(firstUrl)\(connector)\(secondUrlParameter)"
        return finalUrl
    }
    
    func openManualPage(_ id: String?, of type: String, with title: String) {
        if let id = id,
            let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
            let listAPI = APIs.getUrl(id, type: type, isSecure: true, isPartial: true)
            let urlString = APIs.getUrl(id, type: type, isSecure: false, isPartial: false)
            dataViewController.dataObject = [
                "title": title,
                "listapi": listAPI,
                "url": urlString,
                "screenName":"\(type)/\(id)"
            ]
            dataViewController.pageTitle = title
            self.navigationController?.pushViewController(dataViewController, animated: true)
        }
    }
    
    func openProductStoreFront(_ productId: String?) {
        let products = IAP.get(IAPs.shared.products, in: "ebook", with: nil, include: .All)
        for product in products {
            if productId == product.id {
                if let contentItemViewController = storyboard?.instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
                    contentItemViewController.dataObject = product
                    contentItemViewController.hidesBottomBarWhenPushed = true
                    if navigationController != nil {
                        navigationController?.isNavigationBarHidden = false
                        navigationController?.pushViewController(contentItemViewController, animated: true)
                    } else if let topViewController = UIApplication.topViewController() as? DataViewController {
                        topViewController.navigationController?.isNavigationBarHidden = false
                        topViewController.navigationController?.pushViewController(contentItemViewController, animated: true)
                    }
                }
                break
            }
        }
    }
}




