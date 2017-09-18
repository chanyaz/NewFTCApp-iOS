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
            settingDefault = 0
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
    
    static func handle(_ id: String, type: String, title: String) {
        switch type {
        case "option":
            handleOption(id, title: title)
        default:
            break
        }
    }
    
    private static func handleOption(_ id: String, title: String) {
        if let optionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
            let topController = UIApplication.topViewController() {
            //                contentItemViewController.dataObject = itemCell
            //                contentItemViewController.hidesBottomBarWhenPushed = true
            //                contentItemViewController.themeColor = themeColor
            //                contentItemViewController.action = "buy"
            optionController.dataObject = [
                "type": "options",
                "id": id,
                "compactLayout": ""
            ]
            optionController.pageTitle = title
            topController.navigationController?.pushViewController(optionController, animated: true)
        }
    }
    
    static func getContentSections(_ id: String) -> [ContentSection] {
        let contentSection = ContentSection(
            title: "",
            items: [],
            type: "Group",
            adid: nil
        )
        if let allOptions = options[id] {
            for option in allOptions {
                let contentItem = ContentItem(
                    id: option,
                    image: "",
                    headline: option,
                    lead: "",
                    type: "option",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0, row: 0
                )
                contentSection.items.append(contentItem)
            }
        }
        return [contentSection]
        
    }
    
}
