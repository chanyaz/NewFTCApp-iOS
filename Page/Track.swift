//
//  Track.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/17.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Track {
    
    public static func screenView(_ name: String) {
        // MARK: Google Analytics
        for trackingId in GA.trackingIds {
            let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingId)
            tracker?.set(kGAIScreenName, value: name)
            let builder = GAIDictionaryBuilder.createScreenView()
            if let obj = builder?.build() as [NSObject : AnyObject]? {
                tracker?.send(obj)
                //print ("send track for screen name: \(name)")
            }
        }
        // TODO: Send to FTChinese Log
        
    }
    
    public static func event(category: String, action: String, label: String) {
        for trackingId in GA.trackingIds {
            let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingId)
            let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: 0)
            if let obj = builder?.build() as [NSObject : AnyObject]? {
                tracker?.send(obj)
                print ("send track for event: \(category), \(action), \(label)")
            }
        }
    }
    
}
