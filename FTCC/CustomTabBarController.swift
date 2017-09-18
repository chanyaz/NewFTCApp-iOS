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
    private var urlStrings: [String]? = []
    private var urlOrigStrings: [String] = []
    private var urlTempStrings: [String] = []
    private var urlAssets: [AVURLAsset]? = []
    
    
    private var playingUrlStr:String? = ""
    private var playingIndex:Int = 0
    private var playingUrl:URL? = nil
    var count:Int = 0
    
    var fetchAudioResults: [ContentSection]?
    var item: ContentItem?
    var themeColor: String?
    
    let audioView = UIView()
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
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let audioViewHeight:CGFloat = 250
        let buttonWidth:CGFloat = 19
        let buttonHeight: CGFloat = 19
        let margin:CGFloat = 20
        let space = (width - margin*2 - buttonWidth*4)/3
        let spaceBetweenListAndView: CGFloat = 30
        let listY = audioViewHeight - buttonHeight - spaceBetweenListAndView
        let spaceBetweenListAndForward: CGFloat = 50
        let spaceBetweenPreAndForward = (width - margin*2 - buttonWidth*6)/4
        let forwardY = audioViewHeight - spaceBetweenListAndForward*2 - buttonHeight*2
        
        
        preAudio.frame = CGRect(x:margin+buttonWidth+spaceBetweenPreAndForward,y:forwardY,width:buttonWidth,height:buttonHeight)
        preAudio.attributedTitle(for: UIControlState.normal)
        preAudio.setImage(UIImage(named:"PreBtn"), for: UIControlState.normal)
        preAudio.addTarget(self, action: #selector(switchToPreAudio), for: UIControlEvents.touchUpInside)
        
        nextAudio.frame = CGRect(x:margin+buttonWidth*4+spaceBetweenPreAndForward*3,y:forwardY,width:buttonWidth,height:buttonHeight)
        nextAudio.attributedTitle(for: UIControlState.normal)
        nextAudio.setImage(UIImage(named:"NextBtn"), for: UIControlState.normal)
        nextAudio.addTarget(self, action: #selector(switchToNextAudio), for: UIControlEvents.touchUpInside)
        
        forward.frame = CGRect(x:margin,y:forwardY,width:buttonWidth,height:buttonHeight)
        forward.attributedTitle(for: UIControlState.normal)
        forward.setImage(UIImage(named:"FastForwardBtn"), for: UIControlState.normal)
        forward.addTarget(self, action: #selector(skipForward), for: UIControlEvents.touchUpInside)
        
        
        
        back.frame = CGRect(x:width - margin - buttonWidth,y:forwardY,width:buttonWidth,height:buttonHeight)
        back.attributedTitle(for: UIControlState.normal)
        back.setImage(UIImage(named:"FastBackBtn"), for: UIControlState.normal)
        back.addTarget(self, action: #selector(skipBackward), for: UIControlEvents.touchUpInside)
        
        
        audioplayAndPauseButton.frame = CGRect(x:(width/2)-25,y:forwardY-buttonHeight/2,width:buttonWidth*2,height:buttonHeight*2)
        audioplayAndPauseButton.attributedTitle(for: UIControlState.normal)
        audioplayAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
        audioplayAndPauseButton.addTarget(self, action: #selector(pauseOrPlay), for: UIControlEvents.touchUpInside)
        
        list.frame = CGRect(x:margin,y:listY,width:buttonWidth,height:buttonHeight)
        list.attributedTitle(for: UIControlState.normal)
        list.setImage(UIImage(named:"ListBtn"), for: UIControlState.normal)
        list.addTarget(self, action: #selector(listAction), for: UIControlEvents.touchUpInside)
        
        downLoad.frame = CGRect(x:margin+buttonWidth+space,y:listY,width:buttonWidth,height:buttonHeight)
        downLoad.attributedTitle(for: UIControlState.normal)
        downLoad.setImage(UIImage(named:"DownLoadBtn"), for: UIControlState.normal)
        downLoad.addTarget(self, action: #selector(downLoadAction), for: UIControlEvents.touchUpInside)
        
        love.frame = CGRect(x:margin+buttonWidth*2+space*2,y:listY,width:buttonWidth,height:buttonHeight)
        love.attributedTitle(for: UIControlState.normal)
        love.setImage(UIImage(named:"LoveBtn"), for: UIControlState.normal)
        love.addTarget(self, action: #selector(downLoadAction), for: UIControlEvents.touchUpInside)
        
        share.frame = CGRect(x:margin+buttonWidth*3+space*3,y:listY,width:buttonWidth,height:buttonHeight)
        share.attributedTitle(for: UIControlState.normal)
        share.setImage(UIImage(named:"ShareBtn"), for: UIControlState.normal)
        share.addTarget(self, action: #selector(shareAction), for: UIControlEvents.touchUpInside)
        
        
        webAudioView.frame = CGRect(x:0,y:90,width:width,height:height)
        webAudioView.isOpaque = true
        webAudioView.layer.backgroundColor = UIColor.yellow.cgColor
        webAudioView.backgroundColor = UIColor.red
        webAudioView.layer.zPosition = 100
        
        audioPlayTime.frame = CGRect(x:5,y:58,width:50,height:20)
        audioPlayTime.text = "00:00"
        audioPlayTime.textColor = UIColor.white
        
        audioPlayDuration.frame = CGRect(x:width-60,y:58,width:70,height:20)
        audioPlayDuration.text = "00:00"
        audioPlayDuration.textColor = UIColor.white
        
        audioProgressSlider.frame = CGRect(x:60,y:58,width:width - 140,height:20)
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
        
        downSwipeButton.frame = CGRect(x:width-60,y:10,width:40,height:40)
        downSwipeButton.setImage(UIImage(named:"HideBtn"), for: UIControlState.normal)
//        downSwipeButton.setTitle("下滑", for: .normal)
        downSwipeButton.backgroundColor = UIColor.green
        
        audioView.frame = CGRect(x:0,y:height - audioViewHeight+90,width:width,height:audioViewHeight)
        audioView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.9)
        audioView.addSubview(audioPlayStatus)
        audioView.addSubview(audioplayAndPauseButton)
        audioView.addSubview(audioProgressSlider)
        audioView.addSubview(audioPlayTime)
        audioView.addSubview(audioPlayDuration)
        audioView.addSubview(downSwipeButton)
        //        audioView.addSubview(webAudioView)
        audioView.addSubview(back)
        audioView.addSubview(forward)
        audioView.addSubview(nextAudio)
        audioView.addSubview(preAudio)
        audioView.addSubview(list)
        audioView.addSubview(downLoad)
        audioView.addSubview(love)
        audioView.addSubview(share)
        tabView.addSubview(webAudioView)
        
        audioView.layer.zPosition = 200
        tabView.addSubview(audioView)
        
        
        
        
        //        tabView.addSubview(audioPlayStatus)
        //        tabView.addSubview(audioplayAndPauseButton)
        //        tabView.addSubview(audioProgressSlider)
        //        tabView.addSubview(audioPlayTime)
        //        tabView.addSubview(audioPlayDuration)
        //        tabView.addSubview(downSwipeButton)
        //        tabView.addSubview(webAudioView)
        //        tabView.addSubview(list)
        
        tabView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.9)
        tabView.frame = CGRect(x:0,y:height-90,width:width,height:height+90)
        
        view.addSubview(self.tabView)
        
        //        self.tabView.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        self.list.translatesAutoresizingMaskIntoConstraints = false
        //        self.list.addConstraint(NSLayoutConstraint(item: list, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20))
        //        self.list.addConstraint(NSLayoutConstraint(item: list, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20))
        //        self.list.addConstraint(NSLayoutConstraint(item: list, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.audioView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20))
        
        tabView.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
        self.tabBar.isHidden = true
        
        //        view.insertSubview(self.audioPlayerView, belowSubview: self.tabBar)
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.openAudio))
        tabView.upSwipeButton.addGestureRecognizer(tapGestureRecognizer1)
        
        
        tabView.playAndPauseButton.addTarget(self, action: #selector(pauseOrPlay), for: UIControlEvents.touchUpInside)
        
        
        downSwipeButton.addTarget(self, action: #selector(exitAudio), for: UIControlEvents.touchUpInside)
        
        player = TabBarAudioContent.sharedInstance.player
        
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        self.delegate = self
        
        
        //        监听不能放在loadView和viewDidLoad中，因为加载好多次
        //        估计tabBarController先出来，所以获取不到fetchAudioResults
        audioAddGesture()
        //        print("how much viewDidLoad")
        //        fetchAudioResults = TabBarAudioContent.sharedInstance.fetchResults
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
        print("how much viewDidAppear")
    }
    func switchToPreAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        removePlayerItemObservers()
        print("urlString playingIndex pre\(playingIndex)")
        
        
        if fetchAudioResults != nil {
            playingIndex = playingIndex-1
            if playingIndex < 0{
                playingIndex = count - 1
                
            }
            //            ContentItemContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
            let preUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
            audioUrlString = preUrl
            
            updateSingleTonData()
            prepareAudioPlay()
        }
        
    }
    func switchToNextAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        if fetchAudioResults != nil {
            
            removePlayerItemObservers()
            playingIndex += 1
            if playingIndex >= count{
                playingIndex = 0
            }
            
            //            ContentItemContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
            let nextUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
            print("urlString playingIndex\(playingIndex)")
            
            audioUrlString = nextUrl
            updateSingleTonData()
            prepareAudioPlay()
            
        }
    }
    func skipForward(_ sender: UIButton) {
        let currentSliderValue = self.audioProgressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        self.audioProgressSlider.value = currentSliderValue - 15
        self.tabView.progressSlider.value = currentSliderValue - 15
    }
    func skipBackward(_ sender: UIButton) {
        let currentSliderValue = self.audioProgressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        self.audioProgressSlider.value = currentSliderValue + 15
        self.tabView.progressSlider.value = currentSliderValue + 15
    }
    func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        
    }
    
    func listAction(){
        if let listPerColumnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController {
            listPerColumnViewController.fetchListResults = TabBarAudioContent.sharedInstance.fetchResults
            listPerColumnViewController.modalPresentationStyle = .custom
            self.present(listPerColumnViewController, animated: true, completion: nil)
            
        }
    }
    func downLoadAction(_ sender: Any){
        print("download button111\( audioUrlString)")
        
        if audioUrlString != "" {
            print("download button\( audioUrlString)")
            if let button = sender as? UIButtonEnhanced {
                // FIXME: should handle all the status and actions to the download helper
                download.takeActions(audioUrlString, currentStatus: button.status)
                print("download button\( button.status)")
            }
            
        }
    }
    func shareAction(){
        if let item = item {
            self.launchActionSheet(for: item)
        }
    }
    //    playingIndex应该放在时刻跟新的地方获取
    func updateSingleTonData(){
        if let fetchAudioResults = fetchAudioResults, let audioFileUrl = fetchAudioResults[0].items[playingIndex].audioFileUrl {
            TabBarAudioContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
            self.tabView.audioLable.text = fetchAudioResults[0].items[playingIndex].headline
            self.audioPlayStatus.text = fetchAudioResults[0].items[playingIndex].headline
            TabBarAudioContent.sharedInstance.body["title"] = fetchAudioResults[0].items[playingIndex].headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(fetchAudioResults[0].items[playingIndex].id)"
            parseAudioMessage()
            loadUrl()
            
        }
    }
    private func getPlayingUrl(){
        //        print("urlString fetchAudioResults\(String(describing: fetchAudioResults))")
        var urlAsset : URL?
        var playerItemTemp : AVPlayerItem?
        if let fetchAudioResults = fetchAudioResults {
            for (_, item0) in fetchAudioResults[0].items.enumerated() {
                print("urlString000---\(item0)")
                //        for (_, item0) in fetchesAudioObject.fetchResults[0].items.enumerated() {
                if var fileUrl = item0.audioFileUrl {
                    urlOrigStrings.append(fileUrl)
                    fileUrl = fileUrl.replacingOccurrences(of: " ", with: "%20")
                    fileUrl = fileUrl.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
                    urlTempStrings.append(fileUrl) //处理后的audioUrlString
                    fileUrl = fileUrl.replacingOccurrences(of: "%20", with: "")
                    urlStrings?.append(fileUrl)
                    urlAsset = URL(string: fileUrl)
                    playerItemTemp = AVPlayerItem(url: urlAsset!) //可以用于播放的playItem
                    playerItems?.append(playerItemTemp!)
                }
            }
        }
        
        
        print("urlString playerItems000---\(String(describing: playerItems))")
        
        audioUrlString = audioUrlString.replacingOccurrences(of: "%20", with: " ")
        for (urlIndex,urlTempString) in (urlOrigStrings.enumerated()) {
            //            这里面没有执行
            //            第一次点击audioUrlString为空，第二次点击有值
            print("urlString audioUrlString--\(audioUrlString)")
            print("urlString audioUrlString urlTempString--\(urlTempString)")
            if audioUrlString != "" {
                if audioUrlString == urlTempString{
                    print("urlString audioUrlString111---\(String(describing: audioUrlString))")
                    playingUrlStr = urlTempString
                    playingIndex = urlIndex
                }
            }
        }
        print("urlString playingIndex222--\(playingIndex)")
        
    }
    
    
    func exitAudio(){
        //        let deltaY = self.view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.tabView.transform = CGAffineTransform(translationX: 0,y:0)
            self.tabView.setNeedsUpdateConstraints()
            
        }, completion: { (true) in
            print("up animate finish")
        })
    }
    //    把此页面的所有信息都传给AudioPlayBar,包括player，playerItem
    func openAudio(){
        let deltaY = self.view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.tabView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
            self.tabView.setNeedsUpdateConstraints()
//            self.audioView.transform = CGAffineTransform(translationX: 0,y: 90)
            
            
        }, completion: { (true) in
            print("up animate finish")
        })
        playingIndex = 0
        urlOrigStrings = []
        parseAudioMessage()
        getPlayingUrl()
        loadUrl()
        //  getPlayingUrl()需要放在parseAudioMessage()后面，不然第一次audioUrlString为空
        //     getPlayingUrl()放在此处，playingIndex一直为0？
    }
    
    func pauseOrPlay(sender: UIButton) {
        //    func taptextField(sender: UITapGestureRecognizer) {
        player = TabBarAudioContent.sharedInstance.player
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        
        if (player != nil) {
            print("item11 palyer isExist \(String(describing: playerItem))")
            if player?.rate != 0 && player?.error == nil {
                print("palyer item pause)")
                audioplayAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
                tabView.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
                player?.pause()
                
            } else {
                print("palyer item play)")
                audioplayAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
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
                //                downloadButton.setImage(UIImage(named:"DeleteButton"), for: .normal)
            }
            // MARK: - Draw a circle around the downloadButton
            //            downloadButton.drawCircle()
            
            // MARK: - Set sourceVC as self so that the alert can be popped out
            // download.sourceVC = self
            
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            
            if player != nil {
                print("palyer exist")
            }else {
                print("palyer not exist")
                player = AVPlayer()
                
            }
            
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            
            
            
            //            此处闪动一下，应该是被覆盖了
            
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
            if let player = player {
                player.play()
            }
            
            self.audioplayAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
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
                        self?.audioProgressSlider.maximumValue = Float(duration)
                        self?.tabView.progressSlider.maximumValue = Float(duration)
                        if self?.audioProgressSlider.isHighlighted == false {
                            self?.audioProgressSlider.value = Float((CMTimeGetSeconds(time)))
                            self?.tabView.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                        self?.updatePlayTime(current: time, duration: d)
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
//            
//            // MARK: - Observe Audio Route Change and Update UI accordingly
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(AudioPlayerController.updatePlayButtonUI),
//                // MARK: - It has to be NSNotification, not Notification
//                name: NSNotification.Name.AVAudioSessionRouteChange,
//                object: nil
//            )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
            addPlayerItemObservers()
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
        //                let body = AudioContent.sharedInstance.body
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
    func updateMiniPlay(){
        player = TabBarAudioContent.sharedInstance.player
        //        点击list一次也会继续监听
        print("how much updateMiniPlay")
        audioPlayStatus.text=TabBarAudioContent.sharedInstance.item?.headline
        self.tabView.audioLable.text = TabBarAudioContent.sharedInstance.item?.headline

        //        需要获取全局player
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
            
            if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
                //                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
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
        
        if TabBarAudioContent.sharedInstance.isPlaying{
            audioplayAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            tabView.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            
        }else{
            audioplayAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            tabView.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        }
        
        
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
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
    func isHideAudio(sender: UISwipeGestureRecognizer){
        if sender.direction == .up{
            print("up hide audio")
            
            let deltaY = self.audioView.bounds.height
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.audioView.transform = CGAffineTransform(translationX: 0,y: deltaY)
                self.audioView.setNeedsUpdateConstraints()
            }, completion: { (true) in
                print("up animate finish")
            })
        }else if sender.direction == .down{
            print("down show audio")
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
        
    }
    
    func reloadAudioView(){
        //        item的值得时刻记住更新，最好传全局变量还是用自身局部变量？，可以从tab中把值传给此audio么？
        //        需要同时更新webView和id 、item等所有一致性变量，应该把他们整合到一起，一起处理循环、下一首、列表更新
        //        print("reloadAudioView--\(TabBarAudioContent.sharedInstance.item)")
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
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("tabBarController didSelect")
    }
    
    func removePlayerItemObservers() {
        print("removePlayerItemObservers")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: TabBarAudioContent.sharedInstance.playerItem)

        
    }
    
    func addPlayerItemObservers() {
        // MARK: - Observe Play to the End
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: TabBarAudioContent.sharedInstance.playerItem)
        
        
    }
    func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.audioProgressSlider.value = 0
        self.audioplayAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        
        nowPlayingCenter.updateTimeForPlayerItem(player)
        //                orderPlay()
        //        let mode = TabBarAudioContent.sharedInstance.mode
        if let mode = TabBarAudioContent.sharedInstance.mode {
            switch mode {
            case 0:
                orderPlay()
            case 1:
                randomPlay()
            case 2:
                onePlay()
            case 3:
                randomPlay()
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
        let currentItem = self.player?.currentItem
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
        let currentItem = self.player?.currentItem
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
        self.tabView.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        self.audioplayAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    
    
}
