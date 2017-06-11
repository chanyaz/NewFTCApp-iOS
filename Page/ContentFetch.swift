/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
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
    
    func fetchContentForUrl(_ urlString: String, completion : @escaping (_ results: ContentFetchResults?, _ error : NSError?) -> Void){
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
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject] else {
                    
                    let APIError = NSError(domain: "ContentFetch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                
                //                switch ("something") {
                //                case "ok":
                //                    print("Results processed OK")
                //                case "fail":
                //                    if let message = resultsDictionary["message"] {
                //
                //                        let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                //
                //                        OperationQueue.main.addOperation({
                //                            completion(nil, APIError)
                //                        })
                //                    }
                //
                //                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: nil)
                //
                //                    OperationQueue.main.addOperation({
                //                        completion(nil, APIError)
                //                    })
                //
                //                    return
                //                default:
                //                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                //                    OperationQueue.main.addOperation({
                //                        completion(nil, APIError)
                //                    })
                //                    return
                //                }
                
                
                
                guard let sections = resultsDictionary["sections"] as? [[String: Any]] else {
                    let APIError = NSError(domain: "Parse Sections", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Cannot Get the Sections from JSON"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                print("data reformated into dictionary! ")
                
                var contentSections = [ContentSection]()
                for section in sections {
                    if let type = section["type"] as? String,
                        type == "block"{
                        guard let lists = section["lists"] as? [[String: Any]] else {
                            break
                        }
                        for list in lists {
                            guard let items = list["items"] as? [[String: Any]]  else {
                                break
                            }
                            var itemCollection = [ContentItem]()
                            for item in items {
                                let id = item["id"] as? String ?? ""
                                let image = item["image"] as? String ?? ""
                                let headline = item["headline"] as? String ?? ""
                                let lead = item["longlead"] as? String ?? ""
                                let type = item["type"] as? String ?? ""
                                let oneItem = ContentItem(
                                    id: id,
                                    image: image,
                                    headline: headline,
                                    lead: lead,
                                    type: type
                                )
                                itemCollection.append(oneItem)
                            }
                            let title = list["title"] as? String ?? ""
                            let contentSection = ContentSection(
                                title: title,
                                items: itemCollection
                            )
                            contentSections.append(contentSection)
                        }
                        
                    }
                }
                
                
                
                //                for photoObject in photosReceived {
                //                    guard let photoID = photoObject["id"] as? String,
                //                        let farm = photoObject["farm"] as? Int ,
                //                        let server = photoObject["server"] as? String ,
                //                        let secret = photoObject["secret"] as? String else {
                //                            break
                //                    }
                //                    let flickrPhoto = ContentItem(photoID: photoID, farm: farm, server: server, secret: secret)
                //
                //                    guard let url = flickrPhoto.flickrImageURL(),
                //                        let imageData = try? Data(contentsOf: url as URL) else {
                //                            break
                //                    }
                //
                //                    if let image = UIImage(data: imageData) {
                //                        flickrPhoto.thumbnail = image
                //                        flickrPhotos.append(flickrPhoto)
                //                    }
                //                }
                
                OperationQueue.main.addOperation({
                    completion(ContentFetchResults(apiUrl: urlString, fetchResults: contentSections), nil)
                })
                
            } catch _ {
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
}
