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

    var themeColor: String? = nil
    var contentSection: ContentSection? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
//        title.setTitle(contentSection?.title, for: .normal)
        title.text = contentSection?.title
        title.tintColor = UIColor(hex: Color.Content.headline)
        self.backgroundColor = UIColor(hex: Color.Content.border)
    }
    
    
}
