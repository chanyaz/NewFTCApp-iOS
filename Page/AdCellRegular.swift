//
//  AdCellRegular.swift
//  Page
//
//  Created by huiyun.he on 04/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import Foundation
import WebKit

class AdCellRegular: UICollectionViewCell {

   
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var ad: UILabel!
    //small screen need hide adHint,big screen need keep adHint
    @IBOutlet weak var adHint: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = UIColor(hex: "#fff1e0")
        view.backgroundColor = UIColor(hex: "#f6e9d8")
        border.backgroundColor = UIColor(hex: Color.Content.border)
    }
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }

    // MARK: Use WKWebview to migrate current display ads.
    func updateUI() {
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        print ("update UI webView")
        if let row = itemCell?.row,
            row > 0 {
            border.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            // MARK: - set first item's border color to transparent
            border.backgroundColor = nil
        }

    }

}
