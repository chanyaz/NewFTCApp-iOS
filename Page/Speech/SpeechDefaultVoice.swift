//
//  SpeechDefaultVoice.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/7.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
struct SpeechDefaultVoice {

    public let englishVoiceKey = "English Voice"
    public let chineseVoiceKey = "Chinese Voice"
    
    public func getVoiceByLanguage(_ language: String) -> String {
        var englishDefaultVoice = "en-GB"
        var chineseDefaultChoice = "zh-CN"
        if let region = Locale.current.regionCode {
            switch region {
            case "US": englishDefaultVoice = "en-US"
            case "AU": englishDefaultVoice = "en-AU"
            case "ZA": englishDefaultVoice = "en-ZA"
            case "IE": englishDefaultVoice = "en-IE"
            case "TW": chineseDefaultChoice = "zh-TW"
            case "HK": chineseDefaultChoice = "zh-HK"
            default:
                break
            }
        }
        switch language {
        case "en":
            return UserDefaults.standard.string(forKey: englishVoiceKey) ?? englishDefaultVoice
        default:
            return UserDefaults.standard.string(forKey: chineseVoiceKey) ?? chineseDefaultChoice
        }
    }
    
    public static let englishVoice = [
        "英国":"en-GB",
        "美国":"en-US",
        "澳大利亚":"en-AU",
        "南非":"en-ZA",
        "爱尔兰":"en-IE"
    ]
    
    public static let chineseVoice = [
        "中国大陆":"zh-CN",
        "香港":"zh-HK",
        "台湾":"zh-TW"
    ]
    
    public static let languageNames = [
        "en-GB": "英式英语",
        "en-US": "美式英语",
        "en-AU": "澳州英语",
        "en-ZA": "南非英语",
        "en-IE": "爱尔兰英语",
        "zh-CN": "普通话",
        "zh-HK": "香港广东话",
        "zh-TW": "国语"
    ]
    
    public static func getLanguageName(_ code: String) -> String {
        if let languageName = languageNames[code] {
            return languageName
        }
        return code
    }

}

//
//extension Dictionary where Value: Equatable {
//    func allKeys(forValue val: Value) -> [Key] {
//        return self.filter { $1 == val }.map { $0.0 }
//    }
//    mutating func merge(with dictionary: Dictionary) {
//        dictionary.forEach { updateValue($1, forKey: $0) }
//    }
//    
//    func merged(with dictionary: Dictionary) -> Dictionary {
//        var dict = self
//        dict.merge(with: dictionary)
//        return dict
//    }
//}
