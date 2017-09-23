//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelCell: CustomCell {
    
    // MARK: - Style settings for this class
    let imageWidth = 187
    let imageHeight = 140
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
            setStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, (leadText.characters.count)))
            lead.attributedText = setStr
        }
        
        sign.text = nil
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        // MARK: - initialize image view as it will be reused. If you don't do this, the cell might show wrong image when you scroll.
        imageView.image = nil
        
        if let loadedImage = itemCell?.thumbnailImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type: "thumbnail", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.thumbnailImage
            })
        }
        
        
        if let image = UIImage(named: "VideoPlayOverlay"),
            itemCell?.type == "video"{
            overlayImage.image = image
        } else {
            overlayImage.image = nil
        }
        
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
    
    
    
    

    
    
    
}

//TODO: Paid Post Ad should be moved to a subclass rather than the channel cell



