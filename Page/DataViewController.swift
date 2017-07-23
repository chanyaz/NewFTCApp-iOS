//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit


class DataViewController: UICollectionViewController {
    var isLandscape :Bool = false
    var refreshControl = UIRefreshControl()
    let flowLayout = PageCollectionViewLayoutV()
    let flowLayoutH = PageCollectionViewLayoutH()
    //fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    let columnNum: CGFloat = 1 //use number of columns instead of a static maximum cell width
    var cellWidth: CGFloat = 0
    var themeColor: String? = nil
    
    fileprivate var fetches = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    fileprivate let contentAPI = ContentFetch()
    
    // MARK: - Once The dataObject is changed, UI should be updated
    var dataObject = [String: String]()
    var pageTitle: String = ""
    
    //    var pageContent = [String: Any]() {
    //        didSet {
    //            updateUI()
    //        }
    //    }
    //    var contentSection: ContentSection? = nil {
    //
    //    }
    
    
    deinit {
        //MARK: Some of the deinit might b e useful in the future
    }
    
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private func getAPI(_ urlString: String) {
        let horizontalClass = self.traitCollection.horizontalSizeClass
        let verticalCass = self.traitCollection.verticalSizeClass
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        contentAPI.fetchContentForUrl(urlString) {
            [weak self] results, error in
            DispatchQueue.main.async {
                self?.activityIndicator.removeFromSuperview()
                self?.refreshControl.endRefreshing()
                if let error = error {
                    print("Error searching : \(error)")
                    return
                }
                if let results = results {
                    // MARK: - Insert Ads into the fetch results
                    let layoutWay:String
                    if horizontalClass == .regular && verticalCass == .regular {
                        layoutWay="ipadhome"
                    }else{
                        layoutWay="home"
                    }
                    
                    let resultsWithAds = ContentFetchResults(
                        apiUrl: results.apiUrl,
                        fetchResults: AdLayout().insertAds(layoutWay, to: results.fetchResults)
                    )
                    self?.fetches = resultsWithAds
                    
                    
                    //                    self?.fetches = results
                    
                    //                    print("fetches : \(resultsWithAds)")
                    
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
    
    
    
    private func requestNewContent() {
        // MARK: - Request Data from Server
        if let api = dataObject["api"] {
            // TODO: Display a spinner
            
            getAPI(api)
        } else {
            //TODO: Show a warning if there's no api to get
            print("results : error")
        }
        
        // TODO: Check if there's a local version of data
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let screeName = dataObject["screenName"] {
            Track.screenView(screeName)
        }
    }
    
    override func viewWillLayoutSubviews() {
        //         print("33333")//第一次启动出现3次，转屏出现一次
        let horizontalClass = self.traitCollection.horizontalSizeClass
        let verticalCass = self.traitCollection.verticalSizeClass
        
        if horizontalClass == .regular && verticalCass == .regular {
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                isLandscape = true
                collectionView?.collectionViewLayout=flowLayoutH
                flowLayoutH.minimumInteritemSpacing = 0
                flowLayoutH.minimumLineSpacing = 0
            }
            
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                isLandscape = false
                collectionView?.collectionViewLayout=flowLayout
                flowLayout.minimumInteritemSpacing = 0
                flowLayout.minimumLineSpacing = 0
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("22222")//第一次启动不运行，转屏出现一次
        collectionView?.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        
        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        
        //        if horizontalClass == .regular && verticalCass == .regular {
        ////            collectionView?.collectionViewLayout=flowLayout
        ////            flowLayout.minimumInteritemSpacing = 0
        ////            flowLayout.minimumLineSpacing = 0
        //             print("availableWidth : test")
        //        } else {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            //FIXME: Why does this break scrolling?
            //flowLayout.sectionHeadersPinToVisibleBounds = true
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            print("availableWidth : \(availableWidth)")
            
            if horizontalClass != .regular || verticalCass != .regular {
                if #available(iOS 10.0, *) {
                    flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
                } else {
                    flowLayout.estimatedItemSize = CGSize(width: availableWidth, height: 110)
                }
                cellWidth = availableWidth
            }
        }
        
        //        }
        collectionView?.register(UINib.init(nibName: "ChannelCell", bundle: nil), forCellWithReuseIdentifier: "ChannelCell")
        collectionView?.register(UINib.init(nibName: "CoverCell", bundle: nil), forCellWithReuseIdentifier: "CoverCell")
        collectionView?.register(UINib.init(nibName: "HeadlineCell", bundle: nil), forCellWithReuseIdentifier: "HeadlineCell")
        collectionView?.register(UINib.init(nibName: "Ad", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Ad")
        collectionView?.register(UINib.init(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        // MARK: Cell for Regular Size
        collectionView?.register(UINib.init(nibName: "ChannelCellRegular", bundle: nil), forCellWithReuseIdentifier: "ChannelCellRegular")
        collectionView?.register(UINib.init(nibName: "CoverCellRegular", bundle: nil), forCellWithReuseIdentifier: "CoverCellRegular")
        collectionView?.register(UINib.init(nibName: "AdCellRegular", bundle: nil), forCellWithReuseIdentifier: "AdCellRegular")
        collectionView?.register(UINib.init(nibName: "HotArticleCellRegular", bundle: nil), forCellWithReuseIdentifier: "HotArticleCellRegular")
        // MARK: - Update Styles
        view.backgroundColor = UIColor(hex: Color.Content.border)
        collectionView?.backgroundColor = UIColor(hex: Color.Content.border)
        if #available(iOS 10.0, *) {
            refreshControl.addTarget(self, action: #selector(refreshControlDidFire(sender:)), for: .valueChanged)
            collectionView?.refreshControl = refreshControl
        }
        
        // MARK: - Get Content Data for the Page
        requestNewContent()
        
    }
    
    
    func refreshControlDidFire(sender:AnyObject) {
        print ("pull to refresh fired")
        // TODO: Handle Pull to Refresh
        requestNewContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetches.fetchResults.count
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //        print ("items.count-- \(fetches.fetchResults[section].items.count) ----items.count")
        
        return fetches.fetchResults[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = getReuseIdentifierForCell(indexPath)
        let cellItem = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        //         print ("cellItem111---- \(cellItem) ----cellItem")
        switch reuseIdentifier {
        case "CoverCell":
            if let cell = cellItem as? CoverCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        case "HeadlineCell":
            if let cell = cellItem as? HeadlineCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        case "CoverCellRegular":
            if let cell = cellItem as? CoverCellRegular {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        case "ChannelCellRegular":
            if let cell = cellItem as? ChannelCellRegular {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        case "AdCellRegular":
            if let cell = cellItem as? AdCellRegular {
                cell.cellWidth = cellWidth
                //when itemCell change in AdCellRegular, updateUI() will be executed.After adding ad,comment the code
                //                if cell.bounds.height<330{
                //                    cell.adHint.isHidden=true
                //                }else{
                //                    cell.adHint.isHidden=false
                //                }
                return cell
            }
        case "HotArticleCellRegular":
            if let cell = cellItem as? HotArticleCellRegular {
                cell.cellWidth = cellWidth
                //              cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        default:
            if let cell = cellItem as? ChannelCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        }
        return cellItem
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let reuseIdentifier = getReuseIdentifierForSectionHeader(indexPath.section).reuseId ?? ""
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: reuseIdentifier,
                for: indexPath
            )
            
            // MARK: - a common tag gesture for all kinds of headers
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
            headerView.isUserInteractionEnabled = true
            headerView.addGestureRecognizer(tapGestureRecognizer)
            switch reuseIdentifier {
            case "Ad":
                let adView = headerView as! Ad
                adView.contentSection = fetches.fetchResults[indexPath.section]
                //                print ("indexPath.section-- \(indexPath.section) ----indexPath.section")
                return adView
            case "HeaderView":
                let headerView = headerView as! HeaderView
                headerView.themeColor = themeColor
                headerView.contentSection = fetches.fetchResults[indexPath.section]
                return headerView
            default:
                assert(false, "Unknown Identifier")
            }
            //            print ("headerView---- \(headerView) ----headerView")
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        
    }
    
    // Calculate Height for Headers
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if getReuseIdentifierForSectionHeader(section).reuseId != nil {
            return getReuseIdentifierForSectionHeader(section).sectionSize
        }
        return CGSize.zero
        
        //return CGSize(width: 300, height: 250)
    }
    
    
    // MARK: - Use different cell based on different strategy
    private func getReuseIdentifierForCell(_ indexPath: IndexPath) -> String {
        let section = fetches.fetchResults[indexPath.section]
        let sectionTitle = section.title
        let item = section.items[indexPath.row]
        let isCover = ((indexPath.row == 0 && sectionTitle != "") || item.isCover == true)
        
        let layoutKey = layoutType()
        let layoutStrategy: String?
        if let layoutValue = dataObject[layoutKey] {
            layoutStrategy = layoutValue
        } else {
            layoutStrategy = nil
        }
        let reuseIdentifier: String
        
        if layoutStrategy == "Simple Headline" {
            if isCover {
                reuseIdentifier = "CoverCell"
            } else {
                reuseIdentifier = "HeadlineCell"
            }
        } else {
            let horizontalClass = self.traitCollection.horizontalSizeClass
            let verticalCass = self.traitCollection.verticalSizeClass
            if horizontalClass == .regular && verticalCass == .regular {
                
                var isAd = false
                var isHot = false
                let isCover = ((indexPath.row == 0 ) )
                
                //                print("isLandscape----\(isLandscape)")
                
                if !isLandscape{
                    if indexPath.row == 6 {isAd = true}else{isAd = false}
                    if indexPath.row == 10 {isHot = true}else{isHot = false}
                }else if isLandscape {
                    isAd = (indexPath.row == 5)
                    isHot = (indexPath.row == 9)
                }
                
                //                if UIDevice.current.orientation.isPortrait{
                //                    if indexPath.row == 6 {isAd = true}else{isAd = false}
                //                    if indexPath.row == 10 {isHot = true}else{isHot = false}
                //                }else if UIDevice.current.orientation.isLandscape {
                //                    isAd = (indexPath.row == 5)
                //                    isHot = (indexPath.row == 9)
                //                }
                
                
                if isCover && !isAd && !isHot {
                    reuseIdentifier = "CoverCellRegular"
                } else if isAd && !isCover && !isHot {
                    reuseIdentifier = "AdCellRegular"
                } else if !isAd && !isCover && isHot {
                    reuseIdentifier = "HotArticleCellRegular"
                }
                else {
                    reuseIdentifier = "ChannelCellRegular"
                }
            } else {
                if isCover {
                    reuseIdentifier = "CoverCell"
                } else {
                    reuseIdentifier = "ChannelCell"
                }
            }
        }
        //        print ("reuseIdentifier---- \(reuseIdentifier) ----reuseIdentifier")
        return reuseIdentifier
    }
    
    private func getReuseIdentifierForSectionHeader(_ sectionIndex: Int) -> (reuseId: String?, sectionSize: CGSize) {
        let reuseIdentifier: String?
        let sectionSize: CGSize
        let sectionType = fetches.fetchResults[sectionIndex].type
        switch sectionType {
        case "Banner":
            reuseIdentifier = "Ad"
            sectionSize = CGSize(width: view.frame.width, height: view.frame.width/4)
        case "MPU":
            reuseIdentifier = "Ad"
            sectionSize = CGSize(width: 300, height: 250)
        case "HalfPage":
            reuseIdentifier = "Ad"
            sectionSize = CGSize(width: 300, height: 600)
        case "List":
            if fetches.fetchResults[sectionIndex].title != "" {
                reuseIdentifier = "HeaderView"
                sectionSize = CGSize(width: view.frame.width, height: 44)
            } else {
                reuseIdentifier = nil
                sectionSize = CGSize.zero
            }
        default:
            reuseIdentifier = nil
            sectionSize = CGSize.zero
        }
        return (reuseId: reuseIdentifier, sectionSize: sectionSize)
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    
    // MARK: - Handle user tapping on a cell
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // TODO: For a normal cell, allow the action to go through. For special types of cell, such as advertisment in a wkwebview, do not take any action and let wkwebview handle tap.
        let selectedItem = fetches.fetchResults[indexPath.section].items[indexPath.row]
        // MARK: if it is an audio file, push the audio view controller
        if let audioFileUrl = selectedItem.audioFileUrl {
            print ("this is an audio")
            
            //            let body = AudioContent.sharedInstance.body
            //            if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"]
            if let audioPlayer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayer") as? AudioPlayer {
                AudioContent.sharedInstance.body["title"] = selectedItem.headline
                AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                AudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(selectedItem.id)"
                audioPlayer.item = selectedItem
                audioPlayer.themeColor = themeColor
                navigationController?.pushViewController(audioPlayer, animated: true)
            }
            
        } else {
            //MARK: if it is a story, video or other types of HTML based content, push the detailViewController
            if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
                var pageData1 = [ContentItem]()
                var pageData2 = [ContentItem]()
                for (sectionIndex, section) in fetches.fetchResults.enumerated() {
                    for (itemIndex, item) in section.items.enumerated() {
                        if sectionIndex > indexPath.section || (sectionIndex == indexPath.section && itemIndex >= indexPath.row) {
                            pageData1.append(item)
                        } else {
                            pageData2.append(item)
                        }
                    }
                }
                let pageData = pageData1 + pageData2
                detailViewController.contentPageData = pageData
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        //        print ("prepare for segue here")
        
    }
    
    open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        //navigationController?.performSegue(withIdentifier: "Show News Detail", sender: self)
        //performSegue(withIdentifier: "Show Detail Content", sender: self)
        //        print ("header view tapped")
        
        
    }
    
}



fileprivate let itemsPerRow: CGFloat = 3
fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

extension DataViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //print ("sizeFor Item At called")
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem: CGFloat
        let heightPerItem: CGFloat
        // TODO: Should do the layout based on cell's properties
        if indexPath.row == 0 && indexPath.section == 1{
            widthPerItem = (availableWidth / itemsPerRow) * 2
            heightPerItem = widthPerItem * 0.618
        } else {
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = widthPerItem * 0.618
        }
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
}


// MARK: - Private
//private extension DataViewController {
//    func itemForIndexPath(indexPath: IndexPath) -> ContentItem {
//        return fetches[(indexPath as NSIndexPath).section].fetchResults[(indexPath as IndexPath).row]
//    }
//}

/*
 extension DataViewController {
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
 return true
 }
 
 override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
 return true
 }
 
 override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
 
 print ("performAction called! ")
 }
 
 }
 */
