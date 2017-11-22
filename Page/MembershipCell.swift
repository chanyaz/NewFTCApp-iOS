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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iapBackground: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var benefitsLabel: UILabel!
    
    
    @IBOutlet weak var buyButton: UIButton!
    @IBAction func buy(_ sender: Any) {
        if let id = itemCell?.id {
            IAP.buy(id)
        }
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
        if let id = itemCell?.id {
            let status = IAP.checkStatus(id)
            if ["success", "pendingdownload"].contains(status) {
                buyButton.isEnabled = false
            } else {
                buyButton.isEnabled = true
            }
        }
        
    }
    
    private func setupLayout() {
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
    
}
