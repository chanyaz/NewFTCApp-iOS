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

// MARK: - Only the light-weight engagement related data that are enough to calculate Recency, Frequency and Volumn
struct EngagementData {
    static var shared = EngagementData()
    var log: [[String: Any]] = []
    var hasChecked = false
}

struct Engagement {
    private static let engagementDataFileName = "engagementData"
    private static let engagementDataFileExtension = "engagement"
    private static let daysForEngagement: TimeInterval = 90
    private static let secondsInAday: TimeInterval = 24 * 60 * 60
    
    // MARK: When the app launches, check the file system for engagement data
    private static func check() {
        if EngagementData.shared.hasChecked == true {
            return
        }
        if  let data = Download.readFile(engagementDataFileName, for: .documentDirectory, as: engagementDataFileExtension),
            let json = try? JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0)),
            let log = json as? [[String: Any]] {
            EngagementData.shared.log = log
        }
        EngagementData.shared.hasChecked = true
    }
    
    static func save() {
        let logs = EngagementData.shared.log
        let logsCleaned = logs.filter { (log) -> Bool in
            if let timeStamp = log["time"] as? TimeInterval {
                let engageDays = Date().timeIntervalSince1970 - daysForEngagement * secondsInAday
                //let daysPassed = (timeStamp - engageDays)/secondsInAday
                //print ("days passed: \(daysPassed)")
                if timeStamp >= engageDays {
                    //print ("log: keep it")
                    return true
                }
                //print ("log: remove it")
                return false
            }
            return false
        }
        if let data = try? JSONSerialization.data(withJSONObject: logsCleaned, options: JSONSerialization.WritingOptions(rawValue: 0)) {
            Download.saveFile(data, filename: engagementDataFileName, to: .documentDirectory, as: engagementDataFileExtension)
        }
    }
    
    static func screen(_ name: String) -> (score: Double, frequency: Int, recency: Int, volumn: Int)  {
        check()
        let timeStamp = Date().timeIntervalSince1970
        let log: [String: Any] = [
            "time": timeStamp,
            "type": "screen",
            "name": name
        ]
        EngagementData.shared.log.append(log)
        save()
        let engagementScore = score()
        //print ("Log is now: \(EngagementData.shared.log) and engagement score is \(engagementScore)")
        return engagementScore
    }
    
    static func score() -> (score: Double, frequency: Int, recency: Int, volumn: Int) {
        var volume = 0
        var visitingDates = [Int]()
        for log in EngagementData.shared.log {
            if let timeStamp = log["time"] as? TimeInterval {
                if let screenName = log["name"] as? String {
                    if EngagementTracker.shouldTrackEngagementVolumn(for: screenName) {
                        volume += 1
                    }
                }
                let visitingDate = DateHelper.getDay(timeStamp)
                if visitingDates.contains(visitingDate) == false {
                    visitingDates.append(visitingDate)
                }
            }
        }
        // MARK: Frequency is the number of days left in the dates array
        let frequecy = visitingDates.count
        let timeStamp = Date().timeIntervalSince1970
        let currentDate = DateHelper.getDay(timeStamp)
        visitingDates = visitingDates.filter {
            $0 != currentDate
        }
        let lastVisitDate = visitingDates.last ?? 90
        let recency = min(max(currentDate - lastVisitDate, 0),90)
        let score: Double = (Double(frequecy) * sqrt(Double(volume)))/(1 + Double(recency))
        return (score, frequecy, recency, volume)
    }
    
    static func event(category: String, action: String, label: String) {
        check()
        let timeStamp = Date().timeIntervalSince1970
        let log: [String: Any] = [
            "time": timeStamp,
            "type": "event",
            "category": category,
            "action": action,
            "label": label
        ]
        FootPrint.shared.log.append(log)
        //print ("Log is now: \(FootPrint.shared.log)")
    }
    
    static func catchError(_ description: String, withFatal: NSNumber) {
        check()
        let timeStamp = Date().timeIntervalSince1970
        let log: [String: Any] = [
            "time": timeStamp,
            "type": "error",
            "category": description,
            "withFatal": withFatal
        ]
        FootPrint.shared.log.append(log)
        //print ("Log is now: \(FootPrint.shared.log)")
    }
    
}
