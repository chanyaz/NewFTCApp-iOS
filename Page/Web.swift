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
        if let topController = UIApplication.topViewController() {
            if let contentItemViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
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
                }
                if let id = id,
                    let type = type {
                    contentItemViewController.dataObject = ContentItem(
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
                        row: 0)
                    topController.navigationController?.pushViewController(contentItemViewController, animated: true)
                    return
                }
            }
            topController.present(webVC, animated: true, completion: nil)
        }
    }
}
