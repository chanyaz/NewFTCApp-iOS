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
    var tabName: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    private func updateUI() {
        if let title = pageData["title"] {
            channel.text = title
        }
        //self.backgroundColor = UIColor(hex: Color.Tab.background)
        channel.backgroundColor = UIColor(hex: Color.ChannelScroller.background)
        // MARK: Round Corner
        channel.layer.cornerRadius = 3
        channel.layer.masksToBounds = true
        
        if isSelected == true {
            //channel.textColor = UIColor(hex: Color.ChannelScroller.highlightedText)
            channel.textColor = UIColor.white
            channel.backgroundColor = AppNavigation.sharedInstance.getThemeColor(for: tabName)
            //channel.font = UIFont.preferredFont(forTextStyle: .title3)
            //print ("\(String(describing: pageData["title"])) is selected")
        } else {
            channel.textColor = UIColor(hex: Color.ChannelScroller.text)
            channel.backgroundColor = UIColor.clear
            //channel.font = UIFont.preferredFont(forTextStyle: .body)
            //print ("\(String(describing: pageData["title"])) is not selected")
        }
    }
}
