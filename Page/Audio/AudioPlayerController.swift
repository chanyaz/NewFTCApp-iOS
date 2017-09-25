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

class TabBarAudioContent {
    static let sharedInstance = TabBarAudioContent()
    var body = [String: String]()
    var item: ContentItem?
    var player:AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    var audioHeadLine: String? = nil
    var audioUrl: URL? = nil
    var duration: CMTime? = nil
    var time:CMTime? = nil
    var sliderValue:Float? = nil
    var isPlaying:Bool=false
    var isPlayFinish:Bool=false
    var isPlayStart:Bool=false
    var fetchResults: [ContentSection]?
    var items = [ContentItem]()
    var mode:Int?
    var playingIndex:Int?
    
}


class AudioPlayerController: UIViewController,WKScriptMessageHandler,UIScrollViewDelegate,WKNavigationDelegate,UIViewControllerTransitioningDelegate,UIGestureRecognizerDelegate{

    var mode: AVPlayer.RepeatMode = .None
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    private lazy var webView: WKWebView? = nil
    private let nowPlayingCenter = NowPlayingCenter()
    private let download = DownloadHelper(directory: "audio")
    
    private var queuePlayer:AVQueuePlayer?
    private var playerItems: [AVPlayerItem]? = []
    private var urls: [URL] = []
    private var urlStrings: [String]? = []
    private var urlOrigStrings: [String] = []
    private var urlTempStrings: [String] = []
    private var urlAssets: [AVURLAsset]? = []
    
    var item: ContentItem?
    var themeColor: String?
    
    var fetchAudioResults: [ContentSection]?
    var fetchesAudioObject = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    
    private var playingUrlStr:String? = ""
    private var playingIndex:Int = 0
    private var playingUrl:URL? = nil
    var count:Int = 0
    
    @IBOutlet weak var webAudioView: UIWebView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var preAudio: UIButton!
    @IBOutlet weak var nextAudio: UIButton!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playStatus: UILabel!
    
