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
    public static let appMap = [
        "News": [
            "title": "FT中文网",
            "title-image":(day: "FTC-Header", night: "FTC-Header-Night"),
            "navColor": (day: "#333333", night: "#AAAAAA"),
            "navBackGroundColor": (day: "#f7e9d8", night: "#000000"),
            "navBorderColor": (day: "#d5c6b3", night: "#000000"),
            "navBorderWidth": "1",
            "isNavLightContent": false,
            "navRightItem": "Search",
            "navLeftItem": "Chat",
            "Channels": [
                [
                    "title": "首页",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/index.php/jsapi/publish/home",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=home&dfadfadfadfadf",
                    "url":"http://www.ftchinese.com/?webview=ftcapp&newad=yes",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/?webview=ftcapp&bodyonly=yes&newad=yes&maxB=1&backupfile=localbackup&showIAP=yes&018",
                    "compactLayout": "home",
                    "coverTheme": "Classic",
                    "screenName":"homepage",
                    "Insert Content": "home"
                ],
                [
                    "title": "中国",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/china.html?type=json&001",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/china.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/china.html?newad=yes",
                    "regularLayout": "",
                    "screenName":"homepage/china",
                    "coverTheme":"Wheat"
                ],

//                [
//                    "title": "新测试",
//                    "api":"https://d37m993yiqhccr.cloudfront.net/index.php/jsapi/publish/test",
//                    "regularLayout": "",
//                    "compactLayout": "SmoothCover-No-Ad",
//                    "coverTheme": "OutOfBox-Blue",
//                    "url":"http://www.ftchinese.com/channel/datanews.html",
//                    "screenName":"homepage/ftcc"
//                ],
//                [
//                    "title": "测试",
//                    "api":"https://d37m993yiqhccr.cloudfront.net/index.php/jsapi/publish/test",
//                    "regularLayout": "",
//                    "compactLayout": "OutOfBox-No-Ad",
//                    "coverTheme": "OutOfBox-Blue",
//                    "url":"http://www.ftchinese.com/channel/datanews.html",
//                    "screenName":"homepage/ftcc"
//                ],

                [
                    "title": "全球",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/world.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/world.html?webview=ftcapp&bodyonly=yes&newad=yes&002",
                    "url":"http://www.ftchinese.com/channel/world.html?newad=yes",
                    "screenName":"homepage/world",
                    "coverTheme":"Pink"
                ],
                [
                    "title": "观点",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/column.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/opinion.html?webview=ftcapp&bodyonly=yes&newad=yes&ad=no",
                    "url":"http://www.ftchinese.com/channel/opinion.html?newad=yes",
                    "screenName":"homepage/opinion",
                    "coverTheme": "Opinion"
                ],
                [
                    "title": "专栏",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/column.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/column.html?webview=ftcapp&bodyonly=yes&newad=yes&ad=no",
                    "url":"http://www.ftchinese.com/channel/column.html?newad=yes",
                    "screenName":"homepage/column",
                    "coverTheme": "Opinion"
                ],
                [
                    "title": "金融市场",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/markets.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/markets.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/markets.html?newad=yes",
                    "screenName":"homepage/markets",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "商业",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/markets.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/markets.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/markets.html?newad=yes",
                    "screenName":"homepage/business",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "科技",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/markets.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/technology.html?webview=ftcapp&bodyonly=yes&newad=yes&001",
                    "url":"http://www.ftchinese.com/channel/technology.html?newad=yes",
                    "screenName":"homepage/technology",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "管理",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/management.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/management.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/management.html?newad=yes",
                    "screenName":"homepage/management",
                    "coverTheme": "Blue"
                ],
//                [
//                    "title": "思维播客",
//                    "api":"https://d37m993yiqhccr.cloudfront.net/index.php/jsapi/publish/ftcc",
//                    "regularLayout": "",
//                    "compactLayout": "OutOfBox-No-Ad",
//                    "coverTheme": "OutOfBox-Blue",
//                    "url":"http://www.ftchinese.com/channel/datanews.html",
//                    "screenName":"homepage/ftcc"
//                ],
                [
                    "title": "生活时尚",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/lifestyle.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/lifestyle.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/lifestyle.html?newad=yes",
                    "screenName":"homepage/lifestyle",
                    "compactLayout": "OutOfBox",
                    "coverTheme": "OutOfBox-LifeStyle"
                ],
                [
                    "title": "特别报导",
                    //"api":"https://d37m993yiqhccr.cloudfront.net/channel/column.html?type=json",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/special.html?webview=ftcapp&bodyonly=yes&newad=yes&ad=no&001",
                    // MARK: Use the keeplinks parameter to tell web view that there's no need to replace the links in this page
                    "url":"http://www.ftchinese.com/channel/special.html?newad=yes&ad=no&keeplinks=yes",
                    "screenName":"homepage/special",
                    "coverTheme": "Opinion"
                ],
                [
                    "title": "热门文章",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=hot",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/weekly.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/weekly.html?newad=yes",
                    "compactLayout": "OutOfBox",
                    "regularLayout": "",
                    "coverTheme": "OutOfBox",
                    "screenName":"homepage/mostpopular"
                ],
                [
                    "title": "数据新闻",
                    //"api":"https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=datanews",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/datanews.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/datanews.html?newad=yes",
                    "screenName":"homepage/datanews",
                    "compactLayout": "OutOfBox",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "会议活动",
                    "url":"http://www.ftchinese.com/m/events/event.html?webview=ftcapp&newad=yes",
                    "screenName":"homepage/events"
                ],
                [
                    "title": "FT研究院",
                    "url":"http://www.ftchinese.com/m/marketing/intelligence.html?webview=ftcapp&001&newad=yes",
                    "screenName":"homepage/ftintelligence"
                ],
                [
                    "title": "文章收藏",
                    "type": "clip",
                    "url":"http://app003.ftmailbox.com/users/favstorylist?webview=ftcapp",
                    "screenName":"myft",
                    "compactLayout": ""
                ],
                [
                    "title": "FT电子书",
                    "type": "iap",
                    "subtype":"ebook",
                    "compactLayout": "books",
                    "screenName":"homepage/ebook"
                ]
            ]
        ],
        "English": [
            "title": "每日英语",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#a84358",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "英语电台",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=radio&dfadfadfadfadf",
                    "listapi":"https://d1budb999l6vta.cloudfront.net/channel/radio.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/radio.html?webview=ftcapp&newad=yes",
                    "screenName":"english/radio",
                    "coverTheme": ""
                ],
                [
                    "title": "双语阅读",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=ce&dfadfadfadfadf",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/ce.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/ce.html?webview=ftcapp&newad=yes",
                    "screenName":"english/read",
                    "coverTheme": ""
                ],
                [
                    "title": "金融英语速读",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=speedread&dfadfadfadfadf",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/speedread.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/speedread.html?webview=ftcapp&newad=yes",
                    "screenName":"english/speedread",
                    "coverTheme": ""
                ],
                [
                    "title": "原声视频",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=ev&dfadfadfadfadf",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/ev.html?webview=ftcapp&bodyonly=yes&newad=yes&001",
                    "url":"http://www.ftchinese.com/channel/ev.html?webview=ftcapp&newad=yes",
                    "screenName":"english/video",
                    "coverTheme": ""
                ],
                [
                    "title": "Exclusive Content",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=ev&dfadfadfadfadf",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/editorchoice.html?webview=ftcapp&bodyonly=yes&ad=no&018",
                    "url":"http://www.ftchinese.com/channel/editorchoice.html?webview=ftcapp&newad=yes&ad=no",
                    "screenName":"english/video",
                    "coverTheme": ""
                ]
            ]
        ],
        "Academy": [
            "title": "FT商学院",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#057b93",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "热点观察",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=hotcourse",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=hotcourse&webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/m/corp/preview.html?pageid=hotcourse&newad=yes",
                    "screenName":"ftacademy/hottopic",
                    "compactLayout": "OutOfBox",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "MBA训练营",
                    //"api":"https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=mbacamp",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/mbagym.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/mbagym.html?webview=ftcapp&newad=yes",
                    "screenName":"ftacademy/mbagym",
                    "compactLayout": "OutOfBox",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "互动小测",
                    //"api":"https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=quizplus",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=quizplus&webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/mba.html?newad=yes",
                    "screenName":"ftacademy/quiz",
                    "compactLayout": "OutOfBox",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "商学院观察",
                    //"api":"https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=mbastory",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=mbastory&webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/mba.html?newad=yes",
                    "screenName":"ftacademy/mbastory",
                    "compactLayout": "OutOfBox",
                    "coverTheme": "OutOfBox"
                ],
                [
                    "title": "深度阅读",
                    //"api":"https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=mbaread",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=mbaread&webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/mba.html?newad=yes",
                    "screenName":"ftacademy/read",
                    "compactLayout": "OutOfBox",
                    "coverTheme": "OutOfBox"
                ]
            ]
        ],
        "Video": [
            "title": "视频",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#008280",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "最新",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=stream",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/stream.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/stream.html?webview=ftcapp&newad=yes",
                    "coverTheme": "Video",
                    "compactLayout": "Video",
                    "screenName":"video"
                ],
                [
                    "title": "政经",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=vpolitics",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/vpolitics.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/vpolitics.html?webview=ftcapp&newad=yes",
                    "screenName":"video/politics",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "商业",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=vbusiness",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/vbusiness.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/vbusiness.html?webview=ftcapp&newad=yes",
                    "screenName":"video/business",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "秒懂",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=explainer",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/explainer.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/explainer.html?webview=ftcapp&newad=yes",
                    "screenName":"video/business",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "金融",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=vfinance",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/vfinance.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/vfinance.html?webview=ftcapp&newad=yes",
                    "screenName":"video/finance",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "文化",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=vculture",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/vculture.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/vculture.html?webview=ftcapp&newad=yes",
                    "screenName":"video/culture",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "高端视点",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=viewtop",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/viewtop.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/viewtop.html?webview=ftcapp&newad=yes",
                    "screenName":"video/viewtop",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "有色眼镜",
                    //"api": "https://d1budb999l6vta.cloudfront.net/channel/json.html?pageid=tinted",
                    "listapi": "https://d1budb999l6vta.cloudfront.net/channel/videotinted.html?webview=ftcapp&bodyonly=yes&newad=yes",
                    "url":"http://www.ftchinese.com/channel/videotinted.html?webview=ftcapp&newad=yes",
                    "screenName":"video/tinted",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ]
            ]
        ],
        "MyFT": [
            "title": "我的FT",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#5a8caf",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "设置",
                    "type": "setting",
                    "compactLayout": "",
                    "screenName":"myft/preference"
                ],
                ["title": "已读",
                 "type": "read",
                 "screenName":"myft",
                 "compactLayout": ""
                ],
                [
                    "title": "收藏",
                    "type": "clip",
                    "url":"http://app003.ftmailbox.com/users/favstorylist?webview=ftcapp",
                    "screenName":"myft",
                    "compactLayout": ""
                ],
                [
                    "title": "关注",
                    "type": "follow",
                    "screenName":"myft",
                    "Insert Content": "follows",
                    "compactLayout": ""
                ],
                [
                    "title": "会员订阅",
                    "type": "iap",
                    "subtype":"membership",
                    "compactLayout": "books",
                    "screenName":"myft/membership"
                ],
                [
                    "title": "FT电子书",
                    "type": "iap",
                    "subtype":"ebook",
                    "compactLayout": "books",
                    "screenName":"homepage/ebook"
                ],
                [
                    "title": "账户",
                    "type": "account",
                    "url":"http://app003.ftmailbox.com/iphone-2014.html",
                    "screenName":"myft/account"
                ],
                [
                    "title": "FT商城",
                    "url":"https://shop193762308.taobao.com/index.htm",
                    "screenName":"myft/account"
                ]
            ]
        ]
    ]
    
    static let search = [
        "title": "Search",
        "url":"http://www.ftchinese.com/channel/weekly.html?webview=ftcapp",
        "screenName":"Search/Main",
        "type": "Search"
    ]
    
    public static func getNavigation(for tabName: String) -> [String]? {
        if let currentNavigation = appMap[tabName]?["Channels"] as? [String] {
            return currentNavigation
        }
        return nil
    }
    
    public static func getNavigationProperty(for tabName: String, of property: String) -> String? {
        if let p = appMap[tabName]?[property] as? String {
            return p
        }
        if let p = appMap[tabName]?[property] as? (day: String, night: String) {
            let isNightMode = Setting.isSwitchOn("night-reading-mode")
            if isNightMode {
                return p.night
            }
            return p.day
        }
        return nil
    }
    
    public static func isNavigationPropertyTrue(for tabName: String, of property: String) -> Bool {
        if let p = appMap[tabName]?[property] as? Bool {
            return p
        }
        return false
    }
    
    public static func getNavigationPropertyData(for tabName: String, of property: String) -> [[String: String]]? {
        if let p = appMap[tabName]?[property] as? [[String: String]] {
            return p
        }
        return nil
    }
    
    public static func getThemeColor(for tabName: String?) -> UIColor {
        let themeColor: UIColor
        if let tabName = tabName,
            let tabBackGroundColor = getNavigationProperty(for: tabName, of: "navBackGroundColor") {
            let isNavLightContent = isNavigationPropertyTrue(for: tabName, of: "isNavLightContent")
            if isNavLightContent == true {
                themeColor = UIColor(hex: tabBackGroundColor)
            } else {
                themeColor = UIColor(hex: Color.Tab.highlightedText)
            }
        } else {
            themeColor = UIColor(hex: Color.Tab.highlightedText)
        }
        return themeColor
    }
    
    public static func getChannelData(of screenName: String) -> [String: String]? {
        for (_, value) in appMap {
            if let channels = value["Channels"] as? [[String: String]] {
                for channel in channels {
                    if let screenNameString = channel["screenName"],
                        screenName == screenNameString {
                        return channel
                    }
                }
            }
        }
        return nil
    }
    
}
