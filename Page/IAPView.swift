//
//  IAPView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/5.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

class IAPView: UIView {
    
    var dataObject: ContentItem?
    
    public func updateUI() {
        if let price = dataObject?.productPrice {
            let buyButton = addButton("购买：\(price)", disabledTitle: "连接中...", position: .right, backgroundColor: Color.Button.highlight)
            buyButton.addTarget(self, action: #selector(buy(_:)), for: .touchUpInside)
        }
        let tryButton = addButton("试读", disabledTitle: "下载中...", position: .left, backgroundColor: Color.Button.standard)
        tryButton.addTarget(self, action: #selector(tryProduct(_:)), for: .touchUpInside)
    }
    
    private func addButton(_ title: String, disabledTitle: String,  position: NSLayoutAttribute, backgroundColor: String) -> UIButton {
        let buttonPadding: CGFloat = 0
        let buttonWidth = self.frame.width/2 - 2*buttonPadding
        let buttonHeight = self.frame.height
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        button.layer.masksToBounds = true
        button.setTitle(title, for: .normal)
        button.setTitle(disabledTitle, for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: backgroundColor)
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundColor(color: .gray, forState: .disabled)
        self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: -buttonPadding))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -buttonPadding))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: position, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: position, multiplier: 1, constant: -buttonPadding))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        return button
    }
    
    public func buy(_ sender: UIButton) {
        print ("buy product")
        sender.isEnabled = false
        if let id = dataObject?.id {
            IAP.buy(id)
        }
        
    }
    
    public func tryProduct(_ sender: UIButton) {
        sender.isEnabled = false
        print ("try product")
    }
    
}
