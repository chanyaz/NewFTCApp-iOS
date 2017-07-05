//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct AppNavigation {
    
    // MARK: - Use singleton pattern to pass speech data between view controllers.
    static let sharedInstance = AppNavigation()
    
//    public let defaultContentBackgroundColor = "#FFF1E5"
//    public let defaultTabFontColor = "#333333"
//    public let defaultHeaderColor = "#333333"
//    public let highlightedTabFontColor = "#c0282e"
//    public let normalTabFontColor = "#555555"
//    public let defaultBorderColor = "#d4c9bc"
//    public let headlineColor = "#33302d"
//    public let leadColor = "#66605a"
//    public let adBackground = "#f6e9d8"
//    public let channelScrollerBackground = "#e8dbcb"
//    public let channelScrollerHighlight = "#c0282c"
//    public let channelScrollerColor = "#565656"
//    public let navigationBorderColor = "#d5c6b3"
    
    private static let appMap = [
        "News": [
            "title": "FT中文网",
            "navColor": "#333333",
            "navBackGroundColor": "#f7e9d8",
            "isNavLightContent": false,
            "Channels": [
                ["title": "头条",
                 "api":"https://www.ftchinese.com/index.php/jsapi/home",
                 "url":"https://www.ftchinese.com/"
                ],
                ["title": "中国",
                 "api":"https://www.ftchinese.com/channel/china.html?type=json",
                 "url":"http://www.ftchinese.com/channel/china.html",
                 "compactLayout": "Simple Headline",
                 "regularLayout": ""
                ],
                ["title": "全球",
                 "api":"https://www.ftchinese.com/channel/world.html?type=json",
                 "url":"http://www.ftchinese.com/channel/world.html"
                ],
                ["title": "金融市场",
                 "api":"https://www.ftchinese.com/channel/markets.html?type=json",
                 "url":"http://www.ftchinese.com/channel/markets.html"
                ],
                ["title": "管理",
                 "api":"https://www.ftchinese.com/channel/management.html?type=json",
                 "url":"http://www.ftchinese.com/channel/management.html"
                ],
                ["title": "生活时尚",
                 "api":"https://www.ftchinese.com/channel/lifestyle.html?type=json",
                 "url":"http://www.ftchinese.com/channel/lifestyle.html"
                ],
                ["title": "专栏",
                 "api":"https://www.ftchinese.com/channel/column.html?type=json",
                 "url":"http://www.ftchinese.com/channel/column.html"
                ],
                ["title": "热门文章",
                 "api":"https://www.ftchinese.com/channel/weekly.html?type=json",
                 "url":"http://www.ftchinese.com/channel/weekly.html",
                 "compactLayout": "Simple Headline",
                 "regularLayout": ""
                ],
                ["title": "数据新闻",
                 "api":"https://www.ftchinese.com/channel/datanews.html?type=json",
                 "url":"http://www.ftchinese.com/channel/datanews.html"
                ]
            ]
        ],
        "English": [
            "title": "每日英语",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#a84358",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://www.ftchinese.com/channel/english.html?type=json",
                 "url":"http://www.ftchinese.com/channel/english.html"
                ],
                ["title": "英语电台",
                 "api":"https://www.ftchinese.com/channel/radio.html?type=json",
                 "url":"http://www.ftchinese.com/channel/radio.html"
                ],
                ["title": "双语阅读",
                 "api":"https://www.ftchinese.com/channel/ce.html?type=json",
                 "url":"http://www.ftchinese.com/channel/ce.html"
                ],
                ["title": "金融英语速读",
                 "api":"https://www.ftchinese.com/channel/speedread.html?type=json",
                 "url":"http://www.ftchinese.com/channel/speedread.html"
                ],
                ["title": "原声视频",
                 "api":"https://www.ftchinese.com/channel/ev.html?type=json",
                 "url":"http://www.ftchinese.com/channel/ev.html"
                ]
            ]
        ],
        "Academy": [
            "title": "FT商学院",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#057b93",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://www.ftchinese.com/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html"
                ],
                ["title": "热点观察",
                 "api":"https://www.ftchinese.com/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html"
                ],
                ["title": "MBA训练营",
                 "api":"https://www.ftchinese.com/channel/mbagym.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mbagym.html"
                ],
                ["title": "互动小测",
                 "api":"https://www.ftchinese.com/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html"
                ],
                ["title": "深度阅读",
                 "api":"https://www.ftchinese.com/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html"
                ]
            ]
        ],
        "Video": [
            "title": "视频",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#008280",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://www.ftchinese.com/channel/stream.html?type=json",
                 "url":"http://www.ftchinese.com/channel/stream.html"
                ],
                ["title": "商业",
                 "api":"https://www.ftchinese.com/channel/business.html?type=json",
                 "url":"http://www.ftchinese.com/channel/business.html"
                ],
                ["title": "政经",
                 "api":"https://www.ftchinese.com/channel/vpolitics.html?type=json",
                 "url":"http://www.ftchinese.com/channel/vpolitics.html"
                ],
                ["title": "有色眼镜",
                 "api":"https://www.ftchinese.com/channel/videotinted.html?type=json",
                 "url":"http://www.ftchinese.com/channel/videotinted.html"
                ]
            ]
        ],
        "MyFT": [
            "title": "我的FT",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#5a8caf",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://www.ftchinese.com/users/mystories?type=json",
                 "url":"http://www.ftchinese.com/users/mystories"
                ],
                ["title": "阅读偏好",
                 "api":"https://www.ftchinese.com/users/mytopics?type=json",
                 "url":"http://www.ftchinese.com/users/mytopics"
                ],
                ["title": "订阅",
                 "api":"https://www.ftchinese.com/users/favstorylist?type=json",
                 "url":"http://www.ftchinese.com/users/favstorylist"
                ],
                ["title": "账号",
                 "api":"https://www.ftchinese.com/users/discover?type=json",
                 "url":"http://www.ftchinese.com/users/discover"
                ]
            ]
        ]
    ]
    
    
    public func getNavigation(for tabName: String) -> [String]? {
        if let currentNavigation = AppNavigation.appMap[tabName]?["Channels"] as? [String] {
            return currentNavigation
        }
        return nil
    }
    
    public func getNavigationProperty(for tabName: String, of property: String) -> String? {
        if let p = AppNavigation.appMap[tabName]?[property] as? String {
            return p
        }
        return nil
    }
    
    public func isNavigationPropertyTrue(for tabName: String, of property: String) -> Bool {
        if let p = AppNavigation.appMap[tabName]?[property] as? Bool {
            return p
        }
        return false
    }
    
    public func getNavigationPropertyData(for tabName: String, of property: String) -> [[String: String]]? {
        if let p = AppNavigation.appMap[tabName]?[property] as? [[String: String]] {
            return p
        }
        return nil
    }
    
    
    // MARK: Ad Constants
    private let adBaseUrl = "http://www.ftchinese.com/m/marketing/a.html"
    public func getAdPageUrlForAdId(_ adid: String) -> String {
        
        return "\(adBaseUrl)#adid=\(adid)"
    }
    
}
