//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class DataViewController: UICollectionViewController {
    var refreshControl = UIRefreshControl()
    
    //fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    let columnNum: CGFloat = 1 //use number of columns instead of a static maximum cell width
    var cellWidth: CGFloat = 0
    
    
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
    
    
    
    private func getAPI(_ urlString: String) {
        // 1
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        contentAPI.fetchContentForUrl(urlString) {
            results, error in
            
            
            activityIndicator.removeFromSuperview()
            
            self.refreshControl.endRefreshing()
            
            if let error = error {
                // 2
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                // 3
                print("Found \(results.fetchResults.count) matching \(results.apiUrl)")
                // MARK: - Insert Ads into the fetch results
                let resultsWithAds = ContentFetchResults(
                    apiUrl: results.apiUrl,
                    fetchResults: AdLayout().insertAds("home", to: results.fetchResults)
                )
                print("After inserting ads. now there are \(resultsWithAds.fetchResults.count) matching \(results.apiUrl)")
                self.fetches = resultsWithAds
                
                
                
                // 4
                self.collectionView?.reloadData()
            }
        }
    }
    
    
    
    
    
    //    private func updateUI() {
    //        //print (pageContent)
    //    }
    
    private func requestNewContent() {
        // MARK: - Request Data from Server
        if let api = dataObject["api"] {
            // TODO: Display a spinner
            
            getAPI(api)
        } else {
            //TODO: Show a warning if there's no api to get
            
        }
        
        // TODO: Check if there's a local version of data
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        collectionView?.register(UINib.init(nibName: "ChannelCell", bundle: nil), forCellWithReuseIdentifier: "ChannelCell")
        collectionView?.register(UINib.init(nibName: "CoverCell", bundle: nil), forCellWithReuseIdentifier: "CoverCell")
        collectionView?.register(UINib.init(nibName: "HeadlineCell", bundle: nil), forCellWithReuseIdentifier: "HeadlineCell")
        collectionView?.register(UINib.init(nibName: "Ad", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Ad")
        collectionView?.register(UINib.init(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        // MARK: - Update Styles
        view.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultBorderColor)
        collectionView?.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultBorderColor)
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            let paddingSpace = sectionInsetsForPad.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            flowLayout.estimatedItemSize = CGSize(width: availableWidth, height: 110)
            cellWidth = availableWidth
            //print (cellWidth)
        }
        
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // let fetchR = fetches.fetchResults
        print ("found \(fetches.fetchResults.count) sections")
        return fetches.fetchResults.count
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return fetches.fetchResults[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = getReuseIdentifierForCell(indexPath)
        let cellItem = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        switch reuseIdentifier {
        case "CoverCell":
            if let cell = cellItem as? CoverCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
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
            switch reuseIdentifier {
            case "Ad":
                let adView = headerView as! Ad
                adView.urlString = "http://www.ftchinese.com/m/marketing/a.html?v=20161009143608#adid=20220101&pid=phonebanner0"
                return adView
            case "HeaderView":
                let headerView = headerView as! HeaderView
                //headerView.urlString = "http://www.ftchinese.com/m/marketing/a.html?v=20161009143608#adid=20220101&pid=phonebanner0"
                return headerView
            default:
                assert(false, "Unknown Identifier")
            }
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    // Calculate Height for Headers
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let reuseIdentifier = getReuseIdentifierForSectionHeader(section).reuseId {
            print (reuseIdentifier)
            return CGSize(width: view.frame.width, height: view.frame.width/4)
        }
        return CGSize.zero
        
        //return CGSize(width: 300, height: 250)
    }
    
    
    // MARK: - Use different cell based on different strategy
    private func getReuseIdentifierForCell(_ indexPath: IndexPath) -> String {
        let layoutKey = layoutType()
        let layoutStrategy: String?
        if let layoutValue = dataObject[layoutKey] {
            layoutStrategy = layoutValue
        } else {
            layoutStrategy = nil
        }
        let reuseIdentifier: String
        if layoutStrategy == "Simple Headline" {
            if indexPath.section == 0 && indexPath.row == 0 {
                reuseIdentifier = "CoverCell"
            } else {
                reuseIdentifier = "HeadlineCell"
            }
        } else {
            if indexPath.row == 0 {
                reuseIdentifier = "CoverCell"
            } else {
                reuseIdentifier = "ChannelCell"
            }
        }
        return reuseIdentifier
    }
    
    private func getReuseIdentifierForSectionHeader(_ sectionIndex: Int) -> (reuseId: String?, sectionSize: CGSize) {
        let reuseIdentifier: String?
        let sectionSize: CGSize
        let sectionType = fetches.fetchResults[sectionIndex].type
        print (sectionType)
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
            reuseIdentifier = "HeaderView"
            sectionSize = CGSize(width: view.frame.width, height: 80)
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
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}


// MARK: - Private
//private extension DataViewController {
//    func itemForIndexPath(indexPath: IndexPath) -> ContentItem {
//        return fetches[(indexPath as NSIndexPath).section].fetchResults[(indexPath as IndexPath).row]
//    }
//}



fileprivate let itemsPerRow: CGFloat = 3
fileprivate let sectionInsetsForPad = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

extension DataViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //print ("sizeFor Item At called")
        let paddingSpace = sectionInsetsForPad.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem: CGFloat
        heightPerItem = widthPerItem * 0.618
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsetsForPad
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsetsForPad.left
    }
}


