//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/4.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
// MARK: Different organization might use different way to construct API and urls
struct APIs {
    
    // MARK: Domain Name Used for different types of purposes
    private static let htmlDomains = [
        "https://danla2f5eudt1.cloudfront.net/",
        "https://d2e90etfgpidmd.cloudfront.net/"
    ]
    
    private static let domains = [
        "https://d37m993yiqhccr.cloudfront.net/",
        "https://d2e90etfgpidmd.cloudfront.net/"
    ]
    
    // MARK: If there are http resources that you rely on in your page, don't use https as the url base
    private static let webPageDomains = [
        "http://www.ftchinese.com/",
        "http://big5.ftchinese.com/"
    ]

    private static let publicDomains = [
        "http://app003.ftmailbox.com/",
        "http://big5.ftmailbox.com/"
    ]

    
    // MARK: Number of days you want to keep the cached files
    static let expireDay: TimeInterval = 7
    
    // MARK: Search is mostly rendered using web
    //static let searchUrl = "http://app003.ftmailbox.com/search/"
    static let searchUrl = "http://www.ftchinese.com/search/"
    static func jsForSearch(_ keywords: String) -> String {
        return "search('\(keywords)');"
    }
    
    // MARK: Types of files that you want to clean from time to time
    static let expireFileTypes = ["json", "jpeg", "jpg", "png", "gif", "mp3", "mp4", "mov", "mpeg"]
    
    
    private static func getUrlStringInLanguage(_ from: [String]) -> String {
        let currentPrefence = LanguageSetting.shared.currentPrefence
        let urlString: String
        if currentPrefence > 0 && currentPrefence < domains.count{
            urlString = from[currentPrefence]
        } else {
            urlString = from[0]
        }
        return urlString
    }
    
    // MARK: Construct url strings for different types of content
    static func get(_ id: String, type: String) -> String {
        let urlString: String
        let domain = getUrlStringInLanguage(domains)
        
        switch type {
        case "story": urlString = "\(domain)index.php/jsapi/get_story_more_info/\(id)"
        case "tag":
            if let encodedTag = id.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                urlString = "\(domain)\(type)/\(encodedTag)?type=json"
            } else {
                urlString = "\(domain)\(type)/\(id)?type=json"
            }
        case "follow":
            // TODO: Calculate the url string for follow
            let followTypes = Meta.map
            var parameterString = ""
            for followTypeArray in followTypes {
                if let followType = followTypeArray["key"] as? String {
                    let followKeywords = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
                    var keyStrings = ""
                    for (index, value) in followKeywords.enumerated() {
                        if index == 0 {
                            keyStrings += value
                        } else {
                            keyStrings += ",\(value)"
                        }
                    }
                    if keyStrings != "" {
                        parameterString += "&\(followType)=\(keyStrings)"
                    }
                }
            }
            parameterString = parameterString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? parameterString
            urlString = "\(domain)channel/china.html?type=json\(parameterString)"
            print ("follow request type: \(urlString)")
        default:
            urlString = "\(domain)index.php/jsapi/get_story_more_info/\(id)"
        }
        return urlString
    }
    
    // MARK: Get url string for myFT
    static func get(_ key: String, value: String) -> String {
        let domain = getUrlStringInLanguage(domains)
        return "\(domain)channel/china.html?type=json&\(key)=\(value)"
    }
    
    // MARK: Convert Url String for Alternative Language Such as Big5
    static func convert(_ from: String) -> String {
        let currentPreference = LanguageSetting.shared.currentPrefence
        if currentPreference == 0 {
            return from
        }
        let allDomainArrays = [htmlDomains, domains, webPageDomains, publicDomains]
        var newString = from
        for domainArray in allDomainArrays {
            if currentPreference>0 && currentPreference < domainArray.count {
                newString = newString.replacingOccurrences(
                    of: domainArray[0],
                    with: domainArray[currentPreference]
                )
            }
        }
        return newString
    }
    
    // MARK: Use different domains for different types of content
    static func getUrl(_ id: String, type: String) -> String {
        let urlString: String
        let webPageDomain = getUrlStringInLanguage(webPageDomains)
        let publicDomain = getUrlStringInLanguage(publicDomains)
        switch type {
        case "video":
            urlString = "\(webPageDomain)\(type)/\(id)?webview=ftcapp&002"
        case "interactive", "gym", "special":
            urlString = "\(webPageDomain)interactive/\(id)?webview=ftcapp&i=3&001"
        case "story":
            urlString = "\(publicDomain)/\(type)/\(id)?webview=ftcapp&full=y"
        case "photonews", "photo":
            urlString = "\(webPageDomain)photonews/\(id)?webview=ftcapp&i=3"
        case "register":
            urlString = "\(publicDomain)index.php/users/register?i=4&webview=ftcapp"
        default:
            urlString = "\(webPageDomain)"
        }
        return urlString
    }
    
    // MARK: Add query parameter to the url so that the web pages knows it is opened in our app. Then it'll do things like hide headers.
    static func newQueryForWebPage() -> URLQueryItem {
        return URLQueryItem(name: "webview", value: "ftcapp")
    }
}

