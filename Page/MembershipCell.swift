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
    var isAutoRenewal: Bool? = nil
    var purchaseSource: String? = nil
    private let buttonManageKey = "管理订阅"
    private let buttonRestoreKey = "恢复订阅"
    
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
        if buyState == .New || (buyState == .Purchased && isAutoRenewal == nil) {
            // MARK: If the purchase is new or expired, or auto renewal status is unknown, buy it
            if let id = itemCell?.id {
                // MARK: If user logged in, purchase directly
                print ("user id is now \(String(describing: UserInfo.shared.userId))")
                if UserInfo.shared.userId != nil && UserInfo.shared.userId != "" {
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
        } else if buyState == .Purchasing {
            // MARK: If the purchase is in process, do it. 
            Alert.present("您正在购买", message: "正在等待苹果服务器的回应，无需进一步操作")
            print ("the item is already bought")
        } else {
            // MARK: If the user has bought the item an isAutoRenewal is not nil, tap the button will lead to the manage subscription button
            if isAutoRenewal != nil {
                if purchaseSource == PurchaseSource.Site.rawValue {
                    print ("\(String(describing: itemCell?.id)) is bought from web site! No need to do anything now! ")
//                    if let url = URL(string: "http://www.ftacademy.cn/index.php/pay/subscriptionTTEESSTT"),
//                        let topViewController = UIApplication.topViewController() {
//                        topViewController.openLink(url)
//                    }
                } else {
                    if let url = URL(string:DeviceInfo.manageSubscriptionUrl) {
                        UIApplication.shared.openURL(url)
                    }
                }
            } else if let id = itemCell?.id {
                buyImmediately(id)
            } else {
                Alert.present("对不起", message: "找不到已购产品的ID号，请截屏找FT中文网客服帮忙。")
            }
            print ("the item is already bought")
        }
    }

    @IBAction func restore(_ sender: Any) {
        if let button = sender as? UIButton,
        let buttonTitle = button.title(for: .normal),
        buttonTitle == buttonManageKey {
            if let url = URL(string:DeviceInfo.manageSubscriptionUrl) {
                UIApplication.shared.openURL(url)
            }
        } else {
            IAPProducts.store.restorePurchases()
            Track.event(category: "IAP", action: "restore", label: "All")
        }
    }
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        updateContent()
        setupLayout()
        sizeCell()
    }

    private func updateContent() {
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        var buttonActionString = "订阅"
        var benefitsString = ""
        if let productBenefits = itemCell?.productBenefits {
            // MARK: Display Product Benefits
            for benefit in productBenefits {
                benefitsString += "- \(benefit)\n"
            }
            if let id = itemCell?.id,
                let expiresString = IAP.checkPurchaseInDevice(id, property: "expires") {
                buttonActionString = "续订"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = PrivilegeHelper.dateFormatString
                if let expiresDate = dateFormatter.date(from: expiresString) {
                    dateFormatter.dateFormat = PrivilegeHelper.dateFormatStringSimple
                    let expiresDateStringNew = dateFormatter.string(from: expiresDate)
                    let expiresStatement: String
                    if expiresDate >= Date() {
                        buyState = .Purchased
                        if let isAutoRenew = IAP.checkPurchaseInDevice(id, property: "auto_renew_status") {
                            if isAutoRenew == "1" {
                                // MARK: The autorenewal is set to true, remind user about this so that he/she won't be surprised when money is taken.
                                expiresStatement = "您的订阅目前是自动续期，如您在\(expiresDateStringNew)前一天内未关闭自动续订功能，订阅周期会自动延续并扣费。如您需要关闭自动续期，请点击下方按钮进入iTunes Store进行设置。"
                                buttonActionString = "关闭自动续期"
                                isAutoRenewal = true
                            } else {
                                // MARK: The autorenewal is set to false, remind the user that he/she can change it to true.
                                if let purchaseSourceString = IAP.checkPurchaseInDevice(id, property: PrivilegeHelper.purchaseSourceKey),
                                    purchaseSourceString == PurchaseSource.Site.rawValue {
                                    purchaseSource = purchaseSourceString
                                    expiresStatement = "您已经订阅到\(expiresDateStringNew)。"
                                    buttonActionString = "已订阅"
                                } else {
                                    purchaseSource = PurchaseSource.AppleIAP.rawValue
                                    expiresStatement = "您的订阅将于\(expiresDateStringNew)过期，如您希望续订，请点击下方按钮进入iTunes Store进行设置。"
                                    buttonActionString = "打开自动续期"
                                }

                                isAutoRenewal = false
                            }
                        } else {
                            // MARK: The autorenewal status is unknown, the user can tap to manually renew
                            expiresStatement = "您的订阅将于\(expiresDateStringNew)过期"
                            isAutoRenewal = nil
                            buttonActionString = "续订"
                        }
                    } else {
                        // MARK: The subscription has expired. Prompt the user to renew.
                        expiresStatement = "您的订阅已于\(expiresDateStringNew)过期"
                        buyState = .New
                        isAutoRenewal = false
                        buttonActionString = "续订"
                    }
                    benefitsString += "\n\(expiresStatement)\n"
                }
                
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
        
        buyButton.setTitle(buttonActionString, for: .normal)
//        buyButton.setTitle("已订阅", for: .disabled)
        
        if let id = itemCell?.id {
            let status = IAP.checkStatus(id)
            if ["success", "pendingdownload"].contains(status) {
                // MARK: - update restore button content
                restoreButton.setTitle(buttonManageKey, for: .normal)
                //buyButton.setTitle("续订", for: .normal)
                // buyButton.isEnabled = false
                //restoreButton.isHidden = true
            } else {
                // MARK: - update restore button content
                restoreButton.setTitle(buttonRestoreKey, for: .normal)
                //buyButton.isEnabled = true
                //restoreButton.isHidden = false
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
