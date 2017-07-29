//
//  AdStyle.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/15.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//
import UIKit
import Foundation
struct AdLayout {
    func insertAds(_ layout: String, to contentSections: [ContentSection]) -> [ContentSection] {
        var newContentSections = contentSections
        // MARK: It is possible that the JSON Format is broken. Check it here.
        if newContentSections.count < 1 {
            return newContentSections
        }
        switch layout {
        case "home":
            let topBanner = ContentSection(
                title: "Top Banner",
                items: [],
                type: "Banner",
                adid: "20220101"
            )
            let MPU1 = ContentSection(
                title: "MPU 1",
                items: [],
                type: "MPU",
                adid: "20220003"
            )
            let bottomBanner = ContentSection(
                title: "Bottom Banner",
                items: [],
                type: "Banner",
                adid: "20220114"
            )
            // MARK: Create the Info Ad
            let infoAd = ContentItem(id: "20220121", image: "", headline: "", lead: "", type: "ad", preferSponsorImage: "", tag: "", customLink: "", timeStamp: 0, section: 0, row: 0)
            let infoAdSection = ContentSection(
                title: "",
                items: [infoAd],
                type: "",
                adid: ""
            )

            // MARK: - The first item in the first section should be marked as Cover.
            // MARk: - Make sure items has a least one child to avoid potential run time error.
            if newContentSections[0].items.count > 0 {
                newContentSections[0].items[0].isCover = true
            }
            
            // MARK: - Break up the first section into two or more, depending on how you want to layout ads
            let sectionToSplit = newContentSections[0]
            if sectionToSplit.items.count >= 18 {
                let newSection = ContentSection(
                    title: "",
                    items: Array(sectionToSplit.items[9..<sectionToSplit.items.count]),
                    type: "List",
                    adid: ""
                )
                newContentSections.insert(newSection, at: 1)
                newContentSections[0].items = Array(newContentSections[0].items[0..<9])
                newContentSections[0].items.insert(infoAd, at:1)
            }
            
            // MARK: Insert ads into sections that has larger index so that you don't have to constantly recalculate the new index
            newContentSections.insert(MPU1, at: 1)
            newContentSections.insert(topBanner, at: 0)
            newContentSections.append(bottomBanner)
            newContentSections = updateSectionRowIndex(newContentSections)
            return newContentSections
        case "ipadhome":
            // MARK: - The first item in the first section should be marked as Cover
            newContentSections[0].items[0].isCover = true
            // MARK: - Break up the first section into two or more, depending on how you want to layout ads
 
            return newContentSections
        default:
            return newContentSections
        }
    }
    
    func updateSectionRowIndex(_ contentSection: [ContentSection]) -> [ContentSection] {
        let newContentSection = contentSection
        for (sectionIndex, section) in newContentSection.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                item.section = sectionIndex
                item.row = itemIndex
            }
        }
        return newContentSection
    }
    
}
