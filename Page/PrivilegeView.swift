//
//  PrivilegeView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/25.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

struct ConversionTracker {
    static var shared = ConversionTracker()
    var item: ContentItem?
}

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
    
    var titleText = "购买会员服务，阅读FT独家内容"
    let subscriptionTitle = "立即订阅▶︎"
    let loginQuestion = "已经购买过？"
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

        // MARK: Add the login label only if the user hasn't log in
        if UserInfo.shared.userId == nil || UserInfo.shared.userId == "" {
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
        
    }

    @objc open func showSubscription(_ sender: UITapGestureRecognizer) {
        if let privilegeRequired = privilegeRequired {
            let _ = PrivilegeViewHelper.showSubscriptionView(for: privilegeRequired, with: ConversionTracker.shared.item)
            // MARK: Track the tap event even if something is wrong with the conversion item
            let type = ConversionTracker.shared.item?.type ?? ""
            let id = ConversionTracker.shared.item?.id ?? ""
            Track.eventToAll(category: "Privileges", action: "Tap Subscription", label: "\(type)/\(id)")
        }
    }
    
    
    @objc open func showAccountPage(_ sender: UITapGestureRecognizer) {
            UserInfo.showAccountPage()
        // MARK: Track the tap event even if something is wrong with the conversion item
        let type = ConversionTracker.shared.item?.type ?? ""
        let id = ConversionTracker.shared.item?.id ?? ""
        Track.eventToAll(category: "Privileges", action: "Tap Login", label: "\(type)/\(id)")
    }

    
}

struct PrivilegeViewHelper {
    
    public static func insertPrivilegeView(to sourceView: UIView, with privilegeType: PrivilegeType, from item: ContentItem?) {
        let privilegeView = PrivilegeView()
        privilegeView.titleText = PrivilegeHelper.getDescription(privilegeType).body
        privilegeView.privilegeRequired = privilegeType
        //privilegeView.sourceItem = item
        privilegeView.initUI()
        privilegeView.frame = sourceView.frame
        privilegeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sourceView.addSubview(privilegeView)
        
        // MARK: Update the conversion tracker item
        ConversionTracker.shared.item = item
        
        // MARK: Track the event of PrivilegeView display
        if let type = item?.type,
            let id = item?.id {
            Track.eventToAll(category: "Privileges", action: "Display", label: "\(type)/\(id)")
        }
    }
    
    public static func removePrivilegeView(from sourceView: UIView) {
        for subview in sourceView.subviews {
            if let subview = subview as? PrivilegeView {
                subview.removeFromSuperview()
            }
        }
    }
    
    public static func showSubscriptionView(for privilegeRequired: PrivilegeType, with sourceItem: ContentItem?) -> Bool {
        if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
        let membershipChannelData = AppNavigation.getChannelData(of: IAPProducts.membershipScreenName),
        let topViewController = UIApplication.topViewController() {
            // MARK: Update the source item
            ConversionTracker.shared.item = sourceItem
            // MARK: Track the event of Subscription View display
            if let type = sourceItem?.type,
                let id = sourceItem?.id {
                Track.eventToAll(category: "Privileges", action: "Pop Subscription", label: "\(type)/\(id)")
            }
            // MARK: Show a reason why user is redirected here
            let privilegeDescription = PrivilegeHelper.getDescription(privilegeRequired)
            dataViewController.dataObject = membershipChannelData
            // MARK: Only show options that include this privilege
            dataViewController.withPrivilege = privilegeRequired
            dataViewController.privilegeDescriptionBody = privilegeDescription.title
            dataViewController.pageTitle = "会员订阅"
            topViewController.navigationController?.pushViewController(dataViewController, animated: true)
            return true
        }
        return false
    }
}


