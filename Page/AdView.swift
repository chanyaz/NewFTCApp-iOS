//
//  AdView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/12.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import AVKit
import AVFoundation
import MediaPlayer

class AdView: UIView, SFSafariViewControllerDelegate {
    
    private var adid: String?
    private var adWidth: String?
    private var adModel: AdModel?
    private lazy var player: AVPlayer? = nil
    
    //MARK: Don't use DidSet to trigger updateUI, it might cause unexpected crashes
    public var contentSection: ContentSection? = nil

    public func updateUI() {
        if let adType = contentSection?.type, adType == "MPU" {
            adWidth = "300px"
        } else {
            adWidth = "100%"
        }
        clean()
        //TODO: - We should preload the ad information to avoid decreasing our ad inventory
        if let adid = contentSection?.adid {
            self.adid = adid
            if let url = AdParser.getAdUrlFromDolphin(adid) {
                
                //print ("Request Ad From \(url)")
                Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                    DispatchQueue.main.async { () -> Void in
                        // MARK: Dolphin Uses GBK as encoding
                        guard let data = data , error == nil, let adCode = String(data: data, encoding: Download.encodingGBK()) else {
                            self?.handleAdModel()
                            return
                        }
                        let adModel = AdParser.parseAdCode(adCode)
                        self?.adModel = adModel
                        self?.handleAdModel()
                    }
                }
            }
        }
    }
    
    
    private func clean() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
    
    private func handleAdModel() {
        if let adModel = self.adModel {
            // MARK: Track Impression First
            Impressions.report(adModel.impressions)
            if let videoString = adModel.video {
                // MARK: If the asset is already downloaded, no need to request from the Internet
                if let videoFilePath = Download.getFilePath(videoString, for: .cachesDirectory, as: nil) {
                    print ("video already downloaded to:\(videoFilePath)")
                    showAdVideo(videoFilePath)
                    return
                }
                if let url = URL(string: videoString) {
                    Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                        guard let data = data else {
                            self?.loadWebView()
                            return
                        }
                        Download.saveFile(data, filename: videoString, to: .cachesDirectory, as: nil)
                        DispatchQueue.main.async { () -> Void in
                            if let videoFilePath = Download.getFilePath(videoString, for: .cachesDirectory, as: nil) {
                                self?.showAdVideo(videoFilePath)
                                print ("video just downloaded:\(videoString) as \(videoFilePath)")
                            }
                        }
                    }
                }
            } else if let imageString = adModel.imageString {
                // MARK: If the asset is already downloaded, no need to request from the Internet
                if let data = Download.readFile(imageString, for: .cachesDirectory, as: nil) {
                    showAdImage(data)
                    return
                }
                if let url = URL(string: imageString) {
                    Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                        guard let data = data else {
                            self?.loadWebView()
                            return
                        }
                        DispatchQueue.main.async { () -> Void in
                            self?.showAdImage(data)
                        }
                        Download.saveFile(data, filename: imageString, to: .cachesDirectory, as: nil)
                    }
                }
            } else {
                // MARK: Should Use Ad Code to Load Web View
                loadWebView()
            }
        } else {
            loadWebView()
        }
    }
    
    private func showAdVideo(_ path: String) {
        let pathUrl = URL(fileURLWithPath: path)
        player = AVPlayer(url: pathUrl)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        layer.addSublayer(playerLayer)
        player?.isMuted = true
        player?.play()
        
        Track.event(category: "Video Ad", action: "Play Automatically", label: adModel?.video ?? "")
        
        // MARK: video played to the end
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        let adWidth: CGFloat = 300
        let adHeight: CGFloat = 250
        let bottomViewHeight: CGFloat = 44
        let buttonWidth: CGFloat = 36
        let buttonPadding = (bottomViewHeight - buttonWidth)/2

        // MARK: Set Background of the Ad View to default content background
        self.backgroundColor = UIColor(hex: Color.Content.background)
        
        // MARK: Ad a semi-transparent view
        bottomView = UIView()
        bottomView?.backgroundColor = UIColor.black.withAlphaComponent(0.618)
        bottomView?.isOpaque = false
        bottomView?.frame = CGRect(
            x: (self.frame.width - adWidth)/2,
            y: adHeight-bottomViewHeight,
            width: adWidth,
            height: bottomViewHeight)
        if let bottomView = bottomView {
            self.addSubview(bottomView)
        }
        
        
        fadeOutVideoControl()

        
        
//        bottomView?.animateWithDuration
//        (animationDuration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
//            view.alpha = 0
//        },
//                                   completion: nil)
        
        
        
        // MARK: Mute Button
        if let imageForMute = UIImage(named: "sound.png"),
            let imageForSound = UIImage(named: "mute.png") {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
            //button.backgroundColor = UIColor(white: 0, alpha: 0.382)
            button.setImage(imageForMute, for: UIControlState())
            button.setImage(imageForSound, for: .selected)
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 20
            bottomView?.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(videoMuteSwitch), for: .touchUpInside)
            self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: bottomView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -buttonPadding))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: bottomView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -buttonPadding))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        }
        
        // MARK: Play Button
        if let imageForPlay = UIImage(named: "PlayButton"),
            let imageForPause = UIImage(named: "PauseButton") {
            playButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
            //button.backgroundColor = UIColor(white: 0, alpha: 0.382)
            playButton?.setImage(imageForPause, for: UIControlState())
            playButton?.setImage(imageForPlay, for: .selected)
            playButton?.layer.masksToBounds = true
            playButton?.layer.cornerRadius = 20
            playButton?.translatesAutoresizingMaskIntoConstraints = false
            playButton?.addTarget(self, action: #selector(playPauseSwitch), for: .touchUpInside)
            if let playButton = playButton {
            bottomView?.addSubview(playButton)
            self.addConstraint(NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: bottomView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: buttonPadding))
            self.addConstraint(NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: bottomView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -buttonPadding))
            self.addConstraint(NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
            self.addConstraint(NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
            }
        }

    }
    
    private lazy var playButton: UIButton? = nil
    private lazy var bottomView: UIView? = nil
    private lazy var fadeTimer: Timer? = nil
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        
        if (notification.object as? AVPlayerItem) != nil {
            print("Video Finished")
            playButton?.isSelected = true
            bottomView?.fadeIn()
        }
        
    }
    
    private func fadeOutVideoControl() {
        let delay: TimeInterval = 3.0
        if #available(iOS 10.0, *) {
            fadeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] timer in
                self?.bottomView?.fadeOut()
            }
        } else {
            bottomView?.fadeOut(delay: 5.0)
        }
    }
    
    @IBAction private func videoMuteSwitch(sender: UIButton) {
        if sender.isSelected {
            player?.isMuted = true
            sender.isSelected = false
            Track.event(category: "Video Ad", action: "Tap to Mute", label: adModel?.video ?? "")
        } else {
            // MARK: this will make the video play sound even when iPhone is muted
            player?.isMuted = false
            sender.isSelected = true
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("Couldn't turn on sound: \(error.localizedDescription)")
            }
            Track.event(category: "Video Ad", action: "Tap for Sound", label: adModel?.video ?? "")
        }
    }
    
    @IBAction private func playPauseSwitch(sender: UIButton) {
        if sender.isSelected {
            player?.seek(to: kCMTimeZero)
            player?.play()
            sender.isSelected = false
            fadeOutVideoControl()
            Track.event(category: "Video Ad", action: "Tap to Play", label: adModel?.video ?? "")
        } else {
            // MARK: this will make the video play sound even when iPhone is muted
            player?.pause()
            fadeTimer?.invalidate()
            bottomView?.alpha = 1.0
            sender.isSelected = true
            Track.event(category: "Video Ad", action: "Tap to Pause", label: adModel?.video ?? "")
        }
    }
    
    
    private func showAdImage(_ data: Data) {
        let frameWidth = self.frame.width
        let frameHeight = self.frame.height
        if let image = UIImage(data: data),
            let adWidth = self.adWidth {
            let imageWidth: CGFloat
            if adWidth.hasSuffix("px") {
                let adWidthString = adWidth.replacingOccurrences(of: "px", with: "")
                if let adWidthInt = Int(adWidthString) {
                    imageWidth = CGFloat(adWidthInt)
                } else {
                    imageWidth = frameWidth
                }
            } else {
                imageWidth = frameWidth
            }
            let imageX = min(max((frameWidth - imageWidth)/2,0), frameWidth)
            let imageFrame = CGRect(x: imageX, y: 0, width: imageWidth, height: frameHeight)
            let imageView = UIImageView(frame: imageFrame)
            imageView.image = image
            self.addSubview(imageView)
            self.backgroundColor = UIColor(hex: Color.Content.background)
        } else {
            self.loadWebView()
        }
        addTap()
    }
    
    private func addTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let link = self.adModel?.link, let url = URL(string: link) {
            openLink(url)
        }
    }
    
    fileprivate func openLink(_ url: URL) {
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        if let topController = UIApplication.topViewController() {
            topController.present(webVC, animated: true, completion: nil)
        }
    }
    
    private func loadWebView() {
        if let adid = self.adid, let adWidth = self.adWidth {
            let config = WKWebViewConfiguration()
            config.allowsInlineMediaPlayback = true
            
            
            // MARK: Tell the web view what kind of connection the user is currently on
            let contentController = WKUserContentController();
            let jsCode = "window.gConnectionType = '\(Connection.current())';"
            let userScript = WKUserScript(
                source: jsCode,
                injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                forMainFrameOnly: true
            )
            contentController.addUserScript(userScript)
            config.userContentController = contentController
            
            
            let webView = WKWebView(frame: self.frame, configuration: config)
            webView.isOpaque = true
            webView.backgroundColor = UIColor.clear
            webView.scrollView.backgroundColor = UIColor.clear
            webView.navigationDelegate = self
            self.addSubview(webView)
            let urlString = AdParser.getAdPageUrlForAdId(adid)
            if let url = URL(string: urlString) {
                let req = URLRequest(url:url)
                if let adHTMLPath = Bundle.main.path(forResource: "ad", ofType: "html"),
                    let gaJSPath = Bundle.main.path(forResource: "ga", ofType: "js"){
                    do {
                        let adHTML = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let gaJS = try NSString(contentsOfFile:gaJSPath, encoding:String.Encoding.utf8.rawValue)
                        let adCode = adModel?.adCode ?? ""
                        let adHTMLFinal = (adHTML as String)
                            .replacingOccurrences(of: "{google-analytics-js}", with: gaJS as String)
                            .replacingOccurrences(of: "{adbodywidth}", with: adWidth)
                        .replacingOccurrences(of: "{ad-code-from-server}", with: adCode)
                        webView.loadHTMLString(adHTMLFinal, baseURL:url)
                    } catch {
                        webView.load(req)
                    }
                } else {
                    webView.load(req)
                }
            }
        }
    }
    
}

extension AdView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if navigationAction.navigationType == .linkActivated{
                if urlString.range(of: "mailto:") != nil{
                    UIApplication.shared.openURL(url)
                } else {
                    openLink(url)
                }
                decisionHandler(.cancel)
            }  else {
                decisionHandler(.allow)
            }
        }
    }
}


