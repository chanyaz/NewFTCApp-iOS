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
        self.backgroundColor = UIColor.white
        if isSelected == true {
            channel.textColor = UIColor(hex: AppNavigation.sharedInstance.highlightedTabFontColor)
            //print ("\(String(describing: pageData["title"])) is selected")
        } else {
            channel.textColor = UIColor(hex: AppNavigation.sharedInstance.defaultHeaderColor)
            //print ("\(String(describing: pageData["title"])) is not selected")
        }
    }
}
