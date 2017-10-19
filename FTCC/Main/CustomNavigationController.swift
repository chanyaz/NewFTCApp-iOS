//
//  CustomNavigationController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/7.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices


class CustomNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var isLightContent = false
    var tabName: String? = nil

    var audioTitle = ""
    var audioUrlString = ""
    var audioId = ""
    lazy var player: AVPlayer? = nil
    lazy var playerItem: AVPlayerItem? = nil
    var playerLayer: AVPlayerLayer? = nil
    
    var queuePlayer:AVQueuePlayer?
    
    let nowPlayingCenter = NowPlayingCenter()
    let download = DownloadHelper(directory: "audio")
    
    var fetchAudioResults: [ContentSection]?
    var item: ContentItem?
    var themeColor: String?
    
    var tabView = CustomTab()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tabBarController?.tabBar.tintColor = AppNavigation.getThemeColor(for: tabName)
        self.navigationBar.barStyle = .default
        print("CustomNavigationController viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
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
    }

//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return UIStatusBarStyle.default
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.width
        let height = self.view.bounds.height
        tabView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.5)
        tabView.frame = CGRect(x:0,y:height - 90,width:width,height:90)
        view.addSubview(self.tabView)
        tabView.playAndPauseButton.addTarget(self, action: #selector(pauseOrPlay), for: UIControlEvents.touchUpInside)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.openAudio))
        tabView.smallView.addGestureRecognizer(tapGestureRecognizer1)
        tabView.progressSlider.addTarget(self, action: #selector(changeSlider), for: UIControlEvents.valueChanged)
        tabView.isHidden = true
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        addPlayerItemObservers()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBarStyle),
            name: Notification.Name(rawValue: "updateBarStyle"),
            object: nil
        )
    }
    @objc func updateBarStyle(){
        self.navigationBar.barStyle = .default
    }
    @objc func changeSlider(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        print("sliderValueChanged button\(currentTime)")
    }
    @objc func openAudio(){
        
        if let audioPlayerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayerController") as? AudioPlayerController {
            let tabItem = TabBarAudioContent.sharedInstance.item
            if let tabItem = tabItem ,let audioFileUrl = tabItem.caudio {
                TabBarAudioContent.sharedInstance.body["title"] = tabItem.headline
                TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(tabItem.id)"
                audioPlayerController.item = tabItem
            }
            audioPlayerController.modalPresentationStyle = .custom
            self.present(audioPlayerController, animated: true, completion: nil)

//          self.pushViewController(audioPlayerController, animated: false)
        }
        self.navigationBar.barStyle = .black
    }
    
    @objc func pauseOrPlay(sender: UIButton) {
        let  player = TabBarAudioContent.sharedInstance.player
        let  playerItem = TabBarAudioContent.sharedInstance.playerItem
        
        if (player != nil) {
            print("item11 palyer isExist \(String(describing: playerItem))")
            if player?.rate != 0 && player?.error == nil {
                print("palyer item pause)")
                tabView.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
                player?.pause()
                
            } else {
                print("palyer item play)")
                tabView.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = true
                
                player?.play()
                player?.replaceCurrentItem(with: playerItem)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func updateMiniPlay(){
        tabView.isHidden = false
        if let item = TabBarAudioContent.sharedInstance.item{
            player = TabBarAudioContent.sharedInstance.player
            self.tabView.playStatus.text = item.headline
            updateProgressSlider()
            updatePlayButtonUI()
        }
    }
    func updateProgressSlider(){
        // MARK: - Update audio play progress
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
            if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
                let duration = CMTimeGetSeconds(d)
                if duration.isNaN == false {
                    self?.tabView.progressSlider.maximumValue = Float(duration)
                    if self?.tabView.progressSlider.isHighlighted == false {
                        self?.tabView.progressSlider.value = Float((CMTimeGetSeconds(time)))
                    }
                    self?.updatePlayTime(current: time, duration: d)
                    TabBarAudioContent.sharedInstance.duration = d
                    TabBarAudioContent.sharedInstance.time = time
                }
            }
        }
    }
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        self.tabView.playDuration.text = "-\((duration-time).durationText)"
        self.tabView.playTime.text = time.durationText
    }
    @objc func reloadAudioView(){
        if let item = TabBarAudioContent.sharedInstance.item,let audioUrlStrFromList = item.caudio  {
            print("audioUrlStrFromList--\(audioUrlStrFromList)")
            self.tabView.playStatus.text = item.headline
            //           为什么 TabBarAudioContent.sharedInstance.audioHeadLine 一直保持初始值？因为点击首页播放按钮触发的赋值动作，collectionView中cell监听的动作只要其他地方监听会一直触发动作（有待继续核实）
            
        }
        print("audioUrlStrFromList isplaying？--\(TabBarAudioContent.sharedInstance.isPlaying)")
        
        //        updatePlayButtonUI()
        //        反着的原因是可能是初始监控为true的原因
        if TabBarAudioContent.sharedInstance.isPlaying{
            tabView.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
        }else{
            tabView.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
        }
    }
    
    func updateAVPlayerWithLocalUrl() {
        if let localAudioFile = download.checkDownloadedFileInDirectory(audioUrlString) {
            let currentSliderValue = tabView.progressSlider.value
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
    
    func removePlayerItemObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: TabBarAudioContent.sharedInstance.playerItem)
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
    }
    
    private func addPlayerItemObservers() {
        // MARK: - Observe Play to the End
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: TabBarAudioContent.sharedInstance.playerItem)
        
        // MARK: - Update buffer status
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }
    
    
    
    @objc public func updatePlayButtonUI() {
        if TabBarAudioContent.sharedInstance.isPlaying{
            tabView.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
            
        }else{
            tabView.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
        }
    }
    
    @objc func playerDidFinishPlaying() {
        print("finish playing")
        let startTime = CMTimeMake(0, 1)
        TabBarAudioContent.sharedInstance.player?.pause()
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: startTime)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.tabView.progressSlider.value = 0
        self.tabView.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    // Show loader
                    print ("is loading...")
                    self.tabView.playStatus.text = "加载中..."
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    print ("should be playing. Duration is \(String(describing: playerItem?.duration))")
                    self.tabView.playStatus.text = audioTitle
                case "playbackBufferFull":
                    // Hide loader
                    self.tabView.playStatus.text = audioTitle
                    print ("load successfully")
                default:
                    self.tabView.playStatus.text = audioTitle
                    break
                }
            }
            if let time = playerItem?.currentTime(), let duration = playerItem?.duration {
                updatePlayTime(current: time, duration: duration)
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
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
