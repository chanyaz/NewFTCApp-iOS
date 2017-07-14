//
//  ThirdPartyImpressions.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//


import Foundation

//MARK: Send Impressions, Retry if Not Successful
struct Impressions {
    // MARK: Send impressions and retry, retry on pending ect...
    // MARK: Use a Dictionary to keep track of unsent impressions
    private static let key = "Third Party Impressions"
    private static func add(_ uuid: String, impression: Impression) {
        var currentImpressions: [String: [String: String]] = UserDefaults.standard.dictionary(forKey: key) as? [String: [String:String]] ?? [:]
        let impressionDict = [
            "urlString": impression.urlString,
            "adName": impression.adName,
            "date": Date().getDateString()
        ]
        currentImpressions[uuid] = impressionDict
        UserDefaults.standard.set(currentImpressions, forKey: key)
        UserDefaults.standard.synchronize()
        //print ("current impressions is now \(currentImpressions)")
    }
    
    private static func remove(_ uuid: String) {
        var currentImpressions: [String: [String: String]] = UserDefaults.standard.dictionary(forKey: key) as? [String: [String:String]] ?? [:]
        print ("current impressions was \(currentImpressions)")
        currentImpressions.removeValue(forKey: uuid)
        print ("current impressions is now \(currentImpressions)")
        UserDefaults.standard.set(currentImpressions, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private static func send(impressionUrlString: String,
                             timeStamp: String,
                             adName: String,
                             deviceType: String,
                             impressionId: String) {
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
                        remove(impressionId)
                        print("sent \(adName) impression to \(deviceType) \(url.absoluteString)")
                        let impressions = UserDefaults.standard.dictionary(forKey: key) as? [String: [String:String]]
                        print ("After this, impressions are \(String(describing: impressions))")
                    }
                }
            }
        }
    }
    
    // MARK: report ad impressions from Ad View
    public static func report(_ impressions: [Impression]) {
        //print ("found \(impressions.count) impressions callings")
        let deviceType = DeviceInfo.checkDeviceType()
        let unixDateStamp = Date().timeIntervalSince1970
        let timeStamp = String(unixDateStamp).replacingOccurrences(of: ".", with: "")
        for impression in impressions {
            // TODO: How can I remove it from record if sent successfully?
            let impressionId = UUID().uuidString
            //print("uuid: \(uuid)")
            add(impressionId, impression: impression)
            let impressionUrlString = impression.urlString
            let adName = impression.adName
            // TODO: Report a request event
            send(impressionUrlString: impressionUrlString,
                 timeStamp: timeStamp, adName: adName,
                 deviceType: deviceType,
                 impressionId: impressionId)
        }
    }
    
    // MARK: check unsuccessful ad impressions and send them all again. A timer is running from App Delegate to do this every 30 seconds. 
    public static func retry() {
        if let impressions = UserDefaults.standard.dictionary(forKey: key) as? [String: [String:String]] {
            let deviceType = DeviceInfo.checkDeviceType()
            let unixDateStamp = Date().timeIntervalSince1970
            let timeStamp = String(unixDateStamp).replacingOccurrences(of: ".", with: "")
            for (impressionId, impression) in impressions {
                // TODO: How can I remove it from record if sent successfully?
                if let impressionUrlString = impression["urlString"],
                    let adName = impression["adName"] {
                    // MARK: If the date is from yesterday, remove it
                    let impressionDateString = impression["date"] ?? ""
                    if impressionDateString != Date().getDateString() {
                        remove(impressionId)
                        return
                    }
                    // TODO: Report a retry event
                    send(impressionUrlString: impressionUrlString,
                         timeStamp: timeStamp, adName: adName,
                         deviceType: deviceType,
                         impressionId: impressionId)
                }
            }
        }
    }
}

struct Impression {
    var urlString:String
    var adName: String
}
