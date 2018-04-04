//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/4.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
// MARK: Different organization might use different way to construct API and urls
struct APIs {
    
    // MARK: Domain Name For APIs
    private static let htmlDomains = [
        "https://api003.ftmailbox.com/",
        "https://d2e90etfgpidmd.cloudfront.net/"
    ]
    
    // MARK: Domain Name maily for stories
    private static let backupHTMLDomains = [
        "https://d1budb999l6vta.cloudfront.net/",
        "https://d2e90etfgpidmd.cloudfront.net/"
    ]
    
    // MARK: Backup server for List Pages
    private static let backupHTMLDomains2 = [
        "https://d37m993yiqhccr.cloudfront.net/",
        "https://d2e90etfgpidmd.cloudfront.net/"
    ]
    
    // MARK: Backup server 3
    private static let backupHTMLDomains3 = [
        "https://d2noncecxepzyq.cloudfront.net/",
        "https://d2e90etfgpidmd.cloudfront.net/"
        //        "https://danla2f5eudt1.cloudfront.net/",
        //        "https://d2e90etfgpidmd.cloudfront.net/"
    ]
    
    
    // MARK: Domain reserved for subscribers only
    private static let subscriberDomain = [
        "https://webnodeiv.ftchinese.com/",
        "https://webnodeiv.ftchinese.com/"
    ]
    
    // MARK: If there are http resources that you rely on in your page, don't use https as the url base
    private static let webPageDomains = [
        "http://www.ftchinese.com/",
        "http://big5.ftchinese.com/"
    ]

    private static let publicDomains = [
        //"http://app003.ftmailbox.com/",
        "http://www.ftchinese.com/",
        "http://big5.ftmailbox.com/"
    ]
    
    // MARK: - Domain Check: HTTPS domain for audio files
    public static func getAudioDomain() -> String {
        if Privilege.shared.exclusiveContent {
            return "https://creatives001.ftimg.net/"
        }
        return "https://creatives002.ftimg.net/"
    }
    
    
    // MARK: - Domain Check: iOS Receipt Validation
    public static func getiOSReceiptValidationUrlString() -> String {
        if Privilege.shared.exclusiveContent {
            return "https://api002.ftmailbox.com/ios-receipt-validation.php"
        }
        return "https://api003.ftmailbox.com/ios-receipt-validation.php"
    }
    
    // MARK: - Domain Check: Engagement Tracker
    public static func getEngagementTrackerUrlString() -> String {
        if Privilege.shared.exclusiveContent {
            return "https://api002.ftmailbox.com/engagement-tracker.php"
        }
        return "https://api003.ftmailbox.com/engagement-tracker.php"
    }
    
    // MARK: - Domain Check: Track device token
    public static func getDeviceTokenUrlString() -> String {
        if Privilege.shared.exclusiveContent {
            return "https://noti001.ftimg.net/iphone-collect.php"
        }
        return "https://noti.ftimg.net/iphone-collect.php"
    }
    
    // MARK: - Domain Check: Launch Ad Schedule.
    // TODO: - Use background downloading domain just for launch ad schedule
    //public static let lauchAdSchedule = "https://webnodev.ftchinese.com/index.php/jsapi/applaunchschedule"
    public static let lauchAdSchedule = "https://api003.ftmailbox.com/index.php/jsapi/applaunchschedule"

    public static let customerServiceUrlString = "http://www.ftchinese.com/m/corp/subscriber.html?webview=ftcapp&ad=no"
    
    // MARK: Number of days you want to keep the cached files
    public static let expireDay: TimeInterval = 7
    
    // MARK: Search is mostly rendered using web
    public static let searchUrl = "http://www.ftchinese.com/search/"
    public static func jsForSearch(_ keywords: String) -> String {
        return "search('\(keywords)');"
    }
    
    // MARK: Types of files that you want to clean from time to time
    static let expireFileTypes = ["json", "jpeg", "jpg", "png", "gif", "mp3", "mp4", "mov", "mpeg", "cover", "thumbnail", "html", "OutlookoftheFutureof2017", "lunch2", "lunch1"]
    
    public static func getUrlStringInLanguage(_ from: [String]) -> String {
        let currentPrefence = LanguageSetting.shared.currentPrefence
        let urlString: String
        if currentPrefence > 0 && currentPrefence < htmlDomains.count{
            urlString = from[currentPrefence]
        } else {
            urlString = from[0]
        }
        return urlString
    }
    
