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
//    var body = [String: String]()
//    var item: ContentItem?
    var player:AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    var title: String? = nil
    var audioUrl: URL? = nil
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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var preAudio: UIButton!
    @IBOutlet weak var nextAudio: UIButton!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playStatus: UILabel!
    
    var button: UIButton?
    //    var view1 = CustomTab(frame:CGRect(x:0,y:0,width:50,height:40))
    var tabView = CustomTab()
    var lable = CustomTab().audioLable.text
//    var animation = CustomPresentationAnimationController(isPresenting: false)
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {

        super.viewDidLoad()

        
        let width = UIScreen.main.bounds.width
        let height = self.view.bounds.height
//        let tabBarHeight = self.tabBar.
        tabView.frame = CGRect(x:0,y:height - 50,width:width,height:50)
        tabView.backgroundColor = UIColor.red
        self.tabBar.addSubview(tabView)
        
        tabView.button.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
        self.tabBar.isHidden = true
        
        view.insertSubview(self.tabView, belowSubview: self.tabBar)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.taptextField))
        tabView.button.addGestureRecognizer(tapGestureRecognizer)
        //        tabView.addGestureRecognizer(tapGestureRecognizer)
        self.delegate = self
        self.tabBar.backgroundColor =  UIColor.yellow
        //        self.reloadInputViews()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    func changeAudio(){
        self.tabBar.backgroundColor = UIColor.blue
        print("item audioLable sharedInstance\(String(describing: TabBarAudioContent.sharedInstance.title)) ")
        print("item audioLable1\(String(describing:self.tabView.audioLable.text )) ")
        
//    func changeAudio(title:String){
        self.tabView.audioLable.attributedText = NSAttributedString(string:"1111")
        print("item audioLable22\(String(describing:self.tabView.audioLable.text )) ") 
        self.lable = TabBarAudioContent.sharedInstance.title
        tabView.audioLable.backgroundColor = UIColor.yellow
        tabView.button.backgroundColor = UIColor.yellow
    }
   
    
    func taptextField(sender: UITapGestureRecognizer) {
    
        print("item11---\(String(describing: AudioContent.sharedInstance.body["title"]))")
        isShowPlayBlock = true
        let  player = TabBarAudioContent.sharedInstance.player
        let  playerItem = TabBarAudioContent.sharedInstance.playerItem
        
        if (player != nil) {
            print("item11 palyer isExist \(String(describing: playerItem))")
            if player?.rate != 0 && player?.error == nil {
                print("palyer item pause)")
                player?.pause()
                tabView.button.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            } else {
                print("palyer item play)")
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                // MARK: - Continue audio when device is in background
                try? AVAudioSession.sharedInstance().setActive(true)
                player?.play()
                player?.replaceCurrentItem(with: playerItem)
                tabView.button.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            }
        }
//        let aa = storyboard?.instantiateViewController(withIdentifier: "AudioPlayerController") as! AudioPlayerController
//        aa.modalPresentationStyle = UIModalPresentationStyle.custom
//        aa.transitioningDelegate = self
//        UIApplication.shared.keyWindow?.rootViewController?.present(aa, animated: true, completion: nil)
//        self.addChildViewController(aa)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("tabBarController didSelect")
    }


    func parseAudioMessage() {
        let body = AudioContent.sharedInstance.body
        print("interactiveUrl---\(body)")
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            print (title)
            audioTitle = title
            audioUrlString = audioFileUrl.replacingOccurrences(of: " ", with: "%20")
            audioId = interactiveUrl.replacingOccurrences(
                of: "^.*interactive/([0-9]+).*$",
                with: "$1",
                options: .regularExpression
            )
            ShareHelper.sharedInstance.webPageTitle = title
            //            print("interactiveUrl---\(title)")
        }
    }
    

    
    func prepareAudioPlay() {
        print("audioUrlString prepareAudioPlay\(audioUrlString)")
        
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
        if let url = URL(string: audioUrlString) {
            var audioUrl = url
            let cleanAudioUrl = audioUrlString.replacingOccurrences(of: "%20", with: "")
            if let localAudioFile = download.checkDownloadedFileInDirectory(cleanAudioUrl) {
                print ("The Audio is already downloaded")
                audioUrl = URL(fileURLWithPath: localAudioFile)
            }
    
            // MARK: -delete progressSlider setting here
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            
            
            if player != nil {
                print("url item palyer exist")
//                return
            }else {
                print("url item palyer do not exist")
                player = AVPlayer()
            }
            playerLayer=AVPlayerLayer(player: player!)
            playerLayer?.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
            self.view.layer.addSublayer(playerLayer!)
//            queuePlayer = AVQueuePlayer(playerItem:playerItem)
//            queuePlayer?.insert(playerItem!, after: playerItem)
//            queuePlayer?.advanceToNextItem()
            
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            // MARK: - Update audio play progress
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
                if let d = self?.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
//                        self?.progressSlider.maximumValue = Float(duration)
//                        if self?.progressSlider.isHighlighted == false {
//                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
//                        }
//                        self?.updatePlayTime(current: time, duration: d)
                    }
                }
            }
            print("url item palyer continue?")
            //
            // MARK: - Observe Audio Route Change and Update UI accordingly
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(AudioPlayerBar.updatePlayButtonUI),
//                // MARK: - It has to be NSNotification, not Notification
//                name: NSNotification.Name.AVAudioSessionRouteChange,
//                object: nil
//            )
            addPlayerItemObservers()
        }
    }
    
    func updateAVPlayerWithLocalUrl() {
        if let localAudioFile = download.checkDownloadedFileInDirectory(audioUrlString) {
            let currentSliderValue = self.progressSlider.value
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
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // MARK: - Update buffer status
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }
    
    //    private func updatePlayTime(current time: CMTime, duration: CMTime) {
    //        playDuration.text = "-\((duration-time).durationText)"
    //        playTime.text = time.durationText
    //    }
    
//    public func updatePlayButtonUI() {
//        if let player = player {
//            if (player.rate != 0) && (player.error == nil) {
//                
//                self.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
//            } else {
//                self.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
//            }
//        }
//    }

    func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
//        self.progressSlider.value = 0
        self.tabView.button.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
        let stopedPlayerItem: AVPlayerItem = NSNotification().object as! AVPlayerItem
        stopedPlayerItem.seek(to: kCMTimeZero)
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
//            if let time = playerItem?.currentTime(), let duration = playerItem?.duration {
//                updatePlayTime(current: time, duration: duration)
//            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
  

}
