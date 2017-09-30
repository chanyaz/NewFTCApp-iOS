//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class CoverCell: CustomCell {
    
    // MARK: - Style settings for this class
    let imageWidth = 408   // 16 * 52
    let imageHeight = 234  // 9 * 52
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headlineLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headlineTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayImage: UIImageView!
    
    
    
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        func addOverlayConstraints(_ cellWidth: CGFloat?) {
            if let cellWidth = cellWidth {
                let overlayWidth = max(cellWidth * 0.15, 20)
                self.addConstraint(NSLayoutConstraint(item: overlayImage, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: overlayWidth))
                self.addConstraint(NSLayoutConstraint(item: overlayImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: overlayWidth))
            }
        }
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
        headline.font = headline.font.bold()
        lead.textColor = UIColor(hex: Color.Content.lead)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        //let headlineActualWidth: CGFloat?
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
        // MARK: - Update dispay of the cell
        let headlineString = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        headline.text = headlineString
        if let leadText = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.4
            let setStr = NSMutableAttributedString.init(string: leadText)
            setStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, (leadText.characters.count)))
            lead.attributedText = setStr
        }
        
        loadImage("cover")
        addShadow(imageView, of: 4)
        
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
        if image != nil {
            addOverlayConstraints(cellWidth)
        }
        overlayImage.image = image
    }
    
    private func loadImage(_ type: String) {
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Image.background)
        imageView.contentMode = .scaleAspectFit
        // MARK: - As the cell is reusable, asyn image should always be cleared first
        imageView.image = UIImage(named: "Watermark")
        let imageType = type
        if let loadedImage = itemCell?.coverImage {
            imageView.image = loadedImage
            print ("image is already loaded, no need to dowqnload again. ")
        } else if let image = itemCell?.image,
            let downloadedImageData = Download.readFile(image, for: .cachesDirectory, as: imageType){
            imageView.image = UIImage(data: downloadedImageData)
            print ("image is already downloaded to cache, no need to download again. ")
        } else {
            itemCell?.loadImage(type:imageType, width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                // MARK: - Since cover cell is resued, you should always check if it is the right image
                if self?.itemCell?.image == cellContentItem.image {
                    if let imageView = self?.imageView {
                        UIView.transition(with: imageView,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: {
                                            imageView.image = cellContentItem.coverImage
                        },
                                          completion: nil
                        )
                    }
                } else {
                    print ("image should not be displayed as the cell is resued!" )
                }
            })
        }
    }
}