    // MARK: Construct url strings for different types of content
    static func get(_ id: String, type: String, forceDomain: String?) -> String {
        let urlString: String
        let originalDomain = getUrlStringInLanguage(htmlDomains)
        let domain = forceDomain ?? checkServer(originalDomain)
        
        switch type {
        case "story":
            urlString = "\(domain)index.php/jsapi/get_story_more_info/\(id)"
        case "premium":
            // TODO: Update the url when premium api is available
            urlString = "\(domain)index.php/jsapi/get_story_more_info/\(id)"
        case "htmlbook":
            urlString = "\(webPageDomains)\(type)/\(id)"
        case "pagemaker":
            urlString = "\(domain)m/corp/preview.html?pageid=\(id)&webview=ftcapp"
        case "tag":
            if let encodedTag = id.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                urlString = "\(domain)\(type)/\(encodedTag)?type=json"
            } else {
                urlString = "\(domain)\(type)/\(id)?type=json"
            }
        case "follow":
            // MARK: Calculate the url string for follow
            let followTypes = Meta.map
            var parameterString = ""
            for followTypeArray in followTypes {
                if let followType = followTypeArray["key"] as? String {
                    let followKeywords = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
                    var keyStrings = ""
                    for (index, value) in followKeywords.enumerated() {
                        if index == 0 {
                            keyStrings += value
                        } else {
                            keyStrings += ",\(value)"
                        }
                    }
                    if keyStrings != "" {
                        parameterString += "&\(followType)=\(keyStrings)"
                    }
                }
            }
            parameterString = parameterString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? parameterString
            urlString = "\(domain)channel/json.html?pageid=myftfollow&002\(parameterString)"
            print ("follow request type: \(urlString)")
        default:
            urlString = "\(domain)index.php/jsapi/get_story_more_info/\(id)"
        }
        return urlString
    }
    
    // MARK: Get url string for myFT
    static func get(_ key: String, value: String) -> String {
        let domain = getUrlStringInLanguage(htmlDomains)
        return "\(domain)channel/china.html?type=json&\(key)=\(value)"
    }
    
    // MARK: Convert Url String for Alternative Language Such as Big5
    static func convert(_ from: String) -> String {
        let currentPreference = LanguageSetting.shared.currentPrefence
        if currentPreference == 0 {
            return checkServer(from)
        }
        let allDomainArrays = [htmlDomains, backupHTMLDomains, backupHTMLDomains2, backupHTMLDomains3, webPageDomains, publicDomains]
        var newString = from
        for domainArray in allDomainArrays {
            if currentPreference>0 && currentPreference < domainArray.count {
                newString = newString.replacingOccurrences(
                    of: domainArray[0],
                    with: domainArray[currentPreference]
                )
            }
        }
        return checkServer(newString)
    }
    
    // MARK: Get Public Domain
    static func getPublicDomain() -> String {
        let currentPreference = max(1, min(0,LanguageSetting.shared.currentPrefence))
        return publicDomains[currentPreference]
    }
    
    // MARK: Handle non-https links and try to convert them into https links
    static func handleMaualLink(_ from: String) -> String {
        return from
    }
    
    // MARK: Check if the server is likely to respond correctly
    private static func checkServer(_ from: String) -> String {
        // MARK: Get the current luanguage index
        let currentPreference = LanguageSetting.shared.currentPrefence
        let currentIndex = (currentPreference == 0) ? 0 : 1
        
        // MARK: Switch to new domain immediately for subscribers and important user, only if the new secure domain is availabe and assumed accessible
        let serverNotResponding = UserDefaults.standard.string(forKey: Download.serverNotRespondingKey)
        
        // MARK: If the server is inaccessible and new one is available, use that. It should only apply to https.
        var newFrom = from
        let newSecureDomain:String?
        if newFrom.range(of: "https://") != nil {
            // MARK: Exclusive domain for subscribers
            if let forceDomain = ForceDomains.getNewDomain(forBaseUrl: false),
                forceDomain != serverNotResponding {
                // MARK: If the device get notification from APNS
                newFrom = newFrom.replacingOccurrences(of: "^https://.*.(com|net)/", with: forceDomain, options: .regularExpression)
                newSecureDomain = forceDomain
            } else if Privilege.shared.exclusiveContent {
                newFrom = newFrom.replacingOccurrences(of: "^https://.*.(com|net)/", with: subscriberDomain[currentIndex], options: .regularExpression)
                newSecureDomain = subscriberDomain[currentIndex]
            } else {
                newSecureDomain = nil
            }
        } else {
            newSecureDomain = nil
            // MARK: Use new base url
            if let forceDomainForBaseUrl = ForceDomains.getNewDomain(forBaseUrl: true),
                forceDomainForBaseUrl != publicDomains[currentIndex] {
                newFrom = newFrom.replacingOccurrences(of: publicDomains[currentIndex], with: forceDomainForBaseUrl)
                //print ("New Base Url is: \(newFrom)")
            }
        }

        //print ("Server Watch: new domain \(String(describing: newSecureDomain)) and old server that are not responding: \(String(describing: serverNotResponding))")
        if newSecureDomain != nil && newSecureDomain != serverNotResponding {
            //print ("Server Watch: new domain \(String(describing: newSecureDomain))")
            return newFrom
        }
        if let serverNotResponding = serverNotResponding {
            let servers: [String]
            if let newSecureDomain = newSecureDomain {
                // MARK: If a new secure domain is available, add it to the available server list
                servers = [
                    newSecureDomain,
                    htmlDomains[currentIndex]
//                    backupHTMLDomains[currentIndex],
//                    backupHTMLDomains2[currentIndex],
//                    backupHTMLDomains3[currentIndex]
                ]
            } else {
                servers = [
                    htmlDomains[currentIndex]
//                    backupHTMLDomains[currentIndex],
//                    backupHTMLDomains2[currentIndex],
//                    backupHTMLDomains3[currentIndex]
                ]
            }

            //print ("Server Watch: \(servers.joined(separator: ","))")
            // MARK: if you are checking a url that is not using one of the backup servers, return immediately.
            var serverUsedByFromString: String? = nil
            for server in servers {
                if newFrom.hasPrefix(server) {
                    serverUsedByFromString = server
                    break
                }
            }
            if serverUsedByFromString == nil {
                //print ("Server Watch: did not find \(newFrom)")
                return newFrom
            }
            //print ("Server Watch: found \(newFrom)")
            if let errorServerIndex = servers.index(of: serverNotResponding) {
                var nextServerIndex = errorServerIndex + 1
                if nextServerIndex >= servers.count {
                    nextServerIndex = 0
                }
                if let serverUsedByFromString = serverUsedByFromString {
                    let newUrlString = newFrom.replacingOccurrences(of: serverUsedByFromString, with: servers[nextServerIndex])
                    print ("Server Watch: new url string is \(newUrlString)")
                    return newUrlString
                }
            }
        }
        print ("Server Watch: current url string is \(newFrom) without change")
        return newFrom
    }
    
    // MARK: Use different domains for different types of content
    static func getUrl(_ id: String, type: String, isSecure: Bool, isPartial: Bool) -> String {
        let urlString: String
        let webPageDomain: String
        let publicDomain: String
        if isSecure == true {
            let originalDomain = getUrlStringInLanguage(htmlDomains)
            let domain = checkServer(originalDomain)
            webPageDomain = domain
            publicDomain = domain
        } else {
            webPageDomain = getUrlStringInLanguage(webPageDomains)
            let publicDomainOriginal = getUrlStringInLanguage(publicDomains)
            publicDomain = checkServer(publicDomainOriginal)
        }
        let partialParameter: String
        if isPartial == true {
            partialParameter = "?bodyonly=yes"
        } else {
            partialParameter = "?bodyonly=no"
        }
        let hideAdParameter: String
        if id.range(of: "EditorChoice") != nil {
            hideAdParameter = "&ad=no"
        } else {
            hideAdParameter = ""
        }
        switch type {
        case "video":
            urlString = "\(webPageDomain)\(type)/\(id)\(partialParameter)&webview=ftcapp"
        case "radio":
            urlString = "\(webPageDomain)interactive/\(id)\(partialParameter)&webview=ftcapp&exclusive"
        case "pagemaker":
            urlString = "\(webPageDomain)m/corp/preview.html\(partialParameter)&pageid=\(id)&webview=ftcapp\(hideAdParameter)"
        case "interactive", "gym", "special":
            urlString = "\(webPageDomain)interactive/\(id)\(partialParameter)&webview=ftcapp&i=3&001&exclusive"
        case "channel", "tag", "archive", "archiver":
            urlString = "\(webPageDomain)\(type)/\(id.addUrlEncoding())\(partialParameter)&webview=ftcapp"
        case "story", "premium":
            urlString = "\(publicDomain)/\(type)/\(id)\(partialParameter)&webview=ftcapp&full=y"
        case "photonews", "photo":
            urlString = "\(webPageDomain)photonews/\(id)\(partialParameter)&webview=ftcapp&i=3"
        case "register":
            urlString = "\(publicDomain)index.php/users/register\(partialParameter)&i=4&webview=ftcapp"
        case "htmlbook":
            urlString = "\(webPageDomain)htmlbook\(partialParameter)"
        case "htmlfile":
            urlString = "\(webPageDomain)htmlfile\(partialParameter)"
        case "html":
            urlString = "\(webPageDomain)\(id).html\(partialParameter)"
        default:
            urlString = "\(webPageDomain)\(partialParameter)"
        }
        return urlString
    }
    
    // MARK: add paramter to indicate the url should hide ad
    static func removeAd(_ urlString: String) -> String {
        let connector: String
        if urlString.range(of: "?") == nil {
            connector = "?"
        } else {
            connector = "&"
        }
        return "\(urlString)\(connector)ad=no"
    }
    
    // MARK: add parameters for audio url
    static func addParameters(to urlString: String, for type: String) -> String {
        let connector: String
        if urlString.range(of: "?") == nil {
            connector = "?"
        } else {
            connector = "&"
        }
        let finalUrlString: String
        switch type {
        case "audio":
            finalUrlString = "\(urlString)\(connector)hideheader=yes&ad=no&inNavigation=yes&for=audio&enableScript=yes&v=22"
                .replacingOccurrences(of: "&i=3", with: "")
                .replacingOccurrences(of: "?i=3", with: "")
        default:
            finalUrlString = urlString
        }
        return finalUrlString
    }
    
    // MARK: Get url string for subtypes by adding parameters to type urlstring
    static func getUrl(_ id: String, type: String, subType: ContentSubType) -> String {
        let urlString = getUrl(id, type: type, isSecure: false, isPartial: false)
        let finalUrlString: String
        let connector = (urlString.range(of: "?") == nil) ? "?" : "&"
        switch subType {
        case .UserComments:
            finalUrlString = "\(urlString)\(connector)ad=no"
        default:
            finalUrlString = urlString
        }
        return finalUrlString
    }
    
    // MARK: get the url parameter related to subscription
    static func getSubscriptionParameter(from urlString: String) -> String {
        let subscriberParameter: String
        if urlString.range(of: "pagetype=home") != nil {
            if Privilege.shared.editorsChoice == true {
                subscriberParameter = "&subscription=premium"
            } else if Privilege.shared.exclusiveContent == true {
                subscriberParameter = "&subscription=member"
            } else {
                subscriberParameter = ""
            }
        } else {
            subscriberParameter = ""
        }
        return subscriberParameter
    }
    
    // MARK: check if the dataObject is a type that should hide ad
    static func shouldHideAd(_ dataObject: [String: String]) -> Bool {
        if dataObject["type"] == "htmlbook" {
            return true
        }
        if dataObject["listapi"]?.range(of: "EditorChoice") != nil {
            return true
        }
        return false
    }
    
    // MARK: check if the list api url indicates no-repeat for same content
    static func noRepeatForSameContent(_ url: String) -> Bool {
        if url.range(of: "norepeat=yes") != nil {
            return true
        }
        return false
    }
    
    // MARK: check if the dataObject is an editor's choice
    static func isEditorChoice(_ dataObject: [String: String]) -> Bool {
        if dataObject["listapi"]?.range(of: "EditorChoice") != nil {
            return true
        }
        return false
    }
    
    // MARK: Add query parameter to the url so that the web pages knows it is opened in our app. Then it'll do things like hide headers.
    static func newQueryForWebPage() -> URLQueryItem {
        return URLQueryItem(name: "webview", value: "ftcapp")
    }
    
    static func clip(_ id: String, type: String, action: String) -> String? {
        if type == "story" {
            let urlStringBase = "/index.php/users/"
            let urlStringAction: String
            if action == "save" {
                urlStringAction = "addfavstory"
            } else {
                urlStringAction = "removefavstory"
            }
            let urlString = "\(urlStringBase)\(urlStringAction)/\(id)"
            let jsCode = "updateFav('\(urlString)', '\(id)')"
            return jsCode
        }
        return nil
    }
    
    public static func getHTMLCode(_ from: String) -> String {
        let key = "Saved \(from)"
        let savedItems = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? [[String: String]]()
        var contentItems = ""
        for item in savedItems {
            let id = item["id"] ?? ""
            let type =  item["type"] ?? ""
            let link = "/\(type)/\(id)"
            let lead = item["lead"] ?? ""
            let contentItem = "<div class=\"item-container one-row L6 M12 S6 P12 item-container-app no-image\" data-id=\"\(id)\" data-type=\"\(type)\"><div class=\"item-inner\"><h2 class=\"item-headline\"><a target=\"_blank\" href=\"\(link)\">\(item["headline"] ?? "")</a></h2><div class=\"item-lead\">\(lead)</div><div class=\"icon-right icon-save\"></div><div class=\"item-bottom\"></div></div></div>"
            contentItems += contentItem
        }
        contentItems = "<div class=\"block-container has-side\"><div class=\"block-inner\"><div class=\"content-container\"><div class=\"content-inner\"><div class=\"list-container\"><div class=\"list-inner\"><div class=\"items\">\(contentItems)<div id=\"myfavorite-remote\"></div><div class=\"clearfloat\"></div></div></div></div><div class=\"clearfloat block-bottom\"></div></div></div><div class=\"side-container\"><div class=\"side-inner\"><script type=\"text/javascript\">document.write (writeAdNew({devices: ['PC','PadWeb','iPhoneApp','AndroidApp'],pattern:'MPU',position:'Right1'}));</script></div></div><div class=\"clearfloat\"></div></div></div>"
        return contentItems
    }
    
    static func sendThirdPartyTrackings(_ itemId: String, category: String, action: String, label: String) {
        let timeInterval = Int((Date().timeIntervalSince1970)*100000)
        let cntTime = String(timeInterval)
        let ip = NetworkHelper.getWiFiAddress() ?? ""
        // MARK: Send User Location Only For Engagement Related Analysis
        let loc: String
        if let location = LocationHelper.shared.get() {
            loc = "\(location.latitude), \(location.longtitude)"
        } else {
            loc = ""
        }
        let targetDict = [
            "category": category,
            "action": action,
            "label": label,
            "iosToken": UserInfo.shared.deviceToken ?? "",
            "visitorId": UserInfo.shared.uniqueVisitorId ?? "",
            "loc": loc
        ]
        var targetString = ""
        var isFirstItem = true
        for (key, value) in targetDict {
            let seperatorString: String
            if isFirstItem == false {
                seperatorString = ","
            } else {
                seperatorString = ""
                isFirstItem = false
            }
            targetString += "\(seperatorString)\"\(key)\":\"\(value)\""
        }
        let dataForYoulu = [
            "appId": "5002",
            "itemId": itemId,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "action": "0",
            "target": "{\(targetString)}",
            "cntTime": cntTime,
            "ip": ip,
            "cki": UserInfo.shared.userId ?? ""
        ]
        print ("data for youlu: \(dataForYoulu)")
        PostData.sendToThirdParty("https://uluai.com.cn/rcmd/getAppInfo", with: dataForYoulu)
    }
    
}

