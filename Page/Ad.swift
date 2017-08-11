//
//  Ad.swift
//  Page
//
//  Created by ZhangOliver on 2017/6/15.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class Ad: UICollectionReusableView {
    
    @IBOutlet weak var adView: AdView!
    // MARK: - Use lazy var for webView as we might later switch to native ad and use web view only as fallback
    // MARK: - didset might not be a good way to trigger updateUI as it causes unexpected crashes
    var contentSection: ContentSection? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //nibSetup()
        //updateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //nibSetup()
        //updateUI()
    }
    
    // MARK: Use WKWebview to migrate current display ads.
    public func updateUI() {
        // print ("ad header view update UI called")
        let adBackgroundColor = UIColor(hex: Color.Ad.background)
        self.backgroundColor = adBackgroundColor
        adView?.backgroundColor = adBackgroundColor
        adView?.contentSection = self.contentSection
        adView?.updateUI()
    }
    
    // TODO: Need to implement url click in wkwebview
    // TODO: Need to come up with a Ad View Class, which is a subclass of UIView
    // TODO: Upgrade to native for default templates

}
