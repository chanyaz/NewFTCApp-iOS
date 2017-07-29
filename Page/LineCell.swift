//
//  LineCell.swift
//  Page
//
//  Created by ZhangOliver on 2017/7/29.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class LineCell: UICollectionViewCell {
    @IBOutlet weak var border: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hex: Color.Content.background)
        border.backgroundColor = UIColor(hex: Color.Content.border)
    }
}