// MARK: - Error message in diffent languages
struct ErrorMessages {
    struct NoInternet {
        static let en = "Dear reader, you are not connected to the Internet Now. Please connect and try again. "
        static let gb = "亲爱的读者，您现在没有连接互联网，也可能没有允许FT中文网连接互联网的权限，请检查连接和设置之后重试。"
        static let big5 = "親愛的讀者，您現在沒有連接互聯網，也可能沒有允許FT中文網連接互聯網的權限，請檢查連接和設置之後重試。"
    }
    struct Unknown {
        static let en = "Dear reader, you are not able to connect to our server now. Please try again later. "
        static let gb = "亲爱的读者，您现在无法连接FT中文网的服务器，请稍后重试。"
        static let big5 = "親愛的讀者，您現在無法連接FT中文網的服務器，請稍後重試。"
    }
    struct Loading {
        private static let loadingMessage = "<div style=\"text-align: center;\" id='loading-message'>努力加载中...</div>"
        private static let title = "非常抱歉"
        private static let description = "服务器开小差了，您的手机暂时无法获得新的内容。"
        private static let explainTitle = "为什么会发生这样的事？"
        private static let explainDescription = "我们问了领先的经济学家，得到了如下的解释："
        private static let explainations = [
            (title: "滞胀", description: "获取您所需内容的成本涨了，但是内容加载进程又停滞不前。"),
            (title: "通用经济学", description: "没有市场，数据交换发生不了啊！"),
            (title: "流动性陷阱", description: "我们把钱给了技术团队，但是由于现在利息太低，他们就把钱藏在机房里了。所以服务器还是没有启动！"),
            (title: "没达到帕累托最优", description: "存在着另外一个板块，它会让每个人都更开心，而且不会让任何人更不开心。"),
            (title: "供给和需求", description: "太多人蜂拥到FT中文网，导致服务器的服务能力产生了短缺。"),
            (title: "经典经济学", description: "根本就不存在你要看的那个板块，所以你啥也看不见，我们也不会干预。"),
            (title: "凯恩斯经济学", description: "对这个板块的累积需求不一定等于我们能提供服务的能力。"),
            (title: "马尔萨斯理论", description: "不受限制，以几何级数增长的数据请求导致像素的短缺，引发了一场不可避免的灾难。我们对这个板块实施了计划生育，它根本就没出生。")
        ]
        static func getExplainationHTML(with url: String) -> String {
            let titleString = "<h1>\(title)</h1><div>\(description)</div><div>请<a onclick=\"javascript: window.location.href='\(url)';\">点击此处重试一次</a></div>"
            let explainString = "<h2>\(explainTitle)</h2><div>\(explainDescription)</div>"
            var explains = ""
            for explain in explainations {
                explains += "<h3>\(explain.title)</h3><div>\(explain.description)</div>"
            }
            let explainerString = "<style>h1, h2, h3, div {line-height: 140%;}div{padding-bottom: 1em;}</style><div style='padding: 15px;display:none;' id='economics-explainer'>\(titleString)\(explainString)\(explains)</div>"
            let timeoutScript = "<script>setTimeout(function(){document.getElementById('loading-message').style.display = 'none';document.getElementById('economics-explainer').style.display = 'block';}, 10000);</script>"
            return "\(loadingMessage)\(explainerString)\(timeoutScript)"
        }
    }
    // MARK: This code is here because every app would want to set up different ways to measure user happyness.
    struct Feedback {
        public static func score(category: String, action: String, label: String) -> Int {
            if category == "CatchError" {
                // MARK: If there's an error, the user is likely to be very upset. So don't even try to request review.
                HappyUser.shared.canTryRequestReview = false
                // MARK: For now, a catch error event gets a minus one score. We can update that later.
                return -1
            }
            // TODO: There might some events that indicate the user should be very happy. This might be a good opportunity to request review.
            
            
            return 0
        }
    }
}

