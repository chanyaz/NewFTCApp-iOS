//
//  HeaderCollectionReusableView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/15.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {

    
    @IBOutlet weak var title: UILabel!
    var themeColor: String? = nil
    var contentSection: ContentSection? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        title.text = contentSection?.title
        title.textColor = UIColor.white
        //self.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        if let theme = themeColor {
            self.backgroundColor = UIColor(hex: theme)

        }
        //title.font = title.font.bold()

    }
    
}
