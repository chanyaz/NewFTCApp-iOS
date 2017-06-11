//
//  ContentSection.swift
//  Page
//
//  Created by ZhangOliver on 2017/6/10.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ContentSection {
    var title: String
    var items: [ContentItem]
    init (title:String,items:[ContentItem]) {
        self.title = title
        self.items = items
    }
}
