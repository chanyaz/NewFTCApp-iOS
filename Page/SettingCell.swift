//
//  SettingCell.swift
//  Page
//
//  Created by ZhangOliver on 2017/9/16.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class SettingCell: CustomCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var options: UILabel!
    @IBOutlet weak var optionSwitch: UISwitch!

    @IBAction func switchChange(_ sender: UISwitch) {
        if let id = itemCell?.id {
            Setting.saveSwitchChange(id, isOn: sender.isOn)
        }
    }
    
    override func updateUI() {
        super.updateUI()
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        name.textColor = UIColor(hex: Color.Content.headline)
        
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
        //name.isUserInteractionEnabled = true
        
        
        if itemCell?.row != 0 {
            topBorder.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            topBorder.backgroundColor = UIColor.clear
        }
        
        // MARK: Set up right side options
        options.textColor = UIColor(hex: Color.Content.lead)
        optionSwitch.thumbTintColor = UIColor(hex: Color.Content.background)
        optionSwitch.tintColor = UIColor(hex: Color.Content.border)
        optionSwitch.onTintColor = UIColor(hex: Color.Button.switchBackground)
        optionSwitch.backgroundColor = UIColor(hex: Color.Content.border)
        optionSwitch.layer.cornerRadius = 16
        
        // MARK: Hide all the right items first
        options.isHidden = true
        optionSwitch.isHidden = true
        
        if let id = itemCell?.id {
            let settingInfo = Setting.get(id)
            if let settingType = settingInfo.type {
                switch settingType {
                case "switch":
                    optionSwitch.isHidden = false
                    optionSwitch.isOn = Setting.isSwitchOn(id)
                    case "option":
                    options.isHidden = false
                    options.text = "\(Setting.getCurrentOption(id).value) >"
                default:
                    options.isHidden = false
                    options.text = ">"
                }
            }
        }
        
        
    }
    
}
