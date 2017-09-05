//
//  IAPs.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/5.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import StoreKit
// MARK: The singleton that stores IAP products
struct IAPs {
    static var shared = IAPs()
    var products = [SKProduct]()
}
