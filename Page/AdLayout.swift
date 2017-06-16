//
//  AdStyle.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/15.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct AdLayout {
    func insertAds(_ layout: String, to contentSections: [ContentSection]) -> [ContentSection] {
        var newContentSections = contentSections
        switch layout {
        case "home":
            let MPU1 = ContentSection(
                title: "MPU 1",
                items: [],
                type: "MPU",
                adid: "20220003"
            )
            let topBanner = ContentSection(
                title: "Top Banner",
                items: [],
                type: "Banner",
                adid: "20220101"
            )
            
            // MARK: Insert ads into sections that has larger index so that you don't have to constantly recalculate the new index
            newContentSections.insert(MPU1, at: 1)
            newContentSections.insert(topBanner, at: 0)
            return newContentSections
        default:
            return newContentSections
        }
    }

}
