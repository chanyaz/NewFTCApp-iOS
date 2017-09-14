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



class CustomTabBarController: UITabBarController,UITabBarControllerDelegate {
    
    
    var audioTitle = ""
    var audioUrlString = ""
    var audioId = ""
    lazy var player: AVPlayer? = nil
    lazy var playerItem: AVPlayerItem? = nil
    var playerLayer: AVPlayerLayer? = nil
    
    var queuePlayer:AVQueuePlayer?
    
    let nowPlayingCenter = NowPlayingCenter()
    let download = DownloadHelper(directory: "audio")
    
    var item: ContentItem?
    var themeColor: String?
    
    var tabView = CustomTab()
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.width
        let height = self.view.bounds.height
        tabView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.9)
        tabView.frame = CGRect(x:0,y:height - 90,width:width,height:90)
        
        
        tabView.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
        self.tabBar.isHidden = true
        view.addSubview(self.tabView)
        //        view.insertSubview(self.tabView, aboveSubview: self.tabBar)
        //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.taptextField))
        //        tabView.button.addGestureRecognizer(tapGestureRecognizer)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.openAudio))
        
        tabView.playAndPauseButton.addTarget(self, action: #selector(taptextField), for: UIControlEvents.touchUpInside)
        tabView.upSwipeButton.addGestureRecognizer(tapGestureRecognizer1)
        self.delegate = self
        
        tabView.progressSlider.addTarget(self, action: #selector(changeSlider), for: UIControlEvents.valueChanged)
        //        print("how many time viewDidLoad execute?")
        //        第一次点击调用一次执行一次，后面点击就不执行
        player = TabBarAudioContent.sharedInstance.player
        
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        //        此处可以运行上次最后一次播放的playerItem，怎么确定最后一次播放呢？是把上一次缓存下来么？没触发动作，退出audio
        
    }
    
    func changeSlider(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
    }
    
 
    let aa = TabBarAudioContent.sharedInstance.player
    //    把此页面的所有信息都传给AudioPlayBar,包括player，playerItem
    func openAudio(){
        
        if let audioPlayerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayerController") as? AudioPlayerController {
            let tabItem = TabBarAudioContent.sharedInstance.item
            
            if let tabItem = tabItem ,let audioFileUrl = tabItem.audioFileUrl {
                
                AudioContent.sharedInstance.body["title"] = tabItem.headline
                AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                AudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(tabItem.id)"
                //                TabBarAudioContent.sharedInstance.body["title"] = tabItem.headline
                //                TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                //                TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(tabItem.id)"
                audioPlayerController.item = tabItem
            }
            
            audioPlayerController.modalPresentationStyle = .custom
            self.present(audioPlayerController, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    func taptextField(sender: UIButton) {
        let  player = TabBarAudioContent.sharedInstance.player
        let  playerItem = TabBarAudioContent.sharedInstance.playerItem
        
        if (player != nil) {
            print("item11 palyer isExist \(String(describing: playerItem))")
            if player?.rate != 0 && player?.error == nil {
                print("palyer item pause)")
                tabView.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
                player?.pause()
                
            } else {
                print("palyer item play)")
                tabView.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = true
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                // MARK: - Continue audio when device is in background
                try? AVAudioSession.sharedInstance().setActive(true)
                player?.play()
                player?.replaceCurrentItem(with: playerItem)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        self.tabView.playDuration.text = "-\((duration-time).durationText)"
        self.tabView.playTime.text = time.durationText
        //        self.tabView.setNeedsDisplay()
        //        self.tabView.setNeedsLayout()
    }
    

    
//    func updateAVPlayerWithLocalUrl() {
//        if let localAudioFile = download.checkDownloadedFileInDirectory(audioUrlString) {
//            let currentSliderValue = tabView.progressSlider.value
//            let audioUrl = URL(fileURLWithPath: localAudioFile)
//            let asset = AVURLAsset(url: audioUrl)
//            removePlayerItemObservers()
//            playerItem = AVPlayerItem(asset: asset)
//            player?.replaceCurrentItem(with: playerItem)
//            addPlayerItemObservers()
//            let currentTime = CMTimeMake(Int64(currentSliderValue), 1)
//            playerItem?.seek(to: currentTime)
//            nowPlayingCenter.updateTimeForPlayerItem(player)
//            print ("now use local file to play at \(currentTime)")
//        }
//    }
    
//    func removePlayerItemObservers() {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
//    }
//    
//    func addPlayerItemObservers() {
//        // MARK: - Observe Play to the End
//        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
//    }
    
    
    
    public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                
                tabView.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            } else {
                tabView.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            }
        }
    }
    
//    func playerDidFinishPlaying() {
//        print("finish playing")
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playFinish"), object: self)
//        TabBarAudioContent.sharedInstance.player?.pause()
//        nowPlayingCenter.updateTimeForPlayerItem(player)
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
 
    }
    
    
}
