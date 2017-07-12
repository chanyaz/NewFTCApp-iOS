//
//  ChannelCellRegular.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/23.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelCellRegular: UICollectionViewCell {
    
    let imageWidth = 480
    let imageHeight = 270
 
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lead: UILabel!
    
    @IBOutlet weak var tagLable: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagLable.textColor = UIColor(hex: "#9E2F50")
        time.textColor =  UIColor(hex: "##9e2f50")
    }
    
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
   
    
    func updateUI() {
        
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
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
//        if let loadedImage = itemCell?.largeImage {
//            imageView.image = loadedImage
//        } else {
//            itemCell?.loadLargeImage(width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
//                self?.imageView.image = cellContentItem.largeImage
//            })
//        }
        if let loadedImage = itemCell?.thumbnailImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type: "thumbnail", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.thumbnailImage
            })
        }


    }

}
