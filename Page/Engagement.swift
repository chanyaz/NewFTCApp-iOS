//
//  Engagement.swift
//  Page
//
//  Created by ZhangOliver on 2017/12/16.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation

// MARK: - Store user's foot print in memory so that it's fast to calculate and update
struct FootPrint {
    static var shared = FootPrint()
    var log: [[String: Any]] = []
}

// MARK: - Only the light-weight engagement related data are that enought to calculate Recency, Frequency and Volumn
struct EngagementData {
    static var shared = EngagementData()
    var log: [[String: Any]] = []
}

struct Engagement {
    
    static func screen(_ name: String) {
        let unixDateStamp = Date().timeIntervalSince1970
        let timeStamp = Double(unixDateStamp)
        let log: [String: Any] = [
            "time": timeStamp,
            "type": "screen",
            "name": name
        ]
        EngagementData.shared.log.append(log)
        print ("Log is now: \(FootPrint.shared.log)")
    }
    
    static func event(category: String, action: String, label: String) {
        let unixDateStamp = Date().timeIntervalSince1970
        let timeStamp = Double(unixDateStamp)
        let log: [String: Any] = [
            "time": timeStamp,
            "type": "event",
            "category": category,
            "action": action,
            "label": label
        ]
        FootPrint.shared.log.append(log)
        print ("Log is now: \(FootPrint.shared.log)")
    }
    
    static func catchError(_ description: String, withFatal: NSNumber) {
        let unixDateStamp = Date().timeIntervalSince1970
        let timeStamp = Double(unixDateStamp)
        let log: [String: Any] = [
            "time": timeStamp,
            "type": "error",
            "category": description,
            "withFatal": withFatal
        ]
        FootPrint.shared.log.append(log)
        print ("Log is now: \(FootPrint.shared.log)")
    }
    
}
