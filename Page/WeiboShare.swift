




//
//  WeiboShare.swift
//  Page
//
//  Created by Oliver Zhang on 2018/4/19.
//  Copyright © 2018年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

class WeiboShare: UIActivity, Sharable {
    func performShare() {
        perform()
    }
    
    
    var contentItem: ContentItem?
    var sender: Any?
    var to: ShareToType
    
    init (contentItem: ContentItem?, from: Any?, with: ShareToType) {
        self.contentItem = contentItem
        self.sender = from
        self.to = with
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
        
        // MARK: Send the final message and call up Weibo
        func send(_ message: WBMessageObject) {
            let sendMessageToWeiboRequest = WBSendMessageToWeiboRequest()
            sendMessageToWeiboRequest.message = message
            sendMessageToWeiboRequest.shouldOpenWeiboAppInstallPageIfNotInstalled = true
            WeiboSDK.send(sendMessageToWeiboRequest)
        }
        
        // MARK: Send image data to Weibo
        func sendImageData(_ imageData: Data) {
            let message = WBMessageObject()
            let img = WBImageObject()
            img.imageData = imageData
            let finalMessage = message
            finalMessage.imageObject = img
            finalMessage.text = TextForShare.weibo(hasLink: false).text
            send(finalMessage)
        }
        
        // MARK: Send a web link to Weibo
        func sendLink() {
            let webpageObject = WBWebpageObject()
            let shareUrl = ShareHelper.shared.webPageUrl.replacingOccurrences (
                of: "#ccode=[0-9A-Za-z]+$",
                with: "",
                options: .regularExpression
            )
            webpageObject.webpageUrl = TextForShare.weibo(hasLink: true).url
            webpageObject.objectID = "\(shareUrl)#ccode=\(Share.CampaignCode.weibo)"
            // MARK: image size should be less than 32k
            let message = WBMessageObject()
            let image = ShareHelper.shared.thumbnail
            if let image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero) ?? UIImage(named: "ShareIcon") {
                webpageObject.thumbnailData = UIImagePNGRepresentation(image)
            }
            webpageObject.title = ShareHelper.shared.webPageTitle
            webpageObject.description = ShareHelper.shared.webPageDescription
            message.mediaObject = webpageObject
            message.text = TextForShare.weibo(hasLink: true).text
            send(message)
        }
        
        if WeiboSDK.isWeiboAppInstalled() == false {
            let alert = UIAlertController(title: "请先安装微博", message: "谢谢您的支持！请先去app store安装微博再分享", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "了解", style: UIAlertActionStyle.default, handler: nil))
            return
        }
        
        switch to {
        case .ScreenShot:
            ShareHelper.shared.currentWebView?.snapshots(completion: { (image) in
                if let image = image,
                    let imageData = UIImageJPEGRepresentation(image, 0.8){
                    sendImageData(imageData)
                    Track.event(category: "Share", action: "iOS Screen Shot to Weibo", label: ShareHelper.shared.webPageUrl)
                }
            })
        default:
            if let coverImage = ShareHelper.shared.coverImage,
                let imageData = UIImageJPEGRepresentation(coverImage, 0.8) {
                sendImageData(imageData)
            } else {
                sendLink()
            }
            Track.event(category: "Share", action: "iOS Web Page to Weibo", label: ShareHelper.shared.webPageUrl)
        }
    }
    
}
