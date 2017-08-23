//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class FollowCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!
    
    
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
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        name.textColor = UIColor(hex: Color.Content.headline)
        name.font = name.font.bold()
        
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
        
        // MARK: Update Content
        name.text = itemCell?.headline
        name.isUserInteractionEnabled = true
        actionButton.setTitle("+关注", for: .normal)
        actionButton.setTitle("已关注", for: .selected)
        
        addTap()
    }
    
    
    private func addTap() {
        let nameTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapName(_:)))
        name.addGestureRecognizer(nameTapGestureRecognizer)
        
        let actionTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapAction(_:)))
        actionButton.addGestureRecognizer(actionTapGestureRecognizer)
        
    }
    
    open func tapName(_ recognizer: UITapGestureRecognizer) {
        //print ("name is tapped: \(itemCell?.headline); \(itemCell?.id)")
    }
    
    open func tapAction(_ recognizer: UITapGestureRecognizer) {
        //print ("action is tapped: \(itemCell?.headline); \(itemCell?.id); \(actionButton.state)")
    }
    
}
