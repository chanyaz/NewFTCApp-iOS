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
    
    
    // MARK: - Style settings for this class
    let imageWidth = 160
    let imageHeight = 216
    //var adModel: AdModel?
    var pageTitle = ""
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iapBackground: UIView!
    @IBOutlet weak var price: UILabel!
    
    
    @IBOutlet weak var buyButton: UIButton!
    @IBAction func buy(_ sender: Any) {
        if let contentItemViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController,
            let topController = UIApplication.topViewController() {
            contentItemViewController.dataObject = itemCell
            contentItemViewController.hidesBottomBarWhenPushed = true
            contentItemViewController.themeColor = themeColor
            contentItemViewController.action = "buy"
            topController.navigationController?.pushViewController(contentItemViewController, animated: true)
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
        
        
        if let leadText = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression) {
            lead.text = leadText
        }
        
        

        
        // MARK: - update buy button content
        //buyButton.setTitle(itemCell?.productPrice, for: .normal)
        price.text = "\(itemCell?.productPrice ?? "")/年"
        
        if let id = itemCell?.id {
            let status = IAP.checkStatus(id)
            let buttons = [buyButton]
            for button in buttons {
                button?.isHidden = true
            }
            
            switch status {
            case "success", "pendingdownload":
                print ("success or pending download")
            default:
                buyButton.isHidden = false
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
