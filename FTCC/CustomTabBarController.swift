//
//  CustomTabBarController.swift
//  Page
//
//  Created by huiyun.he on 28/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices



class CustomTabBarController: UITabBarController,UITabBarControllerDelegate,WKScriptMessageHandler,UIScrollViewDelegate,WKNavigationDelegate,UIViewControllerTransitioningDelegate,UIGestureRecognizerDelegate {
    
    
    var audioTitle = ""
    var audioUrlString = ""
    var audioId = ""
    lazy var player: AVPlayer? = nil
    lazy var playerItem: AVPlayerItem? = nil
    var playerLayer: AVPlayerLayer? = nil
    
    var queuePlayer:AVQueuePlayer?
    private lazy var webView: WKWebView? = nil
    let nowPlayingCenter = NowPlayingCenter()
    let download = DownloadHelper(directory: "audio")
    
    
    private var playerItems: [AVPlayerItem]? = []
    private var urls: [URL] = []
//    private var urlStrings: [String]? = []
    private var urlOrigStrings: [String] = []
//    private var urlTempStrings: [String] = []
    private var urlAssets: [AVURLAsset]? = []
    
    
    private var playingUrlStr:String? = ""
    private var playingIndex:Int = 0
    private var playingUrl:URL? = nil
    var count:Int = 0
    
    var fetchAudioResults: [ContentSection]?
    var item: ContentItem?
    var themeColor: String?
    
    let deleteButton = UIButton()
    let viewWithLanguages = UIView()
    let audioViewWithContent = UIView()
    let audioView = UIView()
    
    var languages = UISegmentedControl()
    let preAudio = UIButton()
    let nextAudio = UIButton()
    let forward = UIButton()
    let back = UIButton()
    
    let love = UIButton()
    let downLoad = UIButtonEnhanced()
    let list = UIButton()
    let share = UIButton()
    let audioplayAndPauseButton = UIButton()
    let audioPlayStatus = UILabel()
    let audioProgressSlider = UISlider()
    let audioPlayTime = UILabel()
    let audioPlayDuration = UILabel()
    
    let downSwipeButton = UIButton()
    let webAudioView = UIWebView()
    
    var tabView = CustomTab()
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let homeTabBarHeight: CGFloat = 95
        let hideImage = UIImage(named:"HideBtn")
        let hideHeight = (hideImage?.size.height)!*1.1
        let hideWidth = (hideImage?.size.width)!*1.1
        
        let forwardImage = UIImage(named:"FastForwardBtn")
        let forwardHeight = (forwardImage?.size.height)!*1.1
        let forwardWidth = (forwardImage?.size.width)!*1.1
        
        let backImage = UIImage(named:"FastBackBtn")
        let backHeight = (backImage?.size.height)!*1.1
        let backWidth = (backImage?.size.width)!*1.1
        
        let preImage = UIImage(named:"PreBtn")
        let preHeight = (preImage?.size.height)!*1.1
        let preWidth = (preImage?.size.width)!*1.1
        
        let nextImage = UIImage(named:"PreBtn")
        let nextHeight = (nextImage?.size.height)!*1.1
        let nextWidth = (nextImage?.size.width)!*1.1
        
        let pauseImage = UIImage(named:"PauseBtn")
        let pauseHeight = (pauseImage?.size.height)!*1.1
        let pauseWidth = (pauseImage?.size.width)!*1.1
        
        
        let audioViewHeight:CGFloat = 220
        let buttonWidth:CGFloat = 19
        let buttonHeight: CGFloat = 19
        let margin:CGFloat = 20
        let space = (width - margin*2 - buttonWidth*4)/3
        let spaceBetweenSliderAndForward: CGFloat = 65
        let spaceBetweenListAndView: CGFloat = 30
        let spaceBetweenListAndForward: CGFloat = 10
        let spaceBetweenPreAndForward = (width - margin*2 - forwardWidth - preWidth - pauseWidth - nextWidth - backWidth)/4
        
        let forwardY = spaceBetweenListAndView + spaceBetweenListAndForward + buttonHeight + forwardHeight
        
        


        
        
