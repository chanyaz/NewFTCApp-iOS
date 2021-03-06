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
    let cellMinWidth: CGFloat = 50
    
    var lastPendingViewControllerPageTitle = ""
    var currentViewControllerPageTitle = ""
    var lastPendingViewControllerIndex: Int?
    var currentViewControllerIndex: Int?
    
    var channelScrollerView: UICollectionView?
    var scrollerCellIdentifier = "ChannelScrollerCell"
    
    var isUserPanningEnd = false
    var currentChannelIndex: Int = 0 {
        didSet {
            if currentChannelIndex != oldValue {
                //print ("page index changed to \(String(describing: currentChannelIndex))")
                channelScrollerView?.reloadData()
                // MARK: - add "view.layoutIfNeeded()" before implementing scrollToItem method
                view.layoutIfNeeded()
                channelScrollerView?.scrollToItem(
                    at: IndexPath(row: currentChannelIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
                //print ("scrolled to item at index \(currentChannelIndex)")
                if isUserPanningEnd == false {
                    let currentViewController: DataViewController = self.modelController.viewControllerAtIndex(currentChannelIndex, storyboard: self.storyboard!)!
                    let viewControllers = [currentViewController]
                    let direction: UIPageViewControllerNavigationDirection
                    if currentChannelIndex>oldValue {
                        direction = .forward
                    } else {
                        direction = .reverse
                    }
                    self.pageViewController?.setViewControllers(viewControllers, direction: direction, animated: true, completion: {done in })
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
        
        
        // MARK: - Get Channels Data as the Data Source
        if let currentTabName = tabName,
            let p = AppNavigation.getNavigationPropertyData(for: currentTabName, of: "Channels" ) {
            pageData = p
            //print ("page data count: \(p.count)")
            updateBackBarButton(for: 0)
            
            // MARK: - Show Search Button is Required
            createNavItem(for: currentTabName, of: "navRightItem")
            createNavItem(for: currentTabName, of: "navLeftItem")
        }
        
        
        
        
        //MARK: - if there's only one channel, on need to show navigation scroller
        //        if pageData.count > 1 {
        // MARK - Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let fullPageViewRect = self.view.bounds
        let pageViewRect = CGRect(x: 0, y: channelScrollerHeight, width: fullPageViewRect.width, height: fullPageViewRect.height - channelScrollerHeight)
        self.pageViewController!.view.frame = pageViewRect
        
        // MARK: - Add channelScroller
        let channelScrollerRect = CGRect(x: 0, y: 0, width: fullPageViewRect.width, height: channelScrollerHeight)
        
        let flowLayout = UICollectionViewFlowLayout()
        channelScrollerView = UICollectionView(frame: channelScrollerRect, collectionViewLayout: flowLayout)
        channelScrollerView?.autoresizingMask = [.flexibleWidth]
        channelScrollerView?.register(UINib.init(nibName: "ChannelScrollerCell", bundle: nil), forCellWithReuseIdentifier: "ChannelScrollerCell")
        channelScrollerView?.register(UINib.init(nibName: "FixedWidthChannelScrollerCell", bundle: nil), forCellWithReuseIdentifier: "FixedWidthChannelScrollerCell")
        
        
        let numberOfChannels = CGFloat(pageData.count)
        if numberOfChannels > 0 {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            let minWidth = max(view.frame.width / numberOfChannels, cellMinWidth)
            if minWidth > cellMinWidth && numberOfChannels < 4 {
                print ("The cell width is now \(minWidth)")
                scrollerCellIdentifier = "FixedWidthChannelScrollerCell"
            } else {
                flowLayout.estimatedItemSize = CGSize(width: cellMinWidth, height: channelScrollerHeight)
            }
        }
        
        channelScrollerView?.delegate = self
        channelScrollerView?.dataSource = self
        updateColorScheme()
        
        if let channelScrollerView = channelScrollerView {
            self.view.addSubview(channelScrollerView)
        }
        
        //modelController.delegate = self
        
        // MARK: - Notification For English Status Change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nightModeChanged),
            name: Notification.Name(rawValue: Event.nightModeChanged),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Event.nightModeChanged), object: nil)
    }
    
    @objc public override func nightModeChanged() {
        super.nightModeChanged()
        updateColorScheme()
        channelScrollerView?.reloadData()
    }
    
    func updateColorScheme() {
        channelScrollerView?.backgroundColor = UIColor(hex: Color.ChannelScroller.background)
        channelScrollerView?.showsHorizontalScrollIndicator = false
        let thickness = Color.ChannelScroller.bottomBorderWidth
        if thickness > 0 {
            let borderColor = UIColor(hex: Color.Content.border)
            channelScrollerView?.layer.addBorder(edge: .bottom, color: borderColor, thickness: thickness)
        }
    }
    
    fileprivate func createNavItem(for currentTabName: String, of navItemString: String) {
        func insertButton(_ button: UIBarButtonItem, to navItemString: String) {
            switch navItemString {
            case "navRightItem":
                navigationItem.rightBarButtonItem = button
            case "navLeftItem":
                navigationItem.leftBarButtonItem = button
                break
            default:
                break
            }
        }
        if let navItem = AppNavigation.getNavigationProperty(for: currentTabName, of: navItemString) {
            switch navItem {
            case "Search":
                let image = UIImage(named: "Search")
                let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showSearch))
                insertButton(button, to: navItemString)
            case "Chat":
                let image = UIImage(named: "Chat")
                let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showChat))
                insertButton(button, to: navItemString)
            case "Person":
                let image = UIImage(named: "Person")
                let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showPerson))
                insertButton(button, to: navItemString)
            default:
                break
            }
        }
    }

    @objc public func showChat() {
        if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
    
    @objc public func showPerson() {
        //print("should to add person interface")
        ContentItemRenderContent.addPersonInfo = true
        if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
            navigationController?.pushViewController(chatViewController, animated: true)
        }
//        openHTMLInBundle("person-information", title: "注册", isFullScreen: false, hidesBottomBar: true)
    }
 
    private func updateBackBarButton(for index: Int) {
        // MARK: - Set the back bar button for the popped views
        // let title = pageData[index]["title"] ?? ""
        let title = ""
        let backItem = UIBarButtonItem()
        backItem.title = title
        navigationItem.backBarButtonItem = backItem
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scrollerCellIdentifier, for: indexPath as IndexPath)
        if let cell = cell as? ChannelScrollerCell {
            //cell.cellHeight.constant = channelScrollerHeight
            if indexPath.row == currentChannelIndex {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
            cell.cellHeight = channelScrollerHeight
            cell.tabName = tabName
            cell.pageData = pageData[indexPath.row]
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfChannels = CGFloat(pageData.count)
        if numberOfChannels > 0 {
            let minWidth = max(view.frame.width / numberOfChannels, cellMinWidth)
            if minWidth > cellMinWidth && numberOfChannels < 4 {
                return CGSize(width: minWidth, height: channelScrollerHeight)
            }
        }
        return CGSize(width: cellMinWidth, height: channelScrollerHeight)
    }
    
    func goToPage(_ index: Int, isUserPanningEnd: Bool) {
        self.isUserPanningEnd = isUserPanningEnd
        // MARK: update the current page index
        //print (pageViewController)
        currentChannelIndex = index
        updateBackBarButton(for: index)
    }
    
    @objc func showSearch() {
        if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
            // searchViewController
            dataViewController.dataObject = AppNavigation.search
            dataViewController.pageTitle = "搜索"
            navigationController?.pushViewController(dataViewController, animated: true)
        }
    }
    
}

