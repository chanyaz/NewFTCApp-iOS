//
//  RootViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/5/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
// MARK: - Channel View Controller is for Channel Pages with a horizontal navigation collection view at the top of the page
class ChannelViewController: PagesViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    //private var channelScroller: UICollectionView = UICollectionView()
    private let channelScrollerHeight: CGFloat = 40
    var pageData:[[String : String]] = []
    var channelScrollerView: UICollectionView?
    
    var currentChannelIndex: Int = 0 {
        didSet {
            if currentChannelIndex != oldValue {
                print ("page index changed to \(String(describing: currentChannelIndex))")
                channelScrollerView?.reloadData()
                // MARK: - add "view.layoutIfNeeded()" before implementing scrollToItem method
                view.layoutIfNeeded()
                channelScrollerView?.scrollToItem(
                    at: IndexPath(row: currentChannelIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
                print ("scrolled to item at index \(currentChannelIndex)")
            } else {
                print ("page index kept at \(String(describing: currentChannelIndex))")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let fullPageViewRect = self.view.bounds
        let pageViewRect = CGRect(x: 0, y: channelScrollerHeight, width: fullPageViewRect.width, height: fullPageViewRect.height - channelScrollerHeight)
        self.pageViewController!.view.frame = pageViewRect
        
        // MARK: - Add channelScroller
        let channelScrollerRect = CGRect(x: 0, y: 0, width: fullPageViewRect.width, height: channelScrollerHeight)
        let flowLayout = UICollectionViewFlowLayout()
        channelScrollerView = UICollectionView(frame: channelScrollerRect, collectionViewLayout: flowLayout)
        channelScrollerView?.register(UINib.init(nibName: "ChannelScrollerCell", bundle: nil), forCellWithReuseIdentifier: "ChannelScrollerCell")
        //collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.estimatedItemSize = CGSize(width: 50, height: channelScrollerHeight)
        // flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        channelScrollerView?.delegate = self
        channelScrollerView?.dataSource = self
        channelScrollerView?.backgroundColor = UIColor.white
        channelScrollerView?.showsHorizontalScrollIndicator = false
        //channelScrollerView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        if let channelScrollerView = channelScrollerView {
            self.view.addSubview(channelScrollerView)
        }
        
        // MARK: - Get Channels Data as the Data Source
        if let currentTabName = tabName,
            let p = AppNavigation.sharedInstance.getNavigationPropertyData(for: currentTabName, of: "Channels" ) {
            pageData = p
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return pageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelScrollerCell", for: indexPath as IndexPath)
        if let cell = cell as? ChannelScrollerCell {
            //cell.cellHeight.constant = channelScrollerHeight
            if indexPath.row == currentChannelIndex {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
            cell.pageData = pageData[indexPath.row]
            return cell
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: channelScrollerHeight)
    }
    
}

extension ChannelViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        currentChannelIndex = indexPath.row
        return false
    }
}