        preAudio.attributedTitle(for: UIControlState.normal)
        preAudio.setImage(UIImage(named:"PreBtn"), for: UIControlState.normal)
        preAudio.addTarget(self, action: #selector(switchToPreAudio), for: UIControlEvents.touchUpInside)
        
        
        nextAudio.attributedTitle(for: UIControlState.normal)
        nextAudio.setImage(UIImage(named:"NextBtn"), for: UIControlState.normal)
        nextAudio.addTarget(self, action: #selector(switchToNextAudio), for: UIControlEvents.touchUpInside)
        
        
        forward.attributedTitle(for: UIControlState.normal)
        forward.setImage(UIImage(named:"FastForwardBtn"), for: UIControlState.normal)
        forward.addTarget(self, action: #selector(skipForward), for: UIControlEvents.touchUpInside)
        
        
        
        
        back.attributedTitle(for: UIControlState.normal)
        back.setImage(UIImage(named:"FastBackBtn"), for: UIControlState.normal)
        back.addTarget(self, action: #selector(skipBackward), for: UIControlEvents.touchUpInside)
        
        
        
        audioplayAndPauseButton.attributedTitle(for: UIControlState.normal)
        audioplayAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
        audioplayAndPauseButton.addTarget(self, action: #selector(pauseOrPlay), for: UIControlEvents.touchUpInside)
        
        
        list.attributedTitle(for: UIControlState.normal)
        list.setImage(UIImage(named:"ListBtn"), for: UIControlState.normal)
        list.addTarget(self, action: #selector(listAction), for: UIControlEvents.touchUpInside)
        
        
        downLoad.attributedTitle(for: UIControlState.normal)
        downLoad.setImage(UIImage(named:"DownLoadBtn"), for: UIControlState.normal)
        downLoad.addTarget(self, action: #selector(downLoadAction), for: UIControlEvents.touchUpInside)
        
        
        love.attributedTitle(for: UIControlState.normal)
        love.setImage(UIImage(named:"LoveBtn"), for: UIControlState.normal)
        love.addTarget(self, action: #selector(favorite), for: UIControlEvents.touchUpInside)
        
        
        share.attributedTitle(for: UIControlState.normal)
        share.setImage(UIImage(named:"ShareBtn"), for: UIControlState.normal)
        share.addTarget(self, action: #selector(shareAction), for: UIControlEvents.touchUpInside)
        
        
        webAudioView.frame = CGRect(x:0,y:homeTabBarHeight,width:width,height:height)
        webAudioView.isOpaque = true
        webAudioView.layer.backgroundColor = UIColor.yellow.cgColor
        webAudioView.backgroundColor = UIColor.red
        webAudioView.layer.zPosition = 100
        
        //        audioPlayTime.frame = CGRect(x:5,y:58,width:50,height:20)
        audioPlayTime.text = "00:00"
        audioPlayTime.textColor = UIColor.white
        audioPlayTime.font = UIFont(name: "Helvetica-Light", size: 14.0)
        //        audioPlayDuration.frame = CGRect(x:width-60,y:58,width:70,height:20)
        audioPlayDuration.text = "00:00"
        audioPlayDuration.textColor = UIColor.white
        audioPlayDuration.font = UIFont(name: "Helvetica-Light", size: 14.0)
        //        audioProgressSlider.frame = CGRect(x:60,y:58,width:width - 140,height:20)
        //        progressSlider.value = 0.3
        let progressThumbImage = UIImage(named: "SliderImg")
        let aa = progressThumbImage?.imageWithImage(image: progressThumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        audioProgressSlider.setThumbImage(aa, for: .normal)
        audioProgressSlider.maximumTrackTintColor = UIColor.white
        audioProgressSlider.minimumTrackTintColor = UIColor(hex: "#05d5e9")
        audioProgressSlider.addTarget(self, action: #selector(sliderValueChanged), for: UIControlEvents.valueChanged)
        
        self.tabView.progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: UIControlEvents.valueChanged)
        
        
        audioPlayStatus.text = "audio单曲鉴赏"
        audioPlayStatus.textColor = UIColor.white
                audioPlayStatus.frame = CGRect(x:70,y:10,width:width,height:50)
        
        deleteButton.frame = CGRect(x:width-120,y:10,width:40,height:40)
        deleteButton.setImage(UIImage(named:"DeleteButton"), for: UIControlState.normal)
        deleteButton.addTarget(self, action: #selector(deleteAudio), for: UIControlEvents.touchUpInside)
        
        downSwipeButton.frame = CGRect(x:width-50,y:15,width:hideWidth*2,height:hideHeight*2)
        downSwipeButton.setImage(UIImage(named:"HideBtn"), for: UIControlState.normal)
        downSwipeButton.addTarget(self, action: #selector(exitAudio), for: UIControlEvents.touchUpInside)
//        downSwipeButton.backgroundColor = UIColor.red

        

        viewWithLanguages.frame = CGRect(x:0,y:0,width:width,height:homeTabBarHeight)
        audioViewWithContent.frame = CGRect(x:0,y:homeTabBarHeight,width:width,height:height)
        audioView.frame = CGRect(x:0,y:height - audioViewHeight,width:width,height:audioViewHeight)
        viewWithLanguages.backgroundColor = UIColor.white
        viewWithLanguages.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(hex: Color.AudioList.border, alpha: 0.6), thickness: 0.5)

     
        let items = ["中文", "英文"]
        languages = UISegmentedControl(items: items)
        languages.selectedSegmentIndex = 0
        languages.backgroundColor = UIColor(hex: "12a5b3", alpha: 1)
        languages.tintColor = UIColor.white
        languages.layer.borderColor = UIColor(hex: "12a5b3", alpha: 1).cgColor
        languages.layer.borderWidth = 0.5
        languages.layer.cornerRadius = 5
        languages.layer.masksToBounds = true
        let segAttributes: NSDictionary = [
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.font: UIFont(name: "Avenir-MediumOblique", size: 14)!
        ]
        languages.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], for: UIControlState.selected)
        
        audioView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.9)
        
        audioView.addSubview(deleteButton)
//        audioView.addSubview(audioPlayStatus)
        audioView.addSubview(audioplayAndPauseButton)
        audioView.addSubview(audioProgressSlider)
        audioView.addSubview(audioPlayTime)
        audioView.addSubview(audioPlayDuration)
        audioView.addSubview(downSwipeButton)
        audioView.addSubview(back)
        audioView.addSubview(forward)
        audioView.addSubview(nextAudio)
        audioView.addSubview(preAudio)
        audioView.addSubview(list)
        audioView.addSubview(downLoad)
        audioView.addSubview(love)
        audioView.addSubview(share)
        audioViewWithContent.addSubview(webAudioView)
        viewWithLanguages.addSubview(languages)
        audioViewWithContent.addSubview(audioView)
        audioViewWithContent.addSubview(viewWithLanguages)
        tabView.addSubview(audioViewWithContent)
        audioView.layer.zPosition = 200
        
        
        
        tabView.backgroundColor = UIColor.clear
        tabView.frame = CGRect(x:0,y:height-homeTabBarHeight,width:width,height:height+homeTabBarHeight)
        
        view.addSubview(self.tabView)
        

        
        
        self.languages.translatesAutoresizingMaskIntoConstraints = false
        self.tabView.addConstraint(NSLayoutConstraint(item: languages, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.audioViewWithContent, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.tabView.addConstraint(NSLayoutConstraint(item: languages, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.viewWithLanguages, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -20))
        self.tabView.addConstraint(NSLayoutConstraint(item: languages, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.audioViewWithContent, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 40))
        self.tabView.addConstraint(NSLayoutConstraint(item: languages, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 180))
        
        self.webAudioView.translatesAutoresizingMaskIntoConstraints = false
        self.tabView.addConstraint(NSLayoutConstraint(item: webAudioView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.tabView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        self.tabView.addConstraint(NSLayoutConstraint(item: webAudioView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.tabView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.tabView.addConstraint(NSLayoutConstraint(item: webAudioView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.audioViewWithContent, attribute: NSLayoutAttribute.top, multiplier: 1, constant: homeTabBarHeight))
        self.tabView.addConstraint(NSLayoutConstraint(item: webAudioView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width))
        
        self.audioProgressSlider.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: audioProgressSlider, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenSliderAndForward))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioProgressSlider, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioProgressSlider, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.audioPlayTime, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 15))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioProgressSlider, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.audioPlayDuration, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -15))
        
        
        self.audioPlayTime.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: audioPlayTime, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.back, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioPlayTime, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.audioProgressSlider, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        
        self.audioPlayDuration.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: audioPlayDuration, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioPlayDuration, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.audioProgressSlider, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        
        self.back.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: back, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: margin))
        self.audioView.addConstraint(NSLayoutConstraint(item: back, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -forwardY))
        self.audioView.addConstraint(NSLayoutConstraint(item: back, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: backWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: back, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: backHeight))
        
        self.forward.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: forward, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -margin))
        self.audioView.addConstraint(NSLayoutConstraint(item: forward, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -forwardY))
        self.audioView.addConstraint(NSLayoutConstraint(item: forward, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: forwardWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: forward, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: forwardHeight))
        
        self.preAudio.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: preAudio, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.back, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: spaceBetweenPreAndForward))
        self.audioView.addConstraint(NSLayoutConstraint(item: preAudio, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.back, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: preAudio, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: preWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: preAudio, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: preHeight))
        
        self.nextAudio.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: nextAudio, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -spaceBetweenPreAndForward))
        self.audioView.addConstraint(NSLayoutConstraint(item: nextAudio, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant:0))
        self.audioView.addConstraint(NSLayoutConstraint(item: nextAudio, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: nextWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: nextAudio, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: nextHeight))
        
