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
    //https://m.ftimg.net/
    //https://danla2f5eudt1.cloudfront.net/
    
    private static let appMap = [
        "News": [
            "title": "FTCC",
            "navColor": "#333333",
            "navBackGroundColor": "#f7e9d8",
            "isNavLightContent": false,
            "Channels": [
                ["title": "首页",
                 "api":"https://danla2f5eudt1.cloudfront.net/index.php/jsapi/publish/ftcc",
                 "url":"http://www.ftchinese.com/",
                 "screenName":"homepage",
                 "Insert Content": ""
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

}
