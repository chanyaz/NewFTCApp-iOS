//
//  ViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/2.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics
//var globalTalkData = Array(repeating: CellData(), count: 1)
var keyboardWillShowExecute = 0
var showAnimateExecute = 0
class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{
    
    
      //MARK:属性初始化时不能直接使用其他属性
  
    var autoScrollWhenTalk = false
    var historyTalkData:[[String:String]]? = nil
    
    //MAKR: showingData用于存储展示数据中必要的数据，该数据会存储进Caches
    //MARK: showingCellData用于存储展示数据中所有Cell有关数据，该数据依赖shoingData生成
    var showingData:[[String:String]] = Array(repeating: ChatViewModel.buildTalkData(), count: 4)
    var showingCellData = [CellData]() {
        didSet {
            if(self.isTalkListFirstReloadData == false && self.isLoadHistoryDataAtTop == false ) {
                print("tableReloadData")
                self.talkListBlock.reloadData() //就是会执行tableView的函数，所以不能在tableView函数中再次执行reloadData,因为这样的话会陷入死循环
                print("showingCellDataNum:\(showingCellData.count)")
                let currentIndexPath = IndexPath(row: showingCellData.count-1, section: 0)
                self.talkListBlock.scrollToRow(at: currentIndexPath, at: .bottom, animated: true)
                print("scroll2")
            }
            
            
        }
    }
    var isTalkListFirstReloadData = true//用于标志tableView是否是第一次加载数据
    var isLoadHistoryDataAtTop = false
    //TODO:增加函数事件：当拉到tableView顶部时，再次从historyTalkData中加载10个数据
    //TODO:解决刚打开时，显示历史记录时不能scroll到最底部
    
    @IBOutlet weak var talkListBlock: UITableView!

    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var inputBlock: UITextField!
 
