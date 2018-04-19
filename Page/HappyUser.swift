//
//  HappyReader.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/5/11.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import StoreKit
// MARK: When user is happy, request review
struct HappyUser {
    public static var shared = HappyUser()
    private let versionKey = "current version"
    private let scoreKey = "launch count"
    private let requestReviewThreshhold = 8
    private let ratePromptKey = "rate prompted"
    public var shouldTrackRequestReview = false
    public var didRequestReview = false
    public var canTryRequestReview = true
    
    public func feedback(_ score: Int) {
        let versionFromBundle: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let versionFromUserDefault: String = UserDefaults.standard.string(forKey: versionKey) ?? ""
        var currentLaunchCount: Int = UserDefaults.standard.integer(forKey: scoreKey)
        if versionFromBundle == versionFromUserDefault {
            currentLaunchCount += score
        } else {
            UserDefaults.standard.set(versionFromBundle, forKey: versionKey)
            UserDefaults.standard.set(false, forKey: ratePromptKey)
            currentLaunchCount = score
        }
        UserDefaults.standard.set(currentLaunchCount, forKey: scoreKey)
        //print ("current version is \(versionFromBundle) and current Happy User score is \(currentLaunchCount)")
    }
    
    public func requestReview() {
        // MARK: Request user to review
        let currentLaunchCount: Int = UserDefaults.standard.integer(forKey: scoreKey)
        let ratePrompted: Bool = UserDefaults.standard.bool(forKey: ratePromptKey)
        if ratePrompted != true,
            currentLaunchCount >= requestReviewThreshhold,
            HappyUser.shared.canTryRequestReview == true {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(true, forKey: ratePromptKey)
                let deviceType = DeviceInfo.checkDeviceType()
                let versionFromBundle = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                let currentLaunchCount = UserDefaults.standard.integer(forKey: scoreKey)
                Track.event(category: "\(deviceType) Request Review", action: versionFromBundle, label: "\(currentLaunchCount)")
            }
        }
    }
    
}
