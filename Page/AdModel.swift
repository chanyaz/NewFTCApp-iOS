//
//  AdModel.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct AdModel {
    let imageString: String?
    let link: String?
    let video: String?
    let impressions: [Impression]
}

struct AdParser {
    // MARK: Ad Constants
    public static func getAdPageUrlForAdId(_ adid: String) -> String {
        let adBaseUrl = "http://www.ftchinese.com/m/marketing/a.html"
        return "\(adBaseUrl)#adid=\(adid)"
    }
    
    public static func parseAdCode(_ adCode: String) -> AdModel {
        let video = ""
        
        //print ("ad code is now: \(adCode)")
        // MARK: Extract Images
        let imagePatterns = [
            "'imageUrl': '(.+)'",
            "var ImgSrc = '(.+)';",
            "(https://creatives.ftimg.net/.+jpg)",
            "(https://creatives.ftimg.net/.+gif)",
            "<img src=\"(.+)\" style"
        ]
        let image = adCode.matchingStrings(regexes: imagePatterns)
        
        // MARK: Extract Link
        let linkPatterns = [
            "'link': '(.+)'",
            "href=\"([^\"]+)\""
        ]
        let link = adCode.matchingStrings(regexes: linkPatterns)
        if link == nil {
            print ("link is nil, the ad code is now: \(adCode)")
        }
        
        // MARK: Impressions
        let impressionPatterns = [
            "var Imp = '(.+)';"
        ]
        
        var impressions = [Impression]()
        if let impressionUrlString = adCode.matchingStrings(regexes: impressionPatterns) {
            let adName = "Some Ad Name"
            let impression = Impression(urlString: impressionUrlString, adName: adName)
            impressions.append(impression)
        }
        
        // MARK: Test Impressions
        //        impressions = [
        //            Impression(urlString: "https://www.ft.com/", adName: "Some Ad Name")
        //        ]
        
        let adModel = AdModel(
            imageString: image,
            link: link,
            video: video,
            impressions: impressions
        )
        
        return adModel
    }
    
    public static func getAdUrlFromDolphin(_ adid: String) -> URL? {
        let base = "http://dolphin4.ftimg.net/s?z=ft&slot=676544&_sex=101&_cs=1&_csp=1&_dc=2&_mm=2&_sz=2&_am=2&_ut=member&_fallback=0" //10000001
        let urlString =  "\(base)&c=\(adid)"
        if let url = URL(string: urlString) {
            return url
        }
        return nil
    }
    
}


extension String {
    
    func matchingFirstString(regex: String) -> String? {
        //        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return nil }
        //        let nsString = self as NSString
        //        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        //        let matches = results.map { result in
        //            (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
        //                ? nsString.substring(with: result.rangeAt($0))
        //                : ""
        //            }
        //        }
        
        let matches = self.matchingArrays(regex: regex)
        if let matches = matches {
            if matches.count > 0 {
                let firstMatch = matches[0]
                let firstMatchCount = firstMatch.count
                if firstMatchCount > 0 {
                    return firstMatch[firstMatchCount-1]
                }
            }
        }
        
        return nil
    }
    
    func matchingArrays(regex: String) -> [[String]]? {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return nil }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        let matches = results.map { result in
            (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
                ? nsString.substring(with: result.rangeAt($0))
                : ""
            }
        }
        return matches
    }
    
    func matchingStrings(regexes: [String]) -> String? {
        for regex in regexes {
            if let matchString = self.matchingFirstString(regex: regex) {
                return matchString
            }
        }
        return nil
    }
    
}
