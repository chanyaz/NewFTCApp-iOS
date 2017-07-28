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
    private static let appMap = [
        "News": [
            "title": "FT中文网",
            "navColor": "#333333",
            "navBackGroundColor": "#f7e9d8",
            "isNavLightContent": false,
            "Channels": [
                ["title": "首页",
                 "api":"https://danla2f5eudt1.cloudfront.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/",
                 "screenName":"homepage"
                ],
                ["title": "中国",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/china.html?type=json",
                 "url":"http://www.ftchinese.com/channel/china.html",
                 "compactLayout": "Simple Headline",
                 "regularLayout": "",
                 "screenName":"homepage/china"
                ],
                ["title": "全球",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/world.html?type=json",
                 "url":"http://www.ftchinese.com/channel/world.html",
                 "screenName":"homepage/world"
                ],
                ["title": "金融市场",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/markets.html?type=json",
                 "url":"http://www.ftchinese.com/channel/markets.html",
                 "screenName":"homepage/markets"
                ],
                ["title": "管理",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/management.html?type=json",
                 "url":"http://www.ftchinese.com/channel/management.html",
                 "screenName":"homepage/management"
                ],
                ["title": "生活时尚",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/lifestyle.html?type=json",
                 "url":"http://www.ftchinese.com/channel/lifestyle.html",
                 "screenName":"homepage/lifestyle"
                ],
                ["title": "专栏",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/column.html?type=json",
                 "url":"http://www.ftchinese.com/channel/column.html",
                 "screenName":"homepage/column"
                ],
                ["title": "热门文章",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/weekly.html?type=json",
                 "url":"http://www.ftchinese.com/channel/weekly.html",
                 "compactLayout": "Simple Headline",
                 "regularLayout": "",
                 "screenName":"homepage/mostpopular"
                ],
                ["title": "数据新闻",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/datanews.html?type=json",
                 "url":"http://www.ftchinese.com/channel/datanews.html",
                 "screenName":"homepage/datanews"
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
                 "api":"https://danla2f5eudt1.cloudfront.net/index.php/jsapi/publish/test2",
                 "url":"http://www.ftchinese.com/channel/english.html",
                 "screenName":"english"
                ],
                ["title": "英语电台",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/radio.html?type=json",
                 "url":"http://www.ftchinese.com/channel/radio.html",
                 "screenName":"english/radio"
                ],
                ["title": "双语阅读",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/ce.html?type=json",
                 "url":"http://www.ftchinese.com/channel/ce.html",
                 "screenName":"english/read"
                ],
                ["title": "金融英语速读",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/speedread.html?type=json",
                 "url":"http://www.ftchinese.com/channel/speedread.html",
                 "screenName":"english/speedread"
                ],
                ["title": "原声视频",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/ev.html?type=json",
                 "url":"http://www.ftchinese.com/channel/ev.html",
                 "screenName":"english/video"
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
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy"
                ],
                ["title": "热点观察",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy/hottopic"
                ],
                ["title": "MBA训练营",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/mbagym.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mbagym.html",
                 "screenName":"ftacademy/mbagym"
                ],
                ["title": "互动小测",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy/quiz"
                ],
                ["title": "深度阅读",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy/read"
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
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/stream.html?type=json",
                 "url":"http://www.ftchinese.com/channel/stream.html",
                 "screenName":"video"
                ],
                ["title": "商业",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/business.html?type=json",
                 "url":"http://www.ftchinese.com/channel/business.html",
                 "screenName":"ftacademy/business"
                ],
                ["title": "政经",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/vpolitics.html?type=json",
                 "url":"http://www.ftchinese.com/channel/vpolitics.html",
                 "screenName":"ftacademy/politics"
                ],
                ["title": "有色眼镜",
                 "api":"https://danla2f5eudt1.cloudfront.net/channel/videotinted.html?type=json",
                 "url":"http://www.ftchinese.com/channel/videotinted.html",
                 "screenName":"ftacademy/tinted"
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
                 "api":"https://danla2f5eudt1.cloudfront.net/users/mystories?type=json",
                 "url":"http://www.ftchinese.com/users/mystories",
                 "screenName":"myft"
                ],
                ["title": "阅读偏好",
                 "api":"https://danla2f5eudt1.cloudfront.net/users/mytopics?type=json",
                 "url":"http://www.ftchinese.com/users/mytopics",
                 "screenName":"myft/preference"
                ],
                ["title": "订阅",
                 "api":"https://danla2f5eudt1.cloudfront.net/users/favstorylist?type=json",
                 "url":"http://www.ftchinese.com/users/favstorylist",
                 "screenName":"myft/subscription"
                ],
                ["title": "账号",
                 "api":"https://danla2f5eudt1.cloudfront.net/users/discover?type=json",
                 "url":"http://www.ftchinese.com/users/discover",
                 "screenName":"myft/account"
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
    
    
    
    
}
