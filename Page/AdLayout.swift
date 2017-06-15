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
            let topBanner = ContentSection(
                title: "Top Banner",
                items: [],
                type: "Banner",
                adid: "20220101"
            )
            newContentSections.insert(topBanner, at: 0)
            return newContentSections
        default:
            return newContentSections
        }
    }

}
