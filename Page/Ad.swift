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
    var contentSection: ContentSection? = nil {
        didSet {
            updateUI()
        }
    }
    
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
    func updateUI() {
        print ("ad header view update UI called")
        let adBackgroundColor = UIColor(hex: Color.Ad.background)
        self.backgroundColor = adBackgroundColor
        adView?.backgroundColor = adBackgroundColor
        let adWidth: String
        if let adType = contentSection?.type,
            adType == "MPU" {
            adWidth = "300px"
        } else {
            adWidth = "100%"
        }
        //TODO: - We should preload the ad information to avoid decreasing our ad inventory
        if let adid = contentSection?.adid {
            if let url = AdParser.getAdUrlFromDolphin(adid) {
                Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                    DispatchQueue.main.async { () -> Void in
                        guard let data = data , error == nil, let adCode = String(data: data, encoding: .utf8) else {
                            self?.adView?.adid = adid
                            self?.adView?.adWidth = adWidth
                            self?.adView?.loadAdView()
                            return
                        }
                        let adModel = AdParser.parseAdCode(adCode)
                        self?.adView?.adid = adid
                        self?.adView?.adWidth = adWidth
                        self?.adView?.adModel = adModel
                        self?.adView?.loadAdView()
                    }
                }
            }
        }
    }
    
    // TODO: Need to implement url click in wkwebview
    // TODO: Need to come up with a Ad View Class, which is a subclass of UIView
    // TODO: Upgrade to native for default templates
    
    
}
