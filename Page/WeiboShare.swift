




//
//  WeiboShare.swift
//  Page
//
//  Created by Oliver Zhang on 2018/4/19.
//  Copyright © 2018年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
class WeiboShare: UIActivity {
    
    var contentItem: ContentItem?
    var sender: Any?
    
    init (contentItem: ContentItem?, from: Any?) {
        self.contentItem = contentItem
        self.sender = from
    }
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "Weibo")
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "Weibo")
    }
    
    override var activityTitle : String {
        return "微博"
    }
    
    override class var activityCategory : UIActivityCategory {
        return .share
    }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    override func perform() {
        if WeiboSDK.isWeiboAppInstalled() == false {
            let alert = UIAlertController(title: "请先安装微博", message: "谢谢您的支持！请先去app store安装微博再分享", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "了解", style: UIAlertActionStyle.default, handler: nil))
            return
        }
        let webpageObject = WBWebpageObject()
        let shareUrl = ShareHelper.shared.webPageUrl.replacingOccurrences (
            of: "#ccode=[0-9A-Za-z]+$",
            with: "",
            options: .regularExpression
        )
        webpageObject.webpageUrl = TextForShare.weibo(hasLink: true).url
        webpageObject.objectID = "\(shareUrl)#ccode=\(Share.CampaignCode.weibo)"
        let message = WBMessageObject()
        let img = WBImageObject()
        if let coverImage = ShareHelper.shared.coverImage,
            let imgData = UIImageJPEGRepresentation(coverImage, 0.8) {
                img.imageData = imgData
                message.imageObject = img
                message.text = TextForShare.weibo(hasLink: false).text
        } else {
            // MARK: image size should be less than 32k
            var image = ShareHelper.shared.thumbnail
            image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero)
            if image == nil {
                image = UIImage(named: "ShareIcon")
            }
            if let image = image {
                webpageObject.thumbnailData = UIImagePNGRepresentation(image)
            }
            webpageObject.title = ShareHelper.shared.webPageTitle
            webpageObject.description = ShareHelper.shared.webPageDescription
            message.mediaObject = webpageObject
            message.text = TextForShare.weibo(hasLink: true).text
        }
        let sendMessageToWeiboRequest = WBSendMessageToWeiboRequest()
        sendMessageToWeiboRequest.message = message
        sendMessageToWeiboRequest.shouldOpenWeiboAppInstallPageIfNotInstalled = true
        WeiboSDK.send(sendMessageToWeiboRequest)
        Track.event(category: "Share", action: "iOS Web Page to Weibo", label: ShareHelper.shared.webPageUrl)
    }
    
}
