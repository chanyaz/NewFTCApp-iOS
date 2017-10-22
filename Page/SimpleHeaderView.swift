//
//  SimpleHeaderView.swift
//  Page
//
//  Created by ZhangOliver on 2017/9/16.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class SimpleHeaderView: UICollectionReusableView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var headerLeading: NSLayoutConstraint!
    var headerWidth: CGFloat?
    var themeColor: String? = nil
    var contentSection: ContentSection? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
//        title.setTitle(contentSection?.title, for: .normal)
        if let headerWidth = headerWidth,
            headerWidth < UIScreen.main.bounds.width {
            headerLeading.constant = (UIScreen.main.bounds.width - headerWidth)/2 + 14
        } else {
            headerLeading.constant = 14
        }
        title.text = contentSection?.title
        title.tintColor = UIColor(hex: Color.Content.headline)
        self.backgroundColor = UIColor(hex: Color.Content.border)
    }
    
    
}
