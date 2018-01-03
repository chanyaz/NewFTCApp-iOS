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
    var privilegeRequired: PrivilegeType?
    let boxView = UIView()
    let titleView = UILabel()
    let subscriptButton = UIButtonWithSpacing()
    let loginLabel = UILabel()
    
    let verticalPadding: CGFloat = 0
    let horizontalMargin: CGFloat = 15
    let boxViewHeight: CGFloat = 220
    let buttonInsect = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 8)
    
    let titleText = "成为会员，阅读FT独家内容"
    let subscriptionTitle = "立即订阅▶︎"
    let loginQuestion = "已经是FT中文网会员？"
    let loginAction = "登录"
    
    func initUI() {
        backgroundColor = .clear
        addBoxView()
    }
    
    private func addBoxView() {
        addSubview(boxView)
        let boxBackgroundColor = UIColor(hex: Color.Subscription.boxBackground)
        boxView.backgroundColor = boxBackgroundColor
        boxView.layer.shadowColor = boxBackgroundColor.cgColor
        boxView.layer.shadowOffset = CGSize(width: 0, height: -60)
        boxView.layer.shadowOpacity = 0.9
        boxView.layer.shadowRadius = 15.0
        boxView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -verticalPadding))
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: boxView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: boxViewHeight))
        addContentToBoxView()
    }
    
    private func addContentToBoxView() {
        
        // MARK: Prepare style parameters such as colors and paddings
        let fontColor = UIColor(hex: Color.Content.headline)
        let actionColor = UIColor(hex: Color.Button.subscriptionBackground)
        
        // MARK: Add the title view
        boxView.addSubview(titleView)
        titleView.text = titleText
        titleView.textColor = fontColor
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: boxView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: boxView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        
        // MARK: Add the subscription button
        boxView.addSubview(subscriptButton)
        subscriptButton.spacing = 8
        subscriptButton.translatesAutoresizingMaskIntoConstraints = false
        subscriptButton.setTitle(subscriptionTitle, for: .normal)
        subscriptButton.setBackgroundColor(color: actionColor, forState: .normal)
        subscriptButton.contentEdgeInsets = buttonInsect
        addConstraint(NSLayoutConstraint(item: subscriptButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint(item: subscriptButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: boxView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(showSubscription(_:)))
        subscriptButton.isUserInteractionEnabled = true
        subscriptButton.addGestureRecognizer(tapGestureRecognizer)

        // MARK: Add the login label
        let attrs1 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor : fontColor]
        let attrs2 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor : actionColor]
        let attributedString1 = NSMutableAttributedString(string: loginQuestion, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string: loginAction, attributes:attrs2)
        attributedString1.append(attributedString2)
        loginLabel.attributedText = attributedString1
        boxView.addSubview(loginLabel)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: loginLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: subscriptButton, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint(item: loginLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: boxView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        let tapGestureRecognizerForLogin = UITapGestureRecognizer(target:self, action:#selector(showAccountPage(_:)))
        loginLabel.isUserInteractionEnabled = true
        loginLabel.addGestureRecognizer(tapGestureRecognizerForLogin)
        
    }

    @objc open func showSubscription(_ sender: UITapGestureRecognizer) {
        if let privilegeRequired = privilegeRequired {
            let _ = PrivilegeViewHelper.showSubscriptionView(for: privilegeRequired)
        }
    }
    
    
    @objc open func showAccountPage(_ sender: UITapGestureRecognizer) {
            UserInfo.showAccountPage()
    }

    
}

struct PrivilegeViewHelper {
    
    public static func insertPrivilegeView(to sourceView: UIView, with privilegeType: PrivilegeType) {
        let privilegeView = PrivilegeView()
        privilegeView.privilegeRequired = privilegeType
        privilegeView.initUI()
        privilegeView.frame = sourceView.frame
        privilegeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sourceView.addSubview(privilegeView)
    }
    
    public static func removePrivilegeView(from sourceView: UIView) {
        for subview in sourceView.subviews {
            if let subview = subview as? PrivilegeView {
                subview.removeFromSuperview()
            }
        }
    }
    
    public static func showSubscriptionView(for privilegeRequired: PrivilegeType) -> Bool {
        if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
        let membershipChannelData = AppNavigation.getChannelData(of: IAPProducts.membershipScreenName),
        let topViewController = UIApplication.topViewController() {
            // MARK: Show a reason why user is redirected here
            let privilegeDescription = PrivilegeHelper.getDescription(privilegeRequired)
            dataViewController.dataObject = membershipChannelData
            // MARK: Only show options that include this privilege
            dataViewController.withPrivilege = privilegeRequired
            dataViewController.privilegeDescriptionBody = privilegeDescription.body
            dataViewController.pageTitle = privilegeDescription.title
            topViewController.navigationController?.pushViewController(dataViewController, animated: true)
            return true
        }
        return false
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
        for state in states {
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
