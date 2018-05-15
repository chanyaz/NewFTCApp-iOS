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
    
    static let homeAdChId = "1000"
    static let defaultStoryAdChId = "1200"
    static func insertAds(_ layout: String, to contentSections: [ContentSection]) -> [ContentSection] {
        var newContentSections = contentSections
        // MARK: It is possible that the JSON Format is broken. Check it here.
        if newContentSections.count < 1 {
            return newContentSections
        }
        var itemsCount = 0
        for section in newContentSections {
            itemsCount += section.items.count
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
        // MARK: Create the Info Ad
        let paidPostItem = ContentItem(
            id: "20220121",
            image: "",
            headline: "",
            lead: "",
            type: "ad",
            preferSponsorImage: "",
            tag: "",
            customLink: "",
            timeStamp: 0,
            section: 0,
            row: 0
        )

        switch layout {
        case "home", "Video", "OutOfBox", "OutOfBox-LifeStyle":
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
            if newContentSections.count >= 2 {
                if newContentSections[1].items.count > 8 {
                    newContentSections.insert(MPU1, at: 1)
                }
                if newContentSections[0].items.count > 5 {
                newContentSections.insert(topBanner, at: 0)
                }
            }
            
            // MARK: Make sure there's content between MPU and Bottom Banner
            if newContentSections.count > 3  && itemsCount > 10 {
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
        default:
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        }
    }
    
    static func insertFullScreenAd(to items: [ContentItem], for index: Int)->(contentItems: [ContentItem], pageIndex: Int){
        // MARK: If the app is configured NOT to show full screen ad between pages, return the original value immediately
        if Color.Ad.showFullScreenAdBetweenPages == false /* || Ads.shared.hasFullScreenAd == false */{
            return (items, index)
        }
        // MARK: Otherwise, insert ads based on the following instruction
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
    
    static func insertAdId(to items: [ContentItem], with adchId: String) -> [ContentItem] {
        let newItems = items
        for item in newItems {
            item.adchId = adchId
        }
        return newItems
    }
    
    static func removeAds(in items: [ContentItem]) -> [ContentItem] {
        let newItems = items
        for item in newItems {
            item.hideAd = true
        }
        return newItems
    }
    
    static func addPrivilegeRequirements(in items: [ContentItem], with dataObject: [String: String]) -> [ContentItem] {
        var newItems = [ContentItem]()
        for item in items {
            let newItem = addPrivilegeRequirement(in: item, with: dataObject)
            newItems.append(newItem)
        }
        return newItems
    }
    
    
    static func addPrivilegeRequirement(in item: ContentItem, with dataObject: [String: String]) -> ContentItem {
        let newItem = item
        // MARK: If you are openning from an eBook, no privilege is required
        if dataObject["type"]?.range(of: "htmlbook") != nil {
            newItem.privilegeRequirement = nil
            newItem.hideAd = true
            return newItem
        }
        if dataObject["listapi"]?.range(of: "EditorChoice") != nil {
            newItem.privilegeRequirement = .EditorsChoice
            newItem.hideAd = true
            return newItem
        }
        // MARK: Check for premium content
        if newItem.type == "premium"  {
            newItem.privilegeRequirement = .ExclusiveContent
            newItem.hideAd = true
            return newItem
        }
        if newItem.subType == "speedreading" {
            newItem.privilegeRequirement = .SpeedReading
            newItem.hideAd = true
            return newItem
        }
        if newItem.subType == "radio" {
            newItem.privilegeRequirement = .Radio
            newItem.hideAd = true
            return newItem
        }
        // MARK: - Pop out archive privilege only for story
        if newItem.timeStamp > 0 && newItem.type == "story" && newItem.whitelist == false {
            let timeInterval = Date().timeIntervalSince1970
            let timeDifference = timeInterval - newItem.timeStamp
            let timeDifferenceInDays = timeDifference/(60*60*24)
            //print ("pubdate: \(item.timeStamp), today: \(timeInterval), difference in days: \(timeDifferenceInDays)")
            if timeDifferenceInDays > 7 {
                newItem.privilegeRequirement = .Archive
                newItem.hideAd = true
                return newItem
            }
        }
        return newItem
    }
    
    static func markAsDownloaded(in items: [ContentItem]) -> [ContentItem] {
        let newItems = items
        for item in newItems {
            item.isDownloaded = true
        }
        return newItems
    }
    
    public static func switchToNewAdVendor() -> (on: Bool, parameter: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8:00") //Current time zone
        if let date = dateFormatter.date(from: "2020-04-13") {
            let shouldSwitchToNewAdVendor: Bool
            if date <= Date() {
                shouldSwitchToNewAdVendor = true
            } else {
                shouldSwitchToNewAdVendor = false
            }
            if shouldSwitchToNewAdVendor {
                return (true, "&testDB=yes")
            }
        }
        return (false, "")
    }
    
    public static func getSuffixForBaseUrl(_ dataObject: ContentItem?) -> String {
        let suffix: String
        if let adId = dataObject?.adchId {
            suffix = "#adchannelID=\(adId)"
        } else {
            suffix = ""
        }
        return suffix
    }
    
}
