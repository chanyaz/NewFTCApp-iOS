//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelCell: CustomCell {
    

    //var adModel: AdModel?
    var pageTitle = ""
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sign: UILabel!
    @IBOutlet weak var overlayImage: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var headlineTopMarginConstraint: NSLayoutConstraint!
    
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        setupLayout()
        updateContent()
        sizeCell()
    }
    
    private func updateContent() {
        // MARK: - set the border color
        if let row = itemCell?.row,
            row > 0,
            itemCell?.hideTopBorder != true {
            border.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            // MARK: - set first item's border color to transparent
            border.backgroundColor = nil
        }
        
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        
        if let leadText = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            paragraphStyle.lineBreakMode = .byTruncatingTail
            let setStr = NSMutableAttributedString.init(string: leadText)
            setStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, (leadText.count)))
            lead.attributedText = setStr
        }
        
        sign.text = nil
        
        
        // MARK: - Load the image of the item
        loadImage("thumbnail", to: imageView)
        //addShadow(imageView, of: 2)
        
        let itemType = itemCell?.type
        let caudio = itemCell?.caudio ?? ""
        let eaudio = itemCell?.eaudio ?? ""
        let audioFileUrl = itemCell?.audioFileUrl ?? ""
        let image: UIImage?
        if itemType == "video" {
            image = UIImage(named: "VideoPlayOverlay")
        } else if caudio != "" || eaudio != "" || audioFileUrl != "" {
            image = UIImage(named: "AudioPlayOverlay")
        } else {
            image = nil
        }
        overlayImage.image = image
        
        // MARK: - update the tagView
        tagLabel.textColor = UIColor(hex: Color.Content.tag)
        if let firstTag = itemCell?.tag.getFirstTag(Meta.reservedTags) {
            tagLabel.text = firstTag
            headlineTopMarginConstraint.constant = 8
        } else {
            tagLabel.text = nil
            headlineTopMarginConstraint.constant = 0
        }
        
        // MARK: - Tap the tag label to open tag page
        tagLabel.isUserInteractionEnabled = true
        let tapTagRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapTag(_:)))
        tagLabel.addGestureRecognizer(tapTagRecognizer)
    }
    
    
    
    
    private func setupLayout() {
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
        headline.font = headline.font.bold()
        lead.textColor = UIColor(hex: Color.Content.lead)
        sign.textColor = UIColor(hex: Color.Ad.sign)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
    }
    
    private func sizeCell() {
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
    }
    
    
    
//    private func loadImage(_ type: String) {
//        
//        // TODO: Should use global to do the heavy lifting. Otherwise the scrolling will be unresponsive.
//        // MARK: - Load the image of the item
//        imageView.backgroundColor = UIColor(hex: Color.Image.background)
//        imageView.contentMode = .scaleAspectFit
//        // MARK: - As the cell is reusable, asyn image should always be cleared first
//        imageView.image = UIImage(named: "Watermark")
//        let imageType = type
//        let loadedImage: UIImage?
//        switch imageType {
//        case "cover":
//            loadedImage = itemCell?.coverImage
//        case "thumbnail":
//            loadedImage = itemCell?.thumbnailImage
//        default:
//            loadedImage = itemCell?.detailImage
//        }
//        if let loadedImage = loadedImage {
//            imageView.image = loadedImage
//            print ("image is already loaded, no need to download again. ")
//        } else if let image = itemCell?.image {
//            DispatchQueue.global().async {
//                let downloadedImageData = Download.readFile(image, for: .cachesDirectory, as: imageType)
//                DispatchQueue.main.async {
//                    if let downloadedImageData = downloadedImageData {
//                        self.imageView.image = UIImage(data: downloadedImageData)
//                        print ("image is already downloaded to cache, no need to download again. ")
//                    } else {
//                        self.itemCell?.loadImage(type:imageType, width: self.imageWidth, height: self.imageHeight, completion: { [weak self](cellContentItem, error) in
//                            // MARK: - Since channel cell is resued, you should always check if it is the right image
//                            if self?.itemCell?.image == cellContentItem.image {
//                                if let imageView = self?.imageView {
//                                    UIView.transition(with: imageView,
//                                                      duration: 0.3,
//                                                      options: .transitionCrossDissolve,
//                                                      animations: {
//                                                        let loadedImage: UIImage?
//                                                        switch imageType {
//                                                        case "cover":
//                                                            loadedImage = cellContentItem.coverImage
//                                                        case "thumbnail":
//                                                            loadedImage = cellContentItem.thumbnailImage
//                                                        default:
//                                                            loadedImage = cellContentItem.detailImage
//                                                        }
//                                                        imageView.image = loadedImage
//                                    },
//                                                      completion: nil
//                                    )
//                                }
//                            } else {
//                                print ("image should not be displayed as the cell is reused!" )
//                            }
//                        })
//                    }
//                }
//            }
//        }
//    }
    
    
    @objc open func tapTag(_ recognizer: UITapGestureRecognizer) {
        if let topController = UIApplication.topViewController(),
            let tag = tagLabel.text {
            topController.openDataView(tag, of: "tag")
        }
    }
}



