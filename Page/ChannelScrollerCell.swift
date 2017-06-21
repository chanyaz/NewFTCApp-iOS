//
//  ChannelScrollerCell.swift
//  Page
//
//  Created by ZhangOliver on 2017/6/17.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ChannelScrollerCell: UICollectionViewCell {

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
        self.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.channelScrollerBackground)
        if isSelected == true {
            channel.textColor = UIColor(hex: AppNavigation.sharedInstance.channelScrollerHighlight)
            //channel.font = UIFont.preferredFont(forTextStyle: .title3)
            //print ("\(String(describing: pageData["title"])) is selected")
        } else {
            channel.textColor = UIColor(hex: AppNavigation.sharedInstance.channelScrollerColor)
            //channel.font = UIFont.preferredFont(forTextStyle: .body)
            //print ("\(String(describing: pageData["title"])) is not selected")
        }
    }
}
