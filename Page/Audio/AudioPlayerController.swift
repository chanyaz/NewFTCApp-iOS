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

class AudioPlayerController: UIViewController,UIScrollViewDelegate,WKNavigationDelegate,UIViewControllerTransitioningDelegate,UIGestureRecognizerDelegate,CAAnimationDelegate{
    
    private var audioDirectoryName = "audioDirectory"
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    //    private lazy var webView: WKWebView? = nil
    private let nowPlayingCenter = NowPlayingCenter()
    private let download = RemoteDownloadHelper(directory: "audioDirectory")
    private let playerAPI = PlayerAPI.sharedInstance
    private var queuePlayer:AVQueuePlayer?
    private var playerItems: [AVPlayerItem]? = []
    private var urls: [URL] = []
    private var urlStrings: [String]? = []
    private var urlOrigStrings: [String] = []
    private var urlTempString = ""
    private var urlAssets: [AVURLAsset]? = []
    
    var item: ContentItem?
    var themeColor: String?
    
    var fetchAudioResults: [ContentSection]?
//    var fetchesAudioObject = ContentFetchResults(
//        apiUrl: "",
//        fetchResults: [ContentSection]()
//    )

    private var actualAudioLanguageIndex = 0
    var angle :Double = 0
    let imageWidth = 408   // 16 * 52
    let imageHeight = 234  // 9 * 52
    private var playingUrlStr:String? = ""
    private var playingIndex:Int = 0
    private var playingUrl:URL? = nil
    var count:Int = 0
    var tabView = CustomSmallPlayView()
    
