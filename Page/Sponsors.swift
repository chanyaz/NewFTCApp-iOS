//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/4.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation

struct Sponsors {
    static var shared = Sponsors()
    var sponsors = [Sponsor]()
}

struct Sponsor {
    var tag: String
    var title: String
    var adid: String
    var channel: String
    var hideAd: String?
    // MARK: - If it's a channel view
    init(tag: String, title: String, adid: String, channel: String, hideAd: String?) {
        self.tag = tag
        self.title = title
        self.adid = adid
        self.channel = channel
        self.hideAd = hideAd
    }
}
