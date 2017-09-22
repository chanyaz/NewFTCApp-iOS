//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/25.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import SafariServices
class CustomCell: UICollectionViewCell, SFSafariViewControllerDelegate {
    
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    var themeColor: String?
    
    func updateUI() {}
    
    // MARK: These three functions are same as those in the AdView, should find a way to put them in one place
    public func addTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let link = self.itemCell?.adModel?.link, let url = URL(string: link) {
            openLink(url)
        }
    }
    
    public func openLink(_ url: URL) {
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        if let topController = UIApplication.topViewController() {
            topController.present(webVC, animated: true, completion: nil)
        }
    }
}
