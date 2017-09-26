/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software ivar* furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit


class ContentFetch {
    
    let processingQueue = OperationQueue()
    
    func fetchContentForUrl(_ urlString: String, fetchUpdate: FetchUpdateFromInternet, completion : @escaping (_ results: ContentFetchResults?, _ error : NSError?) -> Void){
        guard let fetchUrl = contentSearchURL(urlString) else {
            let APIError = NSError(domain: "API Server", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        let fetchRequest = URLRequest(url: fetchUrl)
        URLSession.shared.dataTask(with: fetchRequest, completionHandler: { (data, response, error) in
            
            if let error = error {
                print (error)
                let APIError = NSError(domain: "API Server", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"API Server Response Error: \(fetchUrl)"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "API Server", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }
            
            do {
                print ("content fetch result is back with data, about to handle the data")
                let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                let contentSections = self.formatJSON(resultsDictionary)
                //MARK: Save the JSON File to Documents Directory
                Download.saveFile(data, filename: urlString, to: .cachesDirectory, as: "json")
                OperationQueue.main.addOperation({
                    completion(ContentFetchResults(apiUrl: urlString, fetchResults: contentSections), nil)
                })
            } catch _ {
                print ("error in content fetch of \(urlString)")
                completion(nil, nil)
                return
            }
            
            
        }).resume()
    }
    
    fileprivate func contentSearchURL(_ urlString:String) -> URL? {
        guard let url = URL(string:urlString) else {
            return nil
        }
        return url
    }
    
    func formatJSON(_ resultsDictionary: Any) -> [ContentSection] {
        if let resultsDictionary = resultsDictionary as? [String: Any] {
            if let sections = resultsDictionary["sections"] as? [[String: Any]] {
                return formatPageMakerJSON(sections)
            } else if let _ = resultsDictionary["id"] as? String,
                let _ = resultsDictionary["cbody"] as? String {
                return formatFTCStoryJSON(resultsDictionary)
            }
        } else if let resultsDictionary = resultsDictionary as? [[String: Any]] {
            return formatFTCChannelJSON(resultsDictionary)
        }
        print ("The API JSON Object is not a known format.")
        return [ContentSection]()
    }
    
    func formatPageMakerJSON(_ sections: [[String: Any]]) -> [ContentSection] {
        var contentSections = [ContentSection]()
        for section in sections {
            if let type = section["type"] as? String,
                type == "block"{
                guard let lists = section["lists"] as? [[String: Any]] else {
                    break
                }
                for (section, list) in lists.enumerated() {
                    guard let items = list["items"] as? [[String: Any]]  else {
                        break
                    }
                    var itemCollection = [ContentItem]()
                    for (row, item) in items.enumerated() {
                        let id = item["id"] as? String ?? ""
                        let image = item["image"] as? String ?? ""
                        let headline = item["headline"] as? String ?? ""
                        let lead = item["longlead"] as? String ?? ""
                        let shortlead = item["shortlead"] as? String ?? ""
                        let type = item["type"] as? String ?? ""
                        let preferSponsorImage = item["preferSponsorImage"] as? String ?? ""
                        let tag = item["tag"] as? String ?? ""
                        let customLink = item["customLink"] as? String ?? ""
                        let timeStampString = item["timeStamp"] as? String ?? "0"
                        let timeStamp = TimeInterval(timeStampString) ?? 0
                        let caudio = item["caudio"] as? String ?? ""
                        let eaudio = item["eaudio"] as? String ?? ""
                        
                        // MARK: Note that section may not be continuous
                        let oneItem = ContentItem(
                            id: id,
                            image: image,
                            headline: headline,
                            lead: lead,
                            type: type,
                            preferSponsorImage: preferSponsorImage,
                            tag: tag,
                            customLink: customLink,
                            timeStamp: timeStamp,
                            section: section,
                            row:row
                        )
                        // MARK: If short lead is an mp3 url address, then it is an audio
                        if shortlead.range(of: ".mp3$", options: .regularExpression) != nil {
                            oneItem.audioFileUrl = shortlead
                        }
                        // MARK: If there is audio field, then the story has audio
                        oneItem.caudio = caudio
                        oneItem.eaudio = eaudio
                        
                        itemCollection.append(oneItem)
                    }
                    let title = list["title"] as? String ?? ""
                    let contentSection = ContentSection(
                        title: title,
                        items: itemCollection,
                        type: "List",
                        adid: nil
                    )
                    contentSections.append(contentSection)
                }
            }
        }
        return contentSections
    }
    
    private func formatFTCChannelJSON(_ items: [[String: Any]]) -> [ContentSection] {
        var contentSections = [ContentSection]()
        var itemCollection = [ContentItem]()
        for (row, item) in items.enumerated() {
            let id = item["id"] as? String ?? ""
            // MARK: if API return a "image" key value, use it directly. If not, check for the "story_pic" key.
            var image = item["image"] as? String ?? ""
            if image == "" {
                if let storyPic = item["story_pic"] as? [String: String] {
                    image = storyPic["smallbutton"] ?? storyPic["cover"] ?? storyPic["bigbutton"] ??  ""
                }
            }
            let headline = item["cheadline"] as? String ?? ""
            var lead = item["clongleadbody"] as? String ?? ""
            if lead == "" {
                lead = item["cshortleadbody"] as? String ?? ""
            }
            let type = item["type"] as? String ?? "story"
            let preferSponsorImage = ""
            let tag = item["tag"] as? String ?? ""
            let customLink = item["customlink"] as? String ?? ""
            let timeStamp = TimeInterval(item["pubdate"] as? String ?? "0") ?? 0
            
            // MARK: Note that section may not be continuous
            let oneItem = ContentItem(
                id: id,
                image: image,
                headline: headline,
                lead: lead,
                type: type,
                preferSponsorImage: preferSponsorImage,
                tag: tag,
                customLink: customLink,
                timeStamp: timeStamp,
                section: 0,
                row:row
            )
            itemCollection.append(oneItem)
        }
        let title = ""
        let contentSection = ContentSection(
            title: title,
            items: itemCollection,
            type: "List",
            adid: nil
        )
        contentSections.append(contentSection)
        return contentSections
    }
    
    private func formatFTCStoryJSON(_ item: [String: Any]) -> [ContentSection] {
        var contentSections = [ContentSection]()
        var itemCollection = [ContentItem]()
        
        // MARK: Get publish time of the content
        let publishTimeString = item["last_publish_time"] as? String ?? "0"
        let publishTime = TimeInterval(publishTimeString) ?? 0
        
        // MARK: Note that section may not be continuous
        let oneItem = ContentItem(
            id: "",
            image: "",
            headline: "",
            lead: "",
            type: "story",
            preferSponsorImage: "",
            tag: "",
            customLink: "",
            timeStamp: publishTime,
            section: 0,
            row:0
        )
        
        //MARK: It is necessary to return the headline, lead, tag
        oneItem.headline = item["cheadline"] as? String ?? ""
        oneItem.tag = item["tag"] as? String ?? ""
        oneItem.lead = item["clongleadbody"] as? String ?? ""
        if oneItem.lead == "" {
            oneItem.lead = item["cshortleadbody"] as? String ?? ""
        }
        
        //MARK: Get images
        var image = item["image"] as? String ?? ""
        if image == "" {
            if let storyPic = item["story_pic"] as? [String: String] {
                image = storyPic["smallbutton"] ?? storyPic["cover"] ?? storyPic["bigbutton"] ??  ""
            }
        }
        if image != "" {
            // MARK: FTC API has a persistent bug that provide extra string in the image url string
            oneItem.image = image.replacingOccurrences(of: "/upload/", with: "/")
        }
        
        oneItem.cbody = item["cbody"] as? String
        oneItem.ebody = item["ebody"] as? String
        oneItem.eheadline = item["eheadline"] as? String
        oneItem.cauthor = item["cauthor"] as? String
        oneItem.eauthor = item["eauthor"] as? String
        oneItem.publishTime = publishTime.unixToTimeStamp()
        oneItem.relatedStories = item["relative_story"] as? [[String: Any]]
        oneItem.relatedVideos = item["relative_vstory"] as? [[String: Any]]
        
        
        // MARK: get story bylines
        let cbyline_description = item["cbyline_description"] as? String ?? ""
        let cauthor = item["cauthor"] as? String ?? ""
        let cbyline_status = item["cbyline_status"] as? String ?? ""
        oneItem.chineseByline = "\(cbyline_description) \(cauthor) \(cbyline_status)"
        
        let ebyline_description = item["ebyline_description"] as? String ?? ""
        let eauthor = item["eauthor"] as? String ?? ""
        let ebyline_status = item["ebyline_status"] as? String ?? ""
        oneItem.englishByline = "\(ebyline_description) \(eauthor) \(ebyline_status)"
        
        itemCollection.append(oneItem)
        let contentSection = ContentSection(
            title: "",
            items: itemCollection,
            type: "List",
            adid: nil
        )
        contentSections.append(contentSection)
        return contentSections
    }
    
    
}

// MARK: When there's local copy of the data, should the app continue to fetch an updated version from the internet?
enum FetchUpdateFromInternet {
    case Always
    case OnlyOnWifi
    case No
}
