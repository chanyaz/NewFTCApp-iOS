//
//  share.swift
//  FT Academy
//
//  Created by ZhangOliver on 15/9/5.
//  Copyright (c) 2015年 Zhang Oliver. All rights reserved.
//


import UIKit


class DataForShare: NSObject, UIActivityItemSource {
    var url: String = ShareHelper.sharedInstance.webPageUrl
    var lead: String = ShareHelper.sharedInstance.webPageDescription
    var imageCover: String = ShareHelper.sharedInstance.webPageImage
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ShareHelper.sharedInstance.webPageTitle;
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        //Sina Weibo cannot handle arrays. It's either text or image
        var textForShare = ""
        if activityType == UIActivityType.mail {
            textForShare = ShareHelper.sharedInstance.webPageDescription
        } else if activityType == UIActivityType.postToWeibo || activityType == UIActivityType.postToTwitter {
            textForShare = "【" + ShareHelper.sharedInstance.webPageTitle + "】" + ShareHelper.sharedInstance.webPageDescription
            let textForShareCredit = "（分享自 @FT中文网）"
            let textForShareLimit = 140
            let textForShareTailCount = textForShareCredit.characters.count + url.characters.count
            if textForShare.characters.count + textForShareTailCount > textForShareLimit {
                let index = textForShare.characters.index(textForShare.startIndex, offsetBy: textForShareLimit - textForShareTailCount - 3)
                //textForShare = textForShare.substring(to: index) + "..."
                textForShare = String(textForShare[..<index]) + "..."
            }
            textForShare = textForShare + "（分享自 @FT中文网）"
        } else {
            textForShare = ShareHelper.sharedInstance.webPageTitle
        }
        return textForShare
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        
        if(activityType == UIActivityType.mail){
            return ShareHelper.sharedInstance.webPageTitle
        } else {
            return ShareHelper.sharedInstance.webPageTitle
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
        thumbnailImageForActivityType activityType: UIActivityType?,
        suggestedSize size: CGSize) -> UIImage? {
        //var image : UIImage
        if let image = UIImage(named: "AppIcon") {
            //image = image.resizableImage(withCapInsets: UIEdgeInsets.zero)
            return image.resizableImage(withCapInsets: UIEdgeInsets.zero)
        }
        return nil
    }
    
}
