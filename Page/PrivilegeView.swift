//
//  PrivilegeView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/25.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
class PrivilegeView: UIView {
    let boxView = UIView()
    let titleView = UILabel()
    let subscriptButton = UIButtonWithSpacing()
    let loginButton = UIButton()
    
    let verticalPadding: CGFloat = 0
    let horizontalMargin: CGFloat = 15
    let boxViewHeight: CGFloat = 240
    let buttonInsect = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    let titleText = "成为会员，阅读FT独家内容"
    let subscriptionTitle = "即刻订阅"
    
    func initUI() {
        backgroundColor = .clear
        addBoxView()
        
    }
    private func addBoxView() {
        addSubview(boxView)
        boxView.backgroundColor = UIColor(hex: Color.Subscription.boxBackground)
        boxView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.bottomMargin, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -verticalPadding))
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -horizontalMargin))
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: boxViewHeight))
        addContentToBoxView()
    }
    
    private func addContentToBoxView() {
        // MARK: Add the title view
        boxView.addSubview(titleView)
        titleView.text = titleText
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: boxView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: boxView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        
        // MARK: Add the subscription button
        boxView.addSubview(subscriptButton)
        subscriptButton.spacing = 3
        subscriptButton.translatesAutoresizingMaskIntoConstraints = false
        subscriptButton.setTitle(subscriptionTitle, for: .normal)
        subscriptButton.setBackgroundColor(color: UIColor(hex: Color.Button.subscriptionBackground), forState: .normal)
        subscriptButton.contentEdgeInsets = buttonInsect
        addConstraint(NSLayoutConstraint(item: subscriptButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint(item: subscriptButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: boxView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        
        
    }
}

struct PrivilegeViewHelper {
    public static func insertPrivilegeView(to sourceView: UIView) {
        let privilegeView = PrivilegeView()
        privilegeView.initUI()
//        privilegeView.frame = sourceView.frame
//        privilegeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sourceView.addSubview(privilegeView)
        privilegeView.translatesAutoresizingMaskIntoConstraints = false
        sourceView.addConstraint(NSLayoutConstraint(item: privilegeView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: sourceView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        sourceView.addConstraint(NSLayoutConstraint(item: privilegeView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: sourceView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        sourceView.addConstraint(NSLayoutConstraint(item: privilegeView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: sourceView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        sourceView.addConstraint(NSLayoutConstraint(item: privilegeView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: sourceView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
    }
}

class UIButtonWithSpacing: UIButton {
    override func setTitle(_ title: String?, for state: UIControlState) {
        if let title = title, spacing != 0 {
            let color = super.titleColor(for: state) ?? UIColor.black
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: [NSAttributedStringKey.kern: spacing,
                             NSAttributedStringKey.foregroundColor: color])
            super.setAttributedTitle(attributedTitle, for: state)
        } else {
            super.setTitle(title, for: state)
        }
    }
    
    fileprivate func updateTitleLabel_() {
        let states:[UIControlState] = [.normal, .highlighted, .selected, .disabled]
        for state in states
        {
            let currentText = super.title(for: state)
            self.setTitle(currentText, for: state)
        }
    }
    
    @IBInspectable var spacing:CGFloat = 0 {
        didSet {
            updateTitleLabel_()
        }
    }
}
