//
//  OptionCell.swift
//  Page
//
//  Created by ZhangOliver on 2017/9/18.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class OptionCell: CustomCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tickImage: UIImageView!
    
    override func updateUI() {
        super.updateUI()
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        name.textColor = UIColor(hex: Color.Content.headline)
        
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
        //name.isUserInteractionEnabled = true
        
        
        if itemCell?.row != 0 {
            topBorder.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            topBorder.backgroundColor = UIColor.clear
        }
        
        if itemCell?.isSelected == true {
            tickImage.isHidden = false
        } else {
            tickImage.isHidden = true
        }
        
        
        updateFontSize()
        
        
    }
    
    private func updateFontSize() {
        if itemCell?.tag == "font-setting" {
            let baseFont: CGFloat = 17
            for (index, fontSize) in Setting.fontSizes.enumerated() {
                if itemCell?.row == index {
                    let fontDescriptor = name.font.fontDescriptor
                    let newFontSize = baseFont * fontSize
                    name.font = UIFont(descriptor: fontDescriptor, size: newFontSize)
                }
            }
        }
    }
    
}

