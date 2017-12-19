//
//  DateHelper.swift
//  Page
//
//  Created by ZhangOliver on 2017/12/16.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation

struct DateHelper {
    static func getCurrentDateString(dateFormat: String) -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateInString = dateFormatter.string(from: currentDate)
        return dateInString
    }
    
    static func getDay(_ from: TimeInterval) -> Int {
        let date = Date(timeIntervalSince1970: from)
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let visitingDate = year * 10000 + month * 100 + day
        return visitingDate
    }
}
