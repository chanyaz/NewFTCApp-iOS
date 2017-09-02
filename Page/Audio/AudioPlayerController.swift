//
//  AudioPlayerController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices

// MARK: - Use singleton pattern to pass speech data between view controllers. It's better in in term of code style than prepare segue.

struct AudioPlayerStyle {
    static let height: CGFloat = 200
}

class AudioPlayerController: UIViewController,WKScriptMessageHandler,UIScrollViewDelegate,WKNavigationDelegate,UIViewControllerTransitioningDelegate {
    
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    private lazy var webView: WKWebView? = nil
    private let nowPlayingCenter = NowPlayingCenter()
    private let download = DownloadHelper(directory: "audio")
    
    var item: ContentItem?
    var themeColor: String?

    @IBOutlet weak var playlist: UIButton!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var downloadButton: UIButtonEnhanced!
//    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var multiple: UIButton!
    @IBOutlet weak var collect: UIButton!
    @IBOutlet weak var preAudio: UIButton!
    @IBOutlet weak var nextAudio: UIButton!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playStatus: UILabel!
    
    
    @IBAction func ButtonPlayPause(_ sender: UIButton) {
        if let player = player {
            print("ButtonPlayPause\(player)")
            if player.rate != 0 && player.error == nil {
                player.pause()
                playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            } else {
                // MARK: - Continue audio even when device is set to mute. Do this only when user is actually playing audio because users might want to read FTC news while listening to music from other apps.
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                // MARK: - Continue audio when device is in background
                try? AVAudioSession.sharedInstance().setActive(true)
                player.play()
                player.replaceCurrentItem(with: playerItem)
                playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
//                playAndPauseButton.image = UIImage(named:"BigPauseButton")
                
                // TODO: - Need to find a way to display media duration and current time in lock screen
                var mediaLength: NSNumber = 0
                if let d = self.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        mediaLength = duration as NSNumber
                    }
                }
                
                var currentTime: NSNumber = 0
                if let c = self.playerItem?.currentTime() {
                    let currentTime1 = CMTimeGetSeconds(c)
                    if currentTime1.isNaN == false {
                        currentTime = currentTime1 as NSNumber
                    }
                }
                nowPlayingCenter.updateInfo(
                    title: audioTitle,
                    artist: "FT中文网",
                    albumArt: UIImage(named: "cover.jpg"),
                    currentTime: currentTime,
                    mediaLength: mediaLength,
                    PlaybackRate: 1.0
                )
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    @IBAction func switchToPreAudio(_ sender: UIButton) {
        self.player?.replaceCurrentItem(with: playerItem)
    }
    @IBAction func switchToNextAudio(_ sender: UIButton) {
        self.player?.replaceCurrentItem(with: playerItem)
    }
    @IBAction func skipForward(_ sender: UIButton) {
        let currentSliderValue = self.progressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
        playerItem?.seek(to: currentTime)
        self.progressSlider.value = currentSliderValue - 15
    }
    @IBAction func skipBackward(_ sender: UIButton) {
        let currentSliderValue = self.progressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
        playerItem?.seek(to: currentTime)
        self.progressSlider.value = currentSliderValue + 15
//        print("self.progressSlider.value\(currentSliderValue)")
    }
    var isSwitch = true
    @IBAction func switchPlayRate(_ sender: UIButton) {
        
//        if isSwitch {
//            self.player?.rate = 2.0
//            isSwitch = false
//        }else {
//           self.player?.rate = 1.0
//            isSwitch = true
//        }
        self.dismiss(animated: true, completion: nil)
//        self.view.frame = CGRect(x:0,y:0,width:200,height:200)

        
    }
    
    @IBAction func favorite(_ sender: UIButton) {
//        if let listPerColumnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController {
//                listPerColumnViewController.modalPresentationStyle = .custom
//            self.present(listPerColumnViewController, animated: false, completion: nil)
//            
//            }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
//        print("sliderValueChanged button")
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        playerItem?.seek(to: currentTime)
//        print("sliderValueChanged button\(currentTime)")
    }
    
    @IBAction func share(_ sender: UIButton) {
        if let item = item {
            self.launchActionSheet(for: item)
        }
    }
    
    @IBAction func download(_ sender: Any) {
         audioUrlString = "http://v.ftimg.net/album/starman.mp3"
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    deinit {
        removePlayerItemObservers()
        
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
        
        // MARK: - Remove Observe Audio Route Change and Update UI accordingly
        NotificationCenter.default.removeObserver(
            self,
            // MARK: - It has to be NSNotification, not Notification
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
        
        
        
        NotificationCenter.default.removeObserver(self)
        
        // MARK: - Stop loading and remove message handlers to avoid leak
        self.webView?.stopLoading()
        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
        self.webView?.configuration.userContentController.removeAllUserScripts()
        
        // MARK: - Remove delegate to deal with crashes on iOS 8
        self.webView?.navigationDelegate = nil
        self.webView?.scrollView.delegate = nil
        
        print ("deinit successfully and observer removed")
    }
    
    override func loadView() {
        super.loadView()
         print("loadView \( ShareHelper.sharedInstance.webPageTitle)")
        ShareHelper.sharedInstance.webPageTitle = ""
        ShareHelper.sharedInstance.webPageDescription = ""
        ShareHelper.sharedInstance.webPageImage = ""
        ShareHelper.sharedInstance.webPageImageIcon = ""
        parseAudioMessage()
        prepareAudioPlay()
        enableBackGroundMode()
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
//        self.webView = WKWebView(frame: self.containerView.frame, configuration: config)
//        self.containerView.addSubview(self.webView!)
//        self.containerView.clipsToBounds = true
        self.webView?.scrollView.bounces = false
        self.webView?.navigationDelegate = self
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView?.scrollView.delegate = self
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        ShareHelper.sharedInstance.webPageUrl = "http://www.ftchinese.com/interactive/\(audioId)"
        let url = "\(ShareHelper.sharedInstance.webPageUrl)?hideheader=yes&ad=no&inNavigation=yes&v=1"
        if let url = URL(string:url) {
            let req = URLRequest(url:url)
            webView?.load(req)
        }
        navigationItem.title = item?.headline
        initStyle()
//        print("item---\(item?.audioFileUrl)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let screenName = "/\(DeviceInfo.checkDeviceType())/audio/\(audioId)/\(audioTitle)"
        Track.screenView(screenName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if self.isMovingFromParentViewController {
            if let player = player {
                player.pause()
                self.player = nil
            }
        } else {
            print ("Audio is not being popped")
        }
    }
    
    private func initStyle() {
//        if let themeColor = themeColor {
//            let theme = UIColor(hex: themeColor)
//        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("page loaded!")
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
    
    func removeAllAudios() {
        Download.removeFiles(["mp3"])
        downloadButton.status = .remote
    }
    
    
    // MARK: - When users click on a link from the web view.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if navigationAction.navigationType == .linkActivated{
                if urlString.range(of: "mailto:") != nil{
                    UIApplication.shared.openURL(url)
                } else {
                    openInView (urlString)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    
    
    
    // FIXME: - This is very simlar to the same func in ViewController. Consider optimize the code.
    func openInView(_ urlString : String) {
        ShareHelper.sharedInstance.webPageUrl = urlString
        let segueId = "Audio To WKWebView"
        if #available(iOS 9.0, *) {
            // MARK: - Use Safariview for iOS 9 and above
            if urlString.range(of: "www.ftchinese.com") == nil && urlString.range(of: "i.ftimg.net") == nil {
                // MARK: - When opening an outside url which we have no control over
                if let url = URL(string:urlString) {
                    if let urlScheme = url.scheme?.lowercased() {
                        if ["http", "https"].contains(urlScheme) {
                            // MARK: - Can open with SFSafariViewController
                            let webVC = SFSafariViewController(url: url)
                            webVC.delegate = self
                            self.present(webVC, animated: true, completion: nil)
                        } else {
                            // MARK: - When Scheme is not supported or no scheme is given, use openURL
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            } else {
                // MARK: Open a url on a page that we have control over
                self.performSegue(withIdentifier: segueId, sender: nil)
            }
        } else {
            // MARK: Fallback on earlier versions
            self.performSegue(withIdentifier: segueId, sender: nil)
        }
    }

    private func parseAudioMessage() {
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

    private func updateAVPlayerWithLocalUrl() {
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
    
    private func removePlayerItemObservers() {
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
    
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        playDuration.text = "-\((duration-time).durationText)"
        playTime.text = time.durationText
    }

    private func prepareAudioPlay() {
        print("audioUrlString prepareAudioPlay\(audioUrlString)")
//        audioUrlString = "http://v.ftimg.net/album/starman.mp3"
        // MARK: - Use https url so that the audio can be buffered properly on actual devices
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
        // MARK: - Remove toolBar's top border. This cannot be done in interface builder.
//        toolBar.clipsToBounds = true
        
        if let url = URL(string: audioUrlString) {
            // MARK: - Check if the file already exists locally
            var audioUrl = url
            //print ("checking the file in documents: \(audioUrlString)")
            let cleanAudioUrl = audioUrlString.replacingOccurrences(of: "%20", with: "")
            if let localAudioFile = download.checkDownloadedFileInDirectory(cleanAudioUrl) {
                print ("The Audio is already downloaded")
                audioUrl = URL(fileURLWithPath: localAudioFile)
                downloadButton.status = .success
                //                downloadButton.setImage(UIImage(named:"DeleteButton"), for: .normal)
            }
            
            // MARK: - Draw a circle around the downloadButton
            downloadButton.drawCircle()
            
            // MARK: - Set sourceVC as self so that the alert can be popped out
            // download.sourceVC = self
            
            // MARK: - Change the size of progressSlider
            let ftPink = UIColor(netHex: 0xFFF1E0)
            let ftRed = UIColor(netHex: 0x9E2F50)
            let progressThumbImage = UIImage(color: ftPink, size: CGSize(width: 1, height: 4))
            let progressThumbImageForHighted = UIImage(color: ftRed, size: CGSize(width: 2, height: 8))
            
            // MARK: - Apple: "The control state whose thumb image you want to use. Specify a single control state value for this parameter. "
            progressSlider.setThumbImage(progressThumbImage, for: .normal)
            progressSlider.setThumbImage(progressThumbImageForHighted, for: .highlighted)
            
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer()
            
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
                        self?.progressSlider.maximumValue = Float(duration)
                        if self?.progressSlider.isHighlighted == false {
                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                        self?.updatePlayTime(current: time, duration: d)
                    }
                }
            }
            
            // MARK: - Observe download status change
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayerController.handleDownloadStatusChange(_:)),
                name: Notification.Name(rawValue: download.downloadStatusNotificationName),
                object: nil
            )
            
            // MARK: - Observe download progress change
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayerController.handleDownloadProgressChange(_:)),
                name: Notification.Name(rawValue: download.downloadProgressNotificationName),
                object: nil
            )
            
            // MARK: - Observe Audio Route Change and Update UI accordingly
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayerController.updatePlayButtonUI),
                // MARK: - It has to be NSNotification, not Notification
                name: NSNotification.Name.AVAudioSessionRouteChange,
                object: nil
            )
            addPlayerItemObservers()
        }
    }
    
    public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                
                self.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            } else {
                self.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            }
        }
    }
