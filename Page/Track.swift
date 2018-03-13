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
            let metricName = GAIFields.customMetric(for: 1)
            let engagementScore = String(engagement.score)
            tracker?.set(metricName, value: engagementScore)
            let builder = GAIDictionaryBuilder.createScreenView()
            if let obj = builder?.build() as [NSObject: AnyObject]? {
                tracker?.send(obj)
                //print ("send track for screen name: \(name)")
            }
        }
        
        sendEngagementData(engagement)

        
    }
    
    private static func sendEngagementData(_ engagement: (score: Double, frequency: Int, recency: Int, volumn: Int)) {
        // MARK: Must have something that can identify the user. Otherwise the data is uselss.
        if UserInfo.shared.userName == nil && UserInfo.shared.userId == nil && UserInfo.shared.deviceToken == nil {
            return
        }
        let s = String(engagement.score)
        let f = String(engagement.frequency)
        let r = String(engagement.recency)
        let v = String(engagement.volumn)
        let u = UserInfo.shared.userName ?? ""
        let i = UserInfo.shared.userId ?? ""
        let d = UserInfo.shared.deviceToken ?? ""
        let eventCategory = "iOS Engagement: \(EngagementTracker.getEventCategory())"
        let eventActionOriginal = UserInfo.shared.userId ?? UserInfo.shared.deviceToken ?? ""
        let eventAction = (eventActionOriginal != "") ? eventActionOriginal : "Unknown"
        let eventLabel = "(\(s),\(f),\(r),\(v))"
        Track.event(category: eventCategory, action: eventAction, label: eventLabel)
        let engagementDict = [
            "s": s,
            "f": f,
            "r": r,
            "v": v,
            "u": u,
            "i": i,
            "d": d
            ] as [String : String]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: engagementDict, options: .init(rawValue: 0))
            if let siteServerUrl = Foundation.URL(string: "https://api001.ftmailbox.com/engagement-tracker.php") {
                var request = URLRequest(url: siteServerUrl)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let task = session.dataTask(with: request) { data, response, error in
                    if let receivedData = data,
                        let httpResponse = response as? HTTPURLResponse,
                        error == nil,
                        httpResponse.statusCode == 200 {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> {
                                // MARK: - parse and verify the required informatin in the jsonResponse
                                print ("Engagement validation from func receiptValidation success: \(jsonResponse)")
                            }
                        } catch {
                            
                        }
                    }
                }
                task.resume()
            }
        }
        catch {
            print("Engagement validation from func receiptValidation: Couldn't create JSON with error: " + error.localizedDescription)
        }
    }
    
    public static func event(category: String, action: String, label: String) {
        for trackingId in GA.trackingIds {
            let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingId)
            let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: 0)
            if let obj = builder?.build() as [NSObject : AnyObject]? {
                tracker?.send(obj)
                print ("send track for event: \(category), \(action), \(label), \(trackingId)")
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
    
    public static func token() {
        let eventCategory = "iOS Token: \(EngagementTracker.getEventCategory())"
        let eventAction: String
        if let userId = UserInfo.shared.userId,
            userId != "" {
            eventAction = userId
        } else {
            eventAction = "Visitor"
        }
        // MARK: Even if there's no device token, we still want to record this so that we know who has not yet enabled notification
        let eventLabelOriginal = UserInfo.shared.deviceToken ?? ""
        let eventLabel = (eventLabelOriginal != "") ? eventLabelOriginal : "None"
        event(category: eventCategory, action: eventAction, label: eventLabel)
    }
    
}
