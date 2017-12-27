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
        // MARK: Save screen name locally
        let engagement = Engagement.screen(name)
         
        // MARK: Google Analytics
        for trackingId in GA.trackingIds {
            let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingId)
            tracker?.set(kGAIScreenName, value: name)
            tracker?.set(GAIFields.customMetric(for: 1), value: String(engagement.score))
            let builder = GAIDictionaryBuilder.createScreenView()
            if let obj = builder?.build() as [NSObject : AnyObject]? {
                tracker?.send(obj)
                //print ("send track for screen name: \(name)")
            }
        }

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
    
    public static func catchError(_ description: String, withFatal: NSNumber) {
        for trackingId in GA.trackingIds {
            let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingId)
            let builder = GAIDictionaryBuilder.createException(withDescription: description, withFatal: withFatal)
            if let obj = builder?.build() as [NSObject : AnyObject]? {
                tracker?.send(obj)
                print ("send error: \(description) with fatal number of \(withFatal)")
            }
        }
    }
    
//    private static func customMetric(_ metricValue: String) {
//        //[tracker set:[GAIFields customMetricForIndex:1] value:metricValue];
//        for trackingId in GA.trackingIds {
//            let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingId)
//            //tracker?.set(1, value: metricValue)
//            tracker?.set("customMetricForIndex:1", value: metricValue)
//        }
//    }
    
}
