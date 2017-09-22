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
class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource {
    
    
    // 一些实验数据
      //MARK:属性初始化时不能直接使用其他属性
    //let textCellData = CellData(whoSays: .robot, saysWhat:SaysWhat(saysType: .text, saysContent: "你好！我是微软小冰。\n- 想和我聊天？\n随便输入你想说的话吧，比如'我喜欢你'、'你吃饭了吗？'\n- 想看精美图片？\n试试输入'xx图片'，比如'玫瑰花图片'、'小狗图片'\n- 想看图文新闻？\n试试输入'新闻'、'热点新闻'"))
   
    /*
    var historyTalkData:[[String:String]] = Array(repeating: ChatViewModel.buildTalkData(), count: 4) {
        didSet {
            print("tableReloadData")
            self.talkListBlock.reloadData() //就是会执行tableView的函数，所以不能在tableView函数中再次执行reloadData,因为这样的话会陷入死循环
            let currentIndexPath = IndexPath(row: historyTalkData.count-1, section: 0)
            self.talkListBlock?.scrollToRow(at: currentIndexPath, at: .bottom, animated: true)
        }
    }
    */
    var autoScrollWhenTalk = false
    var historyTalkData:[[String:String]]? = nil
    var showingData:[[String:String]] = Array(repeating: ChatViewModel.buildTalkData(), count: 4) { //NOTE:只有get 可以省略get
        didSet {
            print("tableReloadData")
            self.talkListBlock.reloadData() //就是会执行tableView的函数，所以不能在tableView函数中再次执行reloadData,因为这样的话会陷入死循环
            let currentIndexPath = IndexPath(row: showingData.count-1, section: 0)
            self.autoScrollWhenTalk=true
            self.talkListBlock?.scrollToRow(at: currentIndexPath, at: .bottom, animated: true)
            //autoScrollWhenTalk = false

        }
        
    }
    //TODO:解决刚打开时，显示历史记录时不能scroll到最底部
    //var showingCell:CellData
    
    @IBOutlet weak var talkListBlock: UITableView!
    
    @IBOutlet weak var inputBlock: UITextField!
    
    @IBAction func touchInputBlock(_ sender: UITextField) {
        let currentIndexPath = IndexPath(row: showingData.count-1, section: 0)
        self.talkListBlock?.scrollToRow(at: currentIndexPath, at: .bottom, animated: false)
        self.inputBlock.resignFirstResponder()
       
    }
    
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {//When tap
        self.inputBlock.resignFirstResponder()

    }
 
    @IBAction func dismissKeyboardWhenSwipe(_ sender: UISwipeGestureRecognizer) {//When swipe
        self.inputBlock.resignFirstResponder()
    }
    