        self.audioplayAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: audioplayAndPauseButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioplayAndPauseButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioplayAndPauseButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: pauseWidth*2))
        self.audioView.addConstraint(NSLayoutConstraint(item: audioplayAndPauseButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: pauseHeight*2))
        
        
        self.list.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: list, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.back, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: list, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.audioView.addConstraint(NSLayoutConstraint(item: list, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: list, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        
        self.downLoad.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: downLoad, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.share, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -space))
        self.audioView.addConstraint(NSLayoutConstraint(item: downLoad, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.audioView.addConstraint(NSLayoutConstraint(item: downLoad, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: downLoad, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        
        self.love.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.list, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: space))
        self.audioView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.audioView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        
        
        self.share.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.audioView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.audioView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.audioView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        
        tabView.playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
        self.tabBar.isHidden = true
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.openAudio))
        tabView.smallView.addGestureRecognizer(tapGestureRecognizer1)
        
        
        tabView.playAndPauseButton.addTarget(self, action: #selector(pauseOrPlay), for: UIControlEvents.touchUpInside)
        
        
        player = TabBarAudioContent.sharedInstance.player
        
        playerItem = TabBarAudioContent.sharedInstance.playerItem
       
        tabView.isHidden = true
        self.delegate = self
        audioAddGesture()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        addPlayerItemObservers()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches Began")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch : UITouch! =  touches.first! as UITouch
        let location = touch.location(in: self.tabView.smallView)
        let previousLocation = touch.previousLocation(in: self.tabView.smallView)
        print("touches Moved tabView.frame.origin.y\(tabView.frame.origin.y)")
        let offsetY = location.y - previousLocation.y
        if tabView.frame.origin.y<height/2{
            self.tabView.transform = CGAffineTransform(translationX: 0,y: -self.view.bounds.height)
        }else{
            tabView.transform = tabView.transform.translatedBy(x: 0, y: offsetY)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches Ended")
        if tabView.frame.origin.y<0{
            self.tabView.transform = CGAffineTransform(translationX: 0,y: -self.view.bounds.height)
        }else{
            self.tabView.transform = CGAffineTransform.identity
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //        最好放在此处，能够获取到值
        fetchAudioResults = TabBarAudioContent.sharedInstance.fetchResults
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMiniPlay),
            name: Notification.Name(rawValue: "updateMiniPlay"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAudioView),
            name: Notification.Name(rawValue: "reloadView"),
            object: nil
        )
        print("how much time did view appear?")
//        getLastPlayAudio()
    }
   @objc func switchToPreAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        removePlayerItemObservers()
        print("urlString playingIndex pre\(playingIndex)")

        if fetchAudioResults != nil {
            playingIndex = playingIndex-1
            if playingIndex < 0{
                playingIndex = count - 1
                
            }
            let preUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
            audioUrlString = preUrl
            updateSingleTonData()
            prepareAudioPlay()
        }
        
    }
  @objc  func switchToNextAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        if fetchAudioResults != nil {
            
            removePlayerItemObservers()
            playingIndex += 1
            if playingIndex >= count{
                playingIndex = 0
            }
            let nextUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
            print("urlString playingIndex\(playingIndex)")
            
            audioUrlString = nextUrl
            updateSingleTonData()
            prepareAudioPlay()
            
        }
    }
   @objc func skipForward(_ sender: UIButton) {
        let currentSliderValue = self.audioProgressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        self.audioProgressSlider.value = currentSliderValue + 15
        self.tabView.progressSlider.value = currentSliderValue + 15
    }
   @objc func skipBackward(_ sender: UIButton) {
        let currentSliderValue = self.audioProgressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        self.audioProgressSlider.value = currentSliderValue - 15
        self.tabView.progressSlider.value = currentSliderValue - 15
    }
   @objc func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        NowPlayingCenter().updatePlayingCenter()
    }
    
   @objc func listAction(){
        if let listPerColumnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController {
            listPerColumnViewController.fetchListResults = TabBarAudioContent.sharedInstance.fetchResults
            listPerColumnViewController.modalPresentationStyle = .custom
            self.present(listPerColumnViewController, animated: true, completion: nil)
            
        }
    }
   @objc func downLoadAction(_ sender: Any){
        let body = TabBarAudioContent.sharedInstance.body
        if let audioFileUrl = body["audioFileUrl"]{
            audioUrlString = audioFileUrl.replacingOccurrences(of: " ", with: "%20")
            audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
        }
        if audioUrlString != "" {
            print("download button\( audioUrlString)")
            if let button = sender as? UIButtonEnhanced {
                // FIXME: should handle all the status and actions to the download helper
                download.takeActions(audioUrlString, currentStatus: button.status)
                print("download button\( button.status)")
            }
            
        }
    }
    var isLove:Bool = false
    @objc func favorite(_ sender: Any) {
        if !isLove{
            self.love.setImage(UIImage(named:"Clip"), for: UIControlState.normal)
            isLove = true
        }else{
            self.love.setImage(UIImage(named:"LoveBtn"), for: UIControlState.normal)
            isLove = false
        }
    }
    
    @objc func shareAction(){
        item = TabBarAudioContent.sharedInstance.item
        if let item = item {
            self.launchActionSheet(for: item)
        }
    }
    @objc func deleteAudio(){
        let alert = UIAlertController(title: "请选择您的操作设置", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(
            title: "清除所有音频",
            style: UIAlertActionStyle.default,
            handler: {_ in self.removeAllAudios() }
        ))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
//   Fixme:should remove the selected mp3 file instead of all mp3
    func removeAllAudios() {
        Download.removeFiles(["mp3"])
        downLoad.status = .remote
    }
    deinit {
        removePlayerItemObservers()
        removeDownloadObserve()
        NotificationCenter.default.removeObserver(self)
        self.webView?.stopLoading()
        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
        self.webView?.configuration.userContentController.removeAllUserScripts()
        self.webView?.navigationDelegate = nil
        self.webView?.scrollView.delegate = nil
        
        print ("tabbar deinit successfully and observer removed")
    }
    //    playingIndex应该放在时刻跟新的地方获取
    func updateSingleTonData(){
        if let fetchAudioResults = fetchAudioResults, let audioFileUrl = fetchAudioResults[0].items[playingIndex].audioFileUrl {
            TabBarAudioContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
            self.tabView.playStatus.text = fetchAudioResults[0].items[playingIndex].headline
            self.audioPlayStatus.text = fetchAudioResults[0].items[playingIndex].headline
            TabBarAudioContent.sharedInstance.body["title"] = fetchAudioResults[0].items[playingIndex].headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(fetchAudioResults[0].items[playingIndex].id)"
            TabBarAudioContent.sharedInstance.playingIndex = playingIndex
            parseAudioMessage()
            loadUrl()
            
        }
    }
    private func getPlayingUrl(){
        playingIndex = 0
        urlOrigStrings = []
        var playerItemTemp : AVPlayerItem?
        audioUrlString = audioUrlString.replacingOccurrences(of: "%20", with: " ")
        if let fetchAudioResults = fetchAudioResults {
            for (index, item0) in fetchAudioResults[0].items.enumerated() {
                if let fileUrl = item0.audioFileUrl {
                    urlOrigStrings.append(fileUrl)
                    if audioUrlString == fileUrl{
                        playingUrlStr = fileUrl
                        playingIndex = index
                    }
                    if let urlAsset = URL(string: fileUrl){
                        playerItemTemp = AVPlayerItem(url: urlAsset) //可以用于播放的playItem
                        playerItems?.append(playerItemTemp!)
                    }
   
                }
            }
        }
        print("urlString playerItems000---\(String(describing: playerItems))")
        
        print("urlString playingIndex222--\(playingIndex)")
        TabBarAudioContent.sharedInstance.playingIndex = playingIndex
        
    }
    
    
    @objc func exitAudio(){
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.tabView.transform = CGAffineTransform.identity
            self.tabView.setNeedsUpdateConstraints()
        }, completion: { (true) in
            print("exit animate finish")
        })
        removeDownloadObserve()
    }
    //    把此页面的所有信息都传给AudioPlayBar,包括player，playerItem
    @objc func openAudio(){
        let deltaY = self.view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.tabView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
            self.tabView.setNeedsUpdateConstraints()
        }, completion: { (true) in
            print("open animate finish")
        })
