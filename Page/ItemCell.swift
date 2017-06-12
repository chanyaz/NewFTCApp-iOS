//
//  ItemCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    //    @IBOutlet weak var title: UILabel!
    //    @IBOutlet weak var image: UIImageView!
    //    @IBOutlet weak var lead: UILabel!
    //    @IBOutlet weak var containerView: UIView!
    //
    //    @IBOutlet weak var headline: UILabel!
    //    @IBOutlet weak var lead: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    
    
    
    var type: String?
    var id: String?
    var link: String?
    
    var cellWidth: CGFloat?
    
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Use the data source to update UI for the cell
    func updateUI() {
        //        layoutMargins.left = 0
        //        layoutMargins.right = 0
        //        layoutMargins.top = 0
        //        layoutMargins.bottom = 0
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        
        headline.text = itemCell?.headline
        lead.text = itemCell?.lead
        if let cellWidth = cellWidth {
            self.containerView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            //let containerWidth: CGFloat = 200
//            print ("contain view width is \(containerWidth)")
//            let containerWidthLayoutConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: containerWidth)
//            containerView.addConstraint(containerWidthLayoutConstraint)
            containerView.frame.size.width = containerWidth
            self.frame.size.width = containerWidth
        }
        print ("update UI for the cell\(String(describing: itemCell?.lead))")
    }
    
    
    // MARK: - View Life Cycle
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        //image.layer.borderColor = themeColor.cgColor
    //        isSelected = false
    //    }
    
    //    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
    //    {
    //        let attr: UICollectionViewLayoutAttributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
    //
    //        var newFrame = attr.frame
    //        self.frame = newFrame
    //
    //        self.setNeedsLayout()
    //        self.layoutIfNeeded()
    //
    //        let desiredHeight: CGFloat = self.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    //        let desiredWidth: CGFloat = self.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width
    //        print ("\(String(describing: lead.text)). Desired width is \(desiredWidth) and desired height is \(desiredHeight)")
    //        newFrame.size.height = desiredHeight
    //        //newFrame.size.width = (desiredWidth - 40)/2
    //        newFrame.size.width = desiredWidth
    //        attr.frame = newFrame
    //        return attr
    //    }
    
}