    @IBOutlet weak var switchChAndEnAudio: UISegmentedControl!
    let love = UIButton()
    let downloadButton = UIButtonDownloadedChange()
    let playlist = UIButton()
    let share = UIButton()
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var preAudio: UIButton!
    @IBOutlet weak var nextAudio: UIButton!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playStatus: UILabel!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var exitTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headLineBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBAction func hideAudioButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBarStyle"), object: self)
        print("this hideAudioButton")
    }
    @objc func openPlayList(_ sender: UIButton) {
        if let listPerColumnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController {
            listPerColumnViewController.fetchListResults = TabBarAudioContent.sharedInstance.fetchResults
            listPerColumnViewController.modalPresentationStyle = .custom
            self.present(listPerColumnViewController, animated: true, completion: nil)
        }
    }
    @IBAction func ButtonPlayPause(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadView"), object: self)
        if let player = player {
            print("ButtonPlayPause\(player)")
            
            if player.rate != 0 && player.error == nil {
                stopRotateAnimate()
                player.pause()
                playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
            } else {
                resumeRotateAnimate()
                player.play()
                player.replaceCurrentItem(with: playerItem)
                playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
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
        print("urlString playingIndex pre\(playingIndex)")
        if fetchAudioResults != nil {
            playingIndex = playingIndex-1
            if playingIndex < 0{
                playingIndex = count - 1
                
            }
            updateSingleTonData()
            prepareAudioPlay()
        }
    }
    @IBAction func switchToNextAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        if fetchAudioResults != nil {
            removePlayerItemObservers()
            playingIndex += 1
            if playingIndex >= count{
                playingIndex = 0
            }
            print("urlString playingIndex\(playingIndex)")
            updateSingleTonData()
            prepareAudioPlay()
            
        }
        
    }
    
    @IBAction func skipForward(_ sender: UIButton) {
        let currentSliderValue = self.progressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
        playerItem?.seek(to: currentTime)
        self.progressSlider.value = currentSliderValue + 15
    }
    @IBAction func skipBackward(_ sender: UIButton) {
        let currentSliderValue = self.progressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
        playerItem?.seek(to: currentTime)
        self.progressSlider.value = currentSliderValue - 15
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        //        NowPlayingCenter().updatePlayingCenter()
        
    }
    
    
    var isLove:Bool = false
    @objc func favorite(_ sender: UIButton) {
        print("hideAudioButton favorite button")
        if !isLove{
            self.love.setImage(UIImage(named:"Clip"), for: UIControlState.normal)
            isLove = true
        }else{
            self.love.setImage(UIImage(named:"LoveBtn"), for: UIControlState.normal)
            isLove = false
        }
    }
    
    
    @objc func share(_ sender: UIButton) {
        if let item = item {
            launchActionSheet(for: item, from: sender)
        }
    }
    
    @IBAction func deleteAudio(_ sender: UIButton) {
//        removeAllAudios()
        Download.removeDirectory(directoryName: audioDirectoryName, for: .cachesDirectory)
        Download.removeFileName("audioData",  for: .cachesDirectory, as: nil)
    }
    private var downloadedItem:[String:String]=[:]
    @objc func download(_ sender: Any) {
        
        Download.createDirectory(directoryName: audioDirectoryName, to: .cachesDirectory)
        let item = TabBarAudioContent.sharedInstance.item
        if let item = item{
            let headline = item.headline
            let image = item.image
//            let lead = item.lead
            let caudio = item.caudio
            let eaudio = item.eaudio
     
//            获取毫秒数
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateInString = dateFormatter.string(from: currentDate)
            let timeInterval = Int((currentDate.timeIntervalSince1970)*100000)
            print("current date String is:\(dateInString)--timeInterval is:\(Int(timeInterval))")

            
            if let caudio = caudio,let eaudio = eaudio{
                actualAudioLanguageIndex = UserDefaults.standard.integer(forKey: Key.audioLanguagePreference)
                if actualAudioLanguageIndex == 1{
                    if let button = sender as? UIButtonDownloadedChange {
                        download.takeActions(eaudio, directoryName: audioDirectoryName, for: .cachesDirectory, currentStatus: button.status, newFileName: headline)
                        print("download button status:\( button.status)--\(eaudio)")
                    }
                }else{
                    if let button = sender as? UIButtonDownloadedChange {
                        download.takeActions(caudio,directoryName: audioDirectoryName, for: .cachesDirectory, currentStatus: button.status, newFileName: headline)
                        print("download button status:\( button.status)--\(caudio)")
                    }
                }
                

                
                let newName = headline + ".jpg"

                
                if let localAudioFile = download.checkDownloadedFileInDirectory(newName, directoryName: audioDirectoryName, for: .cachesDirectory){
                    print("localAudioFile path is: \(localAudioFile)")
                }else{
                    let parseImage = playerAPI.parseAudioUrl(urlString: image)
                    let parseImageUrl = URL(string: parseImage)
                    if let url = parseImageUrl{
                        let request = URLRequest(url:url)
                        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                            if error != nil ,let error = error{
                                print("audio request error\(error)")
                                return
                            }
                            guard let data = data else {
                                return
                            }
                            Download.saveFiles(data, directoryName: self.audioDirectoryName, filename: headline, to:.cachesDirectory , as: "jpg")
                        }).resume()
                    }
                }
                let playingIndexStr = String(playingIndex)
                if let playingIndexData = playingIndexStr.data(using: String.Encoding.utf8){
                    Download.saveFiles(playingIndexData, directoryName: self.audioDirectoryName, filename: headline+"[index]", to:.cachesDirectory , as: nil)
                    print("download bodyData write--\(playingIndex)")
                }
                
                
                
            }
        }
        
        downloadButton.drawCircle()

    }
    func getFileName(urlString:String)-> String{
        var lastPathName = ""
        let urlString = playerAPI.parseAudioUrl(urlString: urlString)
        let url = URL(string: urlString)
        if let url = url{
           lastPathName = url.lastPathComponent
        }
        return lastPathName
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.width
        //        let height = UIScreen.main.bounds.height
        let buttonWidth:CGFloat = 19
        let buttonHeight: CGFloat = 19
        let margin:CGFloat = 20
        let space = (width - margin*2 - buttonWidth*4)/3
        var spaceBetweenListAndView: CGFloat = 0
 
        spaceBetweenListAndView = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 0, OtherIphoneValue: 25)
        exitTopConstraint.constant = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 60, OtherIphoneValue: 30)
        headLineBottomConstraint.constant = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 80, OtherIphoneValue: 45)
        imageViewBottomConstraint.constant = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 90, OtherIphoneValue: 75)
        playlist.attributedTitle(for: UIControlState.normal)
        playlist.setImage(UIImage(named:"ListBtn"), for: UIControlState.normal)
        playlist.addTarget(self, action: #selector(self.openPlayList(_:)), for: UIControlEvents.touchUpInside)
        
        
        downloadButton.attributedTitle(for: UIControlState.normal)
        downloadButton.setImage(UIImage(named:"DownLoadBtn"), for: UIControlState.normal)
        downloadButton.addTarget(self, action: #selector(self.download(_:)), for: UIControlEvents.touchUpInside)
        
        
        love.attributedTitle(for: UIControlState.normal)
        love.setImage(UIImage(named:"LoveBtn"), for: UIControlState.normal)
        love.addTarget(self, action: #selector(self.favorite(_:)), for: UIControlEvents.touchUpInside)
        
        
        share.attributedTitle(for: UIControlState.normal)
        share.setImage(UIImage(named:"ShareBtn"), for: UIControlState.normal)
        share.addTarget(self, action: #selector(self.share(_:)), for: UIControlEvents.touchUpInside)
        
        containerView.addSubview(playlist)
        containerView.addSubview(downloadButton)
        containerView.addSubview(love)
        containerView.addSubview(share)
        
        self.playlist.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.back, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        
        
        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.share, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -space))
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        
        self.love.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.playlist, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: space))
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        
        
        self.share.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        
        
        playStatus.textColor = UIColor(hex: Color.Content.background)
        let themeColor = UIColor(hex: Color.Content.headline)
        audioImage.backgroundColor = themeColor

        
        initStyle()
        fetchAudioResults = TabBarAudioContent.sharedInstance.fetchResults
        player = TabBarAudioContent.sharedInstance.player
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        parseAudioMessage()
        getPlayingUrl()
        addPlayerItemObservers()
        updateProgressSlider()
        if let fetchAudioResults = fetchAudioResults{
            let data = fetchAudioResults[0].items[playingIndex]
            getLoadedImage(item: data)
            let cleanUrl = playerAPI.getUrlAccordingToAudioLanguageIndex(item: data)
            checkLocalFileToUpdateButtonStatus(urlString: self.getFileName(urlString: cleanUrl))
        }
        updatePlayButtonUI()
        self.playStatus.text = fetchAudioResults![0].items[playingIndex].headline