//        parseAudioMessage()
//        getPlayingUrl()
//        loadUrl()
//        addDownloadObserve()
        enableBackGroundMode()
        //  getPlayingUrl()需要放在parseAudioMessage()后面，不然第一次audioUrlString为空
    }
    
    @objc func pauseOrPlay(sender: UIButton) {
        player = TabBarAudioContent.sharedInstance.player
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        if (player != nil) {
            print("playerItem isExist \(String(describing: playerItem))")
            if player?.rate != 0 && player?.error == nil {
                print("palyer item pause)")
                audioplayAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
                tabView.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
                player?.pause()
                
            } else {
                print("playerItem play)")
                audioplayAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
                tabView.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = true
                player?.play()
                player?.replaceCurrentItem(with: playerItem)
                
            }
        }
        NowPlayingCenter().updatePlayingCenter()
    }
    func loadUrl(){
        ShareHelper.sharedInstance.webPageUrl = "http://www.ftchinese.com/interactive/\(audioId)"
        let url = "\(ShareHelper.sharedInstance.webPageUrl)?hideheader=yes&ad=no&inNavigation=yes&v=1"
        
        if let url = URL(string:url) {
            let req = URLRequest(url:url)
            webView?.load(req)
        }
    }
    
    private func prepareAudioPlay() {
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
        
        if let url = URL(string: audioUrlString) {
            // MARK: - Check if the file already exists locally
            var audioUrl = url
            //print ("checking the file in documents: \(audioUrlString)")
            let cleanAudioUrl = audioUrlString.replacingOccurrences(of: "%20", with: "")
            if let localAudioFile = download.checkDownloadedFileInDirectory(cleanAudioUrl) {
                print ("The Audio is already downloaded")
                audioUrl = URL(fileURLWithPath: localAudioFile)
                downLoad.setImage(UIImage(named:"DeleteButton"), for: .normal)
            }
            // MARK: - Draw a circle around the downLoad
            downLoad.drawCircle()
            
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            
            if player != nil {
                print("player exist")
            }else {
                print("player not exist")
                player = AVPlayer()
                
            }
            
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            TabBarAudioContent.sharedInstance.audioUrl = audioUrl
            TabBarAudioContent.sharedInstance.audioHeadLine = item?.headline
            setLastPlayAudio()

            
//            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            try? AVAudioSession.sharedInstance().setActive(true)
            if let player = player {
                player.play()
            }
            
            self.audioplayAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            self.tabView.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            updateProgressSlider()
            addDownloadObserve()
            addPlayerItemObservers()
            NowPlayingCenter().updatePlayingCenter()
//            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "updateMiniPlay"), object: nil)
//            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "reloadView"), object: nil) //移除此监听，再从哪里增加监听呢？
        }
    }
    func updateProgressSlider(){
//         playerItem = TabBarAudioContent.sharedInstance.playerItem
        // MARK: - Update audio play progress
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
            if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
                let duration = CMTimeGetSeconds(d)
                if duration.isNaN == false {
                    self?.audioProgressSlider.maximumValue = Float(duration)
                    self?.tabView.progressSlider.maximumValue = Float(duration)
                    if self?.audioProgressSlider.isHighlighted == false {
                        self?.audioProgressSlider.value = Float((CMTimeGetSeconds(time)))
                        self?.tabView.progressSlider.value = Float((CMTimeGetSeconds(time)))
                    }
                    self?.updatePlayTime(current: time, duration: d)
                    TabBarAudioContent.sharedInstance.duration = d
                    TabBarAudioContent.sharedInstance.time = time
                }
            }
        }
    }
    func removeDownloadObserve(){
        // MARK: - Remove Observe download status change
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: download.downloadStatusNotificationName),
            object: nil
        )
        // MARK: - Remove Observe download progress change
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: download.downloadProgressNotificationName),
            object: nil
        )
    }
   // MARK: - Observe download status change
    func addDownloadObserve(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleDownloadStatusChange(_:)),
            name: Notification.Name(rawValue: download.downloadStatusNotificationName),
            object: nil
        )
        
        // MARK: - Observe download progress change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleDownloadProgressChange(_:)),
            name: Notification.Name(rawValue: download.downloadProgressNotificationName),
            object: nil
        )
    }
    public func updatePlayButtonUI() {
        if TabBarAudioContent.sharedInstance.isPlaying{
            audioplayAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            tabView.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
            
        }else{
            audioplayAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
            tabView.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
        }
    }
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        
        self.audioPlayDuration.text = "-\((duration-time).durationText)"
        self.audioPlayTime.text = time.durationText
        
        self.tabView.playDuration.text = "-\((duration-time).durationText)"
        self.tabView.playTime.text = time.durationText
    }
    
    private func parseAudioMessage() {
        let body = TabBarAudioContent.sharedInstance.body
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            audioTitle = title
            audioUrlString = audioFileUrl.replacingOccurrences(of: " ", with: "%20")
            audioId = interactiveUrl.replacingOccurrences(
                of: "^.*interactive/([0-9]+).*$",
                with: "$1",
                options: .regularExpression
            )
            ShareHelper.sharedInstance.webPageTitle = title
            
        }
    }
    @objc func updateMiniPlay(){
        tabView.isHidden = false
      // 点击了上下首之后，BigImageCell这里为什么没有更新item的值，但是不点击上下首是会更新的？因为prepareAudio没对item进行更新
        player = TabBarAudioContent.sharedInstance.player
        //        点击list一次也会继续监听，值更新了，但是audioPlayStatus.text没有变化？应该跟监听位置有关系？
        print("how much updateMiniPlay\(String(describing: TabBarAudioContent.sharedInstance.audioHeadLine))")
        audioPlayStatus.text = TabBarAudioContent.sharedInstance.audioHeadLine
        self.tabView.playStatus.text = TabBarAudioContent.sharedInstance.audioHeadLine
        
        
        updateProgressSlider()
        updatePlayButtonUI()
        
        parseAudioMessage()
        getPlayingUrl()
        loadUrl()
//        playingCenter()
//        nowPlayingCenter.updateTimeForPlayerItem(player)
        
    }