// MARK: - Error message in diffent languages
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

// MARK: - Use struct to store information so that Xcode can auto-complete codes
struct Event {
    static let englishStatusChange = "English Status Change"
    static let languageSelected = "Language Selected in Story Page"
    static let languagePreferenceChanged = "Language Preference Changed By User Tap"
    static let changeFont = "switch font"
    static let newAdCreativeDownloaded = "New Ad Creative Downloaded"
    static func paidPostUpdate(for page: String) -> String {
        let paidPostUpdated = "Paid Post Update"
        return "\(paidPostUpdated) for \(page)"
    }
}



// MARK: - Use struct to store information so that Xcode can auto-complete codes
struct Key {
    static let languagePreference = "Language Preference"
    static let domainIndex = "Domain Index"
    static let searchHistory = "Search History"
    static let audioHistory = ["Audio Headline History","Audio URL History","Audio Id History","Audio Last Play Time History"]
}

// MARK: - Use a server side image service so that you can request images that are just large enough. If you don't have a image service such as the FT's, you can simply return the same image url.
struct ImageService {
    static func resize(_ imageUrl: String, width: Int, height: Int) -> String {
        return "https://www.ft.com/__origami/service/image/v2/images/raw/\(imageUrl)?source=ftchinese&width=\(width * 2)&height=\(height * 2)&fit=cover"
    }
}

// MARK: - Recognize link patterns in your specific web site so that your app opens links intelligently, rather than opening everything with web view or safari view.
struct LinkPattern {
    static let story = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/story/([0-9]+)"]
    static let interactive = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/interactive/([0-9]+)"]
    static let video = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/video/([0-9]+)"]
    static let photonews = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/photonews/([0-9]+)"]
    static let tag = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/tag/([^?]+)"]
    static let other = ["(http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+).*$"]
}

// MARK: - When you want to add content that are not already in your APIs. For example, you might want to add a most popular section to your home page.
struct SupplementContent {
    static func insertContent(_ layout: String, to contentSections: [ContentSection]) -> [ContentSection] {
        var newContentSections = contentSections
        // MARK: It is possible that the JSON Format is broken. Check it here.
        if newContentSections.count < 1 {
            return newContentSections
        }
        switch layout {
        case "home":
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        case "follows":
            let followTypes = Meta.map
            for followTypeArray in followTypes {
                if let followType = followTypeArray["key"] as? String
                {
                    var followKeywords = followTypeArray["meta"] as? [String: String] ?? [String: String]()
                    let followedKeywords = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
                    for key in followedKeywords {
                        if followKeywords[key] == nil {
                            followKeywords[key] = key
                        }
                    }
                    var items = [ContentItem]()
                    for (key, value) in followKeywords {
                        let item = ContentItem(
                            id: key,
                            image: "",
                            headline: value,
                            lead: "",
                            type: "follow",
                            preferSponsorImage: "",
                            tag: "",
                            customLink: "",
                            timeStamp: 0,
                            section: 0,
                            row: 0
                        )
                        item.followType = followType
                        items.append(item)
                    }
                    if items.count > 0 {
                        let newContentSection = ContentSection(
                            title: followTypeArray["name"] as? String ?? "",
                            items: items,
                            type: "List",
                            adid: nil
                        )
                        newContentSections.append(newContentSection)
                    }
                }
            }
            return newContentSections
        case "ipadhome":
            // MARK: - The first item in the first section should be marked as Cover
            newContentSections[0].items[0].isCover = true
            // MARK: - Break up the first section into two or more, depending on how you want to layout ads
            return newContentSections
        default:
            return newContentSections
        }
    }
}

