




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
        
        //        let authReq = WBAuthorizeRequest()
        //        authReq.redirectURI = Weibo.redirect
        //        authReq.scope = "all"
        //
        //
        //        // MARK: - Construct Weibo Web Image
        //        let message = WBMessageObject()
        //        message.text = "这是分享到新浪微博的一个网页"
        //
        //        let web = WBWebpageObject()
        //        web.objectID = "对应多媒体的唯一标识"
        //        web.title = "多媒体的标题"
        //        web.description = "多媒体内容的描述: 这是一个很努力的作者"
        //        let thumbImg = UIImage(named: "cover.jpg")// 预览图
        //        // 不能超过32k
        //        web.thumbnailData = UIImagePNGRepresentation(thumbImg!)!
        //        web.webpageUrl = "http://www.jianshu.com/u/2846c3d3a974"
        //        message.mediaObject = web
        //
        //
        //        let req: WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authReq, access_token: nil) as! WBSendMessageToWeiboRequest
        //        req.userInfo = ["info": "分享的新闻链接"] // 自定义的请求信息字典， 会在响应中原样返回
        //        req.shouldOpenWeiboAppInstallPageIfNotInstalled = false // 当未安装客户端时是否显示下载页
        //
        //        let re = WeiboSDK.send(req)
        //        print ("send request result: \(re)")
        
        
        
        let webpageObject = WBWebpageObject()
        webpageObject.webpageUrl = "http://www.ftchinese.com/"
        webpageObject.objectID = "someid"
        let thumbImg = UIImage(named: "cover.jpg")// 预览图
        // 不能超过32k
        webpageObject.thumbnailData = UIImagePNGRepresentation(thumbImg!)!
        webpageObject.title = "title"
        webpageObject.description = "description"
        let message = WBMessageObject()
        message.mediaObject = webpageObject
        message.text = "text"
        let sendMessageToWeiboRequest = WBSendMessageToWeiboRequest()
        sendMessageToWeiboRequest.message = message
        WeiboSDK.send(sendMessageToWeiboRequest)
        
        
    }
    
}
