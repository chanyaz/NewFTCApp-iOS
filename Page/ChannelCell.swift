//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Use the data source to update UI for the cell
    func updateUI() {
        // MARK: - Update Styles and Layouts
        self.backgroundColor = UIColor.gray
        containerView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        headline.textColor = UIColor(hex: AppNavigation.sharedInstance.headlineColor)
        lead.textColor = UIColor(hex: AppNavigation.sharedInstance.leadColor)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.black.cgColor
 
        
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
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