    @IBOutlet weak var playlist: UIButton!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var downloadButton: UIButtonEnhanced!
    //    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var multiple: UIButton!
    @IBOutlet weak var collect: UIButton!
    
    
    @IBAction func hideAudioButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        print("this hideAudioButton")
    }
    @IBAction func openPlayList(_ sender: UIButton) {
        if let listPerColumnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController {
            //            listPerColumnViewController.AudioLists = fetchesAudioObject
            listPerColumnViewController.fetchListResults = TabBarAudioContent.sharedInstance.fetchResults
            
            
            listPerColumnViewController.modalPresentationStyle = .custom
            self.present(listPerColumnViewController, animated: false, completion: nil)
        }
    }
    @IBAction func ButtonPlayPause(_ sender: UIButton) {
        if let player = player {
            print("ButtonPlayPause\(player)")
            if player.rate != 0 && player.error == nil {
                player.pause()
                playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
            } else {
                
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                try? AVAudioSession.sharedInstance().setActive(true)
                player.play()
                player.replaceCurrentItem(with: playerItem)
                playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = true
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
        count = (urlOrigStrings.count)
        removePlayerItemObservers()
        print("urlString next")
        
        playingIndex = playingIndex-1
        if playingIndex < 0{
            playingIndex = count - 1
            
        }
        if  (fetchAudioResults?.count)!>0 {
            
            let preUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
            audioUrlString = preUrl
            prepareAudioPlay()
            updateSingleTonData()
        }
    }
    @IBAction func switchToNextAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        if (fetchAudioResults?.count)!>0 {
            
            removePlayerItemObservers()
            playingIndex += 1
            if playingIndex >= count{
                playingIndex = 0
            }

            let nextUrl = urlOrigStrings[playingIndex].replacingOccurrences(of: " ", with: "%20")
            print("urlString playingIndex\(playingIndex)")
            
            //        let index = playingIndex
            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadView11"), object: sender)
            audioUrlString = nextUrl
            prepareAudioPlay()
            updateSingleTonData()
            //            self.playStatus.text = fetchAudioResults[0].items[playingIndex].headline
        }
        
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
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        playerItem?.seek(to: currentTime)
    }
    
    
    
    @IBAction func favorite(_ sender: UIButton) {
        print("hideAudioButton favorite button")
    }
    
    
    @IBAction func share(_ sender: UIButton) {
        if let item = item {
            self.launchActionSheet(for: item)
        }
    }
    @IBAction func download(_ sender: Any) {
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
        // Dispose of any resources that can be recreated.
    }
    private func getPlayingUrl(){
        var urlAsset : URL?
        var playerItemTemp : AVPlayerItem?
        if let fetchAudioResults = fetchAudioResults {
            for (_, item0) in fetchAudioResults[0].items.enumerated() {
//                print("urlString000---\(item0)")
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
        
        //        audioUrlString = audioUrlString.replacingOccurrences(of: "%20", with: " ")
        for (urlIndex,urlTempString) in (urlTempStrings.enumerated()) {
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
    
    override func loadView() {
        super.loadView()
        //        退出列表不会运行此处，但退出自己到tab，再从tab进入会运行此函数
        
        fetchAudioResults = TabBarAudioContent.sharedInstance.fetchResults
        ShareHelper.sharedInstance.webPageTitle = ""
        ShareHelper.sharedInstance.webPageDescription = ""
        ShareHelper.sharedInstance.webPageImage = ""
        ShareHelper.sharedInstance.webPageImageIcon = ""
        //        parseAudioMessage()
//        getDataFromeTab()
        //        prepareAudioPlay()
        //        enableBackGroundMode()
//        getPlayingUrl()
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
        print("webview loaded ?")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAudioView),
            name: Notification.Name(rawValue: "reloadView"),
            object: nil
        )
        audioAddGesture()
    }
    @objc func reloadAudioView(){
        //        item的值得时刻记住更新，最好传全局变量还是用自身局部变量？，可以从tab中把值传给此audio么？
        //        需要同时更新webView和id 、item等所有一致性变量，应该把他们整合到一起，一起处理循环、下一首、列表更新
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
            self.playStatus.text = item.headline
            TabBarAudioContent.sharedInstance.body["title"] = item.headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioUrlStrFromList
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(item.id)"
            
            //  audioTitle = fetchAudioResults[0].items[playingIndex].headline
            parseAudioMessage()
            loadUrl()
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.width
//        let height = UIScreen.main.bounds.height
//        let audioViewHeight:CGFloat = 220
        let buttonWidth:CGFloat = 19
//        let buttonHeight: CGFloat = 19
        let margin:CGFloat = 20
        let space = (width - margin*2 - buttonWidth*4)/3
       
        let spaceBetweenListAndView: CGFloat = 30
        
       
        //        退出列表不会运行此处，但退出自己到tab，再从tab进入会运行此函数
        self.playlist.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.back, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.view.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.view.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        
    
        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.share, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -space))
        self.view.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.view.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.view.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))

        self.collect.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: collect, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.playlist, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: space))
        self.view.addConstraint(NSLayoutConstraint(item: collect, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.view.addConstraint(NSLayoutConstraint(item: collect, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.view.addConstraint(NSLayoutConstraint(item: collect, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))


        self.share.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.view.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.view.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        
        let duration = TabBarAudioContent.sharedInstance.duration
        let time = TabBarAudioContent.sharedInstance.time
        if let duration = duration, let time = time{
            playDuration.text = "-\((duration-time).durationText)"
            playTime.text = time.durationText
            let duration1 = CMTimeGetSeconds(duration)
            if duration1.isNaN == false {
                progressSlider.maximumValue = Float(duration1)
                
                if progressSlider.isHighlighted == false {
                    progressSlider.value = Float((CMTimeGetSeconds(time)))
                }
            }
            
        }
        loadUrl()
        navigationItem.title = item?.headline
        initStyle()
        
    }
    
    func loadUrl(){
        ShareHelper.sharedInstance.webPageUrl = "http://www.ftchinese.com/interactive/\(audioId)"
        let url = "\(ShareHelper.sharedInstance.webPageUrl)?hideheader=yes&ad=no&inNavigation=yes&v=1"
        print("webView getDataFromeTab url--\(url)")
        if let url = URL(string:url) {
            let req = URLRequest(url:url)
            webView?.load(req)
        }
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
        let progressThumbImage = UIImage(named: "SliderImg")
        let aa = progressThumbImage?.imageWithImage(image: progressThumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        progressSlider.setThumbImage(aa, for: .normal)
        progressSlider.maximumTrackTintColor = UIColor.white
        progressSlider.minimumTrackTintColor = UIColor(hex: "#05d5e9")
        self.webAudioView.layer.zPosition = 1
        self.containerView.layer.zPosition = 3
//        self.webAudioView.layer.frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
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
    @objc func isHideAudio(sender: UISwipeGestureRecognizer){
        if sender.direction == .up{
            print("up hide audio")
            
            let deltaY = self.containerView.bounds.height
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.containerView.transform = CGAffineTransform(translationX: 0,y: deltaY)
                self.containerView.setNeedsUpdateConstraints()
            }, completion: { (true) in
                print("up animate finish")
            })
        }else if sender.direction == .down{
            print("down show audio")
            //            let deltaY = self.view.bounds.height
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //                self.containerView.transform = CGAffineTransform.identity
                self.containerView.transform = CGAffineTransform(translationX: 0,y: 0)
                self.containerView.setNeedsUpdateConstraints()
            }, completion: { (true) in
                print("down animate finish")
            })
        }
    }
    //    获取tabBar中的数据，此函数仅仅是刚出来运行，应该与上一首（调用prepareAudioPlay()）分开使用？我觉得后面可以考虑合并，因为假如下一首了，对播放器的操作isPlaying不会相应更新？（可以更新，通过暂停播放按钮控制）
    //    全部用全局导致每次更新代码都得用全局更新，不然不会变化
    private func getDataFromeTab(){
        item = TabBarAudioContent.sharedInstance.item
        parseAudioMessage()
        //            获取从tabBar中播放的数据
        playStatus.text=TabBarAudioContent.sharedInstance.item?.headline
        player = TabBarAudioContent.sharedInstance.player
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        //        let isPlaying = TabBarAudioContent.sharedInstance.isPlaying
        if player != nil {
            
        }else {
            
        }
        
        var currentTimeFromTab: NSNumber = 0
        if let c = TabBarAudioContent.sharedInstance.playerItem?.currentTime() {
            let currentTime1 = CMTimeGetSeconds(c)
            if currentTime1.isNaN == false {
                currentTimeFromTab = currentTime1 as NSNumber
            }
        }
        
        if let player = player{
            if TabBarAudioContent.sharedInstance.isPlaying{
                playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try? AVAudioSession.sharedInstance().setActive(true)
                player.play()
                player.replaceCurrentItem(with: playerItem)
            }else{
                playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
                player.pause()
            }
            //            nowPlayingCenter.updateTimeForPlayerItem(player)
            
            // MARK: - Update audio play progress
            player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
                if let d = self?.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        self?.progressSlider.maximumValue = Float(duration)
                        if self?.progressSlider.isHighlighted == false {
                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                        TabBarAudioContent.sharedInstance.duration = d
                        TabBarAudioContent.sharedInstance.time = time
                        self?.updatePlayTime(current: time, duration: d)
                    }
                }
            }
            
            print("getDataFromeTab player----\(player)--playerItem---\(String(describing: playerItem))")
        }
        addPlayerItemObservers()
        
        print("getDataFromeTab--\(currentTimeFromTab)----\(String(describing: player))")
    }
    
    private func parseAudioMessage() {
        let body = TabBarAudioContent.sharedInstance.body
        //        let body = AudioContent.sharedInstance.body
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
            downloadButton.drawCircle()
            
            // MARK: - Set sourceVC as self so that the alert can be popped out
            // download.sourceVC = self
            
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            
            if player != nil {
                
            }else {
                player = AVPlayer()
                
            }
            
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            
            
            
            //            此处闪动一下，应该是被覆盖了
            
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
            if let player = player {
                player.play()
            }
            playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
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
            
            // MARK: - Observe Audio Route Change and Update UI accordingly
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.updatePlayButtonUI),
                // MARK: - It has to be NSNotification, not Notification
                name: NSNotification.Name.AVAudioSessionRouteChange,
                object: nil
            )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
            addPlayerItemObservers()
        }
    }
    func updateSingleTonData(){
        if let fetchAudioResults = fetchAudioResults, let audioFileUrl = fetchAudioResults[0].items[playingIndex].audioFileUrl {
            TabBarAudioContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
            self.playStatus.text = fetchAudioResults[0].items[playingIndex].headline
            TabBarAudioContent.sharedInstance.body["title"] = fetchAudioResults[0].items[playingIndex].headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(fetchAudioResults[0].items[playingIndex].id)"
            parseAudioMessage()
            loadUrl()
            
        }
    }
    
    @objc public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                //                buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
            } else {
                //                buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            }
        }
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
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview loaded---!")
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
        //        downloadButton.status = .remote
    }
    
    
    // MARK: - When users click on a link from the web view.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        //        print("navigationAction.request.url\(navigationAction.request.url)")
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
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // MARK: - Update buffer status
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }
    
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        playDuration.text = "-\((duration-time).durationText)"
        playTime.text = time.durationText
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
        
        
        
    }
    
    
    
    @objc func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        
        //        self.playAndPauseButton.image = UIImage(named:"BigPlayButton")
        nowPlayingCenter.updateTimeForPlayerItem(player)
        //        orderPlay()
        let mode = TabBarAudioContent.sharedInstance.mode
        print("mode11 \(String(describing: mode))")
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
        prepareAudioPlay()
        updateSingleTonData()
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
        prepareAudioPlay()
        updateSingleTonData()
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
        self.progressSlider.value = 0
        self.playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    
    
    //    此函数会执行，下一首应该更新audioTitle的值
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
                    print ("notification received for \(status)")
                    self.downloadButton.status = status
                    
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
    
    //init 不能少，写在viewDidLoad中不生效
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
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
            print("present animation")
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