struct Meta {
    // MARK: - Things your users can follow
    static let map: [[String: Any]] = [
        ["key": "tag",
         "name": "标签"
        ],
        ["key": "topic",
         "name": "话题",
         "meta": [
            "markets": "金融市场",
            "management": "管理",
            "lifestyle": "生活时尚",
            "business": "商业"
            ]
        ],
        ["key": "area",
         "name": "地区",
         "meta": [
            "china": "中国",
            "us": "美国",
            "europe": "欧洲",
            "africa": "非洲"
            ]
        ],
        ["key": "industry",
         "name": "行业",
         "meta": [
            "technology": "科技",
            "media": "媒体"
            ]
        ],
        ["key": "author",
         "name": "作者"
        ],
        ["key": "column",
         "name": "栏目"
        ]
    ]
    
    // MARK: Tags that are not meant for users to see
    static let reservedTags = [
        "QuizPlus",
        "单选题",
        "SurveyPlus",
        "置顶",
        "低调",
        "精华",
        "小测",
        "生活时尚",
        "深度阅读",
        "教程",
        "测试",
        "FT商学院",
        "英语电台",
        "视频",
        "新闻",
        "数据新闻"
    ]
}

// MARK: - If you are using Admob to track download and performance
struct AdMobTrack {
    static func launch() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ACTConversionReporter.report(withConversionID: "937693643", label: "Qe7aCL-Kx2MQy6OQvwM", value: "1.00", isRepeatable: false)
        } else {
            ACTConversionReporter.report(withConversionID: "937693643", label: "TvNTCJmOiGMQy6OQvwM", value: "1.00", isRepeatable: false)
        }
    }
}

// MARK: - For push notification
struct DeviceToken {
    static let url = "https://noti.ftimg.net/iphone-collect.php"
    // MARK: - Post device token to server
    static func forwardTokenToServer(deviceToken token: Data) {
        let hexEncodedToken = token.map { String(format: "%02hhX", $0) }.joined()
        print("device token: \(hexEncodedToken)")
        // MARK: calculate appNumber based on your bundel ID
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let appNumber: String
        switch bundleID {
        case "com.ft.ftchinese.ipad":
            appNumber = "1"
        case "com.ft.ftchinese.mobile":
            appNumber = "2"
        default:
            appNumber = "0"
        }
        // MARK: get device type
        var deviceType: String
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            deviceType = "pad"
        case .phone:
            deviceType = "phone"
        default:
            deviceType = "unspecified"
        }
        let timeZone = TimeZone.current.abbreviation() ?? ""
        let urlEncoded = "d=\(hexEncodedToken)&t=\(timeZone)&s=start&p=&dt=\(deviceType)&a=\(appNumber)"
        PostData.sendDeviceToken(body: urlEncoded)
    }
}

// MARK: - JS Codes you might need to execute in your web views
struct JSCodes {
    static let autoPlayVideoType = "autoPlayVideo"
    static func get(_ type: String) -> String {
        switch type {
        case autoPlayVideoType:
            return "window.gConnectionType = '\(Connection.current())';playVideoOnWifi();"
        default:
            let fontClass = Setting.getFontClass()
            return "window.gConnectionType = '\(Connection.current())';checkFontSize('\(fontClass)');"
        }
    }
}

// MARK: - Setting page
struct Settings {
    static let page = [
        ContentSection(
            title: "阅读偏好",
            items: [
                ContentItem(
                    id: "font-setting",
                    image: "",
                    headline: "字号设置",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "language-preference",
                    image: "",
                    headline: "语言偏好",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "enable-push",
                    image: "",
                    headline: "新闻推送",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0)
            ],
            type: "Group",
            adid: nil
        ),
        ContentSection(
            title: "流量与缓存",
            items: [
                ContentItem(
                    id: "clear-cache",
                    image: "",
                    headline: "清除缓存",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "no-image-with-data",
                    image: "",
                    headline: "使用数据时不下载图片",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0)
            ],
            type: "Group",
            adid: nil
        ),
        ContentSection(
            title: "服务与反馈",
            items: [
                ContentItem(
                    id: "feedback",
                    image: "",
                    headline: "反馈",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "app-store",
                    image: "",
                    headline: "App Store评分",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "privacy",
                    image: "",
                    headline: "隐私协议",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "about",
                    image: "",
                    headline: "关于我们",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0)
            ],
            type: "Group",
            adid: nil
        )
    ]
}

