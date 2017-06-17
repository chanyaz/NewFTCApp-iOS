//
//  RootViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/5/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
// MARK: - Channel View Controller is for Channel Pages with a horizontal navigation collection view at the top of the page
class ChannelViewController: PagesViewController {
    
    
    var channelScroller: UICollectionView = UICollectionView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let pageViewRect = self.view.bounds
        self.pageViewController!.view.frame = pageViewRect
        
    }
    
    
    
}

