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
    let headline: String?
    let adName: String?
    var bgColor: String
    var lead: String?
    var adCode: String
}

struct AdParser {
    // MARK: Ad Constants
    public static func getAdPageUrlForAdId(_ adid: String) -> String {
        let adBaseUrl = "http://www.ftchinese.com/m/marketing/a.html"
        return "\(adBaseUrl)#adid=\(adid)"
    }
    
    public static func parseAdCode(_ adCode: String) -> AdModel {
        //print ("ad Code is \(adCode)")
        let videoPattern = [
        "var videoUrl = '(.+)'"
        ]
        let video = adCode.matchingStrings(regexes: videoPattern)
        

        
        //TODO: This is a Test Code, Remove after testing is over
        //let video = "https://creatives.ftimg.net/video/adv/AccentureTest2.mp4"
        
        // print ("ad code is now: \(adCode)")
        // MARK: Extract Images
        let imagePatterns = [
            "'imageUrl': '(.+)'",
            "var ImgSrc = '(.+)';",
            "var image = '(.+)'",
            "(https://creatives.ftimg.net/.+jpg)",
            "(https://creatives.ftimg.net/.+gif)",
            "<img src=\"(.+)\" style"
        ]
        let image = adCode.matchingStrings(regexes: imagePatterns)
        
        
        
        // MARK: Extract Link
        let linkPatterns = [
            "'link': '(.+)'",
            "var Click = '(.+)'",
            "href=\"([^\"]+)\""
        ]
        let link = adCode.matchingStrings(regexes: linkPatterns)
        if link == nil {
            print ("link is nil, the ad code is now: \(adCode)")
        }
        
        print ("video is \(String(describing: video)), image is \(String(describing: image)), link is \(String(describing: link))")

        
        // MARK: Headline for Paid Post
        let headlinePatterns = [
            "var headline = '(.+)'"
        ]
        let headline = adCode.matchingStrings(regexes: headlinePatterns)
        
        // MARK: get ad name by combining ad name and ass id
        let adNamePatterns = [
            "var AdName = '(.+)'"
        ]
        var adName = adCode.matchingStrings(regexes: adNamePatterns)
        let assIdPatterns = [
            "var AssID = '(.+)'"
        ]
        if let assId = adCode.matchingStrings(regexes: assIdPatterns), let adNameString = adName {
            adName = "\(adNameString) (\(assId))"
        }
        
        // MARK: get background color for paid post
        let bgColorPatterns = [
            "var bgColor = '(.+)'"
        ]
        let bgColor = adCode.matchingStrings(regexes: bgColorPatterns) ?? "0"
        
        // MARK: get lead for paid post
        let leadPatterns = [
        "var lead = '(.+)'"
        ]
        let lead = adCode.matchingStrings(regexes: leadPatterns)
        
        // MARK: Impressions
        let impressionPatterns = [
            "var Imp = '(.+)';"
        ]
        
        var impressions = [Impression]()
        if let impressionUrlString = adCode.matchingStrings(regexes: impressionPatterns) {
            let adNameForImpression = adName ?? "Some Ad Name"
            let impression = Impression(urlString: impressionUrlString, adName: adNameForImpression)
            impressions.append(impression)
        }
        
        // MARK: Test Impressions
        //                impressions = [
        //                    Impression(urlString: "https://www.ft.com/", adName: "Some Ad Name")
        //                ]
        
        let adModel = AdModel(
            imageString: image,
            link: link,
            video: video,
            impressions: impressions,
            headline: headline,
            adName: adName,
            bgColor: bgColor,
            lead: lead,
            adCode: adCode
        )
        
        return adModel
    }
    
    public static func getAdUrlFromDolphin(_ adid: String) -> URL? {
        let base = "https://d2hxugxrr2jblf.cloudfront.net/s?z=ft&slot=676544&_sex=101&_cs=1&_csp=1&_dc=2&_mm=2&_sz=2&_am=2&_ut=member&_fallback=0"
        let urlString =  "\(base)&c=\(adid)"
        // MARK: This is a test code, remove before publishing
//        if adid == "20220121" {
//            let testUrlString = "https://raw.githubusercontent.com/FTChinese/AdTemplates/master/paid-post-test.html"
//            if let url = URL(string: testUrlString) {
//                return url
//            }
//        }
        
        if let url = URL(string: urlString) {
            print ("ad url is \(urlString)")
            return url
        }
        return nil
    }
    
}


extension String {
    
    func matchingFirstString(regex: String) -> String? {
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
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
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
