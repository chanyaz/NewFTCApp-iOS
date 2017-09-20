//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/18.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Setting {
    private static let keyPrefix = "Setting For "
    private static let options = [
        "font-setting": ["最小","较小","默认","较大","最大"],
        "language-preference": ["简体中文", "繁体中文"]
    ]
    static let fontSizes: [CGFloat] = [0.8, 0.9, 1, 1.2, 1.6]
    static let fontClasses = ["smallest first-child", "smaller", "normal", "bigger", "biggest"]
    static func get(_ id: String) -> (type: String?, default: Int, on: Bool) {
        let settingType: String?
        let settingDefault: Int
        let settingOn: Bool
        switch id {
        case "font-setting":
            settingType = "option"
            settingDefault = 2
            settingOn = true
        case "language-preference":
            settingType = "option"
            settingDefault = (Locale.preferredLanguages[0].hasPrefix("zh-Hant")) ? 1 : 0
            settingOn = true
        case "enable-push":
            settingType = "switch"
            settingDefault = 0
            settingOn = true
        case "no-image-with-data":
            settingType = "switch"
            settingDefault = 0
            settingOn = false
        case "clear-cache":
            settingType = "action"
            settingDefault = 0
            settingOn = false
        case "feedback", "app-store", "privacy", "about":
            settingType = "detail"
            settingDefault = 0
            settingOn = false
        default:
            settingType = nil
            settingDefault = 0
            settingOn = false
        }
        return (settingType, settingDefault, settingOn)
    }
    
    static func getFontClass() -> String {
        let currentIndex = getCurrentOption("font-setting").index
        let fontClass: String
        if currentIndex>=0 && currentIndex < fontClasses.count {
            fontClass = fontClasses[currentIndex]
        } else {
            fontClass = fontClasses[2]
        }
        return fontClass
    }
    
    // MARK: Use string to store user's preference so that we can account for the "unknown" situation where the value is nil
    static func isSwitchOn(_ id: String) -> Bool {
        if let switchStatus = UserDefaults.standard.string(forKey: "\(keyPrefix)\(id)") {
            switch switchStatus {
            case "On":
                return true
            case "Off":
                return false
            default:
                break
            }
        }
        return get(id).on
    }
    
    static func saveSwitchChange(_ id: String, isOn: Bool) {
        let value = (isOn) ? "On": "Off"
        UserDefaults.standard.set(value, forKey: "\(keyPrefix)\(id)")
    }
    
    static func getCurrentOption(_ id: String) -> (index: Int, value: String) {
        var optionIndex = 0
        if let optionValue = UserDefaults.standard.string(forKey: "\(keyPrefix)\(id)") {
            if let currentIndex = Int(optionValue) {
                optionIndex = currentIndex
            } else {
                optionIndex = get(id).default
            }
        } else {
            optionIndex = get(id).default
        }
        let optionValue: String
        if let currentOptions = options[id],
            optionIndex >= 0,
            optionIndex < currentOptions.count {
            optionValue = currentOptions[optionIndex]
        } else {
            optionValue = ""
        }
        return (optionIndex, optionValue)
    }
    
    static func updateOption(_ id: String, with index: Int, from contentSections: [ContentSection]) -> [ContentSection] {
        let newIndex = (index >= 0) ? index : 0
        let indexString = String(newIndex)
        UserDefaults.standard.set(indexString, forKey: "\(keyPrefix)\(id)")
        var newContentSections = contentSections
        if newContentSections.count > 0 {
            for (key, value) in newContentSections[0].items.enumerated() {
                if key == newIndex {
                    value.isSelected = true
                } else {
                    value.isSelected = false
                }
            }
        }
        // MARK: - Extra things to do after updating options
        switch id {
        // MARK: - Save language prefence to memory as it might be used frequently
        case "language-preference":
            LanguageSetting.shared.currentPrefence = index
        default:
            break
        }
        return newContentSections
    }
    
    static func handle(_ id: String, type: String, title: String) {
        switch type {
        case "option":
            handleOption(id, title: title)
        case "action":
            handleAction(id, title: title)
        case "detail":
            handleDetail(id, title: title)
        default:
            break
        }
    }
    
    private static func handleOption(_ id: String, title: String) {
        if let optionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
            let topController = UIApplication.topViewController() {
            optionController.dataObject = [
                "type": "options",
                "id": id,
                "compactLayout": ""
            ]
            optionController.pageTitle = title
            topController.navigationController?.pushViewController(optionController, animated: true)
        }
    }
    
    private static func handleAction(_ id: String, title: String) {
        switch id {
        case "clear-cache":
            removeCache()
        default:
            break
        }
    }
    
    private static func handleDetail(_ id: String, title: String) {
        let urlString: String?
        switch id {
        case "feedback":
            urlString = "http://www.ftchinese.com/m/corp/faq.html"
        case "app-store":
            urlString = "itms-apps://itunes.apple.com/us/app/apple-store/id443870811?mt=8"
        case "privacy":
            urlString = "http://www.ftchinese.com/m/corp/service.html"
        case "about":
            urlString = "http://www.ftchinese.com/m/corp/aboutus.html"
        default:
            urlString = nil
            break
        }
        if let urlString = urlString,
            let url = URL(string: urlString) {
            UIApplication.topViewController()?.openLink(url)
        }
    }
    
    static func removeCache() {
        func cleanCache() {
            Download.cleanFile(APIs.expireFileTypes, for: .cachesDirectory)
            Download.cleanFile(APIs.expireFileTypes, for: .documentDirectory)
            Download.cleanFile(APIs.expireFileTypes, for: .downloadsDirectory)
        }
        let alert = UIAlertController(
            title: "清除缓存",
            message: "清除所有缓存的文件以节约空间，被删除的文件可以重新下载",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(
            UIAlertAction(
                title: "立即清除",
                style: UIAlertActionStyle.default,
                handler: {_ in cleanCache()}
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "取消",
                style: UIAlertActionStyle.default,
                handler: nil
            )
        )
        UIApplication.topViewController()?.present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    static func getContentSections(_ id: String) -> [ContentSection] {
        let selectedIndex = getCurrentOption(id).index
        let contentSection = ContentSection(
            title: "",
            items: [],
            type: "Group",
            adid: nil
        )
        if let allOptions = options[id] {
            for (index, value) in allOptions.enumerated() {
                let contentItem = ContentItem(
                    id: value,
                    image: "",
                    headline: value,
                    lead: "",
                    type: "option",
                    preferSponsorImage: "",
                    tag: id,
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: index
                )
                if index == selectedIndex {
                    contentItem.isSelected = true
                } else {
                    contentItem.isSelected = false
                }
                contentSection.items.append(contentItem)
            }
        }
        return [contentSection]
    }
    
}
