//
//  MyDownloadViewController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CollectInfoController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var dataArray:NSMutableArray?=NSMutableArray()
    var selectArray:NSMutableArray?=NSMutableArray()
    let infoTableView = UITableView()
    let allSelect = UIButton()
    let delete = UIButton()
    let screenWidth = UIScreen.main.bounds.width
    let buttonHeight: CGFloat = 60
    override func viewDidLoad() {
        super.viewDidLoad()
        self.allSelect.frame = CGRect(x: 0, y: -buttonHeight, width: screenWidth/2, height:90)
        self.allSelect.setTitle("全选", for: .normal)
        self.allSelect.backgroundColor = UIColor.red
        self.view.addSubview(allSelect)
        allSelect.addTarget(self, action: #selector(allSelectAction), for: .touchUpInside)
        
        self.delete.frame = CGRect(x: screenWidth/2, y: -buttonHeight, width: UIScreen.main.bounds.width/2, height:90)
        self.delete.setTitle("删除", for: .normal)
        self.delete.backgroundColor = UIColor.blue
        self.view.addSubview(delete)
        
        self.infoTableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.infoTableView.delegate = self
        self.infoTableView.dataSource = self
        self.infoTableView.register(UINib.init(nibName: "CollectTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectTableViewCell")
        self.view.addSubview(infoTableView)
        
        let audioButton = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = audioButton
    }
    @objc func allSelectAction(){
//        let arr = NSArray(array: IndexPath)
    }
    @objc func edit(){
//        for section in 0...self.infoTableView.numberOfSections - 1 {
//            for row in 0...self.infoTableView.numberOfRows(inSection: 0) - 1 {
//                let cell = self.infoTableView.cellForRow(at: NSIndexPath(row: row, section: 0) as IndexPath)
//                cell?.frame.origin.x = -50
//                print("edit infoTableView")
//            }
//        }
        
        self.infoTableView.frame = CGRect(x: 0, y: 90, width: screenWidth, height: UIScreen.main.bounds.height)
        self.allSelect.frame = CGRect(x: 0, y: 0, width: screenWidth/2, height:buttonHeight)
        self.delete.frame = CGRect(x: screenWidth/2, y: 0, width: UIScreen.main.bounds.width/2, height:buttonHeight)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
//        self.infoTableView.isEditing = true
        self.infoTableView.setEditing(true, animated: true)
        
       
    }
    @objc func cancel(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(edit))
        self.infoTableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: UIScreen.main.bounds.height)
        self.allSelect.frame = CGRect(x: 0, y: -buttonHeight, width: screenWidth/2, height:buttonHeight)
        self.delete.frame = CGRect(x: UIScreen.main.bounds.width/2, y: -buttonHeight, width: UIScreen.main.bounds.width/2, height:buttonHeight)
        self.infoTableView.setEditing(false, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       self.infoTableView.allowsMultipleSelection = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cellItem = tableView.dequeueReusableCell(withIdentifier: "CollectTableViewCell") as! CollectTableViewCell
            cellItem.accessoryType = .none
       
            return cellItem

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80.0
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        <#code#>
//    }

}
