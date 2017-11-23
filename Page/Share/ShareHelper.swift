//
//  ShareHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/13.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import UIKit

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
}


extension UIViewController {
    
    func launchActionSheet(for item: ContentItem, from sender: Any) {
        print ("Share \(item.headline), id: \(item.id), type: \(item.type), image: \(item.image)")
        // MARK: - update some global variables
        ShareHelper.shared.webPageUrl = "\(Share.base)\(item.type)/\(item.id)?full=y#ccode=\(Share.CampaignCode.actionsheet)"
        ShareHelper.shared.webPageTitle = item.headline
        ShareHelper.shared.webPageDescription = item.lead
        ShareHelper.shared.webPageImage = item.image
        ShareHelper.shared.webPageImageIcon = ShareHelper.shared.webPageImage
        if let url = URL(string: ShareHelper.shared.webPageUrl), let iconImage = UIImage(named: "ShareIcon.jpg") {
            let wcActivity = WeChatShare(to: "chat")
            let wcCircle = WeChatShare(to: "moment")
            let openInSafari = OpenInSafari()
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
            
            // MARK: - Use the time between action sheet popped and share action clicked to grab the image icon
            if ShareHelper.shared.webPageImageIcon.range(of: "https://image.webservices.ft.com") == nil{
                ShareHelper.shared.webPageImageIcon = "https://image.webservices.ft.com/v1/images/raw/\(ShareHelper.shared.webPageImageIcon)?source=ftchinese&width=72&height=72"
            }
            if let imgUrl = URL(string: ShareHelper.shared.webPageImageIcon) {
                ShareHelper.updateThubmnail(imgUrl)
            }
        }
    }
    
    func launchShareAction(for item: ContentItem, from sender: Any) {
        if WXApi.isWXAppSupport() == true || 1 == 1 {
            let activityVC = CustomShareViewController()
            
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
        } else {
            launchActionSheet(for: item, from: sender)
        }
    }
}

