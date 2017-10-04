//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/25.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import SafariServices
class CustomCell: UICollectionViewCell, SFSafariViewControllerDelegate {
    
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    var isCellReused = false
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    var themeColor: String?
    
    func updateUI() {}
    
    // MARK: These three functions are same as those in the AdView, should find a way to put them in one place
    public func addTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let link = self.itemCell?.adModel?.link,
            let url = URL(string: link),
            let topController = UIApplication.topViewController() {
                topController.openLink(url)
        }
    }
    
    public func openLink(_ url: URL) {
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        if let topController = UIApplication.topViewController() {
            topController.present(webVC, animated: true, completion: nil)
        }
    }
    
    public func addShadow(_ imageView: UIImageView, of radius: CGFloat) {
        imageView.layer.shadowOffset = CGSize(width: 0, height: radius)
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = radius
        imageView.layer.shadowOpacity = 0.618
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = false
    }
    
    public func loadImage(_ type: String, to imageView: UIImageView?) {
        
        func getImageInfo() -> (loadedImage: UIImage?, imageWidth: Int, imageHeight: Int) {
            let loadedImage: UIImage?
            let imageWidth: Int
            let imageHeight: Int
            switch type {
            case "cover":
                loadedImage = itemCell?.coverImage
                imageWidth = 408
                imageHeight = 234
            case "thumbnail":
                loadedImage = itemCell?.thumbnailImage
                imageWidth = 187
                imageHeight = 140
            default:
                loadedImage = itemCell?.detailImage
                imageWidth = 408
                imageHeight = 234
            }
            return (loadedImage, imageWidth, imageHeight)
        }
        
        // TODO: Should use global to do the heavy lifting. Otherwise the scrolling will be unresponsive.
        // MARK: - Load the image of the item
        imageView?.backgroundColor = UIColor(hex: Color.Image.background)
        imageView?.contentMode = .scaleAspectFit
        // MARK: - As the cell is reusable, asyn image should always be cleared first
        imageView?.image = UIImage(named: "Watermark")
        let imageType = type
        let imageInfo = getImageInfo()
        if let loadedImage = imageInfo.loadedImage {
            imageView?.image = loadedImage
            print ("image is already loaded, no need to download again. ")
        } else if let image = itemCell?.image {
            DispatchQueue.global().async {
                let downloadedImageData = Download.readFile(image, for: .cachesDirectory, as: imageType)
                DispatchQueue.main.async {
                    if let downloadedImageData = downloadedImageData {
                        imageView?.image = UIImage(data: downloadedImageData)
                        print ("image is already downloaded to cache, no need to download again. ")
                    } else {
                        self.itemCell?.loadImage(type:imageType, width: imageInfo.imageWidth, height: imageInfo.imageHeight, completion: { [weak self](cellContentItem, error) in
                            // MARK: - Since channel cell is resued, you should always check if it is the right image
                            if self?.itemCell?.image == cellContentItem.image {
                                if let imageView = imageView {
                                    UIView.transition(with: imageView,
                                                      duration: 0.3,
                                                      options: .transitionCrossDissolve,
                                                      animations: {
                                                        let loadedImage: UIImage?
                                                        switch imageType {
                                                        case "cover":
                                                            loadedImage = cellContentItem.coverImage
                                                        case "thumbnail":
                                                            loadedImage = cellContentItem.thumbnailImage
                                                        default:
                                                            loadedImage = cellContentItem.detailImage
                                                        }
                                                        imageView.image = loadedImage
                                    },
                                                      completion: nil
                                    )
                                }
                            } else {
                                print ("image should not be displayed as the cell is reused!" )
                            }
                        })
                    }
                }
            }
        }
    }
    
}
