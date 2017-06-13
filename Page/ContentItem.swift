// MARK: The data source for a channel page collection view

import UIKit

class ContentItem{
    var thumbnail : UIImage?
    var largeImage : UIImage?
    let id : String
    let image: String
    let headline : String
    let lead : String
    let type : String
    
    init (id:String, image:String, headline: String, lead: String, type: String) {
        self.id = id
        self.image = image
        self.headline = headline
        self.lead = lead
        self.type = type
    }
    
    func getImageURL(_ imageUrl: String) -> URL? {
        //    if let url =  URL(string: self.largeImage) {
        //      return url
        //    }
        return nil
    }
    
    func loadLargeImage(_ completion: @escaping (_ contentItem:ContentItem, _ error: NSError?) -> Void) {
        guard let loadURL = getImageURL(image) else {
            DispatchQueue.main.async {
                completion(self, nil)
            }
            return
        }
        
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
            self.largeImage = returnedImage
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()
    }
    
    func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {
        guard let thumbnail = thumbnail else {
            return size
        }
        let imageSize = thumbnail.size
        var returnSize = size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        returnSize.height = returnSize.width / aspectRatio
        
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
        return returnSize
    }
    
}

