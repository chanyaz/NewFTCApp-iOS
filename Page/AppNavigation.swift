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
    
    public let defaultTabBackgroundColor = "#FFEFEF"
    public let defaultContentBackgroundColor = "#FFF1E5"
    public let defaultTabFontColor = "#333333"
    public let highlightedTabFontColor = "#9E2F50"
    public let normalTabFontColor = "#555555"
    public let defaultBorderColor = "#777777"
    
    private static let appMap = [
        "News": [
            "title": "FT中文网",
            "navColor": "#333333",
            "navBackGroundColor": "#FFF1E5",
            "isNavLightContent": false,
            "Channels": ["头条","中国","全球","金融市场","管理","生活时尚","专栏"]
        ],
        "English": [
            "title": "每日英语",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#0F5499",
            "isNavLightContent": true,
            "Channels": ["最新","英语电台","双语阅读","金融英语速读","原声视频"]
        ],
        "Academy": [
            "title": "FT商学院",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#00757F",
            "isNavLightContent": true,
            "Channels": ["最新","热点观察","MBA训练营","互动小测","深度阅读"]
        ],
        "Video": [
            "title": "视频",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#333333",
            "isNavLightContent": true,
            "Channels": ["最新","商业","政经","有色眼镜"]
        ],
        "MyFT": [
            "title": "我的FT",
            "navColor": "#333333",
            "navBackGroundColor": "#FFF1E5",
            "isNavLightContent": false,
            "Channels": ["最新","阅读历史","猜你喜欢","收藏","设置"]
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
    
}
