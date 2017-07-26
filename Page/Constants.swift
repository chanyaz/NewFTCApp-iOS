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

// MARK: Different organization might use different way to construct API and urls
struct APIs {
    private static let base = "https://danla2f5eudt1.cloudfront.net/index.php/jsapi/"
    // MARK: the number of days you want to keep the cached files
    static let expireDay: TimeInterval = 30
    // MARK: the types of files that you want to clean from time to time
    static let expireFileTypes = ["json", "jpeg", "jpg", "png", "gif", "mp3", "mp4", "mov", "mpeg"]
    static func get(_ id: String, type: String) -> String {
        let actionType: String
        switch type {
        case "story": actionType = "get_story_more_info/"
        default:
            actionType = "get_story_more_info/"
        }
        let urlString = "\(base)\(actionType)\(id)"
        //print (urlString)
        return urlString
    }
    
    static func getUrl(_ id: String, type: String) -> String {
        let urlString: String
        // MARK: Use different domains for different types of content
        switch type {
        // MARK: If there are http resources that you rely on in your page, don't use https as the url base
        case "video": urlString = "http://danla2f5eudt1.cloudfront.net/\(type)/\(id)?webview=ftcapp&001"
        case "interactive": urlString = "http://danla2f5eudt1.cloudfront.net/\(type)/\(id)?webview=ftcapp&001"
        case "story": urlString = "http://www.ftchinese.com/story/\(id)?full=y"
        default:
            urlString = "http://danla2f5eudt1.cloudfront.net/"
        }
        print ("open in web view: \(urlString)")
        return urlString
    }
}

struct ErrorMessages {
    struct NoInternet {
        static let en = "Dear reader, you are not connected to the Internet Now. Please connect and try again. "
        static let gb = "亲爱的读者，您现在没有连接互联网，也可能没有允许FT中文网连接互联网的权限，请检查连接和设置之后重试。"
        static let big5 = "親愛的讀者，您現在沒有連接互聯網，也可能沒有允許FT中文網連接互聯網的權限，請檢查連接和設置之後重試。"
    }
    struct Unknown {
        static let en = "Dear reader, you are not able to connect to our server now. Please try again later. "
        static let gb = "亲爱的读者，您现在无法连接FT中文网的服务器，请稍后重试。"
        static let big5 = "親愛的讀者，您現在無法連接FT中文網的服務器，請稍後重試。"
    }
}

struct Event {
    //    static func pagePanningEnd (for tab: String) -> String {
    //        let pagePanningEndName = "Page Panning End"
    //        return "\(pagePanningEndName) for \(tab)"
    //    }
    static let englishStatusChange = "English Status Change"
    static let languageSelected = "Language Selected in Story Page"
    static let languagePreferenceChanged = "Language Preference Changed By User Tap"
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
    static let base = "http://www.ftchinese.com/"
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

struct Key {
    static let languagePreference = "Language Preference"
}

/*
 enum AppError : Error {
 case invalidResource(String, String)
 }
 */




//func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
//    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
//}
