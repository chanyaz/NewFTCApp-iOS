//
//  MyDownloadViewController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CollectInfoController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    private let download = RemoteDownloadHelper(directory: "audio")
    private var audioDirectoryName = "audioDirectory"
    var selectCellArray:[NSIndexPath] = []
    var dataArray:NSMutableArray = []
    var selectArray:NSMutableArray = []
    
    var allDataArray:NSMutableArray = []
    //    var selectArray = NSMutableArray() as? [NSIndexPath]
    var isRepeatOpenMyDownload:Bool=false
    var isEditting :Bool=false
//    let infoTableView = UITableView()
    let allSelect = UIButton()
    let delete = UIButton()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.size.height
    var toolbarHeight: CGFloat = 55
    let buttonHeight: CGFloat = 55
    let leftMoveDistance: CGFloat = 45
    let cellContent: NSArray = ["谁能预测未来样子1", "谁能预测未来样子2", "谁能预测未来样子3","随谁能预测未来样子4","谁能预测未来样子5"]
    let allCellContent:NSMutableArray = [["headline":"谁能预测未来样子1","image":"1111"],
                                  [
                                    "headline":"谁能预测未来样子2","image":"2222"
        ],[
            "headline":"谁能预测未来样子3","image":"3333"
        ]]
    let allCellDatas:NSMutableArray = []

    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var allSelectBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.infoTableView.frame = CGRect(x:0, y: 0, width: screenWidth, height: screenHeight-172)
        self.infoTableView.delegate = self
        self.infoTableView.dataSource = self
        
        print("\(view.layoutMargins.bottom)")
//        toolbarHeight = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 89, OtherIphoneValue: 55)

//        self.allSelectBtn.backgroundColor = UIColor.red
        self.allSelectBtn.setTitleColor(UIColor.black, for: .normal)
        self.deleteBtn.setTitleColor(UIColor.black, for: .normal)
        allSelectBtn.layer.addBorder(edge: .right, color: UIColor(hex: Color.AudioList.border, alpha: 0.6), thickness: 0.5)
        toolBar.layer.addBorder(edge: .top, color: UIColor(hex: Color.AudioList.border, alpha: 1), thickness: 0.5)
        toolBar.layer.addBorder(edge: .bottom, color: UIColor(hex: Color.AudioList.border, alpha: 1), thickness: 0.5)
        
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
        self.navigationItem.rightBarButtonItem = audioButton
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
        self.infoTableView.allowsMultipleSelection = true
        self.infoTableView.allowsSelectionDuringEditing = true
        print("dateArray--\(self.selectCellArray)")

        //       Mark:Get the downloaded data here，Cycle to add，获取本地数据
        do {
            if let subFilesName = Download.readSubFilesInDirector(directoryName: audioDirectoryName, for: .cachesDirectory, as: nil){
                for subFileName in subFilesName {
                    print(" subDirectry Files Name--\( subFileName )")
                    //            应该添加循环读取数据，返回一个Data数组，对数组进行处理，按照图片的时间进行处理
                    if let downloadedData = Download.readFileData(subFileName, directoryName: audioDirectoryName, for: .cachesDirectory, as: nil){
                        let downloadedJsonData = String(data: downloadedData,encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                        print("download downloadedData--\( downloadedData)")
//                        let downloadedJsonData = try JSONSerialization.jsonObject(with: downloadedData, options: .mutableContainers) as! [String : Any]
//                        for index in downloadedJsonData{
//                            print("download json item--\( index)")
                            //             index 是输出(key: "headline", value: 追随内心，还是追随大数据？)此格式key-value数据
//                        }
                        
                        allCellDatas.add(downloadedJsonData as Any)

//                        print("download bodyData1--\( downloadedJsonData)---bodyData：\(allCellDatas)")
                    }
                }
            }
            
            

        }
//        catch {
//
//        }
        
//        dataArray = cellContent.mutableCopy() as! NSMutableArray
        
        dataArray = allCellDatas.mutableCopy() as! NSMutableArray

        
        self.view.backgroundColor = UIColor.white
        let image = UIImage(named: "NavBack")
        let backImage = image?.imageWithImage(image: image!, scaledToSize: CGSize(width: 12, height: 22))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backNavigation))

        
        toolBar.layer.zPosition = 100000
        toolBar.isUserInteractionEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        hideView()
    }
    override func viewDidDisappear(_ animated: Bool) {

    }
    @objc func backNavigation(){
        print("collectInfoController dismiss")
//        self.navigationController?.toolbar.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    deinit {
        print("collectInfoController deinit")
        self.infoTableView.delegate = nil
        self.infoTableView.dataSource = nil
    }
    @IBAction func allSelectAction(_ sender: UIButton){
        print("allSelectAction execute")
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
        removeAllAudios()
    }
    func removeAllAudios() {
        Download.removeFiles(["mp3"])
    }
    @IBAction func deleteAction(_ sender: UIButton){
        print("deleteAction execute")
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
            self.infoTableView.setEditing(true, animated: true)
//            self.toolBar.isHidden = false
            showView()
            tableViewBottomConstraint.constant = 0
//            self.navigationController?.toolbar.isHidden = false
        }else{
            self.isEditting = false
            self.infoTableView.setEditing(false, animated: true)
//            self.navigationController?.toolbar.isHidden = true
//            self.toolBar.isHidden = true
            hideView()
            tableViewBottomConstraint.constant = -50
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
    func hideView(){
            print("up hide audio")
            if  let toolBar = toolBar{
                let deltaY = toolBar.bounds.height + 50
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    toolBar.transform = CGAffineTransform(translationX: 0,y: deltaY)
                    toolBar.setNeedsUpdateConstraints()
                }, completion: { (true) in
                    
                })
            }
    }
    func showView(){
        print("down show audio")
        if  let toolBar = toolBar{
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                toolBar.transform = CGAffineTransform.identity
                toolBar.setNeedsUpdateConstraints()
            }, completion: { (true) in
                
            })
        }
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
        
        
        if let cell = tableView.cellForRow(at: indexPath) as? CollectTableViewCell{
            
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
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectTableViewCell") as! CollectTableViewCell
//        cell.selectedLabel.text = dataArray[indexPath.row] as? String
       let dictionaryData = dataArray[indexPath.row] as! NSDictionary
        cell.selectedLabel.text = dictionaryData["headline"] as? String
        let aa = dictionaryData["image"] as? String
        let bb = aa?.components(separatedBy: ".")
        print("aa---\(bb![0])--\(bb![1])")
        cell.selectedImageView.image = UIImage(named: bb![0])

        

        
        cell.accessoryType = .none
        cell.isEditting = self.isEditting
        if self.selectArray.contains(indexPath){
            cell.isSelected = true
        }else{
            cell.isSelected = false
        }
//        if let results = TabBarAudioContent.sharedInstance.fetchResults{
//            print("test detailImage\(results[0].items[0].coverImage)")
//            cell.selectedImageView.image = results[0].items[0].coverImage
            
//        }
        
        return cell
        
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

    
}


