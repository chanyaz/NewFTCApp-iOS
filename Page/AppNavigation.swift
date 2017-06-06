//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct AppNavigation {
    private static let appMap = [
        "新闻": ["首页","中国","全球","金融市场","管理","生活时尚","专栏"],
        "每日英语": ["最新","英语电台","双语阅读","金融英语速读","原声视频"],
        "FT商学院": ["最新","热点观察","MBA训练营","互动小测","深度阅读"],
        "我的FT": ["最新","阅读历史","猜你喜欢","收藏"],
        "设置": ["用户","阅读习惯","订阅","帮助与反馈"]
    ]
    public func getNavigation(for tabName: String) -> [String]? {
        if let currentNavigation = AppNavigation.appMap[tabName] {
            return currentNavigation
        }
        return nil
    }
}
