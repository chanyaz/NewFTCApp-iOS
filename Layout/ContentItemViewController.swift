//
//  CustomContentItemViewController.swift
//  FTCC
//
//  Created by Oliver Zhang on 2017/10/30.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
class ContentItemViewController: SuperContentItemViewController, UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate ,UIGestureRecognizerDelegate {
    let picker = UIImagePickerController()
    let infoLabel = UILabel()
    let infoTableView = UITableView()
    var  chosenImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
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
            let customNavigation = self.navigationController as? CustomNavigationController
            if  let tabAudioView = customNavigation?.tabView{
                let deltaY = tabAudioView.bounds.height
                UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    tabAudioView.transform = CGAffineTransform(translationX: 0,y: deltaY)
                    tabAudioView.setNeedsUpdateConstraints()
                }, completion: { (true) in
                    
                })
            }
        }
   
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(self.isHideAudio))
        swipeGestureRecognizerDown.direction = .down
        swipeGestureRecognizerDown.delegate = self
        webView?.addGestureRecognizer(swipeGestureRecognizerDown)
        
        let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(self.isHideAudio))
        swipeGestureRecognizerUp.direction = .up
        swipeGestureRecognizerUp.delegate = self
        webView?.addGestureRecognizer(swipeGestureRecognizerUp)

    }
    override func viewDidAppear(_ animated: Bool) {
        print("view viewDidAppear")
    }
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func isHideAudio(sender: UISwipeGestureRecognizer){
        if sender.direction == .up{
            print("up hide audio")
            let customNavigation = self.navigationController as? CustomNavigationController
//            customNavigation?.tabView.isHidden = true
            if  let tabAudioView = customNavigation?.tabView{
                let deltaY = tabAudioView.bounds.height
                UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    tabAudioView.transform = CGAffineTransform(translationX: 0,y: deltaY)
                    tabAudioView.setNeedsUpdateConstraints()
                }, completion: { (true) in
                    
                })
            }

        }else if sender.direction == .down{
            print("down show audio")
            let customNavigation = self.navigationController as? CustomNavigationController
            if  let tabAudioView = customNavigation?.tabView{
                UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    tabAudioView.transform = CGAffineTransform.identity
                    tabAudioView.setNeedsUpdateConstraints()
                }, completion: { (true) in
                    
                })
            }
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
                if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollectInfoController") as? CollectInfoController {
                    navigationController?.pushViewController(chatViewController, animated: true)
                    
                }
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
            cellItem.portraitImageView.addTarget(self, action: #selector(openPhotoAction), for: .touchUpInside)
            
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
        openHTMLInBundle("account", title: "登录", isFullScreen: false, hidesBottomBar: true)
    }
    @objc func openPhotoAction(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("didFinishPickingMediaWithInfo")
        if let  chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.chosenImage = chosenImage
            let visibleCells = self.infoTableView.visibleCells
            
            if let cell = visibleCells[0] as? PortraitTableViewCell{
                cell.portraitImageView.setImage(chosenImage, for: .normal)
            }
        }
        dismiss(animated:true, completion: nil) //  （不加词句，当选择完图片后，不会关闭相册）
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    deinit {
        print("view cancel")
    }
}
