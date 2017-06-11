//
//  ItemCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lead: UILabel!
    var type: String?
    var id: String?
    var link: String?
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        //image.layer.borderColor = themeColor.cgColor
        isSelected = false
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
    {
        let attr: UICollectionViewLayoutAttributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        
        var newFrame = attr.frame
        self.frame = newFrame
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        let desiredHeight: CGFloat = self.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        newFrame.size.height = desiredHeight
        attr.frame = newFrame
        return attr
    }
    
}
