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
        static let backgroundForSectionCover = "#f2dfce"
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
        static let highlightFont = "#FFF1E0"
        static let highlightBorder = "#FF8833"
        static let standard = "#26747a"
        static let standardFont = "#777777"
        static let standardBorder = "#FAAE76"
        static let switchBackground = "#9E2F50"
    }

    struct Header {
        static let text = "#333333"
    }
    
    struct ChannelScroller {
        static let text = "#000000"
        static let highlightedText = "#12a5b3"
        static let background = "#FFFFFF"
        static let showBottomBorder = true
        static let bottomBorderWidth: CGFloat = 0.3
        static let addTextSpace = true
    }
    
    struct Ad {
        static let background = "#f6e9d8"
        static let sign = "#555555"
        static let signBackground = "#ecd4b4"
    }
    
    struct Theme {
        static func get(_ theme: String) -> (background: String, border: String, title: String, tag: String, lead: String) {
            switch theme {
            case "Red":
                return (background: "#9E2F50", border: "#FFF1E0", title: "#FFFFFF", tag: "#FFFFFF", lead: "#FFFFFF")
            default:
                return (background: "#FFF1E0", border: "#e9decf", title: "#333333", tag: "#9E2F50", lead: "#777777")
            }
        }
        static func getCellIndentifier(_ theme: String) -> String {
            switch theme {
            case "Video":
                return "VideoCoverCell"
            default:
                return "ThemeCoverCell"
            }
        }
    }
    
    struct AudioList {
        static let tint = "#29aeba"
        static let border = "#000000"
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



