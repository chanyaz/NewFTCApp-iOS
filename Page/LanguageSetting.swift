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
    let interfaceDictionary = ["置顶": "置頂", "文章收藏": "文章收藏", "视频": "視頻", "账户": "賬戶", "流量与缓存": "流量與緩存", "标签": "標簽", "双语阅读": "雙語閱讀", "全球": "全球", "字号设置": "字號設置", "关于我们": "關於我們", "较小": "較小", "订阅服务": "訂閱服務", "英语电台": "英語電臺", "我的FT": "我的FT", "教育": "教育", "话题": "話題", "金融英语速读": "金融英語速讀", "深度阅读": "深度閱讀", "行业": "行業", "收藏": "收藏", "特别报导": "特別報導", "关注": "關註", "高端视点": "高端視點", "非洲": "非洲", "会员订阅": "會員訂閱", "科技": "科技", "首页": "首頁", "独家": "獨家", "繁體字": "繁體字", "隐私协议": "隱私協議", "FT电子书": "FT電子書", "政经": "政經", "秒懂": "秒懂", "小测": "小測", "每日英语": "每日英語", "语言偏好": "語言偏好", "反馈": "反饋", "MBA训练营": "MBA訓練營", "热门文章": "熱門文章", "最大": "最大", "作者": "作者", "最新": "最新", "SurveyPlus": "SurveyPlus", "夜间模式": "夜間模式", "测试": "測試", "观点": "觀點", "App Store评分": "App Store評分", "已读": "已讀", "互动小测": "互動小測", "简体字": "簡體字", "热点观察": "熱點觀察", "金融市场": "金融市場", "设置": "設置", "文化": "文化", "FT商学院": "FT商學院", "专栏": "專欄", "FT研究院": "FT研究院", "数据新闻": "數據新聞", "媒体": "媒體", "金融": "金融", "阅读偏好": "閱讀偏好", "客服": "客服", "最小": "最小", "低调": "低調", "管理": "管理", "中国": "中國", "单选题": "單選題", "使用数据时不下载图片": "使用數據時不下載圖片", "商业": "商業", "较大": "較大", "QuizPlus": "QuizPlus", "搜索历史": "搜索歷史", "输入关键字开始搜索": "輸入關鍵字開始搜索", "清除缓存": "清除緩存", "商学院观察": "商學院觀察", "生活时尚": "生活時尚", "FT商城": "FT商城", "精华": "精華", "新闻": "新聞", "我的订阅": "我的訂閱", "栏目": "欄目", "默认": "默認", "美国": "美國", "地区": "地區", "原声视频": "原聲視頻", "编辑精选": "編輯精選", "欧洲": "歐洲", "教程": "教程", "服务与反馈": "服務與反饋", "FT中文网": "FT中文網", "有色眼镜": "有色眼鏡", "会议活动": "會議活動"]
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
    
    static func convert(_ from: [ContentSection]) -> [ContentSection] {
        if LanguageSetting.shared.currentPrefence == 0 {
            return from
        }
        let to = from
        for section in from {
            section.title = convert(section.title)
            for item in section.items {
                item.headline = convert(item.headline)
            }
        }
        return to
    }
    
    static func convertHTMLFileName(_ from: String) -> String {
        if LanguageSetting.shared.currentPrefence == 0 {
            return from
        }
        return "\(from)-big5"
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
        let settings = Settings.page + Settings.subscriberContact
        for contentSection in settings {
            gbWords += ",\(contentSection.title)"
            for item in contentSection.items {
                gbWords += ",\(item.headline)"
            }
        }
        for (_, value) in Setting.options {
            for word in value {
                gbWords += ",\(word)"
            }
        }
        for word in ["搜索历史","输入关键字开始搜索"] {
            gbWords += ",\(word)"
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
    
    static func makeMyDict() -> [String: String] {
        let firstString = "FT中文网,FT商学院,商学院观察,热点观察,MBA训练营,互动小测,深度阅读,每日英语,英语电台,金融英语速读,双语阅读,原声视频,FT中文网,首页,中国,独家,编辑精选,全球,观点,专栏,金融市场,商业,科技,教育,管理,生活时尚,特别报导,热门文章,数据新闻,会议活动,FT研究院,文章收藏,FT电子书,我的FT,设置,会员订阅,已读,收藏,关注,账户,FT商城,视频,最新,政经,商业,秒懂,金融,文化,高端视点,有色眼镜,标签,话题,生活时尚,商业,管理,金融市场,地区,欧洲,非洲,美国,中国,行业,科技,媒体,作者,栏目,QuizPlus,单选题,SurveyPlus,置顶,低调,精华,小测,生活时尚,深度阅读,教程,测试,FT商学院,英语电台,视频,新闻,数据新闻,阅读偏好,字号设置,语言偏好,夜间模式,流量与缓存,清除缓存,使用数据时不下载图片,服务与反馈,反馈,App Store评分,隐私协议,关于我们,订阅服务,我的订阅,客服,简体字,繁體字,最小,较小,默认,较大,最大,搜索历史,输入关键字开始搜索"
        let secondString = "FT中文網,FT商學院,商學院觀察,熱點觀察,MBA訓練營,互動小測,深度閱讀,每日英語,英語電臺,金融英語速讀,雙語閱讀,原聲視頻,FT中文網,首頁,中國,獨家,編輯精選,全球,觀點,專欄,金融市場,商業,科技,教育,管理,生活時尚,特別報導,熱門文章,數據新聞,會議活動,FT研究院,文章收藏,FT電子書,我的FT,設置,會員訂閱,已讀,收藏,關註,賬戶,FT商城,視頻,最新,政經,商業,秒懂,金融,文化,高端視點,有色眼鏡,標簽,話題,生活時尚,商業,管理,金融市場,地區,歐洲,非洲,美國,中國,行業,科技,媒體,作者,欄目,QuizPlus,單選題,SurveyPlus,置頂,低調,精華,小測,生活時尚,深度閱讀,教程,測試,FT商學院,英語電臺,視頻,新聞,數據新聞,閱讀偏好,字號設置,語言偏好,夜間模式,流量與緩存,清除緩存,使用數據時不下載圖片,服務與反饋,反饋,App Store評分,隱私協議,關於我們,訂閱服務,我的訂閱,客服,簡體字,繁體字,最小,較小,默認,較大,最大,搜索歷史,輸入關鍵字開始搜索"
        return makeDict(firstString: firstString, secondString: secondString)
    }
*/
    
}
