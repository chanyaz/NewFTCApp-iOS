//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class DataViewController: UICollectionViewController {
    fileprivate let reuseIdentifier = "ItemCell"
    //fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
    fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    
    fileprivate var fetches = ContentFetchResults(
    apiUrl: "",
    fetchResults: [ContentSection]()
    )
    fileprivate let contentAPI = ContentFetch()
    
    // MARK: - Once The dataObject is changed, UI should be updated
    var dataObject = [String: String]()
    var pageTitle: String = ""
    
    var pageContent = [String: Any]() {
        didSet {
            updateUI()
        }
    }
    
    
    private func getAPI(_ urlString: String) {
        // 1
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        contentAPI.fetchContentForUrl(urlString) {
            results, error in
            
            
            activityIndicator.removeFromSuperview()
            
            
            if let error = error {
                // 2
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                // 3
                print("Found \(results.fetchResults.count) matching \(results.apiUrl)")
                //self.fetches.insert(results, at: 0)
                self.fetches = results
                
                
                // 4
                self.collectionView?.reloadData()
            }
        }
    }
    
    
//    private func formatJSONData(_ data: Data) -> [String: Any]? {
//        do {
//            let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
//            if let json = JSON as? [String: Any] {
//                guard let sections = json["sections"] as? [[String: Any]] else {
//                    print("creatives Not an Array")
//                    return nil
//                }
//                for section in sections {
//                    if let type = section["type"] as? String,
//                        type == "block"{
//                        guard let lists = section["lists"] as? [[String: Any]] else {
//                            print("lists Not an Array")
//                            break
//                        }
//                        for list in lists {
//                            print (list)
//                        }
//                    }
//                }
//            }
//        } catch {
//            
//        }
//        return nil
//    }
    
    
    
    private func updateUI() {
        //print (pageContent)
    }
    
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
        
        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // MARK: - Get Content
        view.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)


        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 414, height: 200)
            flowLayout.minimumLineSpacing = 30
        }
        

        

        
        // MARK: - Get Content Data for the Page
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
        return fetches.fetchResults.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return fetches.fetchResults[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)

        // Configure the cell
        
        switch reuseIdentifier {
        case "ItemCell":
            if let cell = cell as? ItemCell {
                // TODO: The following code should be moved to ItemCell class. Then you only need to set fetch result for cell. Check out detail implementation on Paul's Stanford Lecture 9 on table view
                cell.title.text = fetches.fetchResults[indexPath.section].items[indexPath.row].headline
                cell.lead.text = fetches.fetchResults[indexPath.section].items[indexPath.row].lead
                cell.title.preferredMaxLayoutWidth = 440
                cell.lead.preferredMaxLayoutWidth = 440
                return cell
            }
        default: break
        }
        
        return cell
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



fileprivate let itemsPerRow: CGFloat = 1


extension DataViewController : UICollectionViewDelegateFlowLayout {


    //1
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //2
//
//            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//            let availableWidth = view.frame.width - paddingSpace
//            let widthPerItem = availableWidth / itemsPerRow
//        let heightPerItem: CGFloat
//        if indexPath.row == 0 || indexPath.row == 8 {
//            heightPerItem = widthPerItem * 1
//        } else {
//            heightPerItem = widthPerItem * 0.618
//        }
//            return CGSize(width: widthPerItem, height: heightPerItem)
//    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
}
