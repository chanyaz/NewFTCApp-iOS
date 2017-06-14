//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class CoverCell: UICollectionViewCell {
    
    // MARK: - Style settings for this class
    let imageWidth = 832   // 16 * 52
    let imageHeight = 468  // 9 * 52
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
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
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        headline.textColor = UIColor(hex: AppNavigation.sharedInstance.headlineColor)
        headline.font = headline.font.bold()
        
        lead.textColor = UIColor(hex: AppNavigation.sharedInstance.leadColor)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        

        
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        if let loadedImage = itemCell?.largeImage {
            imageView.image = loadedImage
            print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadLargeImage(width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.largeImage
            })
            print ("should load image here")
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
