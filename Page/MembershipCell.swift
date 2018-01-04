//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class MembershipCell: CustomCell {
    // TODO: What if status is changed? For example, after a user buy the product.

    var pageTitle = ""
    var buyState: BuyState = .New
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iapBackground: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var benefitsLabel: UILabel!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBAction func buy(_ sender: Any) {
        switch buyState {
        case .New:
            if let id = itemCell?.id {
                // MARK: If user logged in, purchase directly
                if UserInfo.shared.userName != nil && UserInfo.shared.userName != "" {
                    buyImmediately(id)
                } else {
                    let alert = UIAlertController(title: "您还没有登录FT中文网", message: "建议您先登录FT中文网，再继续购买，这样您购买的会员服务可以跨设备享受。", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(
                        title: "先去登录",
                        style: UIAlertActionStyle.default,
                        handler: {_ in UserInfo.showAccountPage() }
                    ))
                    alert.addAction(UIAlertAction(
                        title: "直接购买",
                        style: UIAlertActionStyle.default,
                        handler: {_ in self.buyImmediately(id)}
                    ))
                    alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
                    if let topViewController = UIApplication.topViewController() {
                        topViewController.present(alert, animated: true, completion: nil)
                    } else {
                        buyImmediately(id)
                    }
                }
            }
        case .Purchasing, .Purchased:
            print ("the item is already bought")
        }
    }

    @IBAction func restore(_ sender: Any) {
        IAPProducts.store.restorePurchases()
        Track.event(category: "IAP", action: "restore", label: "All")
    }
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        setupLayout()
        updateContent()
        sizeCell()
    }
    
    private func updateContent() {
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        var benefitsString = ""
        if let productBenefits = itemCell?.productBenefits {
            // TODO: Display Product Benefits
            for benefit in productBenefits {
                benefitsString += "- \(benefit)\n"
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            paragraphStyle.lineBreakMode = .byTruncatingTail
            let setStr = NSMutableAttributedString.init(string: benefitsString)
            setStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, (benefitsString.count)))
            benefitsLabel.attributedText = setStr
        }

        // MARK: - update buy button content
        price.text = "\(itemCell?.productPrice ?? "")/年"
        buyButton.setTitle("订阅", for: .normal)
        buyButton.setTitle("已订阅", for: .disabled)
        
        // MARK: - update restore button content
        restoreButton.setTitle("恢复购买", for: .normal)
        
        if let id = itemCell?.id {
            let status = IAP.checkStatus(id)
            if ["success", "pendingdownload"].contains(status) {
                buyButton.isEnabled = false
                restoreButton.isHidden = true
            } else {
                buyButton.isEnabled = true
                restoreButton.isHidden = false
            }
        }
    }
    
    private func setupLayout() {
        let buttonTint = UIColor(hex: Color.Button.subscriptionBackground)
        
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
        headline.font = headline.font.bold()
        lead.textColor = UIColor(hex: Color.Content.lead)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        
        // MARK: - Set Button Colors
        buyButton.backgroundColor = UIColor(hex: Color.Button.subscriptionBackground)
        buyButton.setTitleColor(UIColor(hex: Color.Button.subscriptionColor), for: .normal)
        
        // MARK: - Set restore button
        restoreButton.tintColor = buttonTint
        restoreButton.layer.cornerRadius = 3
        restoreButton.layer.borderColor = buttonTint.cgColor
        restoreButton.layer.borderWidth = 1
        restoreButton.contentEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
        
    }
    
    private func sizeCell() {
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
    }
    
    private func buyImmediately(_ id: String) {
        buyState = .Purchasing
        buyButton.setTitle("连接中...", for: .normal)
        IAP.buy(id)
    }
    
}