// MARK: - Use struct to store information so that Xcode can auto-complete codes
struct Event {
    static let englishStatusChange = "English Status Change"
    static let languageSelected = "Language Selected in Story Page"
    static let languagePreferenceChanged = "Language Preference Changed By User Tap"
    static let changeFont = "switch font"
    static let newAdCreativeDownloaded = "New Ad Creative Downloaded"
    static let nightModeChanged = "Night Mode Changed"
    //    static func paidPostUpdate(for page: String) -> String {
    //        let paidPostUpdated = "Paid Post Update"
    //        return "\(paidPostUpdated) for \(page)"
    //    }
}



// MARK: - Use struct to store information so that Xcode can auto-complete codes
struct Key {
    static let languagePreference = "Language Preference"
    static let audioLanguagePreference = "Audio Language Preference"
    static let domainIndex = "Domain Index"
    static let searchHistory = "Search History"
    static let audioHistory = ["Audio Headline History","Audio URL History","Audio Id History","Audio Last Play Time History"]
}

// MARK: - Use a server side image service so that you can request images that are just large enough. If you don't have a image service such as the FT's, you can simply return the same image url.
struct ImageService {
    static func resize(_ imageUrl: String, width: Int, height: Int) -> String {
        return "https://www.ft.com/__origami/service/image/v2/images/raw/\(imageUrl)?source=ftchinese&width=\(width * 2)&height=\(height * 2)&fit=cover"
    }
}

