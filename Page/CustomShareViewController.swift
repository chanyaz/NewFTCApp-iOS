//
//  CustomShareViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/11/23.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

class CustomShareViewController: UIViewController {
    var shareItems: [UIActivity] = []
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    override func loadView() {
        func getItemLeading(for index: Int, with itemWidth: CGFloat, of columns: CGFloat) -> CGFloat {
            let itemIndexInRow = index % Int(columns)
            let itemLeading = itemWidth * CGFloat(itemIndexInRow)
            return itemLeading
        }
        func getItemCenterY(index: Int, rows: CGFloat, columns: CGFloat, containerHeight: CGFloat, itemHeight: CGFloat) -> CGFloat {
            let rowIndex = floor(CGFloat(index)/columns)
            let paddingCount = rows + 1
            let paddingHeight = max(0, (containerHeight-itemHeight*rows)/paddingCount)
            let rowCenterOffset = paddingHeight * (rowIndex + 1) + itemHeight * (rowIndex + 1/2)
            let containerCenterOffset = containerHeight * 1/2
            let itemCenterY = rowCenterOffset - containerCenterOffset
            return itemCenterY
        }
        super.loadView()
        // MARK: Add a bottom layer so that you can tap to dismiss
        let bottomLayer = UIView()
        bottomLayer.isUserInteractionEnabled = true
        bottomLayer.backgroundColor = UIColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0.7
        )
        bottomLayer.frame = view.frame
        bottomLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(close))
        bottomLayer.isUserInteractionEnabled = true
        bottomLayer.addGestureRecognizer(tapGestureRecognizer)
        let swipeDownGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipeDownGesture)
        view.addSubview(bottomLayer)
        
        // MARK: Add the action sheet view so that you can hold all the share options
        let itemCount: CGFloat = CGFloat(shareItems.count)
        let columns: CGFloat = 4
        let rows = ceil(itemCount/columns)
        
        
        let shareSheetHeight: CGFloat = 180 * rows
        let shareSheetView = UIView()
        shareSheetView.backgroundColor = UIColor(hex: Color.Content.background)
        view.addSubview(shareSheetView)
        shareSheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: shareSheetHeight))
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: shareSheetView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
        
        // MARK: Add share images and buttons
        let itemImageHeight: CGFloat = 60
        let itemTitleHeight: CGFloat = 20
        let itemPadding: CGFloat = min(
            itemImageHeight/3,
            (view.frame.width/4 - itemImageHeight)/2
        )
        let itemHeight = itemImageHeight + itemTitleHeight
        let itemWidth = itemImageHeight + 2 * itemPadding
        for (index, item) in shareItems.enumerated() {
            if let title = item.activityTitle,
                let image = item.activityImage {
                let itemView = UIView()
                let itemCenterY = getItemCenterY(index: index, rows: rows, columns: columns, containerHeight: shareSheetHeight, itemHeight: itemHeight)
                itemView.tag = index
                let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(performShare(_:)))
                let itemLeading = getItemLeading(for: index, with: itemWidth, of: columns)
                itemView.isUserInteractionEnabled = true
                itemView.addGestureRecognizer(tapGestureRecognizer)
                itemView.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemHeight))
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemWidth))
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: shareSheetView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: itemLeading))
                view.addConstraint(NSLayoutConstraint(item: itemView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: shareSheetView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: itemCenterY))
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.image = image
                itemView.addSubview(imageView)
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemImageHeight))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemImageHeight))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                let titleLabel = UILabel()
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.textAlignment = .center
                titleLabel.text = title
                titleLabel.font = titleLabel.font.withSize(13)
                titleLabel.textColor = UIColor(hex: Color.Content.headline)
                itemView.addSubview(titleLabel)
                view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: itemWidth))
                view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: itemView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                view.addSubview(itemView)
            }
        }
    }
    
    public func updateItem() {
        print ("should update items for custom share view! ")
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
    @objc func performShare(_ gesture : UITapGestureRecognizer) {
        var shouldDismissCurrentView = true
        if let v = gesture.view {
            let tag = v.tag
            let shareItem = shareItems[tag]
            //shareItem.perform()
            if let shareItem = shareItem as? WeChatShare {
                shareItem.perform()
            } else if let shareItem = shareItem as? OpenInSafari {
                shareItem.perform()
            } else if let shareItem = shareItem as? ShareMore {
                shareItem.perform()
            } else if let shareItem = shareItem as? WeiboShare {
                shareItem.perform()
            } else if let shareItem = shareItem as? SaveScreenshot {
                shareItem.perform()
            } else if let shareItem = shareItem as? ShareScreenshot {
                dismiss(animated: false)
                shareItem.perform()
                //updateItem()
                shouldDismissCurrentView = false
            }
        }
        if shouldDismissCurrentView {
            dismiss(animated: true)
        }
    }
    
}
