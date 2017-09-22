//
//  LaunchScreen.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/27.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import AVKit
import AVFoundation
import StoreKit
import MediaPlayer

class LaunchScreen: UIViewController {
    // MARK: - Find out whether the user is happy and prompt rating if he/she is happy
    public let happyUser = HappyUser()
    public var showCloseButton = true
    public var isBetweenPages = false
    private lazy var timer: Timer? = nil
    
    // MARK: - If the app use a native launch ad, suppress the pop up one
    private let useNativeLaunchAd = "useNativeLaunchAd"
    private var maxAdTimeAfterLaunch = 3.0
    private var maxAdTimeAfterWebRequest = 1.5
    private let fadeOutDuration = 0.5
    private let adSchedule = AdSchedule()
    private lazy var player: AVPlayer? = {return nil} ()
    private lazy var token: Any? = {return nil} ()
    private lazy var overlayView: UIView? = UIView()
    private var adShowed = false
    
    // MARK: - Hide Ad for Demo Purposes
    private let hideAd = false
    private var adType = ""
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: Event.newAdCreativeDownloaded),
            object: nil
        )
        print ("Launch Ad Closed Successfully! ")
    }
    
    override func loadView() {
        super.loadView()
        adOverlayView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeAfterSeconds(maxAdTimeAfterLaunch)
        // MARK: download the latest ad schedule from the internet
        if (adType != "none") {
            adSchedule.updateAdSchedule()
        }
        // Do any additional setup after loading the view.
        // print ("launch screen loaded")
        
        //        Timer.scheduledTimer(
        //            timeInterval: 6,
        //            target: self,
        //            selector: #selector(close),
        //            userInfo: nil,
        //            repeats: true
        //        )
        
        // MARK: - Notification If New Ad Creative is Downloaded
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(retryAd),
            name: Notification.Name(rawValue: Event.newAdCreativeDownloaded),
            object: nil
        )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: On mobile phone, lock the screen to portrait only
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.all
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    
    // MARK: if there's a full screen screen ad to show
    private func adOverlayView() {
        // MARK: - If the developer don't want to display the ad
        if self.adType == "none" || self.hideAd == true || adShowed == true {
            maxAdTimeAfterLaunch = 1.0
            maxAdTimeAfterWebRequest = 1.0
            normalOverlayView()
            return
        }
        adSchedule.parseSchedule()
        if let adScheduleDurationInSeconds: Double = adSchedule.durationInSeconds {
            maxAdTimeAfterLaunch = adScheduleDurationInSeconds
            maxAdTimeAfterWebRequest = maxAdTimeAfterLaunch - 2.0
        }
        //print (maxAdTimeAfterLaunch)
        if adSchedule.adType == "page" {
            reportImpressionToClient(impressions: adSchedule.impression)
            adShowed = true
            addOverlayView()
            showHTMLAd()
        } else if adSchedule.adType == "image" {
            reportImpressionToClient(impressions: adSchedule.impression)
            adShowed = true
            addOverlayView()
            showImage()
        } else if adSchedule.adType == "video" {
            reportImpressionToClient(impressions: adSchedule.impression)
            adShowed = true
            playVideo()
        } else {
            normalOverlayView()
            return
        }
        // MARK: button to close the full screen ad
        addCloseButton()
        // MARK: set custom background
        setAdBackground()
    }
    
    private func addOverlayView() {
        if let overlay = overlayView {
            overlay.backgroundColor = UIColor(netHex:0x000000)
            overlay.frame = self.view.bounds
            self.view.addSubview(overlay)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
        }
    }
    
    
    @objc public func retryAd() {
        print ("Try to parse the ad schedule to decide if you can show an ad now")
        if let overlay = overlayView {
            for subUIView in overlay.subviews {
                subUIView.removeFromSuperview()
            }
        }
        adOverlayView()
    }
    
    // MARK: if there's no ad to load, load the normal start screen
    func normalOverlayView() {
        if let overlayViewNormal = overlayView {
            maxAdTimeAfterLaunch = 6.0
            maxAdTimeAfterWebRequest = 4.0
            overlayViewNormal.backgroundColor = UIColor(netHex:0x002F5F)
            overlayViewNormal.frame = self.view.bounds
            self.view.addSubview(overlayViewNormal)
            overlayViewNormal.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
            
            // MARK: the icon image
            if let image = UIImage(named: "FTC-start") {
                let imageView =  UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 266, height: 210)
                imageView.contentMode = .scaleAspectFit
                overlayViewNormal.addSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1/3, constant: 1))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 266))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 210))
            }
            
            // MARK: the lable at the bottom
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 441, height: 21))
            label.center = CGPoint(x: 160, y: 284)
            label.textAlignment = NSTextAlignment.center
            label.text = "英国《金融时报》中文网"
            label.textColor = UIColor.white
            overlayViewNormal.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -20))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 441))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 21))
            
            // MARK: Request user to review only if the app starts without the launch ad
            if AppLaunch.sharedInstance.from == "notification" {
                happyUser.canTryRequestReview = false
            }
            happyUser.requestReview()
        }
    }
    
    
    
    // MARK: - The close button for the user to close the full screen ad when app launches
    private func addCloseButton() {
        if showCloseButton == false {
            return
        }
        let horizontalLayout:NSLayoutAttribute
        let verticalLayout:NSLayoutAttribute
        let horizontalMargin:CGFloat
        let verticalMargin:CGFloat
        let buttonWidth:CGFloat
        let defaultButtonWidth:CGFloat = 40
        let customButtonWidth:CGFloat = 80
        var isCustomButton = true
        switch adSchedule.closeButtonCustomization {
        case "LeftTop":
            horizontalLayout = .left
            verticalLayout = .top
            buttonWidth = customButtonWidth
            horizontalMargin = 0
            verticalMargin = 0
        case "RightTop":
            horizontalLayout = .right
            verticalLayout = .top
            buttonWidth = customButtonWidth
            horizontalMargin = 0
            verticalMargin = 0
        case "LeftBottom":
            horizontalLayout = .left
            verticalLayout = .bottom
            buttonWidth = customButtonWidth
            horizontalMargin = 0
            verticalMargin = 0
        case "RightBottom":
            horizontalLayout = .right
            verticalLayout = .bottom
            buttonWidth = customButtonWidth
            horizontalMargin = 0
            verticalMargin = 0
        default:
            horizontalLayout = .right
            verticalLayout = .top
            buttonWidth = defaultButtonWidth
            isCustomButton = false
            horizontalMargin = -16
            verticalMargin = 16
        }
        
        
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        if isCustomButton == false {
            let image = getImageFromSupportingFile(imageFileName: "close.png")
            button.backgroundColor = UIColor(white: 0, alpha: 0.382)
            button.setImage(image, for: UIControlState())
            button.layer.masksToBounds = true
            button.layer.cornerRadius = buttonWidth/2
        }
        
        if adSchedule.adType == "video" {
            self.view.viewWithTag(111)?.addSubview(button)
        } else {
            self.overlayView?.addSubview(button)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        view.addConstraint(NSLayoutConstraint(item: button, attribute: horizontalLayout, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: horizontalLayout, multiplier: 1, constant: horizontalMargin))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: verticalLayout, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: verticalLayout, multiplier: 1, constant: verticalMargin))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        
    }
    
    // MARK: - Allow ad operation to set the background color of a full-screen ad
    private func setAdBackground() {
        if let newBGColor = adSchedule.backgroundColor {
            if adSchedule.adType == "video" {
                self.view.viewWithTag(111)?.backgroundColor = newBGColor
            } else {
                self.overlayView?.backgroundColor = newBGColor
            }
        }
    }
    
    // MARK: - Show the image view of a full-screen ad when app launches
    private func showImage() {
        if let image = adSchedule.image {
            let imageView: UIImageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            imageView.contentMode = .scaleAspectFit
            self.overlayView?.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenWidth))
            view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenHeight))
            imageView.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickAd))
            imageView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    // MARK: - Show the HTML view of a full-screen ad when app launches
    private func showHTMLAd() {
        let adPageView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        let base = URL(string: adSchedule.htmlBase)
        let s = adSchedule.htmlFile
        //if #available(iOS 10.0, *) {
        if #available(iOS 10.0, *) {
            adPageView.configuration.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
        } else {
            // Fallback on earlier versions
            //adPageView.configuration.mediaPlaybackRequiresUserAction = false
        }
        adPageView.loadHTMLString(s as String, baseURL:base)
        overlayView?.addSubview(adPageView)
        if adSchedule.adLink != "" {
            let adPageLinkOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickAd))
            overlayView?.addSubview(adPageLinkOverlay)
            adPageLinkOverlay.addGestureRecognizer(tapRecognizer)
        }
    }
    
    // MARK: - Play video of a full-screen ad when app launches
    private func playVideo() {
        let path = adSchedule.videoFilePath
        
        //let path = "/Users/zhangoliver/Library/Developer/CoreSimulator/Devices/D02EDCEC-BD4D-442E-91DD-FEA096B5D07C/data/Containers/Data/Application/E176DB68-9184-489C-B776-8D057159F4B1/Library/Caches/video-adv-AccentureTest2.mp4"
        
        print ("launch ad path is \(path)")
        let pathUrl = URL(fileURLWithPath: path)
        maxAdTimeAfterLaunch = 60.0
        maxAdTimeAfterWebRequest = 57.0
        player = AVPlayer(url: pathUrl)
        let playerController = AVPlayerViewController()
        
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        let videoDuration = asset.duration
        
        // MARK: Video view must be added to the self.view, not a subview, otherwise Xcode complains about constraints
        playerController.player = player
        
        // FIXME: I don't know what the following line does. Please find out.
        self.addChildViewController(playerController)
        playerController.showsPlaybackControls = false
        
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        
        // MARK: The Video should be muted by default. The user can unmute if they want to listen.
        player?.isMuted = true
        player?.play()
        
        self.view.addSubview(playerController.view)
        playerController.view.tag = 111
        playerController.view.frame = self.view.frame
        
        // MARK: Label for time at the left bottom
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        let timeLabel = String(format:"%.0f", CMTimeGetSeconds(videoDuration))
        label.textAlignment = NSTextAlignment.center
        label.adjustsFontSizeToFitWidth = true
        label.text = timeLabel
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(white: 0, alpha: 0.382)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.tag = 112
        playerController.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 20))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -20))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30))
        
        if let image = adSchedule.backupImage {
            playerController.view.backgroundColor = UIColor(patternImage: image)
        }
        
        // MARK: If the advertiser put the customized close button to left bottom corner, hide the time label
        if adSchedule.closeButtonCustomization == "LeftBottom" {
            label.isHidden = true
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        if adSchedule.adLink != "" {
            let adPageLinkOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight - 44))
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickAd))
            playerController.view.addSubview(adPageLinkOverlay)
            adPageLinkOverlay.addGestureRecognizer(tapRecognizer)
        }
        
        var timeRecorded = [0]
        let deviceType = DeviceInfo.checkDeviceType()
        
        let lastcomponent = pathUrl.lastPathComponent
        token = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1,10), queue: DispatchQueue.main, using: { [weak self] timeInterval in
            let timeLeft = CMTimeGetSeconds(videoDuration-timeInterval)
            if let theLabel = self?.view.viewWithTag(112) as? UILabel {
                theLabel.text = String(format:"%.0f", timeLeft)
            }
            // MARK: Record play time as events
            let timeSpent = Int(CMTimeGetSeconds(timeInterval))
            let timeRecordStep = 5
            if !timeRecorded.contains(timeSpent) && timeSpent % timeRecordStep == 0 {
                print(timeSpent)
                Track.event(category: "\(deviceType) Launch Video Play", action: lastcomponent, label: "\(timeSpent)")
                timeRecorded.append(timeSpent)
            }
        })
        
        // MARK: Button for switching the mute mode on and off. Hide it if customized close button is at the left top corner
        if adSchedule.showSoundButton == true && adSchedule.closeButtonCustomization != "LeftTop" {
            let imageForMute = getImageFromSupportingFile(imageFileName: "sound.png")
            let imageForSound = getImageFromSupportingFile(imageFileName: "mute.png")
            let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            button.backgroundColor = UIColor(white: 0, alpha: 0.382)
            button.setImage(imageForMute, for: UIControlState())
            button.setImage(imageForSound, for: .selected)
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 20
            playerController.view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(videoMuteSwitch), for: .touchUpInside)
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 16))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 16))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
        }
        
    }
    
    
    @IBAction private func videoMuteSwitch(sender: UIButton) {
        if sender.isSelected {
            player?.isMuted = true
            sender.isSelected = false
        } else {
            // MARK: this will make the video play sound even when iPhone is muted
            player?.isMuted = false
            sender.isSelected = true
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("Couldn't turn on sound: \(error.localizedDescription)")
            }
        }
    }
    
    private func getImageFromSupportingFile(imageFileName: String) -> UIImage? {
        let filename: NSString = imageFileName as NSString
        let pathExtention = filename.pathExtension
        let pathPrefix = filename.deletingPathExtension
        if let templatepath = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention) {
            let image: UIImage? = UIImage(contentsOfFile: templatepath)
            return image
        }
        return nil
    }
    
    // MARK: report ad impressions
    private func reportImpressionToClient(impressions: [String]) {
        let deviceType = DeviceInfo.checkDeviceType()
        let unixDateStamp = Date().timeIntervalSince1970
        let timeStamp = String(unixDateStamp).replacingOccurrences(of: ".", with: "")
        for impressionUrlString in impressions {
            let impressionUrlStringWithTimestamp = impressionUrlString.replacingOccurrences(of: "[timestamp]", with: timeStamp)
            print ("send to \(impressionUrlStringWithTimestamp)")
            if var urlComponents = URLComponents(string: impressionUrlStringWithTimestamp) {
                let newQuery = URLQueryItem(name: "fttime", value: timeStamp)
                if urlComponents.queryItems != nil {
                    urlComponents.queryItems?.append(newQuery)
                } else {
                    urlComponents.queryItems = [newQuery]
                }
                if let url = urlComponents.url {
                    Download.getDataFromUrl(url) { (data, response, error)  in
                        DispatchQueue.main.async { () -> Void in
                            guard let _ = data , error == nil else {
                                // MARK: Use the original impressionUrlString for Google Analytics
                                Track.event(category: "\(deviceType) Launch Ad", action: "Fail", label: "\(impressionUrlString)")
                                // MARK: The string should have the parameter
                                print ("Fail to send impression to \(url.absoluteString)")
                                return
                            }
                            Track.event(category: "\(deviceType) Launch Ad", action: "Sent", label: "\(impressionUrlString)")
                            print("sent impression to \(url.absoluteString)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: this should be public
    @objc func clickAd() {
        let urlString = adSchedule.adLink
        if let url = URL(string: urlString) {
            openLink(url)
        }
        let deviceType = DeviceInfo.checkDeviceType()
        Track.event(category: "\(deviceType) Launch Ad", action: "Click", label: "\(adSchedule.adLink)")
    }
    
    
    private func closeAfterSeconds(_ seconds: TimeInterval) {
        if timer == nil {
            //timer?.invalidate()
            let nextTimer = Timer.scheduledTimer(
                timeInterval: seconds,
                target: self,
                selector: #selector(close),
                userInfo: nil,
                repeats: false
            )
            nextTimer.tolerance = 1
            timer = nextTimer
        }
    }
    
    
    // MARK: Remove the overlay and reveal the web view. This should be public.
    @objc func close() {

        player?.pause()
        player = nil
        
        if let t = token {
            player?.removeTimeObserver(t)
            token = nil
        }
        timer?.invalidate()
        
        //MARK: If the full page ad is between pages, don't remove it in time
        if isBetweenPages == true {
            return
        }
        
        self.view.superview?.removeFromSuperview()
        self.removeFromParentViewController()
        AppLaunch.sharedInstance.fullScreenDismissed = true
        if let topViewController = UIApplication.topViewController() {
            topViewController.setNeedsStatusBarAppearanceUpdate()
        }
        //self.dismiss(animated: true, completion: nil)
    }
    
}

struct AppLaunch {
    static var sharedInstance = AppLaunch()
    var launched = false
    var adShowed = false
    var fullScreenDismissed = false
    var from: String?
}
