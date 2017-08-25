//
//  HeadlineCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class HeadlineCell: CustomCell {

    let imageWidth = 152
    let imageHeight = 114
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var theme: UILabel!
    @IBOutlet weak var time: UILabel!
    

    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        // MARK: - Update Styles and Layouts
        //    print ("headline should load image here")
        let leadColor = UIColor(hex: Color.Content.lead)
        containerView?.backgroundColor = UIColor(hex: Color.Content.background)
        headline?.textColor = UIColor(hex: Color.Content.headline)
        theme?.textColor = leadColor
        time?.textColor = leadColor
        //    lead.textColor = UIColor(hex: Color.Content.lead)
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
        //     lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        if let loadedImage = itemCell?.thumbnailImage {
            imageView.image = loadedImage
            //        print ("headline image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type:"thumbnail", width: imageWidth * 2, height: imageHeight * 2, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.thumbnailImage
            })
            //      print ("headline should load image here")
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
