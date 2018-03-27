//
//  WebviewHelper.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/20.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import WebKit

enum ContentSubType {
    case UserComments
    case SpeedReading
    case None
}

struct WebviewHelper {
    static func renderStory(_ type: String, subType: ContentSubType, dataObject: ContentItem?, webView: WKWebView?) {
        if let id = dataObject?.id {
            let urlStringOriginal = (subType == .None) ? APIs.getUrl(id, type: type, isSecure: false, isPartial: false) : APIs.getUrl(id, type: type, subType: subType)
            let urlString: String
            var shouldHideAd = false
            if dataObject?.hideAd == true {
                shouldHideAd = true
            } else if let keywords = dataObject?.keywords {
                for sponsor in Sponsors.shared.sponsors {
                    if (keywords.range(of: sponsor.tag) != nil || keywords.range(of: sponsor.title) != nil) && sponsor.hideAd == "yes" {
                        shouldHideAd = true
                    }
                }
            }
            if shouldHideAd == true {
                urlString = APIs.removeAd(urlStringOriginal)
            } else {
                urlString = urlStringOriginal
            }
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                let lead: String
                let tags = dataObject?.tag ?? ""
                let tag: String
                var imageHTML:String
                
                // MARK: story byline
                let byline: String
                var relatedStories = ""
                if let relatedStoriesData = dataObject?.relatedStories {
                    for (index, story) in relatedStoriesData.enumerated() {
                        if let id = story["id"] as? String,
                            let headline = story["cheadline"] as? String {
                            relatedStories += "<li class=\"mp\(index+1)\"><a target=\"_blank\" href=\"/story/\(id)\">\(headline)</a></li>"
                        }
                    }
                }
                
                if relatedStories != "" {
                    relatedStories = "<div class=\"story-box\"><h2 class=\"box-title\"><a>相关文章</a></h2><ul class=\"top10\">\(relatedStories)</ul></div>"
                }
                
                let tagsArray = tags.components(separatedBy: ",")
                var relatedTopics = ""
                for (index, tag) in tagsArray.enumerated() {
                    relatedTopics += "<li class=\"story-theme mp\(index+1)\"><a target=\"_blank\" href=\"/tag/\(tag)\">\(tag)</a><div class=\"icon-right\"><button class=\"myft-follow plus\" data-tag=\"\(tag)\" data-type=\"tag\">关注</button></div></li>"
                }
                let headlineBody = getHeadlineBody(dataObject)
                let headline = headlineBody.headline
                let finalBody: String
                
                // MARK: Story Time
                let timeStamp: String
                var userCommentsOrder: String = ""
                let styleContainerStyle: String
                var adBanner = ""
                var adMPU = ""
                var storyTheme = ""
                let fontClass = Setting.getFontClass()
                var commentsId = id
                let adchID: String
                if dataObject?.adchId == AdLayout.homeAdChId {
                    adchID = AdParser.getAdchID(dataObject)
                } else {
                    adchID = dataObject?.adchId ?? AdLayout.homeAdChId
                }
                
                if subType == .UserComments {
                    finalBody = ""
                    byline = ""
                    relatedStories = ""
                    relatedTopics = ""
                    tag = ""
                    imageHTML = ""
                    timeStamp = ""
                    lead = ""
                    styleContainerStyle = " style=\"display:none;\""
                    switch type {
                    case "interactive":
                        commentsId = "r_interactive_\(id)"
                    case "video":
                        commentsId = "r_video_\(id)"
                    case "story":
                        commentsId = id
                        userCommentsOrder = "storyall1"
                    case "photo", "photonews":
                        commentsId = "r_photo_\(id)"
                    default:
                        commentsId = "r_\(type)_\(id)"
                    }
                } else if type == "ebook" {
                    finalBody = "<p>\(headlineBody.finalBody.replacingOccurrences(of: "\n", with: "</p><p>", options: .regularExpression))</p>"
                    byline = ""
                    relatedStories = ""
                    relatedTopics = ""
                    tag = ""
                    imageHTML = ""
                    timeStamp = ""
                    lead = ""
                    styleContainerStyle = ""
                    storyTheme = "电子书"
                    if let image = dataObject?.image {
                        imageHTML = "<div class=\"leftPic image portrait-img ebook-image-container\" style=\"margin-bottom:0;\"><div class=\"ebook-image-inner\"><figure data-url=\"\(image)\" class=\"loading\"></figure></div></div>"
                    } else {
                        imageHTML = ""
                    }
                    
                    
                } else {
                    finalBody = headlineBody.finalBody
                    byline = dataObject?.chineseByline ?? ""
                    tag = tags.replacingOccurrences(of: "[,，].*$", with: "", options: .regularExpression)
                    storyTheme = "<div class=\"story-theme\"><a target=\"_blank\" href=\"/tag/\(tag)\">\(tag)</a><button class=\"myft-follow plus\" data-tag=\"\(tag)\" data-type=\"tag\">关注</button></div>"
                    if let image = dataObject?.image {
                        imageHTML = "<div class=\"story-image image\" style=\"margin-bottom:0;\"><figure data-url=\"\(image)\" class=\"loading\"></figure></div>"
                    } else {
                        imageHTML = ""
                    }
                    userCommentsOrder = "story"
                    timeStamp = dataObject?.publishTime ?? ""
                    lead = dataObject?.lead ?? ""
                    styleContainerStyle = ""
                    adBanner = "<script type=\"text/javascript\">document.write(writeAdNew({devices: ['iPhoneApp'],pattern:'Banner',position:'Num1'}));</script>"
                    adMPU = "<script type=\"text/javascript\">document.write (writeAdNew({devices:['iPhoneApp'],pattern:'MPU',position:'Middle1',container:'mpuInStroy'}));</script>"
                }
                
                let followTags = getFollow("tag")
                let followTopics = getFollow("topic")
                let followAreas = getFollow("area")
                let followIndustries = getFollow("industry")
                let followAuthors = getFollow("author")
                let followColumns = getFollow("column")
                
                let resourceFileName: String
                switch type {
                case "ebook":
                    resourceFileName = "ebook"
                default:
                    resourceFileName = "story"
                }
                
                let nightClass = Setting.getNightClass()
                let finalFileName = GB2Big5.convertHTMLFileName(resourceFileName)
                if let adHTMLPath = Bundle.main.path(forResource: finalFileName, ofType: "html"){
                    do {
                        let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let storyHTML = (storyTemplate as String).replacingOccurrences(of: "{story-body}", with: finalBody)
                            .replacingOccurrences(of: "{story-headline}", with: headline)
                            .replacingOccurrences(of: "{story-byline}", with: byline)
                            .replacingOccurrences(of: "{story-time}", with: timeStamp)
                            .replacingOccurrences(of: "{story-lead}", with: lead)
                            .replacingOccurrences(of: "{story-theme}", with: storyTheme)
                            .replacingOccurrences(of: "{story-tag}", with: tag)
                            .replacingOccurrences(of: "{story-id}", with: id)
                            .replacingOccurrences(of: "{story-image}", with: imageHTML)
                            .replacingOccurrences(of: "{related-stories}", with: relatedStories)
                            .replacingOccurrences(of: "{related-topics}", with: relatedTopics)
                            .replacingOccurrences(of: "{comments-order}", with: userCommentsOrder)
                            .replacingOccurrences(of: "{story-container-style}", with: styleContainerStyle)
                            .replacingOccurrences(of: "['{follow-tags}']", with: followTags)
                            .replacingOccurrences(of: "['{follow-topics}']", with: followTopics)
                            .replacingOccurrences(of: "['{follow-industries}']", with: followIndustries)
                            .replacingOccurrences(of: "['{follow-areas}']", with: followAreas)
                            .replacingOccurrences(of: "['{follow-authors}']", with: followAuthors)
                            .replacingOccurrences(of: "['{follow-columns}']", with: followColumns)
                            .replacingOccurrences(of: "{adchID}", with: adchID)
                            .replacingOccurrences(of: "{ad-banner}", with: adBanner)
                            .replacingOccurrences(of: "{ad-mpu}", with: adMPU)
                            .replacingOccurrences(of: "{font-class}", with: fontClass)
                            .replacingOccurrences(of: "{comments-id}", with: commentsId)
                            .replacingOccurrences(of: "{night-class}", with: nightClass)
                            
                        let storyHTMLCheckingVideo = JSCodes.getInlineVideo(storyHTML)
                        let storyHTMLRemovingCodes = JSCodes.getCleanHTML(storyHTMLCheckingVideo)
                        webView?.loadHTMLString(storyHTMLRemovingCodes, baseURL:url)
                    } catch {
                        webView?.load(request)
                    }
                } else {
                    webView?.load(request)
                }
            }
        }
    }
    
    // MARK: load content pages such as story, interactive, audio, video, etc...
    static func loadContent(url: String, base: String, webView: WKWebView?) {
        if var urlComponents = URLComponents(string: url) {
            let newQuery = APIs.newQueryForWebPage()
            if urlComponents.queryItems != nil {
                urlComponents.queryItems?.append(newQuery)
            } else {
                urlComponents.queryItems = [newQuery]
            }
            if let urlLink = urlComponents.url,
                let baseUrl = URL(string: base) {
                // MARK: - If it's a url that might be saved
                if urlLink.scheme == "https" {
                    if let data = Download.readFile(url, for: .cachesDirectory, as: "html"),
                        let htmlString = String(data: data, encoding: .utf8) {
                        webView?.loadHTMLString(htmlString, baseURL:baseUrl)
                        // MARK: - If user is on wifi, download the url for possible update of content.
                        if IJReachability().connectedToNetworkOfType() == .wiFi {
                            Download.downloadUrl(url, to: .cachesDirectory, as: "html")
                        }
                    } else {
                        // MARK: - If the file has not been downloaded yet
                        Download.getDataFromUrl(urlLink, completion: {[weak webView] (data, response, error) in
                            if let data = data,
                                let htmlString = String(data: data, encoding: .utf8) {
                                DispatchQueue.main.async {
                                    webView?.loadHTMLString(htmlString, baseURL:baseUrl)
                                }
                                Download.saveFile(data, filename: url, to: .cachesDirectory, as: "html")
                            }
                        })
                    }
                } else {
                    let request = URLRequest(url: urlLink)
                    webView?.load(request)
                }
            }
        }
    }
    
    static func getHeadlineBody(_ dataObject: ContentItem?) -> (headline: String, finalBody: String) {
        // MARK: Get values for the story content
        let headline: String
        let body: String
        let languagePreference = UserDefaults.standard.integer(forKey: Key.languagePreference)
        let eHeadline = dataObject?.eheadline ?? ""
        let eBody = dataObject?.ebody ?? ""
        let cBody = dataObject?.cbody ?? ""
        let cHeadline = dataObject?.headline ?? ""
        if eBody != "" && (languagePreference == 1 || (dataObject?.type == "interactive" && dataObject?.eaudio != nil)) {
            headline = eHeadline
            body = eBody
        } else if eBody != "" && languagePreference == 2 {
            headline = "<div>\(eHeadline)</div><div>\(cHeadline)</div>"
            body = getCEbodyHTML(eBody: eBody, cBody: cBody)
        } else {
            headline = cHeadline
            body = cBody
        }
        let bodyWithMPU = body.replacingOccurrences(
            of: "[\r\t\n]",
            with: "",
            options: .regularExpression
            ).replacingOccurrences(
                of: "^(<p>.*?<p>.*?<p>.*?)<p>",
                with: "$1\(JSCodes.adMPU)<p>",
                options: .regularExpression
        )
        
        // TODO: Premium user will not need to see the MPU ads
        let finalBody: String
        finalBody = bodyWithMPU.replacingOccurrences(
            of: "^(<p>.*?<p>.*?<p>.*?<p>.*?<p>.*?<p>.*?)<p>",
            with: "$1\(JSCodes.adMPU2)<p>",
            options: .regularExpression
        )
        return (headline, finalBody)
        
    }
    
    
    private static func getCEbodyHTML(eBody ebody: String, cBody cbody: String) -> String {
        func getHTML(_ htmls:[String], for index: Int, in className: String) -> String {
            let text: String
            if index < htmls.count {
                text = htmls[index]
            } else {
                text = ""
            }
            let html = "<div class=\(className)><p>\(text)</p></div>"
            return html
        }
        let paragraphPattern = "<p>(.*)</p>"
        let ebodyParapraphs = ebody.matchingArrays(regex: paragraphPattern)
        let cbodyParapraphs = cbody.matchingArrays(regex: paragraphPattern)
        let ebodyLength = ebodyParapraphs?.count ?? 0
        let cbodyLength = cbodyParapraphs?.count ?? 0
        let contentLength = max(ebodyLength, cbodyLength)
        var combinedText = ""
        
        // MARK: Use the pure text in the matching array. Filter out paragraphs that has html tags like img and div
        let ebodysHTML = ebodyParapraphs?.map { (value) -> String in
            let text = value[1]
            return text
            }.filter{
                !$0.contains("<img") && !$0.contains("<div")
        }
        
        let cbodysHTML = cbodyParapraphs?.map { (value) -> String in
            let text = value[1]
            return text
            }.filter{
                !$0.contains("<img") && !$0.contains("<div")
        }
        
        if let ebodysHTML = ebodysHTML, let cbodysHTML = cbodysHTML {
            for i in 0..<contentLength {
                let ebodyHTML = getHTML(ebodysHTML, for: i, in: "leftp")
                let cbodyHTML = getHTML(cbodysHTML, for: i, in: "rightp")
                combinedText += "\(ebodyHTML)\(cbodyHTML)<div class=clearfloat></div>"
            }
        }
        return combinedText
    }
    
    
    private static func getFollow(_ type: String) -> String {
        let follows = UserDefaults.standard.array(forKey: "follow \(type)") as? [String] ?? [String]()
        var followString = ""
        for (index, value) in follows.enumerated() {
            if index == 0 {
                followString += "'\(value)'"
            } else {
                followString += ",'\(value)'"
            }
        }
        return "[\(followString)]"
    }
}