// MARK: - Recognize link patterns in your specific web site so that your app opens links intelligently, rather than opening everything with web view or safari view.
struct LinkPattern {
    static let xiaobingStoryLink = ["http://int-cslog.chinacloudapp.cn/Home/Log\\?content=.*&originalId=([0-9]+)&impressionId=[a-z0-9A-Z]+$","http://cslog.trafficmanager.cn/Home/Log\\?content=.*&originalId=([0-9]+)&impressionId=[a-z0-9A-Z]+$"]
    static let ftcStoryLink = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/story/([0-9]+)"]
    static let story = xiaobingStoryLink + ftcStoryLink
    static let interactive = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/interactive/([0-9]+)"]
    static let video = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/video/([0-9]+)"]
    static let photonews = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/photonews/([0-9]+)"]
    static let tag = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/tag/([^?]+)"]
    static let archiver = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/archiver/([0-9-]+)"]
    static let search = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/search/.*page=([0-9]+)"]
    static let channel = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/channel/([0-9-a-zA-Z]+.html)"]
    static let pagemaker = ["^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/m/corp/preview.html\\?pageid\\=([0-9-a-zA-Z]+)", "^http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/channel/editorchoice-issue.html\\?issue\\=([0-9-a-zA-Z]+)"]
    static let other = ["^(http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+).*$"]
    static let image = [
        "^(http[s]*://.*.jpg)$",
        "^(http[s]*://.*.gif)$",
        "^(http[s]*://.*.png)$",
        "^(http[s]*://.*.jpeg)$"
    ]
    //other:"http://int-cslog.chinacloudapp.cn/Home/Log\\?content=.*&originalId=[0-9]+&impressionId=[a-z0-9A-Z]+$"
}

