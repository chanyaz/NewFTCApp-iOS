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

public extension AVPlayer {
    enum RepeatMode {
        case None
        case One
        case Loop // for AVQueuePlayer
        case Order
        case Random
    }
}
let playMode = ["顺序播放", "列表循环", "单曲循环", "随机播放"]
let playModeImage = ["BigPlayButton", "DeleteButton", "PauseButton", "PlayButton"]
class ListPerColumnViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIViewControllerTransitioningDelegate {
    public var directory: String? = nil
    public let reloadView = "reloadView"
    var AudioLists = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    var fetchListResults: [ContentSection]?
    var item: ContentItem?
    var changePlayModeButton:UIButton? = nil
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var changePlayModeView: UIView!
    //    @IBOutlet weak var changePlayModeButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBAction func exit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    public init(item: ContentItem)
    {
        self.item = item
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.changePlayModeView.frame =  CGRect(x: 0, y: 0, width: self.view.bounds.width-80, height: 50)
        changePlayModeButton = UIButton(type: UIButtonType.system)
        changePlayModeButton?.setTitle("随机播放", for: .normal)
        changePlayModeButton?.setImage(UIImage(named:"BigPlayButton"), for: .normal)
        changePlayModeButton?.setTitleColor(UIColor.red, for: .normal)
        //        button.setBackgroundImage(UIImage(named:"Audio"), for: .normal)
        changePlayModeButton?.titleEdgeInsets = UIEdgeInsets(top: 6, left: 50, bottom: 6, right: 25)
        changePlayModeButton?.imageEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 15)
        changePlayModeButton?.frame = CGRect(x: 0, y: 0, width: 260, height: 50)
        self.changePlayModeView.addSubview(changePlayModeButton!)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        changePlayModeButton?.addGestureRecognizer(tapGestureRecognizer)
    }
    var i:Int=0
    func tapGesture(sender: UITapGestureRecognizer) {
        i+=1
        if i >= playMode.count{
            i = 0
        }
        TabBarAudioContent.sharedInstance.mode = i

        changePlayModeButton?.setTitle(playMode[i], for: .normal)
        changePlayModeButton?.setImage(UIImage(named:playModeImage[i]), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //        return AudioLists.fetchResults[0].items.count
        return  (fetchListResults?[0].items.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellItem = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath)
        if let cell = cellItem as? ListTableViewCell {
            //            cell.itemCell = AudioLists.fetchResults[0].items[indexPath.row]
            cell.itemCell = fetchListResults?[0].items[indexPath.row]
            return cell
        }
        
        return cellItem
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        if (storyboard?.instantiateViewController(withIdentifier: "AudioPlayerController") as? AudioPlayerController) != nil
        {
            
//            audioPlayerBar.item = fetchListResults?[0].items[indexPath.row]
            TabBarAudioContent.sharedInstance.item = fetchListResults?[0].items[indexPath.row]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadView"), object: self)
            self.dismiss(animated: true)
        }
        
    }
    //init 不能少，写在viewDidLoad中不生效
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            print("present ")
            return CustomPresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return nil
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            print("present animation")
            return CustomPresentationAnimation(isPresenting: true)
        }
        else {
            print("present nil")
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("present dismiss nil")
        if dismissed == self {
            return CustomPresentationAnimation(isPresenting: false)
        }
        else {
            print("present dismiss nil11")
            return nil
        }
    }
    
}
