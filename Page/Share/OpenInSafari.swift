//
//  Whatsapp.swift
//  Send2Phone
//
//  Created by Sohel Siddique on 3/27/15.
//  Copyright (c) 2015 Zuzis. All rights reserved.
//

import UIKit

class OpenInSafari : UIActivity{
    
    init(to: String) {
        self.to = to
        self.text = ""
    }
    
    var to: String
    var text:String?
    
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "openInSafari")
    }
    
    override var activityImage: UIImage?
    {
        if to == "safari-custom" {
            return UIImage(named: "SafariCustom")
        } else {
            return UIImage(named: "Safari")
        }
    }
    
    override var activityTitle : String
    {
        return "打开链接"
    }
    
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.share
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        if let url = URL(string: ShareHelper.shared.webPageUrl) {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    
    
    
    
}
