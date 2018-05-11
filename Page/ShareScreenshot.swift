//
//  Whatsapp.swift
//  Send2Phone
//
//  Created by Sohel Siddique on 3/27/15.
//  Copyright (c) 2015 Zuzis. All rights reserved.
//

import UIKit

class ShareScreenshot: UIActivity, Sharable {
    func performShare() {
        perform()
    }
    var contentItem: ContentItem?
    var sender: Any?
    
    init (contentItem: ContentItem?, from: Any?) {
        self.contentItem = contentItem
        self.sender = from
    }
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "ShareScreenshot")
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "ScreenCapture")
    }
    
    override var activityTitle : String {
        return "全文截屏"
    }
    
    override class var activityCategory : UIActivityCategory {
        return UIActivityCategory.share
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        print ("should open the share screen action sheet")
        var senderView: UIView?
        if let sender = sender as? UIBarButtonItem {
            senderView = sender.value(forKey: "view") as? UIView
        } else if let sender = sender as? UIView {
            senderView = sender
        }
        if let senderView = senderView,
            let sourceViewController = senderView.parentViewController,
            let contentItem = contentItem {
            sourceViewController.launchActionSheet(for: contentItem, from: senderView, with: .Screenshot)
        }
    }
    
}

