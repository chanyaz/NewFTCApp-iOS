//
//  MyDownloadViewController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CollectInfoController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var selectCellArray:[NSIndexPath] = []
    var dataArray:NSMutableArray = []
    var selectArray:NSMutableArray = []
//    var selectArray = NSMutableArray() as? [NSIndexPath]
    var isEditting :Bool=false
    let infoTableView = UITableView()
    let allSelect = UIButton()
    let delete = UIButton()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let toolbarHeight: CGFloat = 55
    let buttonHeight: CGFloat = 55
    let leftMoveDistance: CGFloat = 45
    let cellContent: NSArray = ["谁能预测未来样子1", "谁能预测未来样子2", "谁能预测未来样子3","随谁能预测未来样子4","谁能预测未来样子5"]
    override func viewDidLoad() {
        super.viewDidLoad()
        if ContentItemRenderContent.isMySubscribe == false{
            self.allSelect.frame = CGRect(x: 0, y: -buttonHeight, width: screenWidth/2, height:90)
            self.allSelect.setTitle("全选", for: .normal)
            self.allSelect.setTitleColor(UIColor.black, for: .normal)
            self.view.addSubview(allSelect)
            allSelect.addTarget(self, action: #selector(allSelectAction), for: .touchUpInside)
            allSelect.layer.addBorder(edge: .right, color: UIColor(hex: Color.AudioList.border, alpha: 0.6), thickness: 0.5)
            self.delete.frame = CGRect(x: screenWidth/2, y: -buttonHeight, width: screenWidth/2, height:90)
            self.delete.setTitle("删除", for: .normal)
            //        self.delete.backgroundColor = UIColor.blue
            self.delete.setTitleColor(UIColor.black, for: .normal)
            self.view.addSubview(delete)
            delete.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
            self.infoTableView.frame = CGRect(x:0, y: 0, width: screenWidth, height: screenHeight)
            self.infoTableView.delegate = self
            self.infoTableView.dataSource = self
            self.infoTableView.register(UINib.init(nibName: "CollectTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectTableViewCell")
            self.view.addSubview(infoTableView)
            let editButton = UIButton()
            editButton.frame = CGRect(x: 0, y: 0, width: 45, height: 2)
            editButton.backgroundColor = UIColor.white
            editButton.setTitle("编辑", for: .normal)
            editButton.setTitle("取消", for: .selected)
            //        editButton.tintColor = UIColor.black
            editButton.setTitleColor(UIColor.black, for: .normal)
            editButton.titleLabel?.textColor = UIColor.black
            let audioButton = UIBarButtonItem(customView: editButton)
            
            //        let audioButton = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(edit))
            self.navigationItem.rightBarButtonItem = audioButton
            editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
            self.infoTableView.allowsMultipleSelection = true
            self.infoTableView.allowsSelectionDuringEditing = true
            print("dateArray--\(self.selectCellArray)")
            self.navigationController?.toolbar.isHidden = true
            self.navigationController?.toolbar.barStyle = .black
            self.navigationController?.toolbar.barTintColor = UIColor.white
            self.navigationController?.toolbar.frame = CGRect(x: 0, y: screenHeight-toolbarHeight, width: screenWidth, height: toolbarHeight)
            self.navigationController?.toolbar.layer.addBorder(edge: .top, color: UIColor(hex: Color.AudioList.border, alpha: 0.6), thickness: 0.5)
            let allSelectButton = UIBarButtonItem(customView: allSelect)
            let deleteButton = UIBarButtonItem(customView: delete)
            let toolArray = [allSelectButton,deleteButton]
            self.toolbarItems = toolArray
            self.view.backgroundColor = UIColor.white
            //        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            
            dataArray = cellContent.mutableCopy() as! NSMutableArray
        }else{
            ContentItemRenderContent.isMySubscribe = false
            self.infoTableView.register(UINib.init(nibName: "SubscribeTimeTableViewCell", bundle: nil), forCellReuseIdentifier: "SubscribeTimeTableViewCell")
            self.infoTableView.register(UINib.init(nibName: "PersonInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonInfoTableViewCell")
            self.view.addSubview(infoTableView)
        }

    }
    deinit {
//        self.navigationController?.toolbar.isHidden = true
    }
    @objc func allSelectAction(_ sender: UIButton){
        self.selectArray.removeAllObjects()
        self.infoTableView.beginUpdates()
        let visibleCells = self.infoTableView.visibleCells
        for cell in visibleCells {
            let cell = cell as! CollectTableViewCell
            cell.isSelected = !sender.isSelected
            if cell.isSelected{
                cell.selectedButton.setImage(UIImage(named:"LoveListActive"), for: UIControlState.normal)
            }else{
                 cell.selectedButton.setImage(UIImage(named:"LoveList"), for: UIControlState.normal)
            }
            
        }
        if (sender.isSelected == false) { //全选
            for i in 0 ..< self.dataArray.count {
             let indexPath =  NSIndexPath(row: i, section: 0)
                self.selectArray.add(indexPath)
            }
        }else{
            self.selectArray.removeAllObjects()
        }
        sender.isSelected = !sender.isSelected
        self.infoTableView.endUpdates()
        print("dataArray allselect --\(dataArray) --  selectCellArray --\(selectArray)")
    }
    @objc func deleteAction(_ sender: UIButton){
        if self.infoTableView.isEditing{
            self.infoTableView.beginUpdates()
            let indexArr = NSMutableArray() //镜像数组,存放需删除的数据源
            var indexPathToDelete:[IndexPath] = []
            for indexPath in self.selectArray {
                let indexPath = indexPath as! IndexPath
                indexArr.add(self.dataArray[indexPath.row])
                indexPathToDelete.append(indexPath)
            }


            print("dataArray --\(dataArray) -- indexArr000000 --\(indexArr) -- selectArray00000 --\(selectArray)")
           
            indexArr.enumerateObjects { (obj, idx, true) in
                if self.dataArray.contains(obj){
                    self.dataArray.remove(obj)
                }
            }

            self.infoTableView.deleteRows(at: indexPathToDelete, with: UITableViewRowAnimation.none)
            self.selectArray.removeAllObjects()  //需要清空对象，不然没删除完全。
            self.infoTableView.endUpdates()
            print("dataArray --\(dataArray) -- indexArr11111 --\(indexArr) -- selectArray11111 --\(selectArray)")
            
        }
    }
    @objc func edit(_ sender: UIButton){
//        self.selectCellArray.removeAll()
        self.selectArray.removeAllObjects()
        if !sender.isSelected{
            self.isEditting = true
//            self.infoTableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            self.infoTableView.setEditing(true, animated: true)
            self.navigationController?.toolbar.isHidden = false
        }else{
            self.isEditting = false
            self.infoTableView.setEditing(false, animated: true)
            self.navigationController?.toolbar.isHidden = true
        }
        self.infoTableView.beginUpdates()

        let visibleCells = self.infoTableView.visibleCells

        for cell in visibleCells {
            let cell = cell as! CollectTableViewCell
            cell.isEditting = self.isEditting
            cell.isSelected = !sender.isSelected
        }
        sender.isSelected = !sender.isSelected
        self.infoTableView.endUpdates()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ContentItemRenderContent.isMySubscribe == false{
            let cell = tableView.cellForRow(at: indexPath) as! CollectTableViewCell
            if (self.isEditting) {  //若为编辑模式
                if !(self.selectArray.contains(indexPath)) {
                    cell.isSelected = true
                    self.selectArray.add(indexPath)
                    cell.selectedButton.setImage(UIImage(named:"LoveListActive"), for: UIControlState.normal)
                }else{
                    cell.isSelected = false
                    self.selectArray.remove(indexPath)
                    cell.selectedButton.setImage(UIImage(named:"LoveList"), for: UIControlState.normal)
                }
            }else{
                print("您点击了第\(indexPath.row + 1)个cell")
            }
        }else{
            if indexPath.row == 0{
                openHTMLInBundle("person-information", title: "注册", isFullScreen: false, hidesBottomBar: true)
                ContentItemRenderContent.isMySubscribe = true
            }else if indexPath.row == 1{
                if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollectInfoController") as? CollectInfoController {
                    navigationController?.pushViewController(chatViewController, animated: true)
                    
                }
            }else if indexPath.row == 2{
                openHTMLInBundle("register", title: "注册", isFullScreen: false, hidesBottomBar: true)
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ContentItemRenderContent.isMySubscribe == false{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectTableViewCell") as! CollectTableViewCell
            cell.selectedLabel.text = dataArray[indexPath.row] as? String
            cell.accessoryType = .none
            cell.isEditting = self.isEditting
            if self.selectArray.contains(indexPath){
                cell.isSelected = true
            }else{
                cell.isSelected = false
            }
            return cell
        }else{
            if indexPath.row == 1{
                let cellItem = tableView.dequeueReusableCell(withIdentifier: "PortraitTableViewCell") as! PortraitTableViewCell
                
                return cellItem
                
            }else{
                
                let cellItem = tableView.dequeueReusableCell(withIdentifier: "PersonInfoTableViewCell") as! PersonInfoTableViewCell

                return cellItem
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80.0
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
//            // delete item at indexPath
//        }
//        delete.backgroundColor = UIColor.blue
//
//        return [delete]
//    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//            self.dataArray.remove(self.dataArray[indexPath.row])
//            self.infoTableView.beginUpdates()
//            self.infoTableView.deselectRow(at: indexPath, animated: true)
//            self.infoTableView.endUpdates()
//        print("tableView \(dataArray)")
//    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        
//    }

}
