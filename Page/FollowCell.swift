//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class FollowCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topBorder: UIView!
    
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    var themeColor: String?
    
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    func updateUI() {
        
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        name.textColor = UIColor(hex: Color.Content.headline)
        name.font = name.font.bold()
        
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
        
        // MARK: Update Content
        name.text = itemCell?.headline
        name.isUserInteractionEnabled = true
        actionButton.setTitle("+ 关注", for: .normal)
        actionButton.setTitle("已关注", for: .selected)
        
        if let themeColor = themeColor {
            let theme = UIColor(hex: themeColor)
            actionButton.setTitleColor(theme, for: .normal)
            actionButton.setTitleColor(UIColor.white, for: .selected)
            actionButton.tintColor = theme
        }
        
        if itemCell?.row != 0 {
            topBorder.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            topBorder.backgroundColor = UIColor.clear
        }
        
        
        // MARK: Check if the topic is already followed
        if let followType = itemCell?.followType,
            let keyword = itemCell?.id {
            let follows = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
            for followKeyword in follows {
                if followKeyword == keyword {
                    actionButton.isSelected = true
                }
            }
        }
        addTap()
    }
    
    
    private func addTap() {
        let nameTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapName(_:)))
        name.addGestureRecognizer(nameTapGestureRecognizer)
        
        let actionTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapAction(_:)))
        actionButton.addGestureRecognizer(actionTapGestureRecognizer)
        
    }
    
    @objc open func tapName(_ recognizer: UITapGestureRecognizer) {
        //print ("name is tapped: \(itemCell?.headline); \(itemCell?.id)")
        if let followType = itemCell?.followType,
            let followKey = itemCell?.id,
            let followTitle = itemCell?.headline {
            let urlString = APIs.get(followType, value: followKey)
            print ("should show \(urlString)")
            if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
                dataViewController.dataObject = ["title": followTitle,
                                                 "api": urlString,                                                     "screenName":"tag/\(followKey)"]
                dataViewController.pageTitle = followTitle
                if let topController = UIApplication.topViewController() {
                    topController.navigationController?.pushViewController(dataViewController, animated: true)
                }
            }
        }
    }
    
    @objc open func tapAction(_ recognizer: UITapGestureRecognizer) {
        //print ("action is tapped: \(String(describing: itemCell?.headline)); \(String(describing: itemCell?.id)); \(actionButton.state)")
        if let followType = itemCell?.followType,
            let keyword = itemCell?.id {
            var follows = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
            follows = follows.filter{
                $0 != keyword
            }
            if actionButton.state != .selected {
                follows.insert(keyword, at: 0)
            }
            UserDefaults.standard.set(follows, forKey: "follow \(followType)")
            actionButton.isSelected = !actionButton.isSelected
        }
    }
    
}

