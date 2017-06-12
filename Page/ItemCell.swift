//
//  ItemCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {

    
//    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var headline: UILabel!
//    @IBOutlet weak var lead: UILabel!
//    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var headline: UILabel!
//    @IBOutlet weak var lead: UILabel!
    
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
//        let cellMargins = layoutMargins.left + layoutMargins.right
//        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        
        headline.text = itemCell?.headline
        lead.text = itemCell?.lead
        //lead.sizeToFit()
//        if let cellWidth = cellWidth {
//            self.containerView.translatesAutoresizingMaskIntoConstraints = false
//            let containerWidth = cellWidth - cellMargins - containerViewMargins
//            containerViewWidthConstraint.constant = containerWidth
//            //let containerWidth: CGFloat = 200
//            print ("contain view width is \(containerWidth)")
////            let containerWidthLayoutConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: containerWidth)
////            containerView.addConstraint(containerWidthLayoutConstraint)
////            containerView.frame.size.width = containerWidth
////            self.frame.size.width = containerWidth
//        }
        print ("update UI for the cell\(String(describing: itemCell?.lead))")
    }
    
}
