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
    var webPageUrl: String
    var webPageTitle: String
    var webPageDescription: String
    var webPageImage: String
    var webPageImageIcon: String
    var currentWebView: WKWebView?
    
    static func updateThubmnail(_ url: URL) {
        print("Start downloading \(url) for WeChat Shareing. lastPathComponent: \(url.absoluteString)")
        ShareHelper.shared.thumbnail = UIImage(named: "ftcicon.jpg")
        Download.getDataFromUrl(url) {(data, response, error)  in
            //DispatchQueue.main.async { () -> Void in
            guard let data = data , error == nil else {return}
            ShareHelper.shared.thumbnail = UIImage(data: data)
            print("finished downloading wechat share icon: \(url.absoluteString)")
            //}
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
    
    func launchShareAction(for item: ContentItem, from sender: Any) {
        if WXApi.isWXAppSupport() == true {
            launchCustomActionSheet(for: item, from: sender)
        } else {
            launchActionSheet(for: item, from: sender)
        }
    }
    
    
    func launchCustomActionSheet(for item: ContentItem, from sender: Any) {
        updateShareContent(for: item, from: sender)
        let activityVC = CustomShareViewController()
        activityVC.shareItems = [
            WeChatShare(to: "chat-custom"),
            WeChatShare(to: "moment-custom"),
            //WeChatShare(to: "chat-screenshot"),
            OpenInSafari(to: "safari-custom"),
            ShareMore(contentItem: item, from: sender)
        ]
        
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
    
    func launchActionSheet(for item: ContentItem, from sender: Any) {
        updateShareContent(for: item, from: sender)
        if let url = URL(string: ShareHelper.shared.webPageUrl), let iconImage = UIImage(named: "ShareIcon.jpg") {
            let wcActivity = WeChatShare(to: "chat")
            let wcCircle = WeChatShare(to: "moment")
            let openInSafari = OpenInSafari(to: "safari")
            let shareData = DataForShare()
            let image = ShareImageActivityProvider(placeholderItem: iconImage)
            let objectsToShare = [shareData, url, image] as [Any]
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
        if let imgUrl = URL(string: ShareHelper.shared.webPageImageIcon) {
            ShareHelper.updateThubmnail(imgUrl)
        }
    }
    
    func getCurrentWebView() {
        if let detailViewController = self as? DetailViewController,
            let viewPages = detailViewController.pageViewController?.viewControllers {
            print ("this is a detail view")
            let currentPageIndexNumber = detailViewController.currentPageIndex
            for viewPage in viewPages {
                if let viewPage = viewPage as? ContentItemViewController,
                    viewPage.dataObject?.id == detailViewController.contentPageData[currentPageIndexNumber].id {
                    //ShareHelper.shared.fullPageImage = viewPage.webView?.screenshot()
                    ShareHelper.shared.currentWebView = viewPage.webView
                    break
                }
            }
        }
    }
    
    func updateShareContent (for item: ContentItem, from sender: Any) {
        print ("Share \(item.headline), id: \(item.id), type: \(item.type), image: \(item.image)")
        // MARK: - update some global variables
        ShareHelper.shared.webPageUrl = "\(Share.base)\(item.type)/\(item.id)?full=y#ccode=\(Share.CampaignCode.actionsheet)"
        ShareHelper.shared.webPageTitle = item.headline
        ShareHelper.shared.webPageDescription = item.lead
        ShareHelper.shared.webPageImage = item.image
        ShareHelper.shared.webPageImageIcon = ShareHelper.shared.webPageImage
        getCurrentWebView()
        
        // MARK: - capture the screen shot of the webview
        // captureScreenShot()
    }
    
}