    @IBAction func touchInputBlock(_ sender: UITextField) {
        self.talkListBlock.isScrollEnabled = false;//MARK:这两就话可以瞬间停止UIScrollView的惯性滚动
        self.talkListBlock.isScrollEnabled = true;
        let currentIndexPath = IndexPath(row: self.showingCellData.count-1, section: 0)
        self.talkListBlock?.scrollToRow(at: currentIndexPath, at: .bottom, animated: false)
        self.inputBlock.resignFirstResponder()
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {//When tap
        self.talkListBlock.isScrollEnabled = false;
        self.talkListBlock.isScrollEnabled = true;
        let currentIndexPath = IndexPath(row: self.showingCellData.count-1, section: 0)
        self.talkListBlock?.scrollToRow(at: currentIndexPath, at: .bottom, animated: false)
        self.inputBlock.resignFirstResponder()

    }
 
    @IBOutlet var mySwipeGesture: UISwipeGestureRecognizer!
    @IBAction func dismissKeyboardWhenSwipe(_ sender: UISwipeGestureRecognizer) {//When swipe
        print("You are swipping")
        self.inputBlock.resignFirstResponder()
    }
    
   
    @IBOutlet var myPanGesture: UIPanGestureRecognizer!
     
    @IBAction func whatTodoWhenPan(_ sender: UIPanGestureRecognizer) {
        print("You are panning")
        self.inputBlock.resignFirstResponder()
        let scrollOffset = self.talkListBlock.contentOffset.y
        
        let oldContentSize = self.talkListBlock.contentSize
        var startLocation = CGPoint(x: 0, y: 0)
        var stopLocation = CGPoint(x: 0, y: 0)
        if sender.state == .began {
            startLocation = sender.location(in: self.view)
        } else if (sender.state == .ended) {
            stopLocation = sender.location(in: self.view)
        }
        let dy = stopLocation.y - startLocation.y
        print("Chat dy:\(dy)")
        print("Chat scrollOffSet:\(scrollOffset)")
        //MARK:位于顶部时再加载10条历史记录：
        if(scrollOffset < 0 && dy > 50){
            print("At the top now")
            var willAddHistoryData: [[String: String]]
            if let realHistoryTalkData = self.historyTalkData {
                let historyNum = realHistoryTalkData.count
                print("Chat historyNum:\(historyNum)")
                //MARK:只显示历史会话中最近的10条记录
                if historyNum > 0 {
                    if historyNum <= 10  {
                        willAddHistoryData = realHistoryTalkData
                        self.historyTalkData = []
                    } else {
                        willAddHistoryData = Array(realHistoryTalkData[historyNum-10...historyNum-1])
                        self.historyTalkData = Array(realHistoryTalkData[0...historyNum-11])
                    }
                    self.showingData.insert(contentsOf:willAddHistoryData,at:0)
                    print("Chat showingData Num:\(self.showingData.count)")
                    var willAddHistoryCellData = [CellData]()
                    for data in willAddHistoryData {
                        let oneCellData = ChatViewModel.buildCellData(data)
                        willAddHistoryCellData.append(oneCellData)
                    }
                    self.isLoadHistoryDataAtTop = true
                    self.showingCellData.insert(contentsOf:willAddHistoryCellData, at:0)
                    print("Chat showingCellData Num:\(self.showingCellData.count)")
                    
                    self.talkListBlock.reloadData()
                    let newContentSize = self.talkListBlock.contentSize
                    let afterContentOffset = self.talkListBlock.contentOffset
                    let newContentOffset = CGPoint(x: afterContentOffset.x, y: afterContentOffset.y + newContentSize.height - oldContentSize.height)
                    self.talkListBlock.contentOffset = newContentOffset
                    self.isLoadHistoryDataAtTop = false                    /*
                    let currentIndexPath = IndexPath(row: 10, section: 0)
                    self.talkListBlock.scrollToRow(at: currentIndexPath, at: .top, animated: false)
                    */
                    
                }
                
            }
        }
    }
    
    //MARK:Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.可以同时识别两种gesture recognizer
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
 
    //MARK:点击bottom bar 右部的“发送”按钮后发送用户输入的文字
    @IBAction func sendYourTalk(_ sender: UIButton) {
        if let currentYourTalk = inputBlock.text {
            let oneTalkData = [
                "member":"you",
                "type":"text",
                "content":currentYourTalk
            ]
            self.showingData.append(oneTalkData)
            let oneCellData = ChatViewModel.buildCellData(oneTalkData)
            self.showingCellData.append(oneCellData)
            self.inputBlock.text = ""
            self.createTalkRequest(myInputText:currentYourTalk, completion: { talkData in
                if let oneTalkData = talkData {
                    //print(robotRes)
                    self.showingData.append(oneTalkData)
                    let oneCellData = ChatViewModel.buildCellData(oneTalkData)
                    self.showingCellData.append(oneCellData)
                }
            })
        }
    }
    //MARK:点击键盘中Return按键后发生的事件，同上点击“Send"按钮后发生的事件
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let currentYourTalk = textField.text {
            let oneTalkData = [
                "member":"you",
                "type":"text",
                "content":currentYourTalk
            ]
            self.showingData.append(oneTalkData)
            self.inputBlock.text = ""
            let oneCellData = ChatViewModel.buildCellData(oneTalkData)
            self.showingCellData.append(oneCellData)
            self.createTalkRequest(myInputText:currentYourTalk, completion: { talkData in
                if let oneTalkData = talkData {
                    //print(robotRes)
                    self.showingData.append(oneTalkData)
                    let oneCellData = ChatViewModel.buildCellData(oneTalkData)
                    self.showingCellData.append(oneCellData)
                }
                
            })

        }
        return true
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        //MARK:键盘显示时滚动到talk list view滚动到底部
        let currentIndexPath = IndexPath(row: showingCellData.count-1, section: 0)
        self.talkListBlock.scrollToRow(at: currentIndexPath, at: .bottom, animated: true)
        
        print("show:\(keyboardWillShowExecute)")
        keyboardWillShowExecute += 1
        if let userInfo = notification.userInfo, let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt{
            let keyboardBounds = value.cgRectValue
            let keyboardFrame = self.view.convert(keyboardBounds, to: nil)
            
            
            //print(keyboardFrame.height)

            let deltaY = keyboardFrame.size.height
            
             //print("deltaY:\(deltaY)")
            let animation:(() -> Void) = {
                self.view.transform = CGAffineTransform(translationX: 0,y: -deltaY)
                self.view.setNeedsUpdateConstraints()
                self.view.setNeedsLayout()
                //print("showAnimate:\(showAnimateExecute)")
                showAnimateExecute += 1
                //print("self.view.frame:\(self.view.frame)")
            }

            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: UIViewAnimationOptions(rawValue: curve),
              
                animations:animation,
                completion:nil
                /*
                completion: { Void in
                    self.view.layoutIfNeeded()
                
                }
                 */
            )
             self.view.setNeedsLayout()
            //self.view.layoutIfNeeded()
            
            
        }
        
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("hide")
        if let userInfo = notification.userInfo, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt{
            let animation:(() -> Void)={
                self.view.transform = CGAffineTransform.identity
                self.view.setNeedsUpdateConstraints()
            }
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: UIViewAnimationOptions(rawValue: curve),
                animations:animation,
                completion: nil
            )
             self.view.setNeedsLayout()
        }
        
    }
    
    
    @objc func applicationWillResignActive(_ notification:NSNotification){
        //MARK:在该controller为inactive状态时（比如点击了Home键),将键盘置于收缩状态
        self.inputBlock.resignFirstResponder()
        print("applicationWillResignActive")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingCellData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentRow = indexPath.row
        //let cellData = ChatViewModel.buildCellData(self.showingData[currentRow])
        let cellData = self.showingCellData[currentRow]
        let cell = OneTalkCell(cellData, reuseId:"Talk")
        /*
        if (cellData.saysWhat.type == .card) {
            self.asyncBuildImage(url: cellData.saysWhat.coverUrl, completion: { downloadedImg in
                if let realImage = downloadedImg {
                    //cellData.downLoadImage = realImage
                    cell.coverView.image = realImage
                  
                }
            })
        } else if (cellData.saysWhat.type == .image) {
            self.asyncBuildImage(url: cellData.saysWhat.url, completion: {
                downloadedImg in
                
                if let realImage = downloadedImg { //如果成功获取了图片
                    cell.saysImageView.image = realImage
                    
                }
            })
        }
         */
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentRow = indexPath.row
        //let cellData = ChatViewModel.buildCellData(self.showingData[currentRow])
        let cellData = self.showingCellData[currentRow]
        if cellData.isHistoryCutline {
            return cellData.cutlineCellHeight
        }else {
            return max(cellData.cellHeightByHeadImage, cellData.cellHeightByBubble)
        }
    }
    
    
   
        
   func createTalkRequest(myInputText inputText:String = "", completion: @escaping (_ talkData:[String:String]?) -> Void) {
        let bodyString = "{\"query\":\"\(inputText)\",\"messageType\":\"text\"}"
    
    
        let appIdField = "x-msxiaoice-request-app-id"
    
        //小冰正式服务器
        /*
        let urlString = "https://service.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15"
        let appId = "XIeQemRXxREgGsyPki"
        let secret = "4b3f82a71fb54cbe9e4c8f125998c787"
        */
        //小冰测试服务器
        let urlString = "https://sai-pilot.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15-Int"
        let appId = "XI36GDstzRkCzD18Fh"
        let secret = "5c3c48acd5434663897109d18a2f62c5"
 
    
        let timestampField = "x-msxiaoice-request-timestamp"
        let timestamp = Int(Date().timeIntervalSince1970)//生成时间戳
        
        let userIdField = "x-msxiaoice-request-user-id"
        let userId = "e10adc3949ba59abbe56e057f20f883e"
        
        let signatureField = "x-msxiaoice-request-signature"

        let signature = ChatViewModel.computeSignature(verb: "post", path: "/api/Conversation/GetResponse", paramList: ["api-version=2017-06-15-Int"], headerList: ["\(appIdField):\(appId)","\(userIdField):\(userId)"], body: bodyString, timestamp: timestamp, secretKey: secret)
        print("signature:\(signature)")
        
        if let url = URL(string: urlString),
            let body = bodyString.data(using: .utf8)// 将String转化为Data
        {
            var talkRequest = URLRequest(url:url)
            talkRequest.httpMethod = "POST"
            talkRequest.httpBody = body
            talkRequest.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            talkRequest.setValue(appId, forHTTPHeaderField: appIdField)
            talkRequest.setValue(String(timestamp), forHTTPHeaderField: timestampField)
            talkRequest.setValue(signature, forHTTPHeaderField: signatureField)
            talkRequest.setValue(userId, forHTTPHeaderField: userIdField)
      
            (URLSession.shared.dataTask(with: talkRequest) {
                (data,response,error) in

                if error != nil {
                    print("Error: \(String(describing: error))")
                    DispatchQueue.main.async {//返回主线程更新UI
                        completion(nil)
                    }
                    return
                   
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //explainRobotTalk = "Status code is not 200. It is \(httpStatus.statusCode)"
                    print("statusCode:\(httpStatus)")
                    DispatchQueue.main.async {//返回主线程更新UI
                        completion(nil)
                    }
                    return
                    
                }
                
                if let data = data, let dataString = String(data: data, encoding: .utf8){
                    print("Overview Data:\(dataString)")
                    //explainRobotTalk = dataString
                    let talkData:[String:String]?
                    talkData = ChatViewModel.createResponseTalkData(data: data)
                   // createResponseCellData(data: Data)
                    
                    DispatchQueue.main.async {//返回主线程更新UI
                        completion(talkData)
                    }
                    
                }

                
                
            }).resume()
            
        }
    }
    
    
    //MARK:第一次加载时要延迟若干毫秒再滚动到底部，否则如果self.talkListBlock.contentSize.height > self.talkListBlock.frame.size.height，就没法滚动到底部
    func tableViewScrollToBottom(animated:Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let numberOfRows = self.talkListBlock.numberOfRows(inSection: 0)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: 0)
                self.talkListBlock.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                print("scroll1")
            }
        }
    }
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chat Execute viewDidLoad")
        // Do any additional setup after loading the view.
        
        //MARK:监听键盘弹出、收起事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //MARK:监听是否点击Home键以及重新进入界面
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        //MARK:
        self.talkListBlock.delegate = self
        self.talkListBlock.dataSource = self // MARK:两个协议代理，一个也不能少
        self.inputBlock.delegate = self
        self.mySwipeGesture.delegate = self
        self.myPanGesture.delegate = self
        //elf.myPanGesture.require(toFail: self.talkListBlock.panGestureRecognizer)

        
        self.talkListBlock.backgroundColor = UIColor(hex: "#fff1e0")
        self.talkListBlock.separatorStyle = .none //MARK:删除cell之间的分割线
        
        self.bottomBar.backgroundColor = UIColor(hex: "#f7e9d8")
        
        // MARK：为bottomToolbar添加上边框
        let border = CALayer()
        border.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:1)
        border.zPosition = 999.0
        border.backgroundColor = UIColor(hex: "#dddddd").cgColor
        self.bottomBar.layer.addSublayer(border)
        
        self.inputBlock.keyboardType = .default//指定键盘类型，也可以是.numberPad（数字键盘）
        self.inputBlock.keyboardAppearance = .light//指定键盘外观.dark/.default/.light/.alert
        self.inputBlock.returnKeyType = .send//指定Return键上显示
        
        do {
            if let savedTalkData = Download.readFile("chatHistoryTalk", for: .cachesDirectory, as: "json") {
                let jsonAny = try JSONSerialization.jsonObject(with: savedTalkData, options: .mutableContainers)
                if let jsonDic = jsonAny as? NSArray, let historyTalk = jsonDic as? [[String:String]] {
                    self.historyTalkData = historyTalk
                    print("historyTalkDataNum:\(self.historyTalkData?.count ?? 0)")
                }
            }
        } catch {
            
        }
        if let realHistoryTalkData = self.historyTalkData {
            let historyNum = realHistoryTalkData.count
            print("Chat historyNum:\(historyNum)")
            //MARK:只显示历史会话中最近的10条记录
            if historyNum > 0 {
                if historyNum <= 10  {
                   self.showingData = realHistoryTalkData
                   self.historyTalkData = []
                } else {
                   self.showingData = Array(realHistoryTalkData[historyNum-10...historyNum-1])
                   self.historyTalkData = Array(realHistoryTalkData[0...historyNum-11])
                }
            }//否则self.showingData不变, self.historyTalkData不变
            
        }
        print("Chat showingData Num:\(self.showingData.count)")
        var initShowingCellData = [CellData]()
        for data in self.showingData {
            let oneCellData = ChatViewModel.buildCellData(data)
            initShowingCellData.append(oneCellData)
        }
        initShowingCellData.append(CellData(cutline:true)) //此时不涉及showingData的问题，showingData是为了存储的数据，而历史记录数据不用存储
        self.showingCellData = initShowingCellData
        print("Chat showingCellData Num:\(self.showingCellData.count)")
        self.talkListBlock.reloadData()
        self.isTalkListFirstReloadData = false
        self.tableViewScrollToBottom(animated: false)
        
        
        self.createTalkRequest(myInputText:ChatViewModel.triggerGreetContent, completion: { talkData in
            if let oneTalkData = talkData {
                //print(robotRes)
                self.showingData.append(oneTalkData)
                let oneCellData = ChatViewModel.buildCellData(oneTalkData)
                self.showingCellData.append(oneCellData)
                
                
                self.createTalkRequest(myInputText:ChatViewModel.triggerNewsContent, completion: { contentTalkData in
                    if let realContentTalkData = contentTalkData {
                        //print(robotRes)
                        self.showingData.append(realContentTalkData)
                        let oneContentCellData = ChatViewModel.buildCellData(realContentTalkData)
                        self.showingCellData.append(oneContentCellData)
                    }
                })
            }
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        /*
        if(self.talkListBlock.contentSize.height > self.talkListBlock.frame.size.height) {
            print("here")
            print("talkListBlock.contentSize.height:\(self.talkListBlock.contentSize.height)")
            print("talkListBlock.frame.size.height:\(self.talkListBlock.frame.size.height)")
            let offset = CGPoint(x: 0, y: self.talkListBlock.contentSize.height-self.talkListBlock.frame.size.height)
            self.talkListBlock.setContentOffset(offset, animated: false)
        }
         */

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        print("viewWillDisappear")
        do {
            print("do")
            var toSaveHistoryTalkArr:[[String: String]]
            var toSaveTalkData:Data
            var newHistoryTalkData:[[String: String]]
            
            if let realHistoryTalkData = self.historyTalkData {
               newHistoryTalkData = realHistoryTalkData + self.showingData //要存储的是这个
                //print("newHistoryTalkData:\(newHistoryTalkData)")
            } else {
               newHistoryTalkData = self.showingData
            }
            
            let newHistoryNum = newHistoryTalkData.count
            print("newHistoryNum:\(newHistoryNum)")
            //MARK:只存储最近的100条对话记录 // TODO:增加手指下拉动作监测，拉一次多展现10条历史对话记录
            if newHistoryNum > 0 {
                if newHistoryNum <= 100  {
                    toSaveHistoryTalkArr = newHistoryTalkData
                    print("case 1:\(toSaveHistoryTalkArr.count)")
                    
                } else {
                    toSaveHistoryTalkArr = Array(newHistoryTalkData[newHistoryNum-100...newHistoryNum-1])
                    print("case 2:\(toSaveHistoryTalkArr.count)")
                }

                toSaveTalkData = try JSONSerialization.data(withJSONObject: toSaveHistoryTalkArr, options:.prettyPrinted)
                print("toSaveTalkDataNum:\(toSaveTalkData.count)")
                Download.saveFile(toSaveTalkData, filename: "chatHistoryTalk", to:.cachesDirectory , as: "json")
            }
    
        } catch {
            
        }
   }
  
    deinit {
        NotificationCenter.default.removeObserver(self)
        print ("Chat View Controller deinit successfully")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
