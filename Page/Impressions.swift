//
//  ThirdPartyImpressions.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Impressions {
    // TODO: Send impressions and retry, retry on pending ect...
    private static let key = "Third Party Impressions"
    private static func add(_ impression: Impression) {
        var currentImpressions: [Impression] = UserDefaults.standard.array(forKey: key) as? [Impression] ?? []
        currentImpressions.append(impression)
        
        UserDefaults.standard.set(currentImpressions, forKey: key)
        print ("current impressions is now \(currentImpressions)")
    }
    
    // MARK: report ad impressions
    public static func report(_ impressions: [Impression]) {
        //print ("found \(impressions.count) impressions callings")
        let deviceType = DeviceInfo.checkDeviceType()
        let unixDateStamp = Date().timeIntervalSince1970
        let timeStamp = String(unixDateStamp).replacingOccurrences(of: ".", with: "")
        for impression in impressions {
            // TODO: How can I remove this on success?
            add(impression)
            let impressionUrlString = impression.urlString
            let adName = impression.adName
            let impressionUrlStringWithTimestamp = impressionUrlString.replacingOccurrences(of: "[timestamp]", with: timeStamp)
            print ("send to \(impressionUrlStringWithTimestamp)")
            if var urlComponents = URLComponents(string: impressionUrlStringWithTimestamp) {
                let newQuery = URLQueryItem(name: "fttime", value: timeStamp)
                if urlComponents.queryItems != nil {
                    urlComponents.queryItems?.append(newQuery)
                } else {
                    urlComponents.queryItems = [newQuery]
                }
                if let url = urlComponents.url {
                    Download.getDataFromUrl(url) { (data, response, error)  in
                        DispatchQueue.main.async { () -> Void in
                            guard let _ = data , error == nil else {
                                // MARK: Use the original impressionUrlString for Google Analytics
                                //let jsCode = "try{ga('send','event', '\(deviceType) Launch Ad', 'Fail', '\(impressionUrlString)', {'nonInteraction':1});}catch(ignore){}"
                                //self.webView.evaluateJavaScript(jsCode) { (result, error) in
                                //}
                                // MARK: The string should have the parameter
                                print ("Fail to send \(adName) impression to \(deviceType) \(url.absoluteString)")
                                return
                            }
                            //let jsCode = "try{ga('send','event', '\(deviceType) Launch Ad', 'Sent', '\(impressionUrlString)', {'nonInteraction':1});}catch(ignore){}"
                            //self.webView.evaluateJavaScript(jsCode) { (result, error) in
                            //}
                            print("sent \(adName) impression to \(deviceType) \(url.absoluteString)")
                        }
                    }
                }
            }
        }
    }
}

struct Impression {
    var urlString:String
    var adName: String
}
