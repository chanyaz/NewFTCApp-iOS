//
//  CustomContentItemViewController.swift
//  FTCC
//
//  Created by Oliver Zhang on 2017/10/30.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
class ContentItemViewController: SuperContentItemViewController, UITableViewDataSource, UITableViewDelegate {
    
    let infoLabel = UILabel()
    let infoTableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        if (ContentItemRenderContent.addPersonInfo == true){
            infoTableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            infoLabel.text = "nihao"
            self.infoTableView.delegate = self
            self.infoTableView.dataSource = self
            self.infoTableView.separatorStyle = .none
            self.infoTableView.isScrollEnabled = false
            self.infoTableView.register(UINib.init(nibName: "PersonInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonInfoTableViewCell")
            self.view.addSubview(infoTableView)
            ContentItemRenderContent.addPersonInfo = false
        }

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return 4
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section==1 && indexPath.row == 0{
            if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MySubscribeViewController") as? MySubscribeViewController {
                
                navigationController?.pushViewController(mySubscribeViewController, animated: true)
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        if indexPath.section == 0{
//            let cellItem = tableView.dequeueReusableCell(withIdentifier: "PortraitTableViewCell") as! PortraitTableViewCell
//            return cellItem
//
//        }else{
        
            let cellItem = tableView.dequeueReusableCell(withIdentifier: "PersonInfoTableViewCell") as! PersonInfoTableViewCell
//            let name = personInfo.infoMap[indexPath.row]["imageName"]
            print("personInfo value--")
//            cellItem.imageButton.setImage(UIImage(named:name as! String), for: UIControlState.normal)
//            cellItem.tagLabel.text = personInfo.infoMap[indexPath.row]["tagName"] as! String
            return cellItem
            
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 100.0
        }else{
            return 60.0
        }
    }


}
