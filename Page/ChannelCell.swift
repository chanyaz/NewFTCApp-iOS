//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelCell: UICollectionViewCell {

//    @IBOutlet weak var headerLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.contentView.translatesAutoresizingMaskIntoConstraints = false
//        let screenWidth = UIScreen.main.bounds.size.width
//        widthConstraint.constant = screenWidth - (2 * 30)
    }
    
    
    
    
//    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var headline: UILabel!
//    @IBOutlet weak var lead: UILabel!
//    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    
    
    
    
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
        
        
        
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        //lead.sizeToFit()
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
        print ("update UI for the cell\(String(describing: itemCell?.lead))")
    }
    

    

}