// MARK: - When you want to add content that are not already in your APIs. For example, you might want to add a most popular section to your home page.
struct SupplementContent {
    static func insertContent(_ layout: String, to contentSections: [ContentSection]) -> [ContentSection] {
        var newContentSections = contentSections
        // MARK: It is possible that the JSON Format is broken. Check it here.
        if newContentSections.count < 1 {
            return newContentSections
        }
        switch layout {
        case "home":
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        case "follows":
            let followTypes = Meta.map
            for followTypeArray in followTypes {
                if let followType = followTypeArray["key"] as? String
                {
                    var followKeywords = followTypeArray["meta"] as? [String: String] ?? [String: String]()
                    let followedKeywords = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
                    for key in followedKeywords {
                        if followKeywords[key] == nil {
                            followKeywords[key] = key
                        }
                    }
                    var items = [ContentItem]()
                    for (key, value) in followKeywords {
                        let item = ContentItem(
                            id: key,
                            image: "",
                            headline: value,
                            lead: "",
                            type: "follow",
                            preferSponsorImage: "",
                            tag: "",
                            customLink: "",
                            timeStamp: 0,
                            section: 0,
                            row: 0
                        )
                        item.followType = followType
                        items.append(item)
                    }
                    if items.count > 0 {
                        let newContentSection = ContentSection(
                            title: followTypeArray["name"] as? String ?? "",
                            items: items,
                            type: "List",
                            adid: nil
                        )
                        newContentSections.append(newContentSection)
                    }
                }
            }
            return newContentSections
        case "ipadhome":
            // MARK: - The first item in the first section should be marked as Cover
            newContentSections[0].items[0].isCover = true
            // MARK: - Break up the first section into two or more, depending on how you want to layout ads
            return newContentSections
        default:
            return newContentSections
        }
    }
}

struct Meta {
    // MARK: - Things your users can follow
    static let map: [[String: Any]] = [
        ["key": "tag",
         "name": "标签"
        ],
        ["key": "topic",
         "name": "话题",
         "meta": [
            "markets": "金融市场",
            "management": "管理",
            "lifestyle": "生活时尚",
            "business": "商业"
            ]
        ],
        ["key": "area",
         "name": "地区",
         "meta": [
            "china": "中国",
            "us": "美国",
            "europe": "欧洲",
            "africa": "非洲"
            ]
        ],
        ["key": "industry",
         "name": "行业",
         "meta": [
            "technology": "科技",
            "media": "媒体"
            ]
        ],
        ["key": "author",
         "name": "作者"
        ],
        ["key": "column",
         "name": "栏目"
        ]
    ]
    
    // MARK: Tags that are not meant for users to see
    static let reservedTags = [
        "QuizPlus",
        "单选题",
        "SurveyPlus",
        "置顶",
        "低调",
        "精华",
        "小测",
        "生活时尚",
        "深度阅读",
        "教程",
        "测试",
        "FT商学院",
        "英语电台",
        "视频",
        "新闻",
        "数据新闻"
    ]
}

// MARK: - If you are using Admob to track download and performance
struct AdMobTrack {
    static func launch() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ACTConversionReporter.report(withConversionID: "937693643", label: "Qe7aCL-Kx2MQy6OQvwM", value: "1.00", isRepeatable: false)
        } else {
            ACTConversionReporter.report(withConversionID: "937693643", label: "TvNTCJmOiGMQy6OQvwM", value: "1.00", isRepeatable: false)
        }
    }
}

// MARK: - For push notification
struct DeviceToken {
    public static let key = "Device Token Key Word"
    // MARK: - Post device token to server
    static func forwardTokenToServer(deviceToken token: Data) {
        let hexEncodedToken = token.map { String(format: "%02hhX", $0) }.joined()
        UserInfo.shared.deviceToken = hexEncodedToken
        UserDefaults.standard.set(hexEncodedToken, forKey: key)
        print("device token: \(hexEncodedToken)")
        // MARK: calculate appNumber based on your bundel ID
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let appNumber: String
        switch bundleID {
        case "com.ft.ftchinese.ipad":
            appNumber = "1"
        case "com.ft.ftchinese.mobile":
            appNumber = "2"
        default:
            appNumber = "0"
        }
        // MARK: get device type
        var deviceType: String
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            deviceType = "pad"
        case .phone:
            deviceType = "phone"
        default:
            deviceType = "unspecified"
        }
        let timeZone = TimeZone.current.abbreviation() ?? ""
        let urlEncoded = "d=\(hexEncodedToken)&t=\(timeZone)&s=start&p=&dt=\(deviceType)&a=\(appNumber)"
        PostData.send(to: APIs.getDeviceTokenUrlString(), with: urlEncoded)
    }
}

