
//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class ThemeCoverCell: CoverCell {
    
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topic: UILabel!
    var coverTheme: String?
    override func updateUI() {
        super.updateUI()
//        topic.text = itemCell?.tag
//            .replacingOccurrences(of: "^QuizPlus[,，]+", with: "", options: .regularExpression)
//            .replacingOccurrences(
//                of: "[,，].*$",
//                with: "",
//                options: .regularExpression
//        )
        topic.text = itemCell?.tag.getFirstTag(Meta.reservedTags)
        if let coverTheme = coverTheme {
            let backgroundColor = UIColor(hex: Color.Theme.get(coverTheme).background)
            topic.textColor = UIColor(hex: Color.Theme.get(coverTheme).tag)
            headline.textColor = UIColor(hex: Color.Theme.get(coverTheme).title)
            lead.textColor = UIColor(hex: Color.Theme.get(coverTheme).lead)
            innerView.backgroundColor = backgroundColor
            innerView.layer.borderColor = UIColor(hex: Color.Theme.get(coverTheme).border).cgColor
            innerView.layer.borderWidth = 1
            bottomView.backgroundColor = UIColor.clear
            
        }
    }
    
}
