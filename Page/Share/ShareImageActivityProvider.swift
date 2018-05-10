//
//  share.swift
//  FT Academy
//
//  Created by ZhangOliver on 15/9/5.
//  Copyright (c) 2015年 Zhang Oliver. All rights reserved.
//


import UIKit

class ShareImageActivityProvider: UIActivityItemProvider {
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        if activityType?.rawValue == "com.sina.weibo.ShareExtension" || activityType == UIActivityType.postToWeibo || activityType == UIActivityType.postToTwitter,
            let image = ShareHelper.shared.coverImage {
            return image
        } else if activityType == UIActivityType.saveToCameraRoll {
            return ShareHelper.shared.coverImage ?? ShareHelper.shared.thumbnail
        } else {
            return ShareHelper.shared.thumbnail
        }
    }
    
}
