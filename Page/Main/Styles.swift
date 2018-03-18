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
    // MARK: Grouped mostly based on functions
    // MARK: Use tuple for day and night colors as it is clearer
    struct Content {
        static let headline = (day: "#000000", night: "#BBBBBB")
        static let body = (day: "#333333", night: "#AAAAAA")
        static let lead = (day: "#777777", night: "#AAAAAA")
        static let border = (day: "#e9decf", night: "#333333")
        static let background = (day: "#FFF1E0", night: "#000000")
        static let backgroundForSectionCover = (day: "#f2dfce", night: "#333333")
        static let tag = (day: "#9E2F50", night: "#BBBBBB")
        static let time = (day: "#8b572a", night: "#BBBBBB")
        static let stroke = (day: "#c2272f", night: "#BBBBBB")
    }
    
    struct Tab {
        static let text = (day: "#333333", night: "#AAAAAA")
        static let normalText = (day: "#555555", night: "#AAAAAA")
        static let highlightedText = (day: "#c0282e", night: "#BBBBBB")
        static let border = (day: "#d4c9bc", night: "#333333")
        static let background = (day: "#f7e9d8", night: "#000000")
    }
    
    struct Button {
        static let tint = "#057b93"
        static let highlight = "#FF8833"
        static let highlightFont = "#FFF1E0"
        static let highlightBorder = "#FF8833"
        static let standard = "#F2DFCE"
        static let standardFont = "#777777"
        static let standardBorder = "#FAAE76"
        static let switchBackground = "#5a8caf"
        static let subscriptionBackground = "#0d7680"
        static let subscriptionColor = "#FFFFFF"
    }
    
    struct Header {
        static let text = (day: "#333333", night: "#AAAAAA")
    }
    
    struct ChannelScroller {
        static let text = (day: "#565656", night: "#AAAAAA")
        static let highlightedText = (day: "#c0282c", night: "#AAAAAA")
        static let background = (day: "#fff9f5", night: "#333333")
        static let showBottomBorder = false
        static let bottomBorderWidth: CGFloat = 0
        static let addTextSpace = false
    }
    
    
    struct Ad {
        static let background = (day: "#f6e9d8", night: "#AAAAAA")
        static let sign = (day: "#555555", night: "#AAAAAA")
        static let signBackground = (day: "#ecd4b4", night: "#BBBBBB")
        static let showFullScreenAdBetweenPages = true
        static let showFullScreenAdWhenLaunch = true
    }
    
    // MARK: The box that blocks content to request user to subscribe
    struct Subscription {
        static let boxBackground = (day: "#faeadd", night: "#AAAAAA")
    }
    
    struct Theme {
        static func get(_ theme: String) -> (background: String, border: String, title: String, tag: String, lead: String) {
            switch theme {
            case "Classic":
                return (background: "#FFF1E0", border: "#FFF1E0", title: "#333333", tag: "#9E2F50", lead: "#777777")
            case "Red":
                return (background: "#9E2F50", border: "#9E2F50", title: "#FFFFFF", tag: "#FFFFFF", lead: "#FFFFFF")
            case "Opinion":
                return (background: "#cce6ff", border: "#cce6ff", title: "#333333", tag: "#0f5499", lead: "#777777")
            case "Wheat":
                return (background: "#f2dfce", border: "#f2dfce", title: "#333333", tag: "#9E2F50", lead: "#777777")
            case "Lifestyle":
                return (background: "#e0cdac", border: "#e0cdac", title: "#333333", tag: "#9E2F50", lead: "#777777")
            case "Blue":
                return (background: "#0f5499", border: "#0f5499", title: "#FFFFFF", tag: "#FFFFFF", lead: "#FFFFFF")
            case "Video":
                return (background: "#33302e", border: "#33302e", title: "#FFFFFF", tag: "#FFFFFF", lead: "#FFFFFF")
            case "OutOfBox":
                return (background: "#f2dfce", border: "#f2dfce", title: "#333333", tag: "#9E2F50", lead: "#777777")
            case "OutOfBox-LifeStyle":
                return (background: "#e0cdac", border: "#e0cdac", title: "#333333", tag: "#9E2F50", lead: "#777777")
            case "OutOfBox-Blue":
                return (background: "#0f5499", border: "#0f5499", title: "#FFFFFF", tag: "#FFFFFF", lead: "#FFFFFF")
            default:
                return (background: "#FFF1E0", border: "#e9decf", title: "#333333", tag: "#9E2F50", lead: "#777777")
            }
        }
        static func getCellIndentifier(_ theme: String) -> String {
            switch theme {
            case "Classic":
                return "ClassicCoverCell"
            case "Video":
                return "VideoCoverCell"
            case "OutOfBox":
                return "OutOfBoxCoverCell"
            default:
                return "ThemeCoverCell"
            }
        }
    }
    struct AudioList {
        static let tint = "#29aeba"
        static let border = "#000000"
    }
    
    struct Image {
        static let background = "#d7ccc2"
    }
    struct NavButton {
        static let isAudio = true
    }
}

struct ImageSize {
    static let cover = (width: 408, height: 234)
    static let thumbnail = (width: 187, height: 140)
}

struct FontSize {
    static let bodyExtraSize: CGFloat = 3.0
    static let padding: CGFloat = 14
}
struct FontType {
    static let content = "Helvetica-Light"
    static let languageControl = "Avenir-MediumOblique"
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

    public static let trackingIds = ["UA-1608715-1", "UA-1608715-3"]
    
    // MARK: Tracking info specifically linked to your GA property
    public static func customDimensions(_ id: String) -> [(index: Int, value: String?)] {
        // MARK: Track additional user information
        if id == "UA-1608715-3" {
            let userType: String
            if Privilege.shared.editorsChoice {
                userType = "VIP"
            } else if Privilege.shared.exclusiveContent {
                userType = "Subscriber"
            } else if let id = UserInfo.shared.userId,
                id != "" {
                userType = "Free Member"
            } else {
                userType = "Visitor"
            }
            let customDimensions: [(index: Int, value: String?)] = [
                (index: 1, value: userType),
                (index: 2, value: UserInfo.shared.userId),
                (index: 3, value: UserInfo.shared.deviceToken),
                (index: 4, value: EngagementData.shared.latest),
                (index: 5, value: UIDevice.current.identifierForVendor?.uuidString)
            ]
            return customDimensions
        }
        return []
    }
//    public static func getTrackingIds() -> [String] {
//        if Privilege.shared.exclusiveContent {
//            let subscriberTrackingIds = trackingIds + ["daffad"]
//            return subscriberTrackingIds
//        }
//        return trackingIds
//    }
}

struct Share {
    static let base = "http://www.ftchinese.com/"
    static let shareIconName = "ShareIcon.jpg"
    struct CampaignCode {
        static let wechat = "2G178002"
        static let actionsheet = "iosaction"
    }
}

struct ToolBarStatus {
    static let shouldHide = false
}



