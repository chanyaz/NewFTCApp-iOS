//
//  WeChatShare.swift
//  FT中文网
//
//  Created by ZhangOliver on 2016/11/1.
//  Copyright © 2016年 Financial Times Ltd. All rights reserved.
//

import UIKit
class WeChatShare: UIActivity{
    var to: String
    var text:String?
    
    init(to: String) {
        self.to = to
    }
    
    override var activityType: UIActivityType {
        switch to {
        case "moment", "moment-custom": return UIActivityType(rawValue: "WeChatMoment")
        case "fav": return UIActivityType(rawValue: "WeChatFav")
        case "chat-custom": return UIActivityType(rawValue: "WeChat")
        case "chat-screenshot", "moment-screenshot": return UIActivityType(rawValue: "WeChat")
        default: return UIActivityType(rawValue: "WeChat")
        }
    }
    
    override var activityImage: UIImage? {
        switch to {
        case "moment": return UIImage(named: "Moment")
        case "moment-custom", "moment-screenshot": return UIImage(named: "MomentCustom")
        case "chat-custom", "chat-screenshot": return UIImage(named: "WeChatCustom")
        case "fav": return UIImage(named: "WeChatFav")
        default: return UIImage(named: "WeChat")
        }
    }
    
    override var activityTitle : String {
        switch to {
        case "moment", "moment-custom": return "微信朋友圈"
        case "chat-custom": return "微信好友"
        case "chat-screenshot": return "截屏给好友"
        case "moment-screenshot": return "截屏到朋友圈"
        case "fav": return "微信收藏"
        default: return "微信好友"
        }
    }
    
    
    override class var activityCategory : UIActivityCategory {
        // use a subclass to return different value for fav
        return UIActivityCategory.share
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        var toString = ""
        switch to {
        case "moment","moment-custom", "moment-screenshot": toString = "moment"
        case "fav": toString = "fav"
        case "chat-custom": toString = "chat"
        case "chat-screenshot": toString = "chat"
        default: toString = "chat"
        }
        if WXApi.isWXAppInstalled() == false {
            let alert = UIAlertController(title: "请先安装微信", message: "谢谢您的支持！请先去app store安装微信再分享", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "了解", style: UIAlertActionStyle.default, handler: nil))
            return
        }
        let message = WXMediaMessage()
        
        message.title = ShareHelper.shared.webPageTitle
        message.description = ShareHelper.shared.webPageDescription
        var image = ShareHelper.shared.thumbnail
        image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero)
        if image == nil {
            image = UIImage(named: "ShareIcon")
        }
        
        if to.range(of: "screenshot") != nil {
            
            let imageObject =  WXImageObject()
            if let currentWebView = ShareHelper.shared.currentWebView {
                currentWebView.snapshots(completion: { (image) in
                    
                    if let image = image {
                        imageObject.imageData = UIImagePNGRepresentation(image)
                        message.mediaObject = imageObject
                        
                        
                        let req = SendMessageToWXReq()
                        req.bText = false
                        req.message = message
                        let eventAction: String
                        if toString.range(of: "chat") != nil {
                            req.scene = 0
                            eventAction = "iOS Screen Shot to WeChat Friend"
                        } else if toString.range(of: "moment") != nil {
                            req.scene = 1
                            eventAction = "iOS Screen Shot to WeChat Moment"
                        } else if toString == "fav" {
                            req.scene = 2
                            eventAction = "iOS Screen Shot to WeChat Favorate"
                        } else {
                            req.scene = 1
                            eventAction = "iOS Screen Shot to WeChat Moment"
                        }
                        Track.event(category: "Share", action: eventAction, label: ShareHelper.shared.webPageUrl)
                        WXApi.send(req)
                    }
                })
            }
        } else {
            message.setThumbImage(image)
            let webpageObj = WXWebpageObject()
            let shareUrl = ShareHelper.shared.webPageUrl.replacingOccurrences(
                of: "#ccode=[0-9A-Za-z]+$",
                with: "",
                options: .regularExpression
            )
            let c = Share.CampaignCode.wechat
            webpageObj.webpageUrl = "\(shareUrl)#ccode=\(c)"
            //print ("wechat webpage obj url is \(webpageObj.webpageUrl)")
            message.mediaObject = webpageObj
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            let eventAction: String
            if toString.range(of: "chat") != nil {
                req.scene = 0
                eventAction = "iOS Web Page to WeChat Friend"
            } else if toString.range(of: "moment") != nil {
                req.scene = 1
                eventAction = "iOS Web Page to WeChat Moment"
            } else if toString == "fav" {
                req.scene = 2
                eventAction = "iOS Web Page to WeChat Favorate"
            } else {
                req.scene = 1
                eventAction = "iOS Web Page to WeChat Moment"
            }
            Track.event(category: "Share", action: eventAction, label: ShareHelper.shared.webPageUrl)
            WXApi.send(req)
        }
    }
}

// use a subclass to return different value for fav
class WeChatShareFav: WeChatShare {
    override class var activityCategory : UIActivityCategory {
        return UIActivityCategory.action
    }
}