//        rotateAnimation()
//        startRotateAnimate()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAudioView),
            name: Notification.Name(rawValue: "reloadAudio"),
            object: nil
        )
        setNeedsStatusBarAppearanceUpdate()
        addDownloadObserve()
        
    }
    func getLoadedImage(item: ContentItem){
        if let loadedImage = item.coverImage {
            audioImage.image = loadedImage
            clipImage()
            print ("image is already loaded, no need to download again. ")
        } else {
            item.loadImage(type:"cover", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.audioImage.image = cellContentItem.coverImage
                print ("image type is cover. ")
                self?.clipImage()
            })
        }

    }
    func clipImage(){
//        var loadedAudioImage :UIImage? = nil
        let audioImageWidth = audioImage.bounds.width
        let audioImageHeight = audioImage.bounds.height
        let borderWidth :CGFloat = 8
        let ovalWidth = audioImageHeight
        let clipX = audioImageWidth/2-audioImageHeight/2
        let clipY :CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(audioImage.bounds.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.setFillColor( UIColor(hex: "#138f9b").cgColor)
        ctx?.addEllipse(in: CGRect(x: clipX, y: clipY, width: ovalWidth, height: ovalWidth))
        ctx?.fillPath()

        let circlePath = UIBezierPath(ovalIn: CGRect(x: borderWidth+clipX, y: clipY + borderWidth, width: audioImageHeight-2 * borderWidth, height: audioImageHeight-2 * borderWidth))
        circlePath.addClip()
        audioImage.image?.draw(in: CGRect(x: borderWidth, y: borderWidth, width: audioImageWidth, height:audioImageHeight ))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.audioImage.image = image
        UIGraphicsEndImageContext()
    }
    func startRotateAnimate(){
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2*Double.pi
        animation.duration = 20
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        audioImage.layer.add(animation, forKey: nil)
    }
    func stopRotateAnimate(){
        let pausedTime = audioImage.layer.convertTime(CACurrentMediaTime(), from: nil)
        audioImage.layer.speed = 0.0
        audioImage.layer.timeOffset = pausedTime
    }
    func resumeRotateAnimate(){
        if (audioImage.layer.timeOffset == 0) {
            self.startRotateAnimate()
            return
        }
        
        let pausedTime = audioImage.layer.timeOffset
        audioImage.layer.speed = 1.0                                       // 开始旋转
        audioImage.layer.timeOffset = 0.0
        audioImage.layer.beginTime = 0.0
        let timeSincePause = audioImage.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime                                          // 恢复时间
        audioImage.layer.beginTime = timeSincePause;
    }
    func rotateAnimation(){
        let endAngle = CGAffineTransform(rotationAngle:CGFloat(angle*(Double.pi/180.0)))
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.audioImage.transform = endAngle
        },completion: { (true) in
            self.angle+=10
            self.rotateAnimation()
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        super.viewWillAppear(animated)
        let screenName = "/\(DeviceInfo.checkDeviceType())/audio/\(audioId)/\(audioTitle)"
        Track.screenView(screenName)
        if TabBarAudioContent.sharedInstance.isPlaying == true{
           startRotateAnimate()
        }else{
//           stopRotateAnimate() //it can not be added
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        print("bar status style--\(self.preferredStatusBarStyle)")
        
//        addDownloadObserve()
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
        actualAudioLanguageIndex = UserDefaults.standard.integer(forKey: Key.audioLanguagePreference)
        switchChAndEnAudio.selectedSegmentIndex = actualAudioLanguageIndex
        switchChAndEnAudio.backgroundColor = UIColor(hex: "12a5b3", alpha: 1)
        switchChAndEnAudio.tintColor = UIColor.white
        switchChAndEnAudio.layer.borderColor = UIColor(hex: "12a5b3", alpha: 1).cgColor
//        switchChAndEnAudio.layer.borderWidth = 0.5
//        switchChAndEnAudio.layer.cornerRadius = 5
//        switchChAndEnAudio.layer.masksToBounds = true
        let segAttributes: NSDictionary = [
            NSAttributedStringKey.foregroundColor: UIColor(hex: "12a5b3"),
            NSAttributedStringKey.font: UIFont(name: FontType.languageControl, size: 14)!
        ]
        switchChAndEnAudio.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], for: UIControlState.selected)
        switchChAndEnAudio.addTarget(self, action: #selector(switchLanguage(_:)), for: .valueChanged)
        
        let progressThumbImage = UIImage(named: "SliderImg")
        let aa = progressThumbImage?.imageWithImage(image: progressThumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        progressSlider.setThumbImage(aa, for: .normal)
        progressSlider.maximumTrackTintColor = UIColor.white
        progressSlider.minimumTrackTintColor = UIColor(hex: "#05d5e9")
        if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
            print("progress value")
            let duration = CMTimeGetSeconds(d)
            if duration.isNaN == false {
                progressSlider.maximumValue = Float(duration)
                if let currrentPlayingTime = TabBarAudioContent.sharedInstance.time{
                    progressSlider.value = Float((CMTimeGetSeconds(currrentPlayingTime)))
                    self.updatePlayTime(current: currrentPlayingTime, duration: d)
                }
            }
        }

        
        self.view.backgroundColor = UIColor(hex: Color.Tab.highlightedText, alpha: 0.8)
        containerView.backgroundColor = UIColor(hex: Color.Tab.highlightedText, alpha: 0.9)
        audioImage.backgroundColor = UIColor(hex: Color.Tab.highlightedText, alpha: 0)
        
        

        
    }
    public func isExistLocalFile(urlString:String)->Bool{
        var isExist : Bool
        if download.checkDownloadedFileInDirectory(urlString, directoryName: audioDirectoryName, for: .cachesDirectory) != nil{
            isExist = true
        }else{
            isExist = false
        }
        return isExist
    }
    public func checkLocalFileToUpdateButtonStatus(urlString:String){
        if isExistLocalFile(urlString: urlString) == true{
            downloadButton.setImage(UIImage(named:"DownLoadEndBtn"), for: .normal)
            downloadButton.status = .success
        }else{
            downloadButton.setImage(UIImage(named:"DownLoadBtn"), for: .normal)
            downloadButton.status = .remote
        }
    }
    @objc public func switchLanguage(_ sender: UISegmentedControl) {
        removePlayerItemObservers()
        let languageIndex = sender.selectedSegmentIndex
        UserDefaults.standard.set(languageIndex, forKey: Key.audioLanguagePreference)
//        actualAudioLanguageIndex = UserDefaults.standard.integer(forKey: Key.audioLanguagePreference)
        let item0 = TabBarAudioContent.sharedInstance.item
        print ("language is switched manually to \(languageIndex)---item0\(String(describing: item0))")
        if languageIndex == 1{
            if let eaudioUrl = item0?.eaudio{
                audioUrlString = eaudioUrl
                print("engilsh audioUrlString--\(audioUrlString)")
            }else if let caudioUrl = item0?.caudio, item0?.eaudio==nil{
                audioUrlString = caudioUrl
                print("engilsh do not exsit--\(audioUrlString)")
            }
        }else{
            if let caudioUrl = item0?.caudio{
                audioUrlString = caudioUrl
                print("chinese audioUrlString--\(audioUrlString)")
            }
        }

        var audioUrl :URL? = nil
        if audioUrlString != "" {
            checkLocalFileToUpdateButtonStatus(urlString: self.getFileName(urlString: audioUrlString))
            if let localAudioFile = download.checkDownloadedFileInDirectory(self.getFileName(urlString: audioUrlString), directoryName: audioDirectoryName, for: .cachesDirectory){
                audioUrl = URL(fileURLWithPath: localAudioFile)
                
            }else{
                audioUrlString = playerAPI.parseAudioUrl(urlString: audioUrlString)
                if let url = URL(string: audioUrlString){
                    audioUrl = url
                }
            }
//            downloadButton.drawCircle()
            if let audioUrl = audioUrl{
                print ("checking audioUrl: \(audioUrl)")
                let asset = AVURLAsset(url: audioUrl)
                playerItem = AVPlayerItem(asset: asset)
            }
            
            if player != nil {
                
            }else {
                player = AVPlayer()
                
            }
            if languageIndex == 1{
                TabBarAudioContent.sharedInstance.audioHeadLine = item?.eheadline
            }else{
                TabBarAudioContent.sharedInstance.audioHeadLine = item?.headline
            }
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            TabBarAudioContent.sharedInstance.audioUrl = audioUrl
            

            if let player = player {
                player.play()
            }
            playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            // MARK: - Update audio play progress

//            addDownloadObserve()
            addPlayerItemObservers()
            NowPlayingCenter().updatePlayingCenter()
            enableBackGroundMode()
        }
        
    }
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func updateProgressSlider(){
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
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
    }
    
    
    private func getPlayingUrl(){
        //        get playingIndex
        playingIndex = 0
        urlOrigStrings = []
        var playerItemTemp : AVPlayerItem?
        if let fetchAudioResults = fetchAudioResults {
            for (index, item0) in fetchAudioResults[0].items.enumerated() {
//                let fileUrl = playerAPI.getUrlAccordingToAudioLanguageIndex(item: item0)
                if let fileUrl = item0.caudio {
                    urlOrigStrings.append(fileUrl)
                    if audioUrlString == fileUrl{
                        playingUrlStr = fileUrl
                        playingIndex = index
                    }
                    urlTempString = playerAPI.parseAudioUrl(urlString: fileUrl)

                    if let urlAsset = URL(string: urlTempString){
                        playerItemTemp = AVPlayerItem(url: urlAsset) //可以用于播放的playItem
                        playerItems?.append(playerItemTemp!)
                    }
                    
                }
            }
        }
        print("urlString filtered audioUrlString --\(audioUrlString)")
//        print("urlString playerItems---\(String(describing: playerItems))")
        
        print("urlString playingIndex222--\(playingIndex)")
        TabBarAudioContent.sharedInstance.playingIndex = playingIndex
        
    }
    
    @objc func reloadAudioView(){
        removePlayerItemObservers()
        if let item = TabBarAudioContent.sharedInstance.item,let audioUrlStrFromList = item.caudio{
            print("audioUrlStrFromList--\(audioUrlStrFromList)")
            audioUrlString = audioUrlStrFromList
            prepareAudioPlay()
            TabBarAudioContent.sharedInstance.item = item
            self.playStatus.text = item.headline
            getLoadedImage(item: item)
            TabBarAudioContent.sharedInstance.body["title"] = item.headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioUrlStrFromList
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(item.id)"
            parseAudioMessage()
        }
        
        
    }
    //    获取tabBar中的数据，此函数仅仅是刚出来运行，应该与上一首（调用prepareAudioPlay()）分开使用？我觉得后面可以考虑合并，因为假如下一首了，对播放器的操作isPlaying不会相应更新？（可以更新，通过暂停播放按钮控制）
    //    全部用全局导致每次更新代码都得用全局更新，不然不会变化
    private func getDataFromeTab(){
        item = TabBarAudioContent.sharedInstance.item
        parseAudioMessage()
        //            获取从tabBar中播放的数据
        playStatus.text=TabBarAudioContent.sharedInstance.item?.headline
        getLoadedImage(item: TabBarAudioContent.sharedInstance.item!)
        
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
                playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
                player.play()
                player.replaceCurrentItem(with: playerItem)
            }else{
                playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
                player.pause()
            }
            
            print("getDataFromeTab player----\(player)--playerItem---\(String(describing: playerItem))")
        }
        addPlayerItemObservers()
        
        print("getDataFromeTab--\(currentTimeFromTab)----\(String(describing: player))")
    }
    
    private func parseAudioMessage() {
        let body = TabBarAudioContent.sharedInstance.body
        print(" body--\(body)")
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            audioTitle = title
            audioUrlString = audioFileUrl
            audioId = interactiveUrl.replacingOccurrences(
                of: "^.*interactive/([0-9]+).*$",
                with: "$1",
                options: .regularExpression
            )
            ShareHelper.shared.webPageTitle = title
            print("parsed audioUrlString--\(audioUrlString)")
            
        }
    }
    
    private func prepareAudioPlay() {
        
        var audioUrl :URL? = nil
        print("when actualAudioLanguageIndex change, audioUrlString is \(audioUrlString)")
        if audioUrlString != "" {
            checkLocalFileToUpdateButtonStatus(urlString: self.getFileName(urlString: audioUrlString))
            if let localAudioFile = download.checkDownloadedFileInDirectory(self.getFileName(urlString: audioUrlString), directoryName: audioDirectoryName, for: .cachesDirectory){
                
                audioUrl = URL(fileURLWithPath: localAudioFile)
            }else{
                audioUrlString = playerAPI.parseAudioUrl(urlString: audioUrlString)
                if let url = URL(string: audioUrlString){
                    audioUrl = url
                }
            }
//            downloadButton.drawCircle()
            if let audioUrl = audioUrl{
                print ("checking audioUrl: \(audioUrl)")
                let asset = AVURLAsset(url: audioUrl)
                playerItem = AVPlayerItem(asset: asset)
            }
            if player != nil {
                
            }else {
                player = AVPlayer()
                
            }
            actualAudioLanguageIndex = UserDefaults.standard.integer(forKey: Key.audioLanguagePreference)
            if actualAudioLanguageIndex == 1{
                TabBarAudioContent.sharedInstance.audioHeadLine = item?.eheadline
            }else{
                TabBarAudioContent.sharedInstance.audioHeadLine = item?.headline
            }
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            TabBarAudioContent.sharedInstance.audioUrl = audioUrl
//            TabBarAudioContent.sharedInstance.audioHeadLine = item?.headline
            
            if let player = player {
                player.play()
            }
            playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            print("when actualAudioLanguageIndex change, playerItem is \(String(describing: playerItem))")
            // MARK: - Update audio play progress
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
                if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        self?.progressSlider.maximumValue = Float(duration)
                        if self?.progressSlider.isHighlighted == false {
                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                        self?.updatePlayTime(current: time, duration: d)
                        TabBarAudioContent.sharedInstance.duration = d
                        TabBarAudioContent.sharedInstance.time = time
                    }
                }
            }
            
