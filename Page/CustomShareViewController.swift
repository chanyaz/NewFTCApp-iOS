//
//  CustomShareViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/11/23.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

class CustomShareViewController: UIViewController {
    
    override func loadView() {
        super.loadView()

        // MARK: Add a bottom layer so that you can tap to dismiss
        let bottomLayer = UIView()
        bottomLayer.isUserInteractionEnabled = true
        bottomLayer.backgroundColor = UIColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0.7
        )
        bottomLayer.frame = view.frame
        bottomLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(close))
        bottomLayer.isUserInteractionEnabled = true
        bottomLayer.addGestureRecognizer(tapGestureRecognizer)
        view.addSubview(bottomLayer)
        
        // MARK: Add the action sheet view so that you can hold all the share options
        let shareSheetHeight: CGFloat = 100
        let shareSheetView = UIView()
        shareSheetView.backgroundColor = UIColor(hex: Color.Content.background)
        view.addSubview(shareSheetView)
        shareSheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: shareSheetHeight))
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
        
        // MARK: Add share images and buttons
//        let shareItems = [
//            (text: "微信好友", image: UIImage(named: "WeChat"), action: "ShareWeChat")
//        ]
        let wcActivity = WeChatShare(to: "chat")
        let wcCircle = WeChatShare(to: "moment")
        let openInSafari = OpenInSafari()
        let shareItems = [wcActivity, wcCircle, openInSafari]
        let itemImageHeight: CGFloat = 44
        let itemTitleHeight: CGFloat = 20
        let itemPadding: CGFloat = 15
        let itemHeight = itemImageHeight + itemTitleHeight
        var itemLeading = itemPadding
        for item in shareItems {

            if let title = item.activityTitle,
                let image = item.activityImage {
                
                let itemView = UIView()
                itemView.translatesAutoresizingMaskIntoConstraints = false
                //itemView.backgroundColor = UIColor.red
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemHeight))
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemImageHeight))
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: shareSheetView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: itemLeading))
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: shareSheetView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
                itemLeading += itemImageHeight + itemPadding
                
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.image = image
                itemView.addSubview(imageView)
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemImageHeight))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemImageHeight))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
                
                view.addSubview(itemView)
            }
            

        }
        
    }
    
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
}