//  Mark：This function must exist
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    private func audioAddGesture(){
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(self.isHideAudio))
        swipeGestureRecognizerDown.direction = .down
        swipeGestureRecognizerDown.delegate = self
        self.webAudioView.addGestureRecognizer(swipeGestureRecognizerDown)
        
        let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(self.isHideAudio))
        swipeGestureRecognizerUp.direction = .up
        swipeGestureRecognizerUp.delegate = self
        self.webAudioView.addGestureRecognizer(swipeGestureRecognizerUp)
    }
    @objc  func isHideAudio(sender: UISwipeGestureRecognizer){
        if sender.direction == .up{
            let deltaY = self.audioView.bounds.height
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.audioView.transform = CGAffineTransform(translationX: 0,y: deltaY)
                self.audioView.setNeedsUpdateConstraints()
            }, completion: { (true) in
                print("up animate finish")
            })
        }else if sender.direction == .down{
            //            let deltaY = self.view.bounds.height
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //                self.containerView.transform = CGAffineTransform.identity
                self.audioView.transform = CGAffineTransform(translationX: 0,y: 0)
                self.audioView.setNeedsUpdateConstraints()
            }, completion: { (true) in
                print("down animate finish")
            })
        }
    }
    
    
    override func loadView() {
        super.loadView()
        
        print("urlString loadView \( ShareHelper.sharedInstance.webPageTitle)")
        ShareHelper.sharedInstance.webPageTitle = ""
        ShareHelper.sharedInstance.webPageDescription = ""
        ShareHelper.sharedInstance.webPageImage = ""
        ShareHelper.sharedInstance.webPageImageIcon = ""
        
//        enableBackGroundMode()
        let jsCode = "function getContentByMetaTagName(c) {for (var b = document.getElementsByTagName('meta'), a = 0; a < b.length; a++) {if (c == b[a].name || c == b[a].getAttribute('property')) { return b[a].content; }} return '';} var gCoverImage = getContentByMetaTagName('og:image') || '';var gIconImage = getContentByMetaTagName('thumbnail') || '';var gDescription = getContentByMetaTagName('og:description') || getContentByMetaTagName('description') || '';gIconImage=encodeURIComponent(gIconImage);webkit.messageHandlers.callbackHandler.postMessage(gCoverImage + '|' + gIconImage + '|' + gDescription);"
        let userScript = WKUserScript(
            source: jsCode,
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        // MARK: - Use a LeakAvoider to avoid leak
        contentController.add(
            LeakAvoider(delegate:self),
            name: "callbackHandler"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.webAudioView.frame, configuration: config)
        self.webAudioView.addSubview(self.webView!)
        self.webAudioView.clipsToBounds = true
        self.webView?.scrollView.bounces = false
        self.webView?.navigationDelegate = self
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView?.scrollView.delegate = self
//        没点击openAudio,每次点击首页的任何一个播放运行3次，点金audio再退出出后，每次播放执行一次
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(updateMiniPlay),
//            name: Notification.Name(rawValue: "updateMiniPlay"),
//            object: nil
//        )
    }
    
    @objc func reloadAudioView(){
        //        item的值得时刻记住更新，最好传全局变量还是用自身局部变量？，可以从tab中把值传给此audio么？
        //        需要同时更新webView和id 、item等所有一致性变量，应该把他们整合到一起，一起处理循环、下一首、列表更新
//        此函数选择一次list，运行2次，why？需要移除此监听器么？
        removePlayerItemObservers()
        if let item = TabBarAudioContent.sharedInstance.item,let audioUrlStrFromList = item.audioFileUrl{
            print("audioUrlStrFromList--\(audioUrlStrFromList)")
            audioUrlString = audioUrlStrFromList
            audioUrlString = audioUrlString.replacingOccurrences(of: " ", with: "%20")
            //            audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
            print("audioUrlStrFromList--\(audioUrlString)")
            prepareAudioPlay()
            //            updateSingleTonData()
            
            TabBarAudioContent.sharedInstance.item = item
            self.audioPlayStatus.text = item.headline
            self.tabView.playStatus.text = item.headline
            TabBarAudioContent.sharedInstance.body["title"] = item.headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioUrlStrFromList
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(item.id)"
            
            //  audioTitle = fetchAudioResults[0].items[playingIndex].headline
            parseAudioMessage()
            loadUrl()
        }
        
        
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("page loaded11!")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            if let infoForShare = message.body as? String{
                print("infoForShare\(infoForShare)")
                let toArray = infoForShare.components(separatedBy: "|")
                ShareHelper.sharedInstance.webPageDescription = toArray[2]
                ShareHelper.sharedInstance.webPageImage = toArray[0]
                ShareHelper.sharedInstance.webPageImageIcon = toArray[1]
                print("get image icon from web page: \(ShareHelper.sharedInstance.webPageImageIcon)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func removePlayerItemObservers() {
        print("removePlayerItemObservers---")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: TabBarAudioContent.sharedInstance.playerItem)
    }
    
    func addPlayerItemObservers() {
        print("addPlayerItemObservers---")
        // MARK: - Observe Play to the End
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: TabBarAudioContent.sharedInstance.playerItem)
    }
    @objc func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.audioProgressSlider.value = 0
        self.audioplayAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
        
        nowPlayingCenter.updateTimeForPlayerItem(player)
        orderPlay()
        if let mode = TabBarAudioContent.sharedInstance.mode {
            switch mode {
            case 0:
                orderPlay()
            case 1:
                randomPlay()
            case 2:
                onePlay()
            default:
                orderPlay()
            }
        }
        else{
            loopPlay()
        }
    }
    
    func orderPlay(){
        
        count = urlOrigStrings.count
        removePlayerItemObservers()
        playingIndex += 1
        if playingIndex >= count{
            playingIndex = 0
        }
        let nextUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
        print("urlString playingIndex---\(playingIndex)")
        audioUrlString = nextUrl
        updateSingleTonData()
        prepareAudioPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        let nextItem = playerItems?[playingIndex]
        queuePlayer?.advanceToNextItem()
        currentItem?.seek(to: kCMTimeZero)
        queuePlayer?.insert(nextItem!, after: currentItem)
        self.player?.play()
    }
    func randomPlay(){
        let randomIndex = Int(arc4random_uniform(UInt32(urlOrigStrings.count)))
        removePlayerItemObservers()
        playingIndex = randomIndex
        let nextUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
        print("urlString playingIndex---\(playingIndex)")
        audioUrlString = nextUrl
        updateSingleTonData()
        prepareAudioPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        let nextItem = playerItems?[playingIndex]
        queuePlayer?.advanceToNextItem()
        currentItem?.seek(to: kCMTimeZero)
        queuePlayer?.insert(nextItem!, after: currentItem)
        self.player?.play()
    }
    func loopPlay(){
        let currentItem = self.player?.currentItem
        queuePlayer?.advanceToNextItem()
        currentItem?.seek(to: kCMTimeZero)
        queuePlayer?.insert(currentItem!, after: nil)
        self.player?.play()
        
    }
    func onePlay(){
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.audioProgressSlider.value = 0
        self.tabView.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
        self.audioplayAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    

    private func updateAVPlayerWithLocalUrl() {
        if let localAudioFile = download.checkDownloadedFileInDirectory(audioUrlString) {
            let currentSliderValue = self.audioProgressSlider.value
            let audioUrl = URL(fileURLWithPath: localAudioFile)
            let asset = AVURLAsset(url: audioUrl)
            removePlayerItemObservers()
            playerItem = AVPlayerItem(asset: asset)
            player?.replaceCurrentItem(with: playerItem)
            addPlayerItemObservers()
            let currentTime = CMTimeMake(Int64(currentSliderValue), 1)
            playerItem?.seek(to: currentTime)
            nowPlayingCenter.updateTimeForPlayerItem(player)
            print ("now use local file to play at \(currentTime)")
        }
    }
    
    @objc public func handleDownloadStatusChange(_ notification: Notification) {
        DispatchQueue.main.async() {
            if let object = notification.object as? (id: String, status: DownloadStatus) {
                let status = object.status
                let id = object.id
                // MARK: The Player Need to verify that the current file matches status change
                let cleanAudioUrl = self.audioUrlString.replacingOccurrences(of: "%20", with: "")
                print ("Handle download Status Change: \(cleanAudioUrl) =? \(id)")
                if cleanAudioUrl.contains(id) == true {
                    switch status {
                    case .downloading, .remote:
                        self.downLoad.progress = 0
                    case .paused, .resumed:
                        break
                    case .success:
                        // MARK: if a file is downloaded, prepare the audio asset again
                        self.updateAVPlayerWithLocalUrl()
                        self.downLoad.progress = 0
                    }
                    print ("notification received for \(status)")
                    self.downLoad.status = status
                    //self.downLoad.progress = 0
                }
            }
        }
    }
    
    @objc public func handleDownloadProgressChange(_ notification: Notification) {
        DispatchQueue.main.async() {
            if let object = notification.object as? (id: String, percentage: Float, downloaded: String, total: String) {
                let id = object.id
                let percentage = object.percentage
                // MARK: The Player Need to verify that the current file matches status change
                let cleanAudioUrl = self.audioUrlString.replacingOccurrences(of: "%20", with: "")
                if cleanAudioUrl.contains(id) == true {
                    self.downLoad.progress = percentage/100
                    self.downLoad.status = .resumed
                }
            }
        }
    }
    
    private func getLastPlayAudio() {
        let audioHeadLineHistory = UserDefaults.standard.string(forKey: Key.audioHistory[0]) ?? String()
        let audioUrlHistory = UserDefaults.standard.url(forKey: Key.audioHistory[1]) ?? URL(string: "")
        let audioIdHistory = UserDefaults.standard.string(forKey: Key.audioHistory[2]) ?? String()
        let audioLastPlayTimeHistory = UserDefaults.standard.float(forKey: Key.audioHistory[3])
        print("getLastPlayAudio---\(audioLastPlayTimeHistory)")
        self.audioPlayStatus.text = audioHeadLineHistory
        self.tabView.playStatus.text = audioHeadLineHistory
        
        if audioUrlHistory != nil {
            let asset = AVURLAsset(url: audioUrlHistory!)
            
            playerItem = AVPlayerItem(asset: asset)
            
            if player != nil {
                print("player exist")
            }else {
                print("player not exist")
                player = AVPlayer()
                
            }
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            updateProgressSlider()
            
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            TabBarAudioContent.sharedInstance.player = player
            TabBarAudioContent.sharedInstance.audioHeadLine = audioHeadLineHistory
            
        }
        
        //        if audioIdHistory != nil {
        audioId = audioIdHistory.replacingOccurrences(
            of: "^.*interactive/([0-9]+).*$",
            with: "$1",
            options: .regularExpression
        )
        //        }
        updatePlayButtonUI()
//        加了此函数会show play center,它才是显示的函数而不是updatePlayingInfo()或者updateTimeForPlayerItem()，所以最好放在公共的地方; enableBackGroundMode()能直接放在运行出现的地方呢，以后不再运行？应该是不行，因为需要变化控件值。
        NowPlayingCenter().updatePlayingCenter()
//        enableBackGroundMode()
    }

    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            print("resume speech")
            self?.player?.play()
            self?.audioplayAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            self?.tabView.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.player?.pause()
            self?.audioplayAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
            self?.tabView.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
            
            return .success
        }
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
      
        let skipForwardIntervalCommand =  MPRemoteCommandCenter.shared().skipForwardCommand
        skipForwardIntervalCommand.preferredIntervals = [NSNumber(value: 15)]
        
        skipForwardIntervalCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            print("前进15s")
            let currentSliderValue = self.audioProgressSlider.value
            let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
            TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
            self.audioProgressSlider.value = currentSliderValue + 15
            self.tabView.progressSlider.value = currentSliderValue + 15
            return .success
        }
        
        let skipBackwardIntervalCommand =  MPRemoteCommandCenter.shared().skipBackwardCommand
        
        skipBackwardIntervalCommand.preferredIntervals = [NSNumber(value: 15)]
        skipBackwardIntervalCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            print("后退15s")
            let currentSliderValue = self.audioProgressSlider.value
            let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
            TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
            self.audioProgressSlider.value = currentSliderValue - 15
            self.tabView.progressSlider.value = currentSliderValue - 15
            return .success
        }
    
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        

        let changePlaybackPositionCommand = MPRemoteCommandCenter.shared().changePlaybackPositionCommand
        changePlaybackPositionCommand.isEnabled = true
        changePlaybackPositionCommand.addTarget { (MPRemoteCommandEvent:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            let changePlaybackPositionCommandEvent = MPRemoteCommandEvent as! MPChangePlaybackPositionCommandEvent
            let positionTime = changePlaybackPositionCommandEvent.positionTime
//            self.player seekToTime:CMTimeMake(totlaTime.value*playbackPositionEvent.positionTime/CMTimeGetSeconds(totlaTime), totlaTime.timescale)
            if let totlaTime = TabBarAudioContent.sharedInstance.player?.currentItem?.duration{
            
                let currentTime = CMTimeMake((totlaTime.value) * Int64(positionTime)/Int64(CMTimeGetSeconds(totlaTime)), 1)
//            TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
//            NowPlayingCenter().updatePlayingCenter()
                print("changePlaybackPosition currentTime\(currentTime)")
                print("changePlaybackPosition currentTime positionTime\(positionTime)")
            }
            return .success;
        }

        
    }
  
    // MARK: On mobile phone, lock the screen to portrait only
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.all
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override var shouldAutorotate : Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
    }

  
}
