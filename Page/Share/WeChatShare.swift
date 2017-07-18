//
//  WeChatShare.swift
//  FT中文网
//
//  Created by ZhangOliver on 2016/11/1.
//  Copyright © 2016年 Financial Times Ltd. All rights reserved.
//

import UIKit
class WeChatShare : UIActivity{
    var to: String
    var text:String?
    
    init(to: String) {
        self.to = to
    }
    
    override var activityType: UIActivityType {
        switch to {
        case "moment": return UIActivityType(rawValue: "WeChatMoment")
        case "fav": return UIActivityType(rawValue: "WeChatFav")
        default: return UIActivityType(rawValue: "WeChat")
        }
    }
    
    override var activityImage: UIImage? {
        switch to {
        case "moment": return UIImage(named: "Moment")
        case "fav": return UIImage(named: "WeChatFav")
        default: return UIImage(named: "WeChat")
        }
    }
    
    override var activityTitle : String {
        switch to {
        case "moment": return "微信朋友圈"
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
        case "moment": toString = "moment"
        case "fav": toString = "fav"
        default: toString = "chat"
        }
        if WXApi.isWXAppInstalled() == false {
            let alert = UIAlertController(title: "请先安装微信", message: "谢谢您的支持！请先去app store安装微信再分享", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "了解", style: UIAlertActionStyle.default, handler: nil))
            return
        }
        let message = WXMediaMessage()
        message.title = ShareHelper.sharedInstance.webPageTitle
        message.description = ShareHelper.sharedInstance.webPageDescription
        var image = ShareHelper.sharedInstance.thumbnail
        image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero)
        message.setThumbImage(image)
        let webpageObj = WXWebpageObject()
        let shareUrl = ShareHelper.sharedInstance.webPageUrl.replacingOccurrences(
            of: "#ccode=[0-9A-Za-z]+$",
            with: "",
            options: .regularExpression)
        let c = Share.CampaignCode.wechat
        webpageObj.webpageUrl = "\(shareUrl)#ccode=\(c)"
        print ("wechat webpage obj url is \(webpageObj.webpageUrl)")
        message.mediaObject = webpageObj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        if toString == "chat" {
            req.scene = 0
        } else if toString == "fav" {
            req.scene = 2
        } else {
            req.scene = 1
        }
        WXApi.send(req)
    }

}

// use a subclass to return different value for fav
class WeChatShareFav: WeChatShare {
    override class var activityCategory : UIActivityCategory {
        return UIActivityCategory.action
    }
}