extension ChannelViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        goToPage(indexPath.row, isUserPanningEnd: false)
        return false
    }
}

extension ChannelViewController {
    
//    func pagePanningEnd(_ pageInfoObject: (index: Int, title: String)) {
////        let index = pageInfoObject.index
////        //print ("panning to \(pageInfoObject.title): \(index)")
////        goToPage(index, isUserPanningEnd: true)
//    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        //print ("page will change with panning: \(pageViewController)")
        if let viewController = pendingViewControllers[0] as? DataViewController {
            // 2
            lastPendingViewControllerPageTitle = viewController.pageTitle
            lastPendingViewControllerIndex = viewController.pageIndex
            print ("Will be panning to \(lastPendingViewControllerPageTitle)/\(String(describing: lastPendingViewControllerIndex))")
        }
    }
    
//    func pageViewController(_ pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]){
//        print ("page will change with panning: \(pageViewController)")
//        if let viewController = pendingViewControllers[0] as? DataViewController {
//            // 2
//            lastPendingViewControllerPageTitle = viewController.pageTitle
//            print ("Will be panning to \(lastPendingViewControllerPageTitle)")
//        }
//    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //print ("page changed with panning: \(pageViewController)/\(completed)")
        if completed {
            currentViewControllerPageTitle = lastPendingViewControllerPageTitle
            currentViewControllerIndex = lastPendingViewControllerIndex
            print ("page changed with panning: \(currentViewControllerPageTitle)/\(String(describing: currentViewControllerIndex))")
            if let index = currentViewControllerIndex {
                goToPage(index, isUserPanningEnd: true)
            }
        }
    }
    
}
