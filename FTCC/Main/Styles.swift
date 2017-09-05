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
        static let lead = "#000000"
        static let border = "#cecece"
        static let background = "#FFFFFF"
        static let tag = "#9E2F50"
        static let time = "#8b572a"
    }
    
    struct Tab {
        static let text = "#333333"
        static let normalText = "#555555"
        static let highlightedText = "#12a5b3"
        static let border = "#d4c9bc"
        static let background = "#f7e9d8"
    }
    
    struct Button {
        static let tint = "#057b93"
        static let highlight = "#f6801a"
        static let standard = "#26747a"
    }
    
    struct Header {
        static let text = "#333333"
    }
    
    struct ChannelScroller {
        static let text = "#000000"
        static let highlightedText = "#12a5b3"
        static let background = "#FFFFFF"
        //static let background = "#e8dbcb"
        
        //static let background = "#FFFFFF"
        
    }
    
    struct Navigation {
        static let border = "#000000"
    }
    
    struct Ad {
        static let background = "#f6e9d8"
        static let sign = "#555555"
        static let signBackground = "#ecd4b4"
    }
    
}

struct FontSize {
    static let bodyExtraSize: CGFloat = 3.0
    static let padding: CGFloat = 14
}

struct AppGroup {
    static let name = "group.com.ft.ftchinese.mobile"
}

struct WeChat {
    // MARK: - wechat developer appid
    static let appId = "wxc1bc20ee7478536a"
    static let appSecret = "14999fe35546acc84ecdddab197ed0fd"
    static let accessTokenPrefix = "https://api.weixin.qq.com/sns/oauth2/access_token?"
    static let userInfoPrefix = "https://api.weixin.qq.com/sns/userinfo?"
}

struct GA {
    static let trackingIds = ["UA-1608715-1", "UA-1608715-3"]
}

struct Share {
    static let base = "http://www.ftchinese.com/"
    static let shareIconName = "ShareIcon.jpg"
    struct CampaignCode {
        static let wechat = "2G178002"
        static let actionsheet = "iosaction"
    }
}



