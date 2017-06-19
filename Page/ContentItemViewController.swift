//
//  ContentItemViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/19.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ContentItemViewController: UIViewController {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var dataObject: ContentItem?
    var pageTitle: String = ""
    var themeColor: String?
    
    @IBOutlet weak var headline: UILabel!

    override func viewDidLoad() {
        headline.text = dataObject?.headline
    }
}
