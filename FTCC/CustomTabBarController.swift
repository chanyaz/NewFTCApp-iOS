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

class TabBarAudioContent {
    static let sharedInstance = TabBarAudioContent()
    var body = [String: String]()
    var item: ContentItem?
    var player:AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    var title: String? = nil
    var audioUrl: URL? = nil
    var duration: CMTime? = nil
    var time:CMTime? = nil
    var sliderValue:Float? = nil
    var parsedUrlString:String? = nil
    var isPlaying:Bool=false
    
}

class CustomTabBarController: UITabBarController,UITabBarControllerDelegate {
    
    var isShowPlayBlock :Bool = false
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
    
    
    
    //    var button: UIButton?
    //    var view1 = CustomTab(frame:CGRect(x:0,y:0,width:50,height:40))
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
        
        self.tabBar.addSubview(tabView)
        
        tabView.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
        self.tabBar.isHidden = true
        view.insertSubview(self.tabView, aboveSubview: self.tabBar)
        //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.taptextField))
        //        tabView.button.addGestureRecognizer(tapGestureRecognizer)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.openAudio))
        
        tabView.playAndPauseButton.addTarget(self, action: #selector(taptextField), for: UIControlEvents.touchUpInside)
        tabView.upSwipeButton.addGestureRecognizer(tapGestureRecognizer1)
        self.delegate = self
        
        tabView.progressSlider.addTarget(self, action: #selector(changeSlider), for: UIControlEvents.valueChanged)
    }
    
    func changeSlider(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        //        playerItem?.seek(to: currentTime)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        print("sliderValueChanged button\(currentTime)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    //    把此页面的所有信息都传给AudioPlayBar,包括player，playerItem
    func openAudio(){
        
        if let audioPlayerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayerController") as? AudioPlayerController {
            let tabItem = TabBarAudioContent.sharedInstance.item
            
            if let tabItem = tabItem ,let audioFileUrl = tabItem.audioFileUrl {
                
                //                AudioContent.sharedInstance.body["title"] = tabItem.headline
                //                AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                //                AudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(tabItem.id)"
                TabBarAudioContent.sharedInstance.body["title"] = tabItem.headline
                TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(tabItem.id)"
                audioPlayerController.item = tabItem
            }
            
            audioPlayerController.modalPresentationStyle = .custom
            self.present(audioPlayerController, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    func taptextField(sender: UIButton) {
        //    func taptextField(sender: UITapGestureRecognizer) {
        isShowPlayBlock = true
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
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("tabBarController didSelect")
    }
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        self.tabView.playDuration.text = "-\((duration-time).durationText)"
        self.tabView.playTime.text = time.durationText
    }
    
    func parseAudioMessage() {
        let body = TabBarAudioContent.sharedInstance.body
        //        let body = AudioContent.sharedInstance.body
        print("interactiveUrl---\(body)")
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
    
    
    func prepareAudioPlay() {
        print("audioUrlString prepareAudioPlay\(audioUrlString)")
        
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
        if let url = URL(string: audioUrlString) {
            var audioUrl = url
            let cleanAudioUrl = audioUrlString.replacingOccurrences(of: "%20", with: "")
            if let localAudioFile = download.checkDownloadedFileInDirectory(cleanAudioUrl) {
                audioUrl = URL(fileURLWithPath: localAudioFile)
            }
            
            TabBarAudioContent.sharedInstance.parsedUrlString = cleanAudioUrl
            // MARK: -delete progressSlider setting here
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            
            
            if player != nil {
                print("url item palyer exist")
            }else {
                print("url item palyer do not exist")
                player = AVPlayer()
            }
            playerLayer=AVPlayerLayer(player: player!)
            playerLayer?.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
            self.view.layer.addSublayer(playerLayer!)
            TabBarAudioContent.sharedInstance.isPlaying = true
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            // MARK: - Update audio play progress
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
                
                if let d = self?.playerItem?.duration {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        //                        self?.tabView.progressSlider.maximumValue = Float(duration)
                        //                        if self?.tabView.progressSlider.isHighlighted == false {
                        //                            self?.tabView.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        //                        }
                        TabBarAudioContent.sharedInstance.duration = d
                        TabBarAudioContent.sharedInstance.time = time
                        
                        
                        //                        self?.updatePlayTime(current: time, duration: d)
                    }
                }
                
                
            }
            
            
            // MARK: - Observe download status change
            //            NotificationCenter.default.addObserver(
            //                self,
            //                selector: #selector(AudioPlayerController.handleDownloadStatusChange(_:)),
            //                name: Notification.Name(rawValue: download.downloadStatusNotificationName),
            //                object: nil
            //            )
            //
            //            // MARK: - Observe download progress change
            //            NotificationCenter.default.addObserver(
            //                self,
            //                selector: #selector(AudioPlayerController.handleDownloadProgressChange(_:)),
            //                name: Notification.Name(rawValue: download.downloadProgressNotificationName),
            //                object: nil
            //            )
            
            // MARK: - Observe Audio Route Change and Update UI accordingly
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.updatePlayButtonUI),
                // MARK: - It has to be NSNotification, not Notification
                name: NSNotification.Name.AVAudioSessionRouteChange,
                object: nil
            )
            addPlayerItemObservers()
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
    }
    
    private func addPlayerItemObservers() {
        // MARK: - Observe Play to the End
        NotificationCenter.default.addObserver(self,selector:#selector(AudioPlayerController.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // MARK: - Update buffer status
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }
    
    
    
    public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                
                tabView.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            } else {
                tabView.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            }
        }
    }
    
    func playerDidFinishPlaying() {
        print("finish playing")
        let startTime = CMTimeMake(0, 1)
        TabBarAudioContent.sharedInstance.player?.pause()
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: startTime)
        //        self.button?.setTitle("finish", for: .normal)
        //        self.playerItem?.seek(to: startTime)
        //        self.player?.pause()
        self.tabView.progressSlider.value = 0
        self.tabView.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
        //        let stopedPlayerItem: AVPlayerItem = NSNotification().object as! AVPlayerItem
        //        stopedPlayerItem.seek(to: kCMTimeZero)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    // Show loader
                    print ("is loading...")
                    self.tabView.audioLable.text = "加载中..."
                    //                    playStatus.text = "加载中..."
                    
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    print ("should be playing. Duration is \(String(describing: playerItem?.duration))")
                    self.tabView.audioLable.text = audioTitle
                //                    playStatus.text = audioTitle
                case "playbackBufferFull":
                    // Hide loader
                    self.tabView.audioLable.text = audioTitle
                    print ("load successfully")
                //                    playStatus.text = audioTitle
                default:
                    self.tabView.audioLable.text = audioTitle
                    //                    playStatus.text = audioTitle
                    break
                }
            }
            if let time = playerItem?.currentTime(), let duration = playerItem?.duration {
                updatePlayTime(current: time, duration: duration)
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    
    
}
