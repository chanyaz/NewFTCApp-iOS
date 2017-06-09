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
    
    public let defaultTabBackgroundColor = "#f7e9d8"
    public let defaultContentBackgroundColor = "#FFF1E5"
    public let defaultTabFontColor = "#333333"
    public let highlightedTabFontColor = "#c0282e"
    public let normalTabFontColor = "#555555"
    public let defaultBorderColor = "#d4c9bc"
    
    private static let appMap = [
        "News": [
            "title": "FT中文网",
            "navColor": "#333333",
            "navBackGroundColor": "#f7e9d8",
            "isNavLightContent": false,
            "Channels": [
                ["title": "头条",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "中国",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "全球",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "金融市场",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "管理",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "生活时尚",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "专栏",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
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
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "英语电台",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "双语阅读",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "金融英语速读",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "原声视频",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
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
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "热点观察",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "MBA训练营",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "互动小测",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "深度阅读",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
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
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "商业",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "政经",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
                ],
                ["title": "有色眼镜",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/"
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
