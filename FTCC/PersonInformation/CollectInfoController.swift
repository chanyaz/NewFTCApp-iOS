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
    fileprivate let contentAPI = ContentFetch()
    //    var selectCellArray:[NSIndexPath] = []
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
    var cellContent = [String:Any]()
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
        
        if ContentInfoRenderContent.isDownloadedList == true{
            
        
        //       Mark:Get the downloaded data here，Cycle to add，获取本地数据
            if let subFilesName = Download.readSubFilesInDirectory(directoryName: audioDirectoryName, for: .cachesDirectory, as: nil){
                for subFileName in subFilesName {
                    //应该添加循环读取数据，返回一个Data数组，对数组进行处理，按照图片的时间进行处理
                    let subFilesNameWithoutExtension = (subFileName.components(separatedBy: "."))[0]
                    //                let subFilesExtension = (subFileName.components(separatedBy: "."))[1]
                    if let downloadedData = Download.readFileDataWithTime(subFilesNameWithoutExtension, directoryName: audioDirectoryName, for: .cachesDirectory, as: "jpg"),let readIndexData = Download.readFileData(subFilesNameWithoutExtension + "-index", directoryName: audioDirectoryName, for: .cachesDirectory, as: nil),let readTagData = Download.readFileData(subFilesNameWithoutExtension + "-tag", directoryName: audioDirectoryName, for: .cachesDirectory, as: nil){
                        let time = downloadedData["time"] as? Double
                        let data = downloadedData["data"] as! Data
                        let downloadedParsedData = UIImage(data: data)
                        cellContent["headline"] = subFilesNameWithoutExtension
                        cellContent["img"] = downloadedParsedData
                        cellContent["time"] = time
                        
                        print("subDirectry Files Name--\(String(describing:  subFileName))--cellContent:---\(cellContent)")
                        let readIndexDataAsString = String(data: readIndexData,encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                        cellContent["index"] = readIndexDataAsString
                        let readTagDataAsString = String(data: readTagData,encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                        cellContent["tag"] = readTagDataAsString
                        allCellDatas.add(cellContent as Any)
                    }
                    
                }
                
                
            }
            dataArray = allCellDatas.mutableCopy() as! NSMutableArray
        }else{
            dataArray = allCellContent.mutableCopy() as! NSMutableArray
        }
        
                print("download dataArray--\( dataArray)")
        
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
    var isAllSelect:Bool = false
    @IBAction func allSelectAction(_ sender: UIButton){
        isAllSelect = true
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
            
            if isAllSelect{
                Download.removeDirectory(directoryName: audioDirectoryName, for: .cachesDirectory)
            }else{
                print("selectArray pathUrl is：\(selectArray)")
                for oneSelectArray in indexArr {
                    let oneSelectArray = oneSelectArray as! NSDictionary
                    let pathUrl = oneSelectArray["headline"] as! String
                    Download.removeFileAccordingToFilePrefixName(pathUrl, directoryName: audioDirectoryName, for: .cachesDirectory)
                    Download.removeFileAccordingToFileName(pathUrl+"[index]", directoryName: audioDirectoryName, for: .cachesDirectory, as: nil)
                    
                }
                
            }
            
            
            
            
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
        isAllSelect = false
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
                // TODO:还需要去做实现读取tag链接，需要保存tag，对本地文件进行比较，看怎么读取的呢？有2中情况，第1种为获取首页，第2种为获取各种专栏页面，获取的链接形式不一样，最好用tagAPI函数读取urlString名
                print("您点击了第\(indexPath.row + 1)个cell")
                let data = dataArray[indexPath.row]  as! NSDictionary
                if let index = data["index"] as? String{
                    if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
                        var pageData = [ContentItem]()
                        
                        let urlString = "indexphp-jsapi-publish-ftcc"
                        if let data = Download.readFile(urlString, for: .cachesDirectory, as: "json") {
                            //print ("found \(urlString) in caches directory. ")
                            if let resultsDictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
                                let contentSections = contentAPI.formatJSON(resultsDictionary)
                                let results = ContentFetchResults(apiUrl: urlString, fetchResults: contentSections)
                                print ("read results from local file\(results)")
                                
                                if let index = Int(index){
                                    let fetchResults = results.fetchResults
                                    print("currentPageIndex is:--\(index)---fetchResults is:\(fetchResults)")
                                    for (_, section) in (fetchResults.enumerated()) {
                                        for (_, item) in section.items.enumerated() {
                                            if ["story"].contains(item.type) {
                                                pageData.append(item)
                                            }
                                        }
                                    }
                                    pageData[index].isLandingPage = true
                                    detailViewController.contentPageData = pageData
                                    detailViewController.currentPageIndex = index
                                    navigationController?.pushViewController(detailViewController, animated: true)
                                }
                                //print ("update UI from local file with \(urlString)")
                            }
                        }
//                        var tag = data["tag"]
//                        let tagAPI = APIs.get(tag, type: "tag")
//
//                        detailViewController.pageData =  ["title": tag,
//                                                         "api": tagAPI,
//                                                         "url":"",
//                                                         "screenName":"tag/\(tag)"]
                        
                        
                    }
                }
                
                
            }
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectTableViewCell") as! CollectTableViewCell
        let dictionaryData = dataArray[indexPath.row]  as! NSDictionary
        cell.selectedLabel.text = dictionaryData["headline"] as? String
        cell.selectedImageView.image = dictionaryData["img"] as? UIImage
        cell.accessoryType = .none
        cell.isEditting = self.isEditting
        if self.selectArray.contains(indexPath){
            cell.isSelected = true
        }else{
            cell.isSelected = false
        }
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


