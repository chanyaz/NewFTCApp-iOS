//
//  AudioPlayer.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/5.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//


import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices

// MARK: - Use singleton pattern to pass speech data between view controllers. It's better in in term of code style than prepare segue.
class AudioContent {
    static let sharedInstance = AudioContent()
    var body = [String: String]()
}

class AudioPlayer: UIViewController,WKScriptMessageHandler,UIScrollViewDelegate,WKNavigationDelegate {
    
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    private lazy var webView: WKWebView? = nil
    private let nowPlayingCenter = NowPlayingCenter()
    private let download = DownloadHelper(directory: "audio")
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    public var language: String?
    public var screenName: String?
    var item: ContentItem?
    var themeColor: String?
    var isPrivilegeViewOn = false
    @IBOutlet weak var containerView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var buttonPlayAndPause: UIBarButtonItem!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var downloadButton: UIButtonEnhanced!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playStatus: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var playerView: UIView!
    
    @IBAction func ButtonPlayPause(_ sender: UIBarButtonItem) {
        if let player = player {
            if player.rate != 0 && player.error == nil {
                player.pause()
                buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
                UIApplication.shared.isIdleTimerDisabled = false
            } else {
                startToPlay(from: nil)
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    
    private func startToPlay(from start: CMTime?) {
        if let player = player {
            // MARK: - Continue audio even when device is set to mute. Do this only when user is actually playing audio because users might want to read FTC news while listening to music from other apps.
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            // MARK: - Continue audio when device is in background
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
            player.replaceCurrentItem(with: playerItem)
            if let start = start {
                player.seek(to: start)
            }
            buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
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
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    
    fileprivate var isSaved = false
    @IBAction func love(_ sender: UIBarButtonItem) {
        if let item = item {
            if isSaved == false {
                Download.save(item, to: "clip", uplimit: 50, action: "save")
                isSaved = true
                sender.image = UIImage(named: "Delete")
            } else {
                Download.save(item, to: "clip", uplimit: 50, action: "delete")
                isSaved = false
                sender.image = UIImage(named: "Clip")
            }
        }
    }
    
    @IBOutlet weak var loveButton: UIBarButtonItem!
    fileprivate func checkLoveButton() {
        if let item = item {
            let key = "Saved clip"
            let savedItems = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? [[String: String]]()
            for savedItem in savedItems {
                if item.id == savedItem["id"] && item.type == savedItem["type"] {
                    isSaved = true
                    break
                }
            }
            if isSaved == true {
                loveButton.image = UIImage(named: "Delete")
            } else {
                loveButton.image = UIImage(named: "Clip")
            }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        playerItem?.seek(to: currentTime)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        if let item = item {
            launchActionSheet(for: item, from: sender, with: .Default)
        }
    }
    
    @IBAction func download(_ sender: Any) {
        if audioUrlString != "" {
            if let button = sender as? UIButtonEnhanced {
                // FIXME: should handle all the status and actions to the download helper
                download.takeActions(audioUrlString, currentStatus: button.status)
            }
        }
    }
    
    @IBAction func settings(_ sender: Any) {
        let alert = UIAlertController(title: "请选择您的操作设置", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(
            title: "清除所有音频",
            style: UIAlertActionStyle.default,
            handler: {_ in self.removeAllAudios() }
        ))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        if let player = player {
            player.pause()
            self.player = nil
            print ("player is set to nil")
        }
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
        
        //print ("deinit successfully and observer removed")
    }
    
    
    override func loadView() {
        super.loadView()
        ShareHelper.shared.webPageTitle = ""
        ShareHelper.shared.webPageDescription = ""
        ShareHelper.shared.webPageImage = ""
        ShareHelper.shared.webPageImageIcon = ""
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
        contentController.add(LeakAvoider(delegate:self), name: "callbackHandler")
        contentController.add(LeakAvoider(delegate:self), name: "audioData")
        contentController.add(LeakAvoider(delegate:self), name: "scrollTo")
        contentController.add(LeakAvoider(delegate:self), name: "seekAudio")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.containerView.frame, configuration: config)
        self.containerView.addSubview(self.webView!)
        self.containerView.clipsToBounds = true
        self.webView?.scrollView.bounces = false
        self.webView?.navigationDelegate = self
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView?.scrollView.delegate = self
        let url: String
        if let id = item?.id,
            let type = item?.type {
            if ["story", "premium"].contains(type) || item?.ebody != nil{
                item?.hideAd = true
                WebviewHelper.renderStory(type, subType: .None, dataObject: item, webView: webView)
            } else {
                let shareUrl = APIs.getUrl(id, type: type, isSecure: false, isPartial: false)
                ShareHelper.shared.webPageUrl = shareUrl
                let actualUrl = APIs.getUrl(id, type: type, isSecure: true, isPartial: false)
                let finalUrl = APIs.addParameters(to: actualUrl, for: "audio")
                url = APIs.addParameters(to: shareUrl, for: "audio")
                WebviewHelper.loadContent(url: finalUrl, base: url, webView: webView)
            }
        } else {
            ShareHelper.shared.webPageUrl = "http://www.ftchinese.com/interactive/\(audioId)"
            url = "\(ShareHelper.shared.webPageUrl)?hideheader=yes&ad=no&inNavigation=yes&v=1"
            WebviewHelper.loadContent(url: url, base: url, webView: webView)
        }
        
        // MARK: Check if the audio is behind pay wall
        if let privilege = item?.privilegeRequirement {
            if !PrivilegeHelper.isPrivilegeIncluded(privilege, in: Privilege.shared) {
                PrivilegeViewHelper.insertPrivilegeView(to: view, with: privilege, from: item, endWith: "")
                isPrivilegeViewOn = true
            } else {
                if let item = item {
                    let eventLabel = PrivilegeHelper.getLabel(prefix: privilege.rawValue, type: item.type, id: item.id, suffix: "")
                    Track.eventToAll(category: "Privileges", action: "Listen", label: eventLabel)
                }
            }
        }
        navigationItem.title = item?.headline
        initStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: - Update membership status
        PrivilegeHelper.updatePrivilges()
        let screen: String
        if let currentScreenName = screenName {
            screen = "/\(DeviceInfo.checkDeviceType())/\(currentScreenName)"
        } else {
            screen = "/\(DeviceInfo.checkDeviceType())/audio/\(audioId)/\(audioTitle)"
        }
        Track.screenView(screen, trackEngagement: true)
        checkLoveButton()
    }
    
    private func initStyle() {
        if let themeColor = themeColor {
            let theme = UIColor(hex: themeColor)
            visualEffectView.backgroundColor = theme
            playerView.backgroundColor = theme
            toolBar.backgroundColor = theme
            toolBar.barTintColor = theme
        }
        let webViewBG = UIColor(hex: Color.Content.background)
        view.backgroundColor = webViewBG
        // MARK: set the web view opaque to avoid white screen during loading
        webView?.isOpaque = false
        webView?.backgroundColor = webViewBG
        webView?.scrollView.backgroundColor = webViewBG
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print("page loaded!")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler" {
            if let infoForShare = message.body as? String{
                let toArray = infoForShare.components(separatedBy: "|")
                if toArray.count >= 3 {
                    item?.lead = toArray[2]
                    item?.image = toArray[0]
                    ShareHelper.shared.webPageDescription = toArray[2]
                    ShareHelper.shared.webPageImage = toArray[0]
                    ShareHelper.shared.webPageImageIcon = toArray[1]
                }
                //print("get image icon from web page: \(ShareHelper.shared.webPageImageIcon)")
            }
        } else if message.name == "audioData" {
            if let audioData = message.body as? [String: Any],
                let scriptData = audioData["text"] as? [[[String: Any]]] {
                var startTimes = [[Double]]()
                for scriptBlock in scriptData {
                    var currentBlock = [Double]()
                    for oneScript in scriptBlock {
                        if let oneTime = oneScript["start"] as? Double {
                            currentBlock.append(oneTime)
                        }
                    }
                    startTimes.append(currentBlock)
                }
                audioScriptData = startTimes
            }
        } else if message.name == "scrollTo" {
            if let scrollY = message.body as? Int {
                let scrollPoint = CGPoint(x: 0, y: scrollY)
                webView?.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        } else if message.name == "seekAudio" {
            if let seekAudio = message.body as? Double {
                let newCMTime = CMTime.init(seconds: seekAudio, preferredTimescale: Int32(NSEC_PER_SEC))
                //player?.seek(to: newCMTime)
                startToPlay(from: newCMTime)
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
                    if let topController = UIApplication.topViewController() {
                        topController.openLink(url)
                    }
                    //openInView (urlString)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    private func parseAudioMessage() {
        let body = AudioContent.sharedInstance.body
        if let title = body["title"],
            let audioFileUrl = body["audioFileUrl"],
            let interactiveUrl = body["interactiveUrl"] {
            //print (title)
            audioTitle = title
            audioUrlString = audioFileUrl.replacingOccurrences(of: " ", with: "%20")
            audioId = interactiveUrl.replacingOccurrences(
                of: "^.*interactive/([0-9]+).*$",
                with: "$1",
                options: .regularExpression
            )
            print ("audio id is \(audioId)")
            ShareHelper.shared.webPageTitle = title
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
        NotificationCenter.default.addObserver(self,selector:#selector(AudioPlayer.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        // MARK: - Update buffer status
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }
    
    private var audioScriptData: [[Double]]?
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        playDuration.text = "-\((duration-time).durationText)"
        playTime.text = time.durationText
        updateTimeInWeb(time)
    }
    
    private var lastIndex = (k:0, l:0)
    private var latestIndex = (k:0, l:0)
    
    private func updateTimeInWeb(_ time: CMTime) {
        if let audioScriptData = audioScriptData {
            let currentTimeInSeconds = Double(CMTimeGetSeconds(time))
            //print ("current CM time is: \(currentTimeInSeconds)")
            for (k, timeBlockValue) in audioScriptData.enumerated() {
                for (l, timeValue) in timeBlockValue.enumerated() {
                    if timeValue >= currentTimeInSeconds {
                        let lastK = lastIndex.k
                        let lastL = lastIndex.l
                        if k != latestIndex.k || l != latestIndex.l {
                            let jsCode = "showHightlight(\(lastK), \(lastL));"
                            webView?.evaluateJavaScript(jsCode) { (result, error) in
                                if result != nil {
                                    //print (result ?? "unprintable JS result")
                                }
                            }
                            latestIndex = (k:k, l:l)
                        }
                        return
                    }
                    lastIndex = (k:k, l:l)
                }
            }
        }
    }
    
    //var isAudioFileDownloaded = false
    private func prepareAudioPlay() {
        // MARK: - Use https url so that the audio can be buffered properly on actual devices
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "\(APIs.getAudioDomain())album/")
        print ("audio url is \(audioUrlString)")
        // MARK: - Remove toolBar's top border. This cannot be done in interface builder.
        toolBar.clipsToBounds = true
        if let url = URL(string: audioUrlString) {
            // MARK: - Check if the file already exists locally
            var audioUrl = url
            //print ("checking the file in documents: \(audioUrlString)")
            let cleanAudioUrl = audioUrlString.replacingOccurrences(of: "%20", with: "")
            if let localAudioFile = download.checkDownloadedFileInDirectory(cleanAudioUrl) {
                //print ("The Audio is already downloaded")
                audioUrl = URL(fileURLWithPath: localAudioFile)
                downloadButton.status = .success
                playStatus.text = audioTitle
                //isAudioFileDownloaded = true
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
                selector: #selector(AudioPlayer.handleDownloadStatusChange(_:)),
                name: Notification.Name(rawValue: download.downloadStatusNotificationName),
                object: nil
            )
            
            // MARK: - Observe download progress change
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayer.handleDownloadProgressChange(_:)),
                name: Notification.Name(rawValue: download.downloadProgressNotificationName),
                object: nil
            )
            
            // MARK: - Observe Audio Route Change and Update UI accordingly
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayer.updatePlayButtonUI),
                // MARK: - It has to be NSNotification, not Notification
                name: NSNotification.Name.AVAudioSessionRouteChange,
                object: nil
            )
            addPlayerItemObservers()
        }
    }
    
    @objc public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
            } else {
                buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            }
        }
    }
    
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            //print("resume music")
            self?.player?.play()
            self?.buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.player?.pause()
            self?.buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            return .success
        }
        //        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {[weak self] event in
        //            print ("next audio")
        //            return .success
        //        }
        //        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {[weak self] event in
        //            print ("previous audio")
        //            return .success
        //        }
    }
    
    @objc func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
        nowPlayingCenter.updateTimeForPlayerItem(player)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    playStatus.text = "加载中..."
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    playStatus.text = audioTitle
                case "playbackBufferFull":
                    // Hide loader
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
                        self.downloadButton.progress = 0
                    case .paused, .resumed:
                        break
                    case .success:
                        // MARK: if a file is downloaded, prepare the audio asset again
                        self.updateAVPlayerWithLocalUrl()
                        self.downloadButton.progress = 0
                    }
                    print ("Audio Player: notification received for \(status)")
                    self.downloadButton.status = status
                    //self.downloadButton.progress = 0
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
                    self.downloadButton.progress = percentage/100
                    self.downloadButton.status = .resumed
                }
            }
        }
    }
    
}

// TODO: Display Background Images for Radio Columns
// TODO: Let users easily find downloaded file to play
