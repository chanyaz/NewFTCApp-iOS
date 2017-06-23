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
        //self.backgroundColor = UIColor(hex: Color.Tab.background)
        self.backgroundColor = UIColor(hex: Color.ChannelScroller.background)
        if isSelected == true {
            channel.textColor = UIColor(hex: Color.ChannelScroller.highlightedText)
            //channel.font = UIFont.preferredFont(forTextStyle: .title3)
            //print ("\(String(describing: pageData["title"])) is selected")
        } else {
            channel.textColor = UIColor(hex: Color.ChannelScroller.text)
            //channel.font = UIFont.preferredFont(forTextStyle: .body)
            //print ("\(String(describing: pageData["title"])) is not selected")
        }
    }
}
