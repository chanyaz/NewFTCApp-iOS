//
//  share.swift
//  FT Academy
//
//  Created by ZhangOliver on 15/9/5.
//  Copyright (c) 2015年 Zhang Oliver. All rights reserved.
//


import UIKit

class DataForShare: NSObject, UIActivityItemSource {
    var url: String = ShareHelper.shared.webPageUrl
    var lead: String = ShareHelper.shared.webPageDescription
    var imageCover: String = ShareHelper.shared.webPageImage
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        let title = ShareHelper.shared.webPageTitle
        return title
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        //Sina Weibo cannot handle arrays. It's either text or image
        var textForShare = ""
        //print (activityType?.rawValue)
        if activityType?.rawValue == "com.tencent.xin.sharetimeline" {
            return URL(string: ShareHelper.shared.webPageUrl)
        } else if activityType == UIActivityType.mail {
            textForShare = ShareHelper.shared.webPageDescription
        } else if activityType?.rawValue == "com.sina.weibo.ShareExtension" || activityType == UIActivityType.postToWeibo || activityType == UIActivityType.postToTwitter {
            textForShare = "【" + ShareHelper.shared.webPageTitle + "】" + ShareHelper.shared.webPageDescription
            let textForShareCredit = "（分享自 @FT中文网）"
            let textForShareLimit = 140
            let textForShareTailCount = textForShareCredit.count + url.count
            if textForShare.count + textForShareTailCount > textForShareLimit {
                let index = textForShare.index(textForShare.startIndex, offsetBy: textForShareLimit - textForShareTailCount - 3)
                //textForShare = textForShare.substring(to: index) + "..."
                textForShare = String(textForShare[..<index]) + "..."
            }
            textForShare = "\(textForShare)\(ShareHelper.shared.webPageUrl)（分享自 @FT中文网）"
        } else {
            textForShare = ShareHelper.shared.webPageTitle
        }
        return textForShare
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return ShareHelper.shared.webPageTitle
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
        thumbnailImageForActivityType activityType: UIActivityType?,
        suggestedSize size: CGSize) -> UIImage? {
        if let image = UIImage(named: "ShareIcon") {
            return image.resizableImage(withCapInsets: UIEdgeInsets.zero)
        }
        return nil
    }
    
}