// MARK: - JS Codes you might need to execute in your web views
struct JSCodes {
    static let adMPU = "<script type=\"text/javascript\">document.write (writeAdNew({devices:['iPhoneWeb','iPhoneApp'],pattern:'MPU',position:'Middle1',container:'mpuInStroy'}));</script>"
    static let adMPU2 = "<script type=\"text/javascript\">document.write (writeAdNew({devices:['iPhoneWeb','iPhoneApp'],pattern:'MPU',position:'Middle2',container:'mpuInStroy'}));</script>"
    
    static let turnOnNightClass = "setTimeout(function(){document.documentElement.className += ' night';},0);"
    static let turnOffNightClass = "document.documentElement.className = document.documentElement.className.replace(/night/g, '');"
    static let autoPlayVideoType = "autoPlayVideo"
    static let englishAudioType = "English Audio"
    static func get(_ type: String) -> String {
        let isNightMode = Setting.isSwitchOn("night-reading-mode")
        let nightModeCode: String
        if isNightMode {
            nightModeCode = turnOnNightClass
        } else {
            nightModeCode = ""
        }
        switch type {
        case autoPlayVideoType:
            let jsCode = "\(nightModeCode)window.gConnectionType = '\(Connection.current())';playVideoOnWifi();"
            return jsCode
        case englishAudioType:
            let jsCode = "\(nightModeCode)window.gConnectionType = '\(Connection.current())';var ebody = document.getElementById('speedread-article').innerHTML;webkit.messageHandlers.ebody.postMessage({ebody: ebody});"
            return jsCode
        case "manual":
            var jsCode = ""
            jsCode += "document.body.style.backgroundColor = '#FFF1E0';"
            jsCode += "var sections = document.querySelectorAll('section, .rich_media_area_extra, .rich_media_area_primary');"
            jsCode += "for (var i=0; i<sections.length; i++) {sections[i].style.backgroundColor = 'transparent';}"
            
            jsCode += "var hiddenEles = document.querySelectorAll('.qr_code_pc');"
            jsCode += "for (var j=0; j<hiddenEles.length; j++) {hiddenEles[j].style.display = 'none';}"
            
            jsCode += "sections = document.querySelectorAll('section, p, h2, img, div');"
            jsCode += "var foundEnd = false;"
            jsCode += "for (var k=0; k<sections.length; k++) {if (/^推荐[阅读]*$/i.test(sections[k].innerHTML)) {foundEnd = true;}if(foundEnd === true){sections[k].style.display = 'none';}}"
            jsCode += nightModeCode
            return jsCode
        default:
            let fontClass = Setting.getFontClass()
            let jsCode = "window.isTextToSpeechEnabled=true;window.gConnectionType = '\(Connection.current())';\(nightModeCode)checkFontSize('\(fontClass)');"
            return jsCode
        }
    }
    public static func get(in id: String, with json: String, where position: String) -> String {
        // updateProductsHTML
        return "updateProductsHTML('\(id)', \(json), '\(position)');"
    }
    
    public static func getInlineVideo(_ storyHTML: String) -> String {
        let storyHTMLCheckingVideo: String
        if storyHTML.range(of: "inlinevideo") != nil {
            storyHTMLCheckingVideo = storyHTML.replacingOccurrences(
                of: "<div class=[\"]*inlinevideo[\"]* id=[\"]([^\"]*)[\"]* auto[sS]tart=[\"]*([a-zA-Z]+)[\"]* title=\"(.*)\" image=\"([^\"]*)\" vid=\"([^\"]*)\" vsource=\"([^\"]*)\"></div>",
                with: "<div class='o-responsive-video-container'><div class='o-responsive-video-wrapper-outer'><div class='o-responsive-video-wrapper-inner'><script src='http://union.bokecc.com/player?vid=$1&siteid=922662811F1A49E9&autoStart=$2&width=100%&height=100%&playerid=3571A3BF2AEC8829&playertype=1'></script></div></div><a class='o-responsive-video-caption' href='/video/$5' target='_blank'>$3</a></div>",
                options: .regularExpression
            )
        } else {
            storyHTMLCheckingVideo = storyHTML
        }
        return storyHTMLCheckingVideo
    }
    
    public static func getCleanHTML(_ storyHTML: String) -> String {
        let storyHTMLCleanHTML: String
        if storyHTML.range(of: "<div class=\"story-theme\"><a target=\"_blank\" href=\"/tag/\"></a><button class=\"myft-follow plus\" data-tag=\"\" data-type=\"tag\">关注</button></div>") != nil {
            storyHTMLCleanHTML = storyHTML.replacingOccurrences(of: "<div class=\"story-theme\"><a target=\"_blank\" href=\"/tag/\"></a><button class=\"myft-follow plus\" data-tag=\"\" data-type=\"tag\">关注</button></div>", with: "")
                .replacingOccurrences(of: "<div class=\"story-image image\" style=\"margin-bottom:0;\"><figure data-url=\"\" class=\"loading\"></figure></div>", with: "")
                .replacingOccurrences(of: "<div class=\"story-box last-child\" ><h2 class=\"box-title\"><a>相关话题</a></h2><ul class=\"top10\"><li class=\"story-theme mp1\"><a target=\"_blank\" href=\"/tag/\"></a><div class=\"icon-right\"><button class=\"myft-follow plus\" data-tag=\"\" data-type=\"tag\">关注</button></div></li></ul></div>", with: "")
        } else {
            storyHTMLCleanHTML = storyHTML
        }
        return storyHTMLCleanHTML
    }
    
