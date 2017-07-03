//
//  DetailModelDelegate.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/24.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation

// MARK: Delegate Step 1: Create Protocol. Follow the steps to learn how to use protocol and delegate. How to pass data from model to controller https://medium.com/ios-os-x-development/ios-three-ways-to-pass-data-from-model-to-controller-b47cc72a4336

protocol DetailModelDelegate: class {
    // MARK: When user panning to change page title, the navigation item title should change accordingly
    func didChangePage(_ item: ContentItem?, index: Int)
}
