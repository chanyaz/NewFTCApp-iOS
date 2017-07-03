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
            

            // MARK: - The first item in the first section should be marked as Cover
            newContentSections[0].items[0].isCover = true
            
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
            }
            
            
            // MARK: Insert ads into sections that has larger index so that you don't have to constantly recalculate the new index
            newContentSections.insert(MPU1, at: 1)
            newContentSections.insert(topBanner, at: 0)
            newContentSections.append(bottomBanner)
            newContentSections = updateSectionRowIndex(newContentSections)

            
            return newContentSections
        case "ipadhome":
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
            
            
            // MARK: - The first item in the first section should be marked as Cover
            newContentSections[0].items[0].isCover = true
           
//            print ("newContentSections[0] --\(newContentSections[0].items.count)--")
            
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
            }
            
            
            // MARK: Insert ads into sections that has larger index so that you don't have to constantly recalculate the new index
            newContentSections.insert(MPU1, at: 1)
            newContentSections.insert(topBanner, at: 0)
//            newContentSections.append(bottomBanner)
            newContentSections = updateSectionRowIndex(newContentSections)
            print ("newContentSections[0] --\(newContentSections[0].items)--")
            
            
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