//    func remoteControlReceivedWithEvent()
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            print("resume music")
            self?.player?.play()
            self?.playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
//            self?.playAndPauseButton.image = UIImage(named:"BigPauseButton")
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.player?.pause()
            self?.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            
            return .success
        }
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        
        MPRemoteCommandCenter.shared().previousTrackCommand.accessibilityActivate()
//        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {[weak self] event in
//            print ("next audio")
//
//            return .success
//        }
//        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {[weak self] event in
//            print ("previous audio")
//            return .success
//        }
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        
        
        let skipBackwardIntervalCommand =  MPRemoteCommandCenter.shared().skipBackwardCommand
        skipBackwardIntervalCommand.preferredIntervals = [NSNumber(value: 1.5)]
        skipBackwardIntervalCommand.accessibilityActivate()
        
        let skipForwardIntervalCommand =  MPRemoteCommandCenter.shared().skipForwardCommand
        skipForwardIntervalCommand.preferredIntervals = [NSNumber(value: 3.5)]
        
        skipForwardIntervalCommand.addTarget(self, action: #selector(skipForwardEvent))
        skipBackwardIntervalCommand.addTarget(self, action: #selector(skipBackwardEvent))
        
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        
//        let changePlaybackRateCommand = MPRemoteCommandCenter.shared().changePlaybackRateCommand
//        changePlaybackRateCommand.isEnabled = true
//        changePlaybackRateCommand.addTarget(self, action: #selector(changePlaybackRateEvent))
//        changePlaybackRateCommand.supportedPlaybackRates = [NSNumber(value: 2)]
        
//        let changePlaybackPositionCommand = MPRemoteCommandCenter.shared().changePlaybackPositionCommand
//        changePlaybackPositionCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
//            
//
//            return .success;
//        }
        
    }
    
    func skipForwardEvent() {
        print("前进3.5s")
    }
    func skipBackwardEvent() {
        print("后退3.5s")
    }
    func changePlaybackRateEvent(){
        self.player?.rate = 2.0
        print("改变播放速度")
    }
    
    func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
//        self.playAndPauseButton.image = UIImage(named:"BigPlayButton")
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    // Show loader
                    print ("is loading...")
                    playStatus.text = "加载中..."
                    
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    print ("should be playing. Duration is \(String(describing: playerItem?.duration))")
                    playStatus.text = audioTitle
                case "playbackBufferFull":
                    // Hide loader
                    print ("load successfully")
                    playStatus.text = audioTitle
                default:
                    playStatus.text = audioTitle
                    break
                }
            }
            if let time = playerItem?.currentTime(), let duration = playerItem?.duration {
                updatePlayTime(current: time, duration: duration)
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }


    public func handleDownloadStatusChange(_ notification: Notification) {
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
                        self.downloadButton.progress = 0
                    case .paused, .resumed:
                        break
                    case .success:
                        // MARK: if a file is downloaded, prepare the audio asset again
                        self.updateAVPlayerWithLocalUrl()
                        self.downloadButton.progress = 0
                    }
                    print ("notification received for \(status)")
                    self.downloadButton.status = status
                    //self.downloadButton.progress = 0
                }
            }
        }
    }

    public func handleDownloadProgressChange(_ notification: Notification) {
        DispatchQueue.main.async() {
            if let object = notification.object as? (id: String, percentage: Float, downloaded: String, total: String) {
                let id = object.id
                let percentage = object.percentage
                // MARK: The Player Need to verify that the current file matches status change
                let cleanAudioUrl = self.audioUrlString.replacingOccurrences(of: "%20", with: "")
                if cleanAudioUrl.contains(id) == true {
                    self.downloadButton.progress = percentage/100
                    self.downloadButton.status = .resumed
                }
            }
        }
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.commonInit()
//    }
//    
//    
//    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        
//        self.commonInit()
//    }
//    
//    func commonInit() {
//        self.modalPresentationStyle = .custom
//        self.transitioningDelegate = self
//    }
//
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        
//        if presented == self {
//            return CustomPresentationController(presentedViewController: presented, presenting: presenting)
//        }
//        
//        return nil
//    }
//    
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if presented == self {
//            return CustomPresentationAnimation(isPresenting: true)
//        }
//        else {
//            return nil
//        }
//    }
//    
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if dismissed == self {
//            return CustomPresentationAnimation(isPresenting: false)
//        }
//        else {
//            return nil
//        }
//    }


}