    @IBAction func sendYourTalk(_ sender: UIButton) {//MARK:点击“Send"按钮后发生的事件
       
        if let currentYourTalk = inputBlock.text {
            let oneTalkData = [
                "member":"you",
                "type":"text",
                "content":currentYourTalk
            ]
            self.showingData.append(oneTalkData)
        
            self.inputBlock.text = ""
            self.createTalkRequest(myInputText:currentYourTalk, completion: { talkData in
                if let oneTalkData = talkData {
                    //print(robotRes)
                    self.showingData.append(oneTalkData)
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
            self.createTalkRequest(myInputText:currentYourTalk, completion: { talkData in
                if let oneTalkData = talkData {
                    //print(robotRes)
                    self.showingData.append(oneTalkData)
                }
                
            })

        }
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //TODO:区分scroll是.scrollToRow程序导致的，还是人为滚动导致的
        if(self.autoScrollWhenTalk==false){
            self.inputBlock.resignFirstResponder()
            self.autoScrollWhenTalk=true
        }
        
        
    }
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
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
    
    
    // TODO:Fix the bug: 当键盘处于弹出时，如果滑动行为导致返回页面一半的话，还是会导致talkBlock缩回键盘之下。目前临时解决方案是inactive状态时，将键盘置于收缩状态。否则键盘的监听会出问题。
    @objc func applicationWillResignActive(_ notification:NSNotification){
        //MARK:在该controller为inactive状态时（比如点击了Home键),将键盘置于收缩状态
        self.inputBlock.resignFirstResponder()
        print("applicationWillResignActive")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingData.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentRow = indexPath.row
        let cellData = ChatViewModel.buildCellData(self.showingData[currentRow])
        //self.historyTalkData[currentRow]["rowHeight"] =  String(describing: max(cellData.cellHeightByHeadImage, cellData.cellHeightByBubble))
        let cell = OneTalkCell(cellData, reuseId:"Talk")
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
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentRow = indexPath.row
        //let cellData = self.talkData[currentRow] //获取到
        let cellData = ChatViewModel.buildCellData(self.showingData[currentRow])
        return max(cellData.cellHeightByHeadImage, cellData.cellHeightByBubble)
    }
    func optimizedImageURL(_ imageUrl: String, width: Int, height: Int) -> URL? { //MARK:该方法copy自Content/ContentItem.swift: getImageURL
        let urlString: String
        if let u = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            urlString = ImageService.resize(u, width: width, height: height)
        } else {
            urlString = imageUrl
        }
        if let url =  URL(string: urlString) {
            return url
        }
        return nil
    }
    
  
    
    //异步加载image：
    func asyncBuildImage(url imageUrl: String, completion: @escaping (_ loadedImage: UIImage?) -> Void) {
        let optimizedUrl = self.optimizedImageURL(imageUrl, width: 240, height: 135)
        //print("ImageUrl:\(imageUrl)")
        //print("OptimizedUrl:\(String(describing: optimizedUrl))")
        if let imgUrl = optimizedUrl {
            let imgRequest = URLRequest(url: imgUrl)
            
            URLSession.shared.dataTask(with: imgRequest, completionHandler: {
                (data, response, error) in
                if error != nil{
                    DispatchQueue.main.async {//返回主线程更新UI
                        completion(nil)
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                let myUIImage = UIImage(data: data) //NOTE: 由于闭包可以在func范围之外生存，闭包中如果有参数类型是struct/enum，那么它将被复制一个新值作为参数。如果这个闭包会允许这个参数发生改变（即以闭包为其中一个参数的func是mutate的），那么闭包会产生一个副本,造成不必要的后果。所以struct中的mutate func中的escape closure的参数不能是self，也不能在closure内部改变self的属性。改为class，则可以。
                
                 if let realUIImage = myUIImage { //如果成功获取了图片
                    //cellData.downLoadImage = realUIImage
                    DispatchQueue.main.async {
                        completion(realUIImage)
                    }
                    
                 
                 } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }).resume()
            
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
    
    
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Execute viewDidLoad")
        // Do any additional setup after loading the view.
        
        //MARK:监听键盘弹出、收起事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //MARK:监听是否点击Home键以及重新进入界面
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        self.talkListBlock.delegate = self
        self.talkListBlock.dataSource = self // MARK:两个协议代理，一个也不能少
        self.inputBlock.delegate = self
        
        self.talkListBlock.backgroundColor = UIColor(hex: "#fff1e0")
        self.talkListBlock.separatorStyle = .none //MARK:删除cell之间的分割线
        
        self.bottomToolbar.backgroundColor = UIColor(hex: "#f7e9d8")
        
        // MARK：为bottomToolbar添加上边框
        let border = CALayer()
        border.frame = CGRect(x:0, y:0, width:self.bottomToolbar.frame.width, height:1)
        border.backgroundColor = UIColor(hex: "#dddddd").cgColor
        self.bottomToolbar.layer.addSublayer(border)
        
        self.inputBlock.keyboardType = .default//指定键盘类型，也可以是.numberPad（数字键盘）
        self.inputBlock.keyboardAppearance = .light//指定键盘外观.dark/.default/.light/.alert
        self.inputBlock.returnKeyType = .send//指定Return键上显示
        
        do {
            if let savedTalkData = Download.readFile("chatHistoryTalk", for: .cachesDirectory, as: "json") {
                let jsonAny = try JSONSerialization.jsonObject(with: savedTalkData, options: .mutableContainers)
                if let jsonDic = jsonAny as? NSArray, let historyTalk = jsonDic as? [[String:String]] {
                    self.historyTalkData = historyTalk
                    //print(self.historyTalkData ?? "")
                    print("historyTalkData:\(self.historyTalkData?.count ?? 0)")
                    
                }
            }
        } catch {
            
        }
        if let realHistoryTalkData = self.historyTalkData {
            let historyNum = realHistoryTalkData.count
            
            //MARK:只显示历史会话中最近的10条记录
            if historyNum > 0 {
                if historyNum <= 10  {
                   self.showingData = realHistoryTalkData
                } else {
                   self.showingData = Array(realHistoryTalkData[historyNum-10...historyNum-1])
                }
  
            }
        }
        
        self.createTalkRequest(myInputText:ChatViewModel.triggerGreetContent, completion: { talkData in
            if let oneTalkData = talkData {
                //print(robotRes)
                self.showingData.append(oneTalkData)
                self.createTalkRequest(myInputText:ChatViewModel.triggerNewsContent, completion: { talkData in
                    if let oneTalkData = talkData {
                        //print(robotRes)
                        self.showingData.append(oneTalkData)
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

        

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        
        do {
            var toSaveHistoryTalkArr:[[String: String]]
            var toSaveTalkData:Data
            if let realHistoryTalkData = self.historyTalkData {
                let newHistoryTalkData = realHistoryTalkData + self.showingData //要存储的是这个
                //print("newHistoryTalkData:\(newHistoryTalkData)")
                let newHistoryNum = newHistoryTalkData.count
                print("newHistoryNum\(newHistoryNum)")
                //MARK:只存储最近的100条对话记录 // TODO:增加手指下拉动作监测，拉一次多展现10条历史对话记录
                if newHistoryNum > 0 {
                    if newHistoryNum <= 100  {
                        toSaveHistoryTalkArr = newHistoryTalkData
                        print("case 1:\(toSaveHistoryTalkArr.count)")
                        
                    } else {
                        toSaveHistoryTalkArr = Array(newHistoryTalkData[newHistoryNum-100...newHistoryNum-1])
                        print("case 2:\(toSaveHistoryTalkArr.count)")
                        //toSaveTalkData = try JSONSerialization.data(withJSONObject: newHistoryTalkData[newHistoryNum-50...newHistoryNum-1], options:.prettyPrinted)
                    }

                    toSaveTalkData = try JSONSerialization.data(withJSONObject: toSaveHistoryTalkArr, options:.prettyPrinted)
                    print("toSaveTalkDataNum:\(toSaveTalkData.count)")
                    Download.saveFile(toSaveTalkData, filename: "chatHistoryTalk", to:.cachesDirectory , as: "json")
                }
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
