//
//  ChannelScrollerCell.swift
//  Page
//
//  Created by ZhangOliver on 2017/6/17.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelScrollerCell: UICollectionViewCell {

    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var channel: UILabel!
    var pageData = [String: String]() {
        didSet {
            updateUI()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    private func updateUI() {
        if let title = pageData["title"] {
            channel.text = title
        }
        //self.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        self.backgroundColor = UIColor.white
        channel.textColor = UIColor(hex: AppNavigation.sharedInstance.defaultHeaderColor)
    }
}
