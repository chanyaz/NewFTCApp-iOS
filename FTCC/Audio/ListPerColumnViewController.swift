//
//  listPerColumnViewController.swift
//  Page
//
//  Created by huiyun.he on 24/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class ListPerColumnViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIViewControllerTransitioningDelegate {
    let customTabBarController = CustomTabBarController()
    var AudioLists = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    var item: ContentItem?
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var exitButton: UIButton!
    
    
    @IBAction func exit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customTabBarController.item = item
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
//        self.transitioningDelegate = self
//        self.modalPresentationStyle = .custom
//        listTableView?.register(UINib(nibName: "AudioListsTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioListsTableViewCell")
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return AudioLists.fetchResults[0].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellItem = tableView.dequeueReusableCell(withIdentifier: "AudioListTableViewCell", for: indexPath)
        if let cell = cellItem as? AudioListTableViewCell {
            cell.itemCell = AudioLists.fetchResults[0].items[indexPath.row]
            return cell
        }
        
        return cellItem
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        item = AudioLists.fetchResults[0].items[indexPath.row]
//        当点击一行，更新ContentItemViewController中的内容
        self.dismiss(animated: true)
        
//        if let contentItemViewController = storyboard?.instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController
//        {
//            print("update contentItemViewController content")
//            contentItemViewController.fetchesDataObject = AudioLists
//            contentItemViewController.dataObject = item
//            contentItemViewController.modalPresentationStyle = UIModalPresentationStyle.custom
//            self.present(contentItemViewController, animated: true, completion: nil)
//        }
        
        
//        if let audioPlayerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayerController") as? AudioPlayerController {
//            if let audioFileUrl = item?.audioFileUrl {
//                
//                AudioContent.sharedInstance.body["title"] = item?.headline
//                AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
//                AudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(String(describing: item?.id))"
//                audioPlayerController.item = item
//                self.addChildViewController(audioPlayerController)
//                self.view.addSubview(audioPlayerController.view)
//                audioPlayerController.view.frame = CGRect(x:0,y:self.view.bounds.height-200,width:self.view.bounds.width,height:200)
//
//            }
//        }
    }
    //init 不能少，写在viewDidLoad中不生效
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    //        override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
    //            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    //
    //            self.commonInit()
    //        }
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            return CustomPresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return nil
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return CustomPresentationAnimation(isPresenting: true)
        }
        else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return CustomPresentationAnimation(isPresenting: false)
        }
        else {
            return nil
        }
    }

}
