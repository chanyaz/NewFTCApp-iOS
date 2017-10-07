//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class CoverCell: CustomCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headlineLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headlineTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayImage: UIImageView!
    var isCoverCellReused = false
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        func addOverlayConstraints(_ cellWidth: CGFloat?) {
            if let cellWidth = cellWidth {
                let overlayWidth = max(cellWidth * 0.15, 20)
                self.addConstraint(NSLayoutConstraint(item: overlayImage, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: overlayWidth))
                self.addConstraint(NSLayoutConstraint(item: overlayImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: overlayWidth))
            }
        }
        super.updateUI()
        // MARK: - Update Styles and Layouts only Once
        if isCoverCellReused == false {
            containerView.backgroundColor = UIColor(hex: Color.Content.background)
            headline.font = headline.font.bold()
            layoutMargins.left = 0
            layoutMargins.right = 0
            layoutMargins.top = 0
            layoutMargins.bottom = 0
            containerView.layoutMargins.left = 0
            containerView.layoutMargins.right = 0
            // MARK: - Use calculated cell width to diplay auto-sizing cells
            let cellMargins = layoutMargins.left + layoutMargins.right
            let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
            //let headlineActualWidth: CGFloat?
            if let cellWidth = cellWidth {
                self.contentView.translatesAutoresizingMaskIntoConstraints = false
                let containerWidth = cellWidth - cellMargins - containerViewMargins
                containerViewWidthConstraint.constant = containerWidth
            }
            addOverlayConstraints(cellWidth)
            isCoverCellReused = true
        }
        // MARK: - Update content of the cell eveny time            
        headline.text = itemCell?.headline
        headline.textColor = UIColor(hex: Color.Content.headline)
        lead.textColor = UIColor(hex: Color.Content.lead)
        // FIXME: This is a dilema: use attributed text and performance is bad, use text and line height is gone.
        //lead.text = itemCell?.lead
        lead.attributedText = itemCell?.attributedLead
        loadImage("cover", to: imageView)
        //addShadow(imageView, of: 4)
        overlayImage.image = itemCell?.overlayButtonImage
        //print ("update ui called. cell width is \(cellWidth)")
        
        
    }
    
    //    override func prepareForReuse() {
    //        super.prepareForReuse()
    //        print ("prepare for reuse called. cell width is \(cellWidth)")
    //    }
    //
    //    // TODO: Since the cell is reused, put all the things that are only needed once here.
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        print ("awake from nib called. cell width is \(cellWidth)")
    //    }
    
    
    
    
}
