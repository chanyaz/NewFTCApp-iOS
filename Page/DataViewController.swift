//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ItemCell"

class DataViewController: UICollectionViewController {
    
    
    // MARK: - Once The dataObject is changed, UI should be updated
    var dataObject = [String: String]()
    var pageTitle: String = ""
    
    var pageContent = [String: Any]() {
        didSet {
            updateUI()
        }
    }
    
    

    
    private func getAPI(_ urlString: String) {
        let url = URL(string: urlString)
        if let urlValue = url {
            Download().getDataFromUrl(urlValue) { (data, response, error)  in
                guard let data = data , error == nil else { return }
                DispatchQueue.main.async { () -> Void in
                    if let k = self.formatJSONData(data) {
                        self.pageContent = k
                    }
                }
            }
        }
    }
    
    
    private func formatJSONData(_ data: Data) -> [String: Any]? {
        do {
            let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
            if let json = JSON as? [String: Any] {
                guard let sections = json["sections"] as? [[String: Any]] else {
                    print("creatives Not an Array")
                    return nil
                }
                for section in sections {
                    if let type = section["type"] as? String,
                        type == "block"{
                        guard let lists = section["lists"] as? [[String: Any]] else {
                            print("lists Not an Array")
                            break
                        }
                        for list in lists {
                            print (list)
                        }
                    }
                }
            }
        } catch {
            
        }
        return nil
    }
    
    
    
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
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        
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
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 100
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        // Configure the cell
        switch reuseIdentifier {
        case "ItemCell":
            if let cell = cell as? ItemCell {
                cell.title.text = "headline of the story"
                cell.lead.text = "lead for this story"
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
