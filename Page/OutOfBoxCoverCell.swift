//
//  OutOfBoxCoverCell.swift
//  Page
//
//  Created by ZhangOliver on 2017/9/17.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class OutOfBoxCoverCell: VideoCoverCell {
    override func updateUI() {
        super.updateUI()
//        imageView.layer.cornerRadius = 8
//        imageView.clipsToBounds = true
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.618
        imageView.layer.masksToBounds = false;
        imageView.clipsToBounds = false;
        
    }

}
