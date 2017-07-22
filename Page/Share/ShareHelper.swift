//
//  ShareHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/13.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
struct ShareHelper {
    static var sharedInstance = ShareHelper()
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
        ShareHelper.sharedInstance.thumbnail = UIImage(named: "ftcicon.jpg")
        Download.getDataFromUrl(url) { (data, response, error)  in
            DispatchQueue.main.async { () -> Void in
                guard let data = data , error == nil else {return}
                ShareHelper.sharedInstance.thumbnail = UIImage(data: data)
                print("finished downloading wechat share icon: \(url.absoluteString)")
            }
        }
    }
}


extension UIViewController {
    func launchActionSheet(for item: ContentItem) {
        print ("Share \(item.headline), id: \(item.id), type: \(item.type), image: \(item.image)")
        // MARK: - update some global variables
        ShareHelper.sharedInstance.webPageUrl = "\(Share.base)\(item.type)/\(item.id)?full=y#ccode=\(Share.CampaignCode.actionsheet)"
        ShareHelper.sharedInstance.webPageTitle = item.headline
        ShareHelper.sharedInstance.webPageDescription = item.lead
        ShareHelper.sharedInstance.webPageImage = item.image
        ShareHelper.sharedInstance.webPageImageIcon = ShareHelper.sharedInstance.webPageImage
        if let url = URL(string: ShareHelper.sharedInstance.webPageUrl), let iconImage = UIImage(named: "ShareIcon.jpg") {
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
            
            //TODO: - This might fail in iPad
            self.present(activityVC, animated: true, completion: nil)
            
            
            
            
            //            if UIDevice.current.userInterfaceIdiom == .pad {
            //                //self.presentViewController(controller, animated: true, completion: nil)
            //                let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
            //                popup.present(from: CGRect(x: fromViewController.view.frame.size.width / 2, y: fromViewController.view.frame.size.height / 4, width: 0, height: 0), in: fromViewController.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            //            } else {
            //            }
            
            // MARK: - Use the time between action sheet popped and share action clicked to grab the image icon
            if ShareHelper.sharedInstance.webPageImageIcon.range(of: "https://image.webservices.ft.com") == nil{
                ShareHelper.sharedInstance.webPageImageIcon = "https://image.webservices.ft.com/v1/images/raw/\(ShareHelper.sharedInstance.webPageImageIcon)?source=ftchinese&width=72&height=72"
            }
            if let imgUrl = URL(string: ShareHelper.sharedInstance.webPageImageIcon) {
                ShareHelper.updateThubmnail(imgUrl)
            }
            
        }
    }
}

