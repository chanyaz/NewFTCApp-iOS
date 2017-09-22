//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class BookCell: CustomCell {
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
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkDetailButton: UIButton!
    @IBAction func checkDetail(_ sender: UIButton) {
        if let contentItemViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController,
            let topController = UIApplication.topViewController() {
            contentItemViewController.dataObject = itemCell
            contentItemViewController.hidesBottomBarWhenPushed = true
            contentItemViewController.themeColor = themeColor
            topController.navigationController?.pushViewController(contentItemViewController, animated: true)
        }
    }
    
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
    
    @IBOutlet weak var readButton: UIButton!
    @IBAction func read(_ sender: UIButton) {
        if let id = itemCell?.id {
            IAP.readBook(id)
        }
    }
    
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        setupLayout()
        updateContent()
        sizeCell()
    }
    
    private func updateContent() {
        // MARK: - set the border color
        if let row = itemCell?.row,
            row > 0,
            itemCell?.hideTopBorder != true {
            border.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            // MARK: - set first item's border color to transparent
            border.backgroundColor = nil
        }
        
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        
        if let leadText = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            paragraphStyle.lineBreakMode = .byTruncatingTail
            let setStr = NSMutableAttributedString.init(string: leadText)
            setStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, (leadText.characters.count)))
            lead.attributedText = setStr
        }
        
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        // MARK: - initialize image view as it will be reused. If you don't do this, the cell might show wrong image when you scroll.
        imageView.image = nil
        if let loadedImage = itemCell?.thumbnailImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type: "thumbnail", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.thumbnailImage
            })
        }
        
        // MARK: - update buy button content
        buyButton.setTitle(itemCell?.productPrice, for: .normal)
        
        if let id = itemCell?.id {
            let status = IAP.checkStatus(id)
            let buttons = [buyButton, checkDetailButton, readButton]
            for button in buttons {
                button?.isHidden = true
            }
            
            switch status {
            case "success", "pendingdownload":
                readButton.isHidden = false
            default:
                buyButton.isHidden = false
                checkDetailButton.isHidden = false
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
        let buttonTint = UIColor(hex: Color.Button.highlight)
        let buttons = [buyButton, checkDetailButton, readButton]
        for button in buttons {
            button?.tintColor = buttonTint
            button?.layer.cornerRadius = 3
            button?.layer.borderColor = buttonTint.cgColor
            button?.layer.borderWidth = 1
            button?.contentEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
        }
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

//TODO: Paid Post Ad should be moved to a subclass rather than the channel cell



