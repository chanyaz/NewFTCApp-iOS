// MARK: The data source for a channel page collection view

import UIKit

class ContentItem{
    // MARK: Diffent types of iamges
    var thumbnailImage: UIImage?
    var coverImage: UIImage?
    var detailImage: UIImage?
    
    let id: String
    var image: String
    var headline: String
    var lead: String
    var type: String
    
    var preferSponsorImage: String
    var tag: String
    var customLink: String
    var timeStamp: TimeInterval
    
    var section: Int
    var row: Int
    var isLandingPage = false
    
    var isCover = false
    var hideTopBorder: Bool?
    var englishByline: String?
    var chineseByline: String?
    var publishTime: String?
    
    var adModel: AdModel?
    
    
    
    // MARK: detail data that only comes with detail content API
    var cbody: String?
    var ebody: String?
    var eheadline: String?
    var cauthor: String?
    var eauthor: String?
    var locations: String?
    var relatedStories: [[String: Any]]?
    var relatedVideos: [[String: Any]]?
    
    // MARK: Audio File Url for Interactive such as FT Radio
    var audioFileUrl: String?
    
    // MARK: Audio File urls for story such as FTCC
    var caudio: String?
    var eaudio: String?
    
    // MARK: properties that are exclusive for eBooks
    var productGroupTitle: String?
    var isDownloaded = false
    var expireDateString: String?
    var periodString: String?
    var productPrice: String?
    
    var isSelected = false
    
    
    var followType: String?
    

    
    init (id: String,
          image: String,
          headline: String,
          lead: String,
          type: String,
          preferSponsorImage: String,
          tag: String,
          customLink: String,
          timeStamp: TimeInterval,
          section: Int,
          row: Int) {
        self.id = id
        self.image = image
        self.headline = headline
        self.lead = lead
        self.type = type
        self.preferSponsorImage = preferSponsorImage
        self.tag = tag
        self.customLink = customLink
        self.timeStamp = timeStamp
        self.section = section
        self.row = row
    }
    
    
    
    
    
    
    func getImageURL(_ imageUrl: String, width: Int, height: Int) -> URL? {
        let urlString: String
        //MARK: Deal with the stupid API error
        let imageUrlCleaned = imageUrl.replacingOccurrences(of: "/upload/", with: "/")
        if let u = imageUrlCleaned.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            urlString = ImageService.resize(u, width: width, height: height)
        } else {
            urlString = imageUrlCleaned
        }
        if let url =  URL(string: urlString) {
            return url
        }
        return nil
    }
    
    func loadImage(type: String, width: Int, height: Int, completion: @escaping (_ contentItem:ContentItem, _ error: NSError?) -> Void) {
        guard let loadURL = getImageURL(image, width: width, height: height) else {
            DispatchQueue.main.async {
                completion(self, nil)
            }
            return
        }
        //print ("\(loadURL.absoluteString) should be loaded just once")
        let request = URLRequest(url:loadURL)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(self, error as NSError?)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(self, nil)
                }
                return
            }
            
            let returnedImage = UIImage(data: data)
            switch type {
            case "thumbnail":
                self.thumbnailImage = returnedImage
            case "cover":
                self.coverImage = returnedImage
            default:
                self.detailImage = returnedImage
            }
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()
    }
    
}

