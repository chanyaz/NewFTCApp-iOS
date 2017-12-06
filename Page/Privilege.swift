//
//  Benefits.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Privilege {
    static var shared = Privilege()
    init(adBlock: Bool, englishText: Bool, englishAudio: Bool, exclusiveContent: Bool) {
        self.adBlock = adBlock
        self.englishText = englishText
        self.englishAudio = englishAudio
        self.exclusiveContent = exclusiveContent
    }
    init() {
        self.adBlock = false
        self.englishText = false
        self.englishAudio = false
        self.exclusiveContent = false
    }
    var adBlock = false
    var englishText = false
    var englishAudio = false
    var exclusiveContent = false
}
