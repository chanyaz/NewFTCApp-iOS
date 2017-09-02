//
//  ColumnAllListViewController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class ColumnAllListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var columnAllList: UITableView?
    var columnMyList: UITableView?
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var allListButton: UIButton!
    @IBOutlet weak var myListButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
//    @IBOutlet weak var buttonPlayAndPause: UIBarButtonItem!
    @IBAction func openAllList(_ sender: UIButton) {
        if let columnAllList = columnAllList {
            columnAllList.register(UINib(nibName: "ColumnAllListCell", bundle: nil), forCellReuseIdentifier: "ColumnAllListCell")
            self.tableContainerView.addSubview(columnAllList)
            self.tableContainerView.willRemoveSubview(columnMyList!)
        }

        print("openAllList")
    }
    @IBAction func openMyList(_ sender: UIButton) {
        if let columnMyList = columnMyList {
            columnMyList.register(UINib(nibName: "ColumnMyListCell", bundle: nil), forCellReuseIdentifier: "ColumnMyListCell")
            self.tableContainerView.addSubview(columnMyList)
            self.tableContainerView.willRemoveSubview(columnAllList!)
        }
//        self.tableContainerView.addSubview(columnMyList!)
        
        print("openMyList")
    }
    @IBAction func tryToRead(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func toBuy(_ sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        columnAllList=UITableView(frame: CGRect(x: 0, y: 0, width: 300, height: 400), style: UITableViewStyle.plain)
        columnMyList=UITableView(frame: CGRect(x: 0, y: 0, width: 300, height: 400), style: UITableViewStyle.plain)
        columnAllList?.delegate = self
        columnAllList?.dataSource = self
        columnMyList?.delegate = self
        columnMyList?.dataSource = self

        
        columnAllList?.register(UINib(nibName: "ColumnAllListCell", bundle: nil), forCellReuseIdentifier: "ColumnAllListCell")
        self.tableContainerView.addSubview(columnAllList!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == columnMyList {
            print("---columnMyList")
            return 5
        }else if tableView == columnAllList {

            print("---columnAllList")
            return 7
        }
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == columnMyList {
            print("---columnMyList")
            return 40
        }else if tableView == columnAllList {
            //            reuseIdentifier = "ChannelViewCell11"
            print("---columnAllList")
            return 50
        }
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier = ""

        if tableView == columnMyList {
           reuseIdentifier = "ColumnMyListCell"
        }else if tableView == columnAllList {
           reuseIdentifier = "ColumnAllListCell"
 
        }
        
        let cellItem = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
//        print(cellItem)
//        cell.textLabel?.text = "hh"
        
        switch reuseIdentifier {
        case "ColumnMyListCell":
            if let cell = cellItem as? ColumnMyListCell {
                cell.backgroundColor = UIColor.yellow
//                print ("this is an audio--\(indexPath.row)")
                return cell
            }
        case "ColumnAllListCell":
            if let cell = cellItem as? ColumnAllListCell {
                cell.backgroundColor = UIColor.brown
                return cell
            }
            
        default:
            if let cell = cellItem as? ColumnAllListCell {
                cell.layer.borderWidth = 1
                return cell
            }
        }
        return cellItem
        
//        let cellItem = tableView.dequeueReusableCell(withIdentifier: "ColumnAllListCell", for: indexPath)
//            cellItem.layer.borderWidth = 1
//              print(cellItem)
//        return cellItem
    }
    

    

}
