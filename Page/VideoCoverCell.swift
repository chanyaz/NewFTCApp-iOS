//
//  VideoCoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class VideoCoverCell: CoverCell {
    
    @IBOutlet weak var topicBorderView: UIView!
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var innerView: UIView!
    var coverTheme: String?
    override func updateUI() {
        super.updateUI()
        if let firstTag = itemCell?.tag.getFirstTag(Meta.reservedTags) {
            topic.text = firstTag
            topicBorderView.isHidden = false
        } else {
            topic.text = nil
            topicBorderView.isHidden = true
        }
        if let coverTheme = coverTheme {
            let backgroundColor = UIColor(hex: Color.Theme.get(coverTheme).background)
            let borderTheme: String
            if itemCell?.isCover == true {
                innerView.backgroundColor = backgroundColor
                headline.textColor = UIColor(hex: Color.Theme.get(coverTheme).title)
                lead.textColor = UIColor(hex: Color.Theme.get(coverTheme).lead)
                innerView.layer.borderWidth = 0
                borderTheme = coverTheme
            } else if itemCell?.row == 0 {
                let firstSectionColor = UIColor(hex: Color.Content.backgroundForSectionCover)
                innerView.backgroundColor = firstSectionColor
                innerView.layer.borderWidth = 0
                borderTheme = coverTheme.replacingOccurrences(
                    of: "-.*$",
                    with: "",
                    options: .regularExpression
                )
            } else {
                innerView.layer.borderColor = UIColor(hex: Color.Content.border).cgColor
                innerView.backgroundColor = UIColor(hex: Color.Content.background)
                innerView.layer.borderWidth = 1.0
                borderTheme = coverTheme.replacingOccurrences(
                    of: "-.*$",
                    with: "",
                    options: .regularExpression
                )
            }
            let borderColor = UIColor(hex: Color.Theme.get(borderTheme).tag)
            topic.textColor = borderColor
            topicBorderView.backgroundColor = borderColor
        }
    }
    
}
