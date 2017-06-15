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
    var type: String
    var adid: String?
    init (title:String,items:[ContentItem],type:String,adid:String?) {
        self.title = title
        self.items = items
        self.type = type
        self.adid = adid
    }
}
