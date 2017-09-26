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
    static func insertAds(_ layout: String, to contentSections: [ContentSection]) -> [ContentSection] {
        var newContentSections = contentSections
        // MARK: It is possible that the JSON Format is broken. Check it here.
        if newContentSections.count < 1 {
            return newContentSections
        }
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
        switch layout {
        case "home":
            // MARK: Create the Info Ad
            let paidPostItem = ContentItem(id: "20220121", image: "", headline: "", lead: "", type: "ad", preferSponsorImage: "", tag: "", customLink: "", timeStamp: 0, section: 0, row: 0)
            
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
                // MARK: Insert the paid post under Cover
                newContentSections[0].items.insert(paidPostItem, at:1)
                
                // MARK: Tell the second story not to display border
                if newContentSections[0].items.count > 2 {
                    newContentSections[0].items[2].hideTopBorder = true
                }
            }
            
            // MARK: Insert ads into sections that has larger index so that you don't have to constantly recalculate the new index
            newContentSections.insert(MPU1, at: 1)
            newContentSections.insert(topBanner, at: 0)
            // MARK: Make sure there's content between MPU and Bottom Banner
            if newContentSections.count > 3 {
                newContentSections.append(bottomBanner)
            }
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        case "ipadhome":
            // MARK: - The first item in the first section should be marked as Cover
            newContentSections[0].items[0].isCover = true
            // MARK: - Break up the first section into two or more, depending on how you want to layout ads
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        case "OutOfBox-No-Ad":
            if newContentSections[0].items.count > 0 {
                newContentSections[0].items[0].isCover = true
            }
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        case "Video", "OutOfBox", "OutOfBox-LifeStyle":
            if newContentSections[0].items.count > 0 {
                newContentSections[0].items[0].isCover = true
            }
            if newContentSections.count > 2 {
                if newContentSections[0].items.count + newContentSections[1].items.count > 6 {
                    newContentSections.insert(MPU1, at: 2)
                }
            }
            newContentSections.insert(topBanner, at: 0)
            if newContentSections.count > 3 {
                newContentSections.append(bottomBanner)
            }
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        default:
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        }
    }
    
    static func insertFullScreenAd(to items: [ContentItem], for index: Int)->(contentItems: [ContentItem], pageIndex: Int){
        var newItems = items
        var newPageIndex = index
        var insertionPointAfter = index + 2
        
        // MARK: Insert a full page ad after the next content page
        if insertionPointAfter > newItems.count {
            insertionPointAfter = newItems.count
        }
        let newItem = ContentItem(id: "fullpagead1", image: "", headline: "full page ad 1", lead: "", type: "ad", preferSponsorImage: "", tag: "", customLink: "", timeStamp: 0, section: 0, row: 0)
        newItems.insert(newItem, at:insertionPointAfter)
        
        // MARK: Insert a full page ad before the previous content page
        var insertionPointBefore = index - 1
        if insertionPointBefore < 0 {
            insertionPointBefore = 0
        }
        let newItem2 = ContentItem(id: "fullpagead2", image: "", headline: "full page ad 2", lead: "", type: "ad", preferSponsorImage: "", tag: "", customLink: "", timeStamp: 0, section: 0, row: 0)
        newItems.insert(newItem2, at:insertionPointBefore)
        newPageIndex += 1
        
        return (newItems, newPageIndex)
    }
    
}
