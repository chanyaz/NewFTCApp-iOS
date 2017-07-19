//
//  Style.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/22.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
struct Color {
    // Those nested structures are grouped mostly according to their functions
    struct Content {
        static let headline = "#000000"
        static let body = "#333333"
        static let lead = "#777777"
        static let border = "#d4c9bc"
        static let background = "#FFF1E0"
        static let tag = "#9E2F50"
        static let time = "#8b572a"
    }
    
    struct Tab {
        static let text = "#333333"
        static let normalText = "#555555"
        static let highlightedText = "#c0282e"
        static let border = "#d4c9bc"
        static let background = "#f7e9d8"
    }
    
    struct Button {
        static let tint = "#057b93"
    }
    
    struct Header {
        static let text = "#333333"
    }
    
    struct ChannelScroller {
        static let text = "#565656"
        static let highlightedText = "#c0282c"
        static let background = "#e8dbcb"
    }
    
    struct Navigation {
        static let border = "#d5c6b3"
    }
    
    struct Ad {
        static let background = "#f6e9d8"
    }
    
}

struct FontSize {
    static let bodyExtraSize: CGFloat = 3.0
}


struct APIs {
    // TODO: This should be a function rather than a constant, because other news organization might use different way to construct API
    static let story = "https://www.ftchinese.com/index.php/jsapi/get_story_more_info/"
}

struct Event {
    //    static func pagePanningEnd (for tab: String) -> String {
    //        let pagePanningEndName = "Page Panning End"
    //        return "\(pagePanningEndName) for \(tab)"
    //    }
    static let englishStatusChange = "English Status Change"
}

struct GA {
    static let trackingIds = ["UA-1608715-1", "UA-1608715-3"]
}

struct WeChat {
    // MARK: - wechat developer appid
    static let appId = "wxc1bc20ee7478536a"
    static let appSecret = "14999fe35546acc84ecdddab197ed0fd"
    static let accessTokenPrefix = "https://api.weixin.qq.com/sns/oauth2/access_token?"
    static let userInfoPrefix = "https://api.weixin.qq.com/sns/userinfo?"
}

struct Share {
    static let base = "https://m.ftimg.net/"
    static let shareIconName = "ShareIcon.jpg"
    struct CampaignCode {
        static let wechat = "2G178002"
        static let actionsheet = "iosaction"
    }
    
}

struct Push {
    static let deviceTokenUrl = "https://noti.ftimg.net/iphone-collect.php"
}

struct AppGroup {
    static let name = "group.com.ft.ftchinese.mobile"
}

/*
 enum AppError : Error {
 case invalidResource(String, String)
 }
 */




//func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
//    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
//}
