//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/2.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//
import Foundation
import UIKit

struct Content {
    static func updateSectionRowIndex(_ contentSection: [ContentSection]) -> [ContentSection] {
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
