//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelCell: UICollectionViewCell {
    
    // MARK: - Style settings for this class
    let imageWidth = 152
    let imageHeight = 114
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    func updateUI() {
        if itemCell?.type != "ad" {
            updateContent()
        } else {
            updateAd()
        }
    }
    
    private func updateAd() {
        // MARK: - Update Styles and Layouts
        updateContent()
        containerView.backgroundColor = UIColor(hex: Color.Ad.background)
        
    }
    
    private func updateContent() {
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
        
        // MARK: - set the border color
        if let row = itemCell?.row,
            row > 0 {
            border.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            // MARK: - set first item's border color to transparent
            border.backgroundColor = nil
        }
        
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        if let loadedImage = itemCell?.thumbnailImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type: "thumbnail", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.thumbnailImage
            })
        }
        
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
        //print ("update UI for the cell\(String(describing: itemCell?.lead))")
    }
    
}
