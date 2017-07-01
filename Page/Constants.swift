//
//  Style.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/22.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Color {
// Those nested structures are grouped mostly according to their functions
    struct Content {
        static let headline = "#33302d"
        static let body = "#333333"
        static let lead = "#66605a"
        static let border = "#d4c9bc"
        static let background = "#FFF1E0"
    }
    struct Tab {
        static let text = "#333333"
        static let normalText = "#555555"
        static let highlightedText = "#c0282e"
        static let border = "#d4c9bc"
        static let background = "#f7e9d8"
    }
    struct Button {
        static let tint = "#057b93"
    }
    struct Header {
        static let text = "#333333"
    }
    
    struct ChannelScroller {
        static let text = "#565656"
        static let highlightedText = "#c0282c"
        static let background = "#e8dbcb"
    }
    struct Navigation {
        static let border = "#d5c6b3"
    }
    struct Ad {
        static let background = "#f6e9d8"
    }
}
struct APIs {
    static let story = "https://m.ftimg.net/index.php/jsapi/get_story_more_info/"
}
struct Event {
//    static func pagePanningEnd (for tab: String) -> String {
//        let pagePanningEndName = "Page Panning End"
//        return "\(pagePanningEndName) for \(tab)"
//    }
}

