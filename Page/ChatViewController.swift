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
class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    // 一些实验数据
      //MARK:属性初始化时不能直接使用其他属性
    let textCellData = CellData(whoSays: .robot, saysWhat:SaysWhat(saysType: .text, saysContent: "你好！我是微软小冰。\n- 想和我聊天？\n随便输入你想说的话吧，比如'我喜欢你'、'你吃饭了吗？'\n- 想看精美图片？\n试试输入'xx图片'，比如'玫瑰花图片'、'小狗图片'\n- 想看图文新闻？\n试试输入'新闻'、'热点新闻'"))
    
    /* 一些测试数据
     let imageCellData = CellData(whoSays: .robot, saysWhat: SaysWhat(saysType: .image, saysImage: "landscape.jpeg"))
     let cardCellData = CellData(whoSays: .robot, saysWhat: SaysWhat(saysType:.card,saysTitle:"澳洲高端葡萄酒势头强劲",saysDescription:"一瓶1951年奔富葛兰许拍出5万澳元的澳洲历史最高价。澳洲高端葡萄酒国际地位正在提高，中国是第一大市场。",saysCover:"https://www.ft.com/__origami/service/image/v2/images/raw/http%3A%2F%2Fi.ftimg.net%2Fpicture%2F9%2F000072299_piclink.jpg?source=ftchinese",saysUrl:"http://www.ftchinese.com/story/001073823"))
    */
    var talkData = Array(repeating: CellData(), count: 5) {
    
        didSet {
            print("tableReloadData")
            self.talkListBlock.reloadData()
            //let num = talkData.count
            let currentIndexPath = IndexPath(row: talkData.count-1, section: 0)
            //let firstIndexPath = IndexPath(row: 0, section: 0)
            
            self.talkListBlock?.scrollToRow(at: currentIndexPath, at: .bottom, animated: true)
            
        }
    }
 
    
    
    

    @IBOutlet weak var talkListBlock: UITableView!
    
    @IBOutlet weak var inputBlock: UITextField!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.inputBlock.resignFirstResponder()

    }
 

    @IBAction func sendYourTalk(_ sender: UIButton) {
        if let currentYourTalk = inputBlock.text {
            let currentYouSaysWhat = SaysWhat(saysType: .text, saysContent: currentYourTalk)
            let currentYouCellData = CellData(whoSays: .you, saysWhat: currentYouSaysWhat)
            self.talkData.append(currentYouCellData)
            
            self.inputBlock.text = ""
            self.createTalkRequest(myInputText:currentYourTalk)
            /* 使用本地测试数据
            var currentRobotCellData = CellData()
            switch currentYourTalk {
            case "text":
                currentRobotCellData = self.textCellData
                self.talkData.append(currentRobotCellData)
            case "image":
                currentRobotCellData = self.imageCellData
                self.talkData.append(currentRobotCellData)
            case "card":
                currentRobotCellData = self.cardCellData
                self.talkData.append(currentRobotCellData)
            default:
                self.createTalkRequest(myInputText:currentYourTalk)
            }
            */
        }

    }
    

    func keyboardWillShow(_ notification: NSNotification) {
        
        print("show:\(keyboardWillShowExecute)")
        keyboardWillShowExecute += 1
        if let userInfo = notification.userInfo, let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt{
            let keyboardBounds = value.cgRectValue
            let keyboardFrame = self.view.convert(keyboardBounds, to: nil)
            
            
            //print(keyboardFrame.height)

            let deltaY = keyboardFrame.size.height
            
             print("deltaY:\(deltaY)")
            let animation:(() -> Void) = {
                self.view.transform = CGAffineTransform(translationX: 0,y: -deltaY)
                self.view.setNeedsUpdateConstraints()
                self.view.setNeedsLayout()
                print("showAnimate:\(showAnimateExecute)")
                showAnimateExecute += 1
                print("self.view.frame:\(self.view.frame)")
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
    func keyboardWillHide(_ notification: NSNotification) {
        print("hide")
        if let userInfo = notification.userInfo, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt{
            let animation:(() -> Void)={
                self.view.transform = CGAffineTransform.identity
                self.view.setNeedsUpdateConstraints()
                //self.view.setNeedsLayout()
                //self.keyboardNeedLayout = true
            }
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: UIViewAnimationOptions(rawValue: curve),
                animations:animation,
                completion: nil
            )
            //self.view.layoutIfNeeded()
             self.view.setNeedsLayout()
        }
        
    }
    
    
    // TODO:Fix the bug: 当键盘处于弹出时，如果滑动行为导致返回页面一半的话，还是会导致talkBlock缩回键盘之下。目前临时解决方案是inactive状态时，将键盘置于收缩状态。否则键盘的监听会出问题。
    func applicationWillResignActive(_ notification:NSNotification){
        //MARK:在该controller为inactive状态时（比如点击了Home键),将键盘置于收缩状态
        self.inputBlock.resignFirstResponder()
        print("applicationWillResignActive")
    }
    /*
    func applicationDidBecomeActive(_ notification:NSNotification){
        //self.inputBlock.resignFirstResponder()
        print("applicationDidBecomeActive")
    }
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.talkData.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellData = self.talkData[indexPath.row]
        let currentHeight = max(currentCellData.cellHeightByHeadImage, currentCellData.cellHeightByBubble)
        return currentHeight
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellData = self.talkData[indexPath.row]
        let cell = OneTalkCell(cellData, reuseId:"Talk")
        return cell
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let currentYourTalk = textField.text {
            let currentYouSaysWhat = SaysWhat(saysType: .text, saysContent: currentYourTalk)
            let currentYouCellData = CellData(whoSays: .you, saysWhat: currentYouSaysWhat)
            self.talkData.append(currentYouCellData)
            
            textField.text = ""
            self.createTalkRequest(myInputText:currentYourTalk)

        }
        return true
    }
    
    func createTalkRequest (myInputText inputText:String = "") {
        let bodyString = "{\"query\":\"\(inputText)\",\"messageType\":\"text\"}"
        let urlString = "https://sai-pilot.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15-Int"
        
        let appIdField = "x-msxiaoice-request-app-id"
        let appId = "XI36GDstzRkCzD18Fh"
        
        let secret = "5c3c48acd5434663897109d18a2f62c5"
        
        let timestampField = "x-msxiaoice-request-timestamp"
        let timestamp = Int(Date().timeIntervalSince1970)//生成时间戳
        
        let userIdField = "x-msxiaoice-request-user-id"
        let userId = "e10adc3949ba59abbe56e057f20f883e"
        
        let signatureField = "x-msxiaoice-request-signature"

        let signature = computeSignature(verb: "post", path: "/api/Conversation/GetResponse", paramList: ["api-version=2017-06-15-Int"], headerList: ["\(appIdField):\(appId)","\(userIdField):\(userId)"], body: bodyString, timestamp: timestamp, secretKey: secret)
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
                var explainRobotTalk = ""
                var responseCellData:CellData? = nil
                if error != nil {
                    explainRobotTalk = "Error: \(String(describing: error))"
                    //print(explainRobotTalk)
                    //return
                } else if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    explainRobotTalk = "Status code is not 200. It is \(httpStatus.statusCode)"
                    //print()
                    //return
                } else if let data = data, let dataString = String(data: data, encoding: .utf8){
                    print("Overview Data:\(dataString)")
                    explainRobotTalk = dataString
                    responseCellData = createResponseCellData(data: data)
                    
                } else {
                    explainRobotTalk = "Some do catch error when execute createResponseCellData."
                }
                let explainRobotSaysWhat = SaysWhat(saysType: .text, saysContent: explainRobotTalk)
                let explainRobotCellData = CellData(whoSays: .robot, saysWhat: explainRobotSaysWhat)
                let robotCellData = responseCellData ?? explainRobotCellData
                self.talkData.append(robotCellData)

                
                
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
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
         */
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
        
        self.talkData.append(self.textCellData)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
