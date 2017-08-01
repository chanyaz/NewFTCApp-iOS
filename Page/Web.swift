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
        }
        if let type = type, type == "tag" {
            if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
                if let id = id {
                    dataViewController.dataObject = ["title": id,
                                                     "api": APIs.get(id, type: type),
                                                     "url":"http://www.ftchinese.com/channel/datanews.html",
                                                     "screenName":"homepage/datanews"]
                    //                    dataViewController.contentPageData = [ContentItem(
                    //                        id: id,
                    //                        image: "",
                    //                        headline: "",
                    //                        lead: "",
                    //                        type: type,
                    //                        preferSponsorImage: "",
                    //                        tag: "",
                    //                        customLink: "",
                    //                        timeStamp: 0,
                    //                        section: 0,
                    //                        row: 0)]
                    //dataViewController.dataObject = self.pageData[index]
                    dataViewController.pageTitle = id
                    //dataViewController.themeColor = ""
                    self.navigationController?.pushViewController(dataViewController, animated: true)
                    return
                }
            }
        }
        if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
            if let id = id,
                let type = type {
                detailViewController.contentPageData = [ContentItem(
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
                    row: 0)]
                self.navigationController?.pushViewController(detailViewController, animated: true)
                return
            }
        }
        self.present(webVC, animated: true, completion: nil)
    }
}
