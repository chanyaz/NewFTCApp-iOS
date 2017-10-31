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
            if let navigationHeight = self.navigationController?.navigationBar.frame.size.height{
                infoTableView.frame = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            self.infoTableView.delegate = self
            self.infoTableView.dataSource = self
            self.infoTableView.separatorStyle = .none
            self.infoTableView.isScrollEnabled = false
            self.infoTableView.register(UINib.init(nibName: "PersonInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonInfoTableViewCell")
            self.infoTableView.register(UINib.init(nibName: "PortraitTableViewCell", bundle: nil), forCellReuseIdentifier: "PortraitTableViewCell")
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
        if indexPath.section==1{
            if indexPath.row == 0{
                openHTMLInBundle("person-information", title: "注册", isFullScreen: false, hidesBottomBar: true)
            }else if indexPath.row == 1{
                openHTMLInBundle("register", title: "注册", isFullScreen: false, hidesBottomBar: true)
            }else if indexPath.row == 2{
                openHTMLInBundle("register", title: "注册", isFullScreen: false, hidesBottomBar: true)
            }else if indexPath.row == 3{
                if let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
                    let topController = UIApplication.topViewController() {
                    
                    settingsController.dataObject = [
                        "type": "setting",
                        "id": "setting",
                        "compactLayout": "",
                        "title": "设置"
                    ]
                    settingsController.pageTitle = "设置"
                    topController.navigationController?.pushViewController(settingsController, animated: true)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0{
            let cellItem = tableView.dequeueReusableCell(withIdentifier: "PortraitTableViewCell") as! PortraitTableViewCell
            cellItem.loginButton.addTarget(self, action: #selector(openAccount), for: .touchUpInside)
            return cellItem

        }else{
        
            let cellItem = tableView.dequeueReusableCell(withIdentifier: "PersonInfoTableViewCell") as! PersonInfoTableViewCell
            if let name = personInfo.infoMap[indexPath.row]["imageName"],let textValue = personInfo.infoMap[indexPath.row]["tagName"]{

                cellItem.imageButton.setImage(UIImage(named:name ), for: UIControlState.normal)
                cellItem.tagLabel.text = textValue
            
            }
            return cellItem
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 150.0
        }else{
            return 80.0
        }
    }
    @objc func openAccount(){
        openHTMLInBundle("account", title: "注册", isFullScreen: false, hidesBottomBar: true)
    }

}
