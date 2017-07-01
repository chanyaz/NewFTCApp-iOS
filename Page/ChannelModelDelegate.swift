//
//  ChannelModelDelegate.swift
//  Page
//
//  Created by ZhangOliver on 2017/7/1.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
// MARK: Delegate Step 1: Create Protocol.

protocol ChannelModelDelegate: class {
    func pagePanningEnd(_ pageInfoObject: (index: Int, title: String))
}
