//
//  HeaderCollectionReusableView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/15.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var headerLeading: NSLayoutConstraint!
    var headerWidth: CGFloat?
    @IBOutlet weak var title: UIButton!
    var themeColor: String? = nil
    var contentSection: ContentSection? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if let headerWidth = headerWidth,
            headerWidth < UIScreen.main.bounds.width {
        headerLeading.constant = (UIScreen.main.bounds.width - headerWidth)/2 + 14
        } else {
            headerLeading.constant = 14
        }
        title.setTitle(contentSection?.title, for: .normal)
        title.tintColor = UIColor(hex: Color.Content.headline)
        self.backgroundColor = UIColor(hex: Color.Content.background)
    }
    
}
