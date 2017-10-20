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
    let interfaceDictionary = ["置顶": "置頂", "视频": "視頻", "账户": "賬戶", "流量与缓存": "流量與緩存", "名": "名", "标签": "標籤", "双语阅读": "雙語閲讀", "全球": "全球", "字号设置": "字號設置", "关于我们": "關於我們", "较小": "較小", "微信": "微信", "英语电台": "英語電台", "我的FT": "我的FT", "话题": "話題", "金融英语速读": "金融英語速讀", "深度阅读": "深度閲讀", "行业": "行業", "收藏": "收藏", "特别报导": "特別報導", "关注": "關注", "高端视点": "高端視點", "非洲": "非洲", "繁體字": "繁體字", "科技": "科技", "首页": "首頁", "隐私协议": "隱私協議", "登录": "登錄", "FT电子书": "FT電子書", "政经": "政經", "秒懂": "秒懂", "小测": "小測", "每日英语": "每日英語", "语言偏好": "語言偏好", "反馈": "反饋", "免费": "免費", "MBA训练营": "MBA訓練營", "热门文章": "熱門文章", "最大": "最大", "作者": "作者", "最新": "最新", "SurveyPlus": "SurveyPlus", "测试": "測試", "App Store评分": "App Store評分", "已读": "已讀", "互动小测": "互動小測", "简体字": "簡體字", "热点观察": "熱點觀察", "金融市场": "金融市場", "设置": "設置", "文化": "文化", "FT商学院": "FT商學院", "专栏": "專欄", "FT研究院": "FT研究院", "数据新闻": "數據新聞", "媒体": "媒體", "金融": "金融", "阅读偏好": "閲讀偏好", "最小": "最小", "用户": "用戶", "低调": "低調", "管理": "管理", "中国": "中國", "单选题": "單選題", "使用数据时不下载图片": "使用數據時不下載圖片", "商业": "商業", "较大": "較大", "QuizPlus": "QuizPlus", "清除缓存": "清除緩存", "商学院观察": "商學院觀察", "生活时尚": "生活時尚", "精华": "精華", "新闻": "新聞", "栏目": "欄目", "默认": "默認", "美国": "美國", "地区": "地區", "原声视频": "原聲視頻", "欧洲": "歐洲", "新闻推送": "新聞推送", "密码": "密碼", "教程": "教程", "服务与反馈": "服務與反饋", "FT中文网": "FT中文網", "注册": "註冊", "有色眼镜": "有色眼鏡", "会议活动": "會議活動"]
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
        for contentSection in Settings.page {
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
        for value in ["登录","微信","免费","注册","用户","名","密码"] {
            gbWords += ",\(value)"
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
        let firstString = "FT中文网,FT商学院,热点观察,MBA训练营,互动小测,商学院观察,深度阅读,每日英语,英语电台,双语阅读,金融英语速读,原声视频,FT中文网,首页,中国,全球,金融市场,管理,生活时尚,专栏,特别报导,热门文章,数据新闻,会议活动,FT研究院,FT电子书,我的FT,已读,收藏,关注,设置,账户,视频,最新,政经,商业,秒懂,金融,文化,高端视点,有色眼镜,标签,话题,生活时尚,商业,管理,金融市场,地区,欧洲,非洲,美国,中国,行业,科技,媒体,作者,栏目,QuizPlus,单选题,SurveyPlus,置顶,低调,精华,小测,生活时尚,深度阅读,教程,测试,FT商学院,英语电台,视频,新闻,数据新闻,阅读偏好,字号设置,语言偏好,新闻推送,流量与缓存,清除缓存,使用数据时不下载图片,服务与反馈,反馈,App Store评分,隐私协议,关于我们,简体字,繁體字,最小,较小,默认,较大,最大,登录,微信,免费,注册,用户,名,密码"
        let secondString = "FT中文網,FT商學院,熱點觀察,MBA訓練營,互動小測,商學院觀察,深度閲讀,每日英語,英語電台,雙語閲讀,金融英語速讀,原聲視頻,FT中文網,首頁,中國,全球,金融市場,管理,生活時尚,專欄,特別報導,熱門文章,數據新聞,會議活動,FT研究院,FT電子書,我的FT,已讀,收藏,關注,設置,賬戶,視頻,最新,政經,商業,秒懂,金融,文化,高端視點,有色眼鏡,標籤,話題,生活時尚,商業,管理,金融市場,地區,歐洲,非洲,美國,中國,行業,科技,媒體,作者,欄目,QuizPlus,單選題,SurveyPlus,置頂,低調,精華,小測,生活時尚,深度閲讀,教程,測試,FT商學院,英語電台,視頻,新聞,數據新聞,閲讀偏好,字號設置,語言偏好,新聞推送,流量與緩存,清除緩存,使用數據時不下載圖片,服務與反饋,反饋,App Store評分,隱私協議,關於我們,簡體字,繁體字,最小,較小,默認,較大,最大,登錄,微信,免費,註冊,用戶,名,密碼"
        return makeDict(firstString: firstString, secondString: secondString)
    }

 */
}
