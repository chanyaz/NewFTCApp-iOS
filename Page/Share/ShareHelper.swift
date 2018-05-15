//
//  ShareHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/13.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import WebKit

enum ActionSheetType {
    case Default
    case Screenshot
}

enum ShareToType {
    case ScreenShot
    case Default
}

protocol Sharable {
    func performShare()
}

struct ShareHelper {
    
    static var shared = ShareHelper()
    private init() {
        thumbnail = UIImage(named: Share.shareIconName)
        webPageUrl = ""
        webPageTitle = ""
        webPageDescription = ""
        webPageImage = ""
        webPageImageIcon = ""
    }
    var thumbnail: UIImage?
    var coverImage: UIImage?
    var webPageUrl: String
    var webPageTitle: String
    var webPageDescription: String
    var webPageImage: String
    var webPageImageIcon: String
    var currentWebView: WKWebView?
    
    static func updateShareImage() {
        ShareHelper.shared.thumbnail = UIImage(named: "ftcicon.jpg")
        if let url = URL(string: ShareHelper.shared.webPageImageIcon) {
            Download.getDataFromUrl(url) {(data, response, error)  in
                guard let data = data, error == nil else {return}
                ShareHelper.shared.thumbnail = UIImage(data: data)
            }
        }
        ShareHelper.shared.coverImage = nil
        let statusType = IJReachability().connectedToNetworkOfType()
        if statusType == .wiFi,
            let url = URL(string: ShareHelper.shared.webPageImage) {
            Download.getDataFromUrl(url) {(data, response, error)  in
                guard let data = data, error == nil else {return}
                ShareHelper.shared.coverImage = UIImage(data: data)
            }
        }
    }
    
    static func stitchImages(images: [UIImage], isVertical: Bool) -> UIImage {
        var stitchedImages : UIImage!
        if images.count > 0 {
            var maxWidth = CGFloat(0), maxHeight = CGFloat(0)
            for image in images {
                if image.size.width > maxWidth {
                    maxWidth = image.size.width
                }
                if image.size.height > maxHeight {
                    maxHeight = image.size.height
                }
            }
            var totalSize : CGSize
            let maxSize = CGSize(width: maxWidth, height: maxHeight)
            if isVertical {
                totalSize = CGSize(width: maxSize.width, height: maxSize.height * (CGFloat)(images.count))
            } else {
                totalSize = CGSize(width: maxSize.width  * (CGFloat)(images.count), height:  maxSize.height)
            }
            UIGraphicsBeginImageContext(totalSize)
            for image in images {
                let offset = (CGFloat)(images.index(of: image)!)
                let rect =  AVMakeRect(aspectRatio: image.size, insideRect: isVertical ?
                    CGRect(x: 0, y: maxSize.height * offset, width: maxSize.width, height: maxSize.height) :
                    CGRect(x: maxSize.width * offset, y: 0, width: maxSize.width, height: maxSize.height))
                image.draw(in: rect)
            }
            stitchedImages = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return stitchedImages
    }
}

extension UIViewController {
    
    func launchActionSheet(for item: ContentItem, from sender: Any, with type: ActionSheetType) {
        updateShareContent(for: item, from: sender)
        let activityVC = CustomShareViewController()
        var shareItems = [Sharable]()
        if type == .Screenshot {
            if #available(iOS 10.0, *),
                Privilege.shared.exclusiveContent,
                item.type != "premium",
                WXApi.isWXAppInstalled() {
                shareItems.append(WeChatShare(to: "chat-screenshot"))
                shareItems.append(WeChatShare(to: "moment-screenshot"))
                shareItems.append(WeiboShare(contentItem: item, from: sender, with: .ScreenShot))
                shareItems.append(SaveScreenshot())
                //shareItems.append(ShareScreenshot(contentItem: item, from: sender))
            }
        } else {
            if WXApi.isWXAppInstalled() {
                shareItems.append(WeChatShare(to: "chat-custom"))
                shareItems.append(WeChatShare(to: "moment-custom"))
            }
            if WeiboSDK.isWeiboAppInstalled() {
                shareItems.append(WeiboShare(contentItem: item, from: sender, with: .Default))
            }
            if #available(iOS 10.0, *),
                Privilege.shared.exclusiveContent,
                item.type != "premium" {
                //            shareItems.append(WeChatShare(to: "chat-screenshot"))
                //            shareItems.append(WeChatShare(to: "moment-screenshot"))
                if WXApi.isWXAppInstalled() || WeiboSDK.isWeiboAppInstalled() {
                    shareItems.append(ShareScreenshot(contentItem: item, from: sender))
                } else {
                    shareItems.append(SaveScreenshot())
                }
            }
            shareItems.append(OpenInSafari(to: "safari-custom"))
            shareItems.append(ShareMore(contentItem: item, from: sender))
        }
        activityVC.shareItems = shareItems
        // MARK: Use this to support both iPhone and iPad
        activityVC.modalPresentationStyle = .overCurrentContext
        let popoverPresentationController = activityVC.popoverPresentationController
        if let sender = sender as? UIView {
            popoverPresentationController?.sourceView = sender
        } else if let sender = sender as? UIBarButtonItem {
            popoverPresentationController?.barButtonItem = sender
        } else {
            popoverPresentationController?.sourceView = view
        }
        present(activityVC, animated: true, completion: nil)
        grabImagesForShare()
    }
    
