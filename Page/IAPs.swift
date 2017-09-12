//
//  IAPs.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/5.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import StoreKit
// MARK: The singleton that stores IAP products, download tasks, etc...
struct IAPs {
    static var shared = IAPs()
    var products = [SKProduct]()
    
    // MARK: - The Download Operation Queue
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: keep a reference of all the Download Tasks
    var downloadTasks = [String: URLSessionDownloadTask]()
    
    var downloadDelegate: IAPView?
    
    // MARK: - Keep a reference of all the Download Progress
    var downloadProgresses = [String: String]()
    
}
