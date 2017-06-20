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
    private let channelScrollerHeight: CGFloat = 44
    
    var channelScrollerView: UICollectionView?
    var isUserPanningEnd = false
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
                if isUserPanningEnd == false {
                    let currentViewController: DataViewController = self.modelController.viewControllerAtIndex(currentChannelIndex, storyboard: self.storyboard!)!
                    let viewControllers = [currentViewController]
                    let direction: UIPageViewControllerNavigationDirection
                    if currentChannelIndex>oldValue {
                        direction = .forward
                    } else {
                        direction = .reverse
                    }
                    self.pageViewController!.setViewControllers(viewControllers, direction: direction, animated: true, completion: {done in })
                } else {
                    print ("the user is panning, no need to update page view")
                }
            }
        }
    }
    
    var modelController: ChannelModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        
        if _modelController == nil {
            if let t = tabName {
                _modelController = ChannelModelController(tabName: t)
            }
        }
        return _modelController!
    }
    
    var _modelController: ChannelModelController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: Set up pages for the channel view
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        self.pageViewController!.dataSource = self.modelController
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParentViewController: self)
        // MARK: To avoid pageview controller behind the navigation and bottom bar, just uncheck Under Top Bars for both: UIPageViewController and your custom PageContentViewController: https://stackoverflow.com/questions/18202475/content-pushed-down-in-a-uipageviewcontroller-with-uinavigationcontroller
        // self.automaticallyAdjustsScrollViewInsets = false
        
        
        // MARK - Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
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
        channelScrollerView?.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.channelScrollerBackground)
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
        
        // MARK: - Observing notification about page panning end
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pagePanningEnd(_:)),
            name: NSNotification.Name(rawValue: AppNavigation.sharedInstance.pagePanningEndNotification),
            object: nil
        )
    }
    
    deinit {
        // MARK: - Starting from iOS 8, Observers will automatically be removed when deinit.
        // MARK: - Remove Panning End Observer
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: AppNavigation.sharedInstance.pagePanningEndNotification),
            object: nil
        )
    }
    
    func pagePanningEnd(_ notification: Notification) {
        if let object = notification.object as? (index: Array.Index, title: String) {
            let index = object.index as Int
            print ("panning to \(object.title): \(index)")
            goToPage(index, isUserPanningEnd: true)
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
    
    func goToPage(_ index: Int, isUserPanningEnd: Bool) {
        self.isUserPanningEnd = isUserPanningEnd
        currentChannelIndex = index
    }
    
    
}

extension ChannelViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // TODO: use a gotopage function
        goToPage(indexPath.row, isUserPanningEnd: false)
        return false
    }
}
