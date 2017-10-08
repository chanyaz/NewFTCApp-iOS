//
//  SmoothCoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/10/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class SmoothCoverCell: UICollectionViewCell {
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    //var isCellReused = false
    var itemCell: ContentItem?
    var themeColor: String?
    
    var coverTheme: String?
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topicView: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var headline: UILabel!
    
    @IBOutlet weak var lead: UILabel!
    
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    var isSmoothCoverReused = false
    
    func updateUI() {
        if isSmoothCoverReused == false {
            if let cellWidth = cellWidth {
                widthConstraint.constant = cellWidth
            }
            imageView.backgroundColor = UIColor(hex: Color.Image.background)
            imageView.contentMode = .scaleAspectFit
            isSmoothCoverReused = true
            headline.textColor = UIColor(hex: Color.Content.headline)
            lead.textColor = UIColor(hex: Color.Content.lead)
            topicView.textColor = UIColor(hex: Color.Content.tag)
            borderView.backgroundColor = UIColor(hex: Color.Content.tag)
            // MARK: Tap the topic view to open tag page
            topicView.isUserInteractionEnabled = true
            let tapTagRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapTag(_:)))
            topicView.addGestureRecognizer(tapTagRecognizer)
        }
        headline.text = itemCell?.headline
        lead.attributedText = itemCell?.attributedLead
        topicView.text = itemCell?.mainTag
        //lead.text = itemCell?.lead
        loadImage("cover")
        overlayImageView.image = itemCell?.overlayButtonImage
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = CellHelper.shared.placeHolderImage
        overlayImageView.image = nil
    }
    
    
    func loadImage(_ type: String) {
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
        // MARK: Use global to do the heavy lifting. Otherwise the scrolling will be unresponsive.
        // MARK: - Load the image of the item
        // MARK: - As the cell is reusable, asyn image should always be cleared first
        DispatchQueue.global().async {
            let imageType = type
            let imageInfo = getImageInfo()
            if let loadedImage = imageInfo.loadedImage {
                DispatchQueue.main.async {
                    self.imageView.image = loadedImage
                }
                print ("image is already loaded, no need to download again. ")
            } else if let image = self.itemCell?.image {
                let downloadedImageData = Download.readFile(image, for: .cachesDirectory, as: imageType)
                if let downloadedImageData = downloadedImageData {
                    let image = UIImage(data: downloadedImageData)
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        print ("image is already downloaded to cache, no need to download again. ")
                    }
                } else {
                    self.itemCell?.loadImage(type:imageType, width: imageInfo.imageWidth, height: imageInfo.imageHeight, completion: { [weak self](cellContentItem, error) in
                        // MARK: - Since channel cell is resued, you should always check if it is the right image
                        if self?.itemCell?.image == cellContentItem.image {
                            if let imageView = self?.imageView {
                                let loadedImage: UIImage?
                                switch imageType {
                                case "cover":
                                    loadedImage = cellContentItem.coverImage
                                case "thumbnail":
                                    loadedImage = cellContentItem.thumbnailImage
                                default:
                                    loadedImage = cellContentItem.detailImage
                                }
                                DispatchQueue.main.async {
                                    UIView.transition(with: imageView,
                                                      duration: 0.3,
                                                      options: .transitionCrossDissolve,
                                                      animations: {
                                                        imageView.image = loadedImage
                                    },
                                                      completion: nil
                                    )
                                }
                            }
                        } else {
                            print ("image should not be displayed as the cell is reused!" )
                        }
                    })
                }
            }
        }
    }
    
    @objc open func tapTag(_ recognizer: UITapGestureRecognizer) {
        if let topController = UIApplication.topViewController(),
            let tag = topicView.text {
            topController.openDataView(tag, of: "tag")
        }
    }
    
}
