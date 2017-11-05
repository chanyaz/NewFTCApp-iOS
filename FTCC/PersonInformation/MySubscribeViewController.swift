//
//  MySubscribeViewController.swift
//  FTCC
//
//  Created by huiyun.he on 05/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class MySubscribeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    let infoTableView = UITableView()
    let allSelect = UIButton()
    let delete = UIButton()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoTableView.frame = CGRect(x:0, y: 0, width: screenWidth, height: screenHeight)
        self.infoTableView.delegate = self
        self.infoTableView.dataSource = self
            
        self.infoTableView.register(UINib.init(nibName: "SubscribeTimeTableViewCell", bundle: nil), forCellReuseIdentifier: "SubscribeTimeTableViewCell")
        self.infoTableView.register(UINib.init(nibName: "PersonInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonInfoTableViewCell")
        
        self.infoTableView.separatorStyle = .none
 
        self.view.addSubview(infoTableView)
        print("viewDidLoad load?")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        self.infoTableView.delegate = nil
        self.infoTableView.dataSource = nil
    }
    @objc func allSelectAction(_ sender: UIButton){
       
    }
    @objc func deleteAction(_ sender: UIButton){
       
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 3

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0{

                if let collectInfoController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollectInfoController") as? CollectInfoController {
                    self.navigationController?.pushViewController(collectInfoController, animated: true)
                    print("collectInfoController load?")
                    
                }
            }else if indexPath.row == 1{
                
                
            }else if indexPath.row == 2{
                //                openHTMLInBundle("register", title: "注册", isFullScreen: false, hidesBottomBar: true)
                if let subscribeManageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubscribeManageViewController") as? SubscribeManageViewController {
                    navigationController?.pushViewController(subscribeManageViewController, animated: true)
                    
                }
            }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            if indexPath.row == 0{
                let cellItem = tableView.dequeueReusableCell(withIdentifier: "PersonInfoTableViewCell") as! PersonInfoTableViewCell
                cellItem.imageButton.setImage(UIImage(named:"MyDownload"), for: UIControlState.normal)
                cellItem.tagLabel.text = "我的下载"
                
                return cellItem
                
            }else if indexPath.row == 1{
                
                let cellItem = tableView.dequeueReusableCell(withIdentifier: "SubscribeTimeTableViewCell") as! SubscribeTimeTableViewCell
                
                return cellItem
            }else{
                
                let cellItem = tableView.dequeueReusableCell(withIdentifier: "PersonInfoTableViewCell") as! PersonInfoTableViewCell
                cellItem.imageButton.setImage(UIImage(named:"SubsribeManage"), for: UIControlState.normal)
                cellItem.tagLabel.text = "管理订阅"
                return cellItem
            }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 120.0

    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }


}