    func launchSystemDefaultActionSheet(for item: ContentItem, from sender: Any) {
        updateShareContent(for: item, from: sender)
        if let url = URL(string: ShareHelper.shared.webPageUrl), let iconImage = UIImage(named: "ShareIcon.jpg") {
            let wcActivity = WeChatShare(to: "chat")
            let wcCircle = WeChatShare(to: "moment")
            let openInSafari = OpenInSafari(to: "safari")
            let shareData = DataForShare()
            let image = ShareImageActivityProvider(placeholderItem: iconImage)
            let objectsToShare = [url, shareData, image] as [Any]
            let activityVC: UIActivityViewController
            if WXApi.isWXAppSupport() == true {
                activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, openInSafari])
            } else {
                activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [openInSafari])
            }
            
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            // MARK: Use this to support both iPhone and iPad
            activityVC.modalPresentationStyle = UIModalPresentationStyle.popover
            present(activityVC, animated: true, completion: nil)
            
            let popoverPresentationController = activityVC.popoverPresentationController
            if let sender = sender as? UIView {
                popoverPresentationController?.sourceView = sender
            } else if let sender = sender as? UIBarButtonItem {
                popoverPresentationController?.barButtonItem = sender
            } else {
                popoverPresentationController?.sourceView = view
            }
            
            grabImagesForShare()
        }
    }
    
    private func grabImagesForShare() {
        // MARK: - Use the time between action sheet popped and share action clicked to grab the image icon
        if ShareHelper.shared.webPageImageIcon.range(of: "https://image.webservices.ft.com") == nil{
            ShareHelper.shared.webPageImageIcon = "https://image.webservices.ft.com/v1/images/raw/\(ShareHelper.shared.webPageImageIcon)?source=ftchinese&width=72&height=72"
        }
        ShareHelper.updateShareImage()
    }
    
    private func getCurrentWebView(from sender: Any) {
        ShareHelper.shared.currentWebView = nil
        if let dataView = sender as? DataViewController {
            ShareHelper.shared.currentWebView = dataView.webView
        } else if let contentView = sender as? ContentItemViewController {
            ShareHelper.shared.currentWebView = contentView.webView
        } else if let detailViewController = self as? DetailViewController,
            let viewPages = detailViewController.pageViewController?.viewControllers {
            let currentPageIndexNumber = detailViewController.currentPageIndex
            for viewPage in viewPages {
                if let viewPage = viewPage as? ContentItemViewController,
                    viewPage.dataObject?.id == detailViewController.contentPageData[currentPageIndexNumber].id {
                    ShareHelper.shared.currentWebView = viewPage.webView
                    break
                }
            }
        }
    }
    
    func updateShareContent (for item: ContentItem, from sender: Any) {
        // MARK: - update some global variables
        if item.customLink != "" {
            ShareHelper.shared.webPageUrl = "\(item.customLink)#ccode=\(Share.CampaignCode.actionsheet)"
        } else {
            ShareHelper.shared.webPageUrl = "\(Share.base)\(item.type)/\(item.id)?full=y#ccode=\(Share.CampaignCode.actionsheet)"
        }
        ShareHelper.shared.webPageTitle = item.headline
        ShareHelper.shared.webPageDescription = item.lead
        ShareHelper.shared.webPageImage = item.image
        ShareHelper.shared.webPageImageIcon = item.image
        getCurrentWebView(from: sender)
    }
    
}