//            addDownloadObserve()
            addPlayerItemObservers()
            NowPlayingCenter().updatePlayingCenter()
            enableBackGroundMode()
            NotificationCenter.default.removeObserver(
                self,
                name: Notification.Name(rawValue: "reloadView"),
                object: nil
            )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadView"), object: self)
            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
        }
    }
    func updateSingleTonData(){
        actualAudioLanguageIndex = UserDefaults.standard.integer(forKey: Key.audioLanguagePreference)
        print("actualAudioLanguageIndex is \(actualAudioLanguageIndex)")
        if actualAudioLanguageIndex == 0{
            if let fetchAudioResults = fetchAudioResults, let audioFileUrl = fetchAudioResults[0].items[playingIndex].caudio {
                TabBarAudioContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
                self.tabView.playStatus.text = fetchAudioResults[0].items[playingIndex].headline
                getLoadedImage(item: fetchAudioResults[0].items[playingIndex])
                
                TabBarAudioContent.sharedInstance.body["title"] = fetchAudioResults[0].items[playingIndex].headline
                TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(fetchAudioResults[0].items[playingIndex].id)"
                TabBarAudioContent.sharedInstance.playingIndex = playingIndex
                parseAudioMessage()
            }
        }else if actualAudioLanguageIndex == 1{
            if let fetchAudioResults = fetchAudioResults, let audioFileUrl = fetchAudioResults[0].items[playingIndex].eaudio {
                print("actualAudioLanguageIndex==1 audioFileUrl--\(audioFileUrl)")
                TabBarAudioContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
                self.tabView.playStatus.text = fetchAudioResults[0].items[playingIndex].eheadline
                getLoadedImage(item: fetchAudioResults[0].items[playingIndex])
                // to do: change headline to eheadline
                TabBarAudioContent.sharedInstance.body["title"] = fetchAudioResults[0].items[playingIndex].headline
                TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(fetchAudioResults[0].items[playingIndex].id)"
                TabBarAudioContent.sharedInstance.playingIndex = playingIndex
                parseAudioMessage()
            }
        }

    }
    
    @objc public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                self.playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            } else {
                self.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
            }
        }
    }
    
    
    deinit {
        removePlayerItemObservers()
        removeDownloadObserve()
        
        // MARK: - Remove Observe Audio Route Change and Update UI accordingly
        NotificationCenter.default.removeObserver(
            self,
            // MARK: - It has to be NSNotification, not Notification
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: "reloadAudio"),
            object: nil
        )
        print ("deinit successfully and observer removed")
    }
    
    
    
    func removeAllAudios() {
        Download.removeFiles(["mp3"])
        downloadButton.status = .remote
    }
    
    private func updateAVPlayerWithLocalUrl() {
        if audioUrlString != "" {
            let currentSliderValue = self.progressSlider.value
            if let localAudioFile = download.checkDownloadedFileInDirectory(self.getFileName(urlString: audioUrlString), directoryName: audioDirectoryName, for: .cachesDirectory){
                print ("local audio file is: \(localAudioFile)")
                let localAudioFile = playerAPI.parseAudioUrl(urlString: localAudioFile)
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
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: "reloadView"),
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
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        playDuration.text = "-\((duration-time).durationText)"
        playTime.text = time.durationText
    }
    
    //    This function is used many times and seems to be reused
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            print("resume speech")
            self?.player?.play()
            self?.playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.player?.pause()
            self?.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
            
            return .success
        }
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        
        let skipForwardIntervalCommand =  MPRemoteCommandCenter.shared().skipForwardCommand
        skipForwardIntervalCommand.preferredIntervals = [NSNumber(value: 15)]
        
        skipForwardIntervalCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            print("前进15s")
            if let currrentPlayingTime = TabBarAudioContent.sharedInstance.time{
                let currentSliderValue = CMTimeGetSeconds(currrentPlayingTime)
                let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
                TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
                self.progressSlider.value = Float(currentSliderValue + 15)
                NowPlayingCenter().updatePlayingCenter()
            }
            
            return .success
        }
        
        let skipBackwardIntervalCommand =  MPRemoteCommandCenter.shared().skipBackwardCommand
        
        skipBackwardIntervalCommand.preferredIntervals = [NSNumber(value: 15)]
        skipBackwardIntervalCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            print("后退15s")
            if let currrentPlayingTime = TabBarAudioContent.sharedInstance.time{
                let currentSliderValue = CMTimeGetSeconds(currrentPlayingTime)
                let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
                TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
                self.progressSlider.value = Float(currentSliderValue - 15)
                NowPlayingCenter().updatePlayingCenter()
            }
            return .success
        }
        
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        
        
        let changePlaybackPositionCommand = MPRemoteCommandCenter.shared().changePlaybackPositionCommand
        changePlaybackPositionCommand.isEnabled = true
        changePlaybackPositionCommand.addTarget { (MPRemoteCommandEvent:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            let changePlaybackPositionCommandEvent = MPRemoteCommandEvent as! MPChangePlaybackPositionCommandEvent
            let positionTime = changePlaybackPositionCommandEvent.positionTime
            if let totlaTime = TabBarAudioContent.sharedInstance.player?.currentItem?.duration{
                
                let currentTime = CMTimeMake(Int64(totlaTime.value) * Int64(positionTime)/Int64(CMTimeGetSeconds(totlaTime)), 1)
                //                TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
                //                NowPlayingCenter().updatePlayingCenter()
                print("changePlaybackPosition currentTime\(currentTime)")
                print("changePlaybackPosition currentTime positionTime\(positionTime)")
                //                滑动会触发playerDidFinishPlaying()函数？
            }
            return .success;
        }
        
        
    }
    
    
    
    @objc func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: .normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
        let mode = TabBarAudioContent.sharedInstance.mode
        print("mode11 \(String(describing: mode))")
        if let mode = TabBarAudioContent.sharedInstance.mode {
            switch mode {
            case 0:
                orderPlay()
            case 1:
                onePlay()
            case 2:
                randomPlay()
            default:
                orderPlay()
            }
        }
        else{
            print("mode nil orderPlay")
            orderPlay()
        }
    }
    
    func orderPlay(){
        count = urlOrigStrings.count
        removePlayerItemObservers()
        playingIndex += 1
        if playingIndex >= count{
            playingIndex = 0
            
        }
        print("urlString playingIndex---\(playingIndex)")
        updateSingleTonData()
        prepareAudioPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        if let nextItem = playerItems?[playingIndex]{
            queuePlayer?.advanceToNextItem()
            currentItem?.seek(to: kCMTimeZero)
            queuePlayer?.insert(nextItem, after: currentItem)
            self.player?.play()
        }
        
    }
    func randomPlay(){
        let randomIndex = Int(arc4random_uniform(UInt32(urlOrigStrings.count)))
        removePlayerItemObservers()
        playingIndex = randomIndex
        print("urlString playingIndex---\(playingIndex)")
        updateSingleTonData()
        prepareAudioPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        if let nextItem = playerItems?[playingIndex]{
            queuePlayer?.advanceToNextItem()
            currentItem?.seek(to: kCMTimeZero)
            queuePlayer?.insert(nextItem, after: currentItem)
            self.player?.play()
        }
    }
    func onePlay(){
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
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
                let item0 = TabBarAudioContent.sharedInstance.item
                let cleanAudioUrl  = self.playerAPI.getUrlAccordingToAudioLanguageIndex(item: item0)
                print ("Handle download Status Change: \(cleanAudioUrl) =? \(id)")
                var headline = ""
                let lastPathName = self.getFileName(urlString: cleanAudioUrl)
                if let headline0 = item0?.headline{
                    headline = headline0
                }

                if id.contains(headline) == true && id.contains(lastPathName) == true {
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
                let item0 = TabBarAudioContent.sharedInstance.item
                let cleanAudioUrl  = self.playerAPI.getUrlAccordingToAudioLanguageIndex(item: item0)
                var headline = ""
                let lastPathName = self.getFileName(urlString: cleanAudioUrl)
                if let headline0 = item0?.headline{
                    headline = headline0
                }
                
                if id.contains(headline) == true && id.contains(lastPathName) == true {
                    self.downloadButton.progress = percentage/100
                    self.downloadButton.status = .resumed
                    print("downloadButton progress is:\(percentage)--id:\(id)")
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
   
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}