    public static func getUserLoginJsCode() -> String {
        let jsCode: String
        if UserInfo.shared.userName != nil && UserInfo.shared.userName != "" {
            jsCode = "hideUserLogin();"
        } else {
            jsCode = "promptUserLogin();"
        }
        return (jsCode)
    }
}

// MARK: - Alert Messages that you might want to change for your own
struct Alerts {
    static func tryBook() {
        Alert.present("试读结束", message: "如果您对本书的内容感兴趣，请返回购买")
    }
}

// MARK: - Setting page
struct Settings {
    
    static let subscriberContact = [
        ContentSection(
            title: "订阅服务",
            items: [
                ContentItem(
                    id: "subscriber-info",
                    image: "",
                    headline: "我的订阅",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0
                ),
                ContentItem(
                    id: "subscriber-contact",
                    image: "",
                    headline: "客服",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0
                )
            ],
            type: "Group",
            adid: nil
        )
    ]
    
    static let page = [
        ContentSection(
            title: "阅读偏好",
            items: [
                ContentItem(
                    id: "font-setting",
                    image: "",
                    headline: "字号设置",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "language-preference",
                    image: "",
                    headline: "语言偏好",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "night-reading-mode",
                    image: "",
                    headline: "夜间模式",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0)
                //                ContentItem(
                //                    id: "enable-push",
                //                    image: "",
                //                    headline: "新闻推送",
                //                    lead: "",
                //                    type: "setting",
                //                    preferSponsorImage: "",
                //                    tag: "",
                //                    customLink: "",
                //                    timeStamp: 0,
                //                    section: 0,
                //                    row: 0)
            ],
            type: "Group",
            adid: nil
        ),
        ContentSection(
            title: "流量与缓存",
            items: [
                ContentItem(
                    id: "clear-cache",
                    image: "",
                    headline: "清除缓存",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "no-image-with-data",
                    image: "",
                    headline: "使用数据时不下载图片",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0)
            ],
            type: "Group",
            adid: nil
        ),
        ContentSection(
            title: "服务与反馈",
            items: [
                ContentItem(
                    id: "feedback",
                    image: "",
                    headline: "反馈",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "app-store",
                    image: "",
                    headline: "App Store评分",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "privacy",
                    image: "",
                    headline: "隐私协议",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0),
                ContentItem(
                    id: "about",
                    image: "",
                    headline: "关于我们",
                    lead: "",
                    type: "setting",
                    preferSponsorImage: "",
                    tag: "",
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0)
            ],
            type: "Group",
            adid: nil
        )
    ]
}

struct FullScreenFallBack {
    static let id = "com.ft.ftchinese.mobile.book.bubble"
    static let link = ""
    static let backgroundColor = "#000000"
}

struct ContentItemRenderContent {
    static var addPersonInfo = false
}

// MARK: - Validate if the HTML snippets are what we expect rather than error message from server.
struct HTMLValidator {
    static func validate(_ htmlData: Data, url: String) -> Bool {
        if let htmlCode = String(data: htmlData, encoding: .utf8){
            if htmlCode.range(of: "item-container") != nil {
                print ("\(url) html validated! ")
                return true
            } else {
                // MARK: If the html validation fails, mark the current server as not responding so that the client can switch to another backup server
                print ("\(url) HTML validation failed and marked as not responding: \(htmlCode)")
                Download.markServerAsNotResponding(url)
                Track.event(category: "CatchError", action: "HTML Validation Fail", label: url)
                return false
            }
        }
        print ("html Data cannot be converted to string ")
        Track.event(category: "CatchError", action: "HTML Data Conversion Fail", label: url)
        return false
    }
}

struct EngagementTracker {
    public static func shouldTrackEngagementVolumn(for screenName: String) -> Bool {
        // MARK: Pair the keywords with the privileges
        let engagementForPrivilege: [(keyword: String, privilegeIncluded: Bool)]
        engagementForPrivilege = [
            ("EditorChoice", Privilege.shared.editorsChoice),
            ("/Book", Privilege.shared.book),
            ("premium", Privilege.shared.exclusiveContent),
            ("/SpeedReading", Privilege.shared.speedreading),
            ("audio/en/story", Privilege.shared.englishAudio),
            ("/audio", Privilege.shared.radio),
            ("/Archive", Privilege.shared.archive),
            ("/en/", Privilege.shared.englishText),
            ("/ce/", Privilege.shared.englishText)
        ]
        for item in engagementForPrivilege {
            if screenName.range(of: item.keyword) != nil {
                return item.privilegeIncluded
            }
        }
        // MARK: For non-subscribers, any free content counts as effective volume
        if !Privilege.shared.exclusiveContent {
            if screenName.range(of: "story") != nil || screenName.range(of: "audio") != nil || screenName.range(of: "interactive") != nil {
                return true
            }
        }
        return false
    }
    
    public static func getEventCategory() -> String {
        if Privilege.shared.editorsChoice {
            return "VIP"
        }
        if Privilege.shared.exclusiveContent {
            return "Member"
        }
        return "Other"
    }
}
