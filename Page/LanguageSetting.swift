//
//  LanguageSetting.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/20.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation

struct LanguageSetting {
    static var shared = LanguageSetting()
    var currentPrefence = 0
    let interfaceDictionary = ["置顶": "置頂", "视频": "視頻", "订阅": "訂閲", "账户": "賬戶", "流量与缓存": "流量與緩存", "标签": "標籤", "双语阅读": "雙語閲讀", "全球": "全球", "字号设置": "字號設置", "关于我们": "關於我們", "英语电台": "英語電台", "我的FT": "我的FT", "FTCC": "FTCC", "话题": "話題", "金融英语速读": "金融英語速讀", "深度阅读": "深度閲讀", "行业": "行業", "关注": "關注", "收藏": "收藏", "高端视点": "高端視點", "非洲": "非洲", "科技": "科技", "首页": "首頁", "隐私协议": "隱私協議", "FT电子书": "FT電子書", "政经": "政經", "秒懂": "秒懂", "小测": "小測", "每日英语": "每日英語", "语言偏好": "語言偏好", "反馈": "反饋", "MBA训练营": "MBA訓練營", "热门文章": "熱門文章", "作者": "作者", "最新": "最新", "SurveyPlus": "SurveyPlus", "测试": "測試", "App Store评分": "App Store評分", "已读": "已讀", "互动小测": "互動小測", "热点观察": "熱點觀察", "金融市场": "金融市場", "设置": "設置", "文化": "文化", "FT商学院": "FT商學院", "专栏": "專欄", "FT研究院": "FT研究院", "数据新闻": "數據新聞", "媒体": "媒體", "金融": "金融", "阅读偏好": "閲讀偏好", "低调": "低調", "管理": "管理", "中国": "中國", "单选题": "單選題", "使用数据时不下载图片": "使用數據時不下載圖片", "商业": "商業", "QuizPlus": "QuizPlus", "清除缓存": "清除緩存", "商学院观察": "商學院觀察", "生活时尚": "生活時尚", "精华": "精華", "新闻": "新聞", "栏目": "欄目", "美国": "美國", "地区": "地區", "原声视频": "原聲視頻", "欧洲": "歐洲", "新闻推送": "新聞推送", "教程": "教程", "服务与反馈": "服務與反饋", "FT中文网": "FT中文網", "有色眼镜": "有色眼鏡", "会议活动": "會議活動"]
}

struct GB2Big5 {
    static func convert(_ from: String) -> String {
        if LanguageSetting.shared.currentPrefence == 0 {
            return from
        }
        if let big5String = LanguageSetting.shared.interfaceDictionary[from] {
            return big5String
        }
        return from
    }
    
    // MARK: - Do NOT DELETE. Playground tool to generate big 5 dictionary to convert just the simplified charaters used in interface. This way you don't have to embed a GB2Big5 library, which makes the app bigger and might cause performance issues.
    /*
    static func createDict() {
        var gbWords = "FT中文网"
        for (_, value) in AppNavigation.appMap {
            if let title = value["title"] {
                gbWords += ",\(title)"
            }
            if let channels = value["Channels"] as? [[String: String]] {
                for channel in channels {
                    if let channelTitle = channel["title"] {
                        gbWords += ",\(channelTitle)"
                    }
                }
            }
        }
        for value in Meta.map {
            if let name = value["name"] {
                gbWords += ",\(name)"
            }
            if let meta = value["meta"] as? [String: String] {
                for (_, value) in meta {
                    gbWords += ",\(value)"
                }
            }
        }
        for value in Meta.reservedTags {
            gbWords += ",\(value)"
        }
        for contentSection in Settings.page {
            gbWords += ",\(contentSection.title)"
            for item in contentSection.items {
                gbWords += ",\(item.headline)"
            }
        }
        print (gbWords)
    }
    
    static func makeDict(firstString: String, secondString: String) -> [String: String]{
        var dict = [String: String]()
        let firstArray = firstString.components(separatedBy: ",")
        let secondArray = secondString.components(separatedBy: ",")
        if firstArray.count > 0 && firstArray.count == secondArray.count {
            for i in 0..<firstArray.count {
                dict[firstArray[i]] = secondArray[i]
            }
        }
        print (dict)
        return dict
    }
    
     */
}
