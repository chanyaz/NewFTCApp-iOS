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
    @IBOutlet weak var underLine: UIView!
    
    var cellHeight: CGFloat?
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
            channel.text = GB2Big5.convert(title)
            if Color.ChannelScroller.addTextSpace{
                channel.addTextSpacing(value: 12)
            }
        }
        // MARK: Show the new channel sign
        if let isNew = pageData["new"],
            isNew == "yes" {
            print ("this is a new channel! ")
        }

        if isSelected == true {
            channel.textColor = AppNavigation.getThemeColor(for: tabName)
            channel.font = channel.font.bold()
            underLine.backgroundColor = AppNavigation.getThemeColor(for: tabName)
        } else {
            channel.textColor = UIColor(hex: Color.ChannelScroller.text)
            underLine.backgroundColor = UIColor.clear
            channel.font = channel.font.desetBold()
        }
    }
}


