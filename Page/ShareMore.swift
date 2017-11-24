//
//  Whatsapp.swift
//  Send2Phone
//
//  Created by Sohel Siddique on 3/27/15.
//  Copyright (c) 2015 Zuzis. All rights reserved.
//

import UIKit

class ShareMore: UIActivity{
    var contentItem: ContentItem?
    var sender: Any?
    //    var to: String
    //    var text:String?
    
    //    init(to: String) {
    //        self.to = to
    //        self.text = ""
    //    }
    
    init (contentItem: ContentItem?, from: Any?) {
        self.contentItem = contentItem
        self.sender = from
    }
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "ShareMore")
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "More")
    }
    
    override var activityTitle : String
    {
        return "更多"
    }
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.share
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        print ("should open the system share action sheet")
        var senderView: UIView?
        if let sender = sender as? UIBarButtonItem {
            senderView = sender.value(forKey: "view") as? UIView
        } else if let sender = sender as? UIView {
            senderView = sender
        }
        
        if let senderView = senderView,
            let sourceViewController = senderView.parentViewController,
            let contentItem = contentItem {
            sourceViewController.launchActionSheet(for: contentItem, from: senderView)
        }
    }
    
}

