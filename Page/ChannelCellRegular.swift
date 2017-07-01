//
//  ChannelCellRegular.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/23.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelCellRegular: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headLine: UILabel!
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    func updateUI() {
//        headLine.backgroundColor = UIColor.blue
//        headLine.textColor  = UIColor.blue
    }
}
