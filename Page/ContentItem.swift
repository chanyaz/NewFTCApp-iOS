// MARK: The data source for a channel page collection view

import UIKit

class ContentItem{
    // MARK: Diffent types of iamges
    var thumbnailImage: UIImage?
    var coverImage: UIImage?
    var detailImage: UIImage?
    
    let id : String
    let image: String
    let headline : String
    let lead : String
    let type : String
    
    let preferSponsorImage: String
    let tag: String
    let customLink: String
    let timeStamp: Int
    
    var section: Int
    var row: Int
    
    var isCover = false
    
    
    
    // MARK: detail data that only comes with detail content API
    var cbody: String?
    var ebody: String?
    var cauthor: String?
    var eauthor: String?
    var locations: String?
    
    
    
    
    init (id: String,
          image: String,
          headline: String,
          lead: String,
          type: String,
          preferSponsorImage: String,
          tag: String,
          customLink: String,
          timeStamp: Int,
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
        if let u = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            urlString = "https://www.ft.com/__origami/service/image/v2/images/raw/\(u)?source=ftchinese&width=\(width * 2)&height=\(height * 2)&fit=cover"
        } else {
            urlString = imageUrl
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
        let loadRequest = URLRequest(url:loadURL)
        
        URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
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

