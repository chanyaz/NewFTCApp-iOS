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
}
