//
//  CustomSmallPlayView.swift
//  Page
//
//  Created by huiyun.he on 27/09/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import MediaPlayer
import WebKit
import SafariServices

class CustomSmallPlayView: UIView {
    lazy var player: AVPlayer? = nil
    lazy var playerItem: AVPlayerItem? = nil
    var isHideMessage:Bool?
    let playAndPauseButton = UIButton()
    let playStatus = UILabel()
    let progressSlider = UISlider()
    let playTime = UILabel()
    let playDuration = UILabel()
    let smallView = UIView()
    
    let upSwipeButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.frame = frame
        //        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        let homePlayBtn = UIImage(named:"HomePlayBtn")
        let homePlayBtnHeight = (homePlayBtn?.size.height)!
        let homePlayBtnWidth = (homePlayBtn?.size.width)!
        var homeTabBarHeight: CGFloat = 90
        var playAndPauseBtnBottomMargin: CGFloat = 12
        var spaceBetweenProgressAndSmallView: CGFloat = 65
        let leftMarginPlayAndPauseButton: CGFloat = 20
        let spaceBetweenProgressAndLable: CGFloat = 15
        
        playAndPauseBtnBottomMargin = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 0, OtherIphoneValue: 1)
        spaceBetweenProgressAndSmallView = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 55, OtherIphoneValue: 56)
        homeTabBarHeight = UIDevice.current.setDifferentDeviceLayoutValue(iphoneXValue: 124, OtherIphoneValue: 90)
        playAndPauseButton.attributedTitle(for: UIControlState.normal)
        playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
        
        self.playAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item:  self.playAndPauseButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -playAndPauseBtnBottomMargin))
        self.addConstraint(NSLayoutConstraint(item:  self.playAndPauseButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: leftMarginPlayAndPauseButton))
        self.addConstraint(NSLayoutConstraint(item: self.playAndPauseButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: homePlayBtnWidth))
        self.addConstraint(NSLayoutConstraint(item: self.playAndPauseButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: homePlayBtnHeight))
        
        
        playStatus.text = "单曲鉴赏"
        playStatus.textColor = UIColor.white
        playStatus.font = UIFont(name: FontType.content, size: 16.0)
        
        self.playStatus.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: playStatus, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.playAndPauseButton, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: playStatus, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.playAndPauseButton, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: leftMarginPlayAndPauseButton))
        self.addConstraint(NSLayoutConstraint(item: playStatus, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -15))
        
        playTime.text = "00:00"
        playTime.textColor = UIColor.white
        playTime.font = UIFont(name: FontType.content, size: 14.0)
        
        self.playTime.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: playTime, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: playTime, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.progressSlider, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        
        let progressThumbImage = UIImage(named: "SliderImg")
        let aa = progressThumbImage?.imageWithImage(image: progressThumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        progressSlider.setThumbImage(aa, for: .normal)
        progressSlider.maximumTrackTintColor = UIColor.white
        progressSlider.minimumTrackTintColor = UIColor(hex: "#05d5e9")
        
        
        self.progressSlider.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -spaceBetweenProgressAndSmallView))
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.playTime, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: spaceBetweenProgressAndLable))
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.playDuration, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -spaceBetweenProgressAndLable))
        
        playDuration.text = "00:00"
        playDuration.textColor = UIColor.white
        playDuration.font = UIFont(name: FontType.content, size: 14.0)
        self.playDuration.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: playDuration, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10))
        self.addConstraint(NSLayoutConstraint(item: playDuration, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.progressSlider, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        

        self.smallView.addSubview(playStatus)
        self.smallView.addSubview(playAndPauseButton)
        self.smallView.addSubview(progressSlider)
        self.smallView.addSubview(playTime)
        self.smallView.addSubview(playDuration)
        //        self.smallView.addSubview(upSwipeButton)
        smallView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.9)
        smallView.frame = CGRect(x:0,y:0,width:width,height:homeTabBarHeight)
        self.addSubview(smallView)
        
        self.playAndPauseButton.addTarget(self, action: #selector(pauseOrPlay), for: UIControlEvents.touchUpInside)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.openAudio))
        self.smallView.addGestureRecognizer(tapGestureRecognizer1)
        self.progressSlider.addTarget(self, action: #selector(changeSlider), for: UIControlEvents.valueChanged)
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func pauseOrPlay(sender: UIButton) {
        let  player = TabBarAudioContent.sharedInstance.player
        let  playerItem = TabBarAudioContent.sharedInstance.playerItem
        
        if (player != nil) {
            print("item11 palyer isExist \(String(describing: playerItem))")
            if player?.rate != 0 && player?.error == nil {
                print("palyer item pause)")
                self.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
                player?.pause()
                
            } else {
                print("palyer item play)")
                self.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = true
                
                player?.play()
                player?.replaceCurrentItem(with: playerItem)
                
            }
        }
    }
    
    @objc func openAudio(){
        if let audioPlayerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayerController") as? AudioPlayerController {
            let tabItem = TabBarAudioContent.sharedInstance.item
            if let tabItem = tabItem ,let audioFileUrl = tabItem.caudio {
                TabBarAudioContent.sharedInstance.body["title"] = tabItem.headline
                TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(tabItem.id)"
                audioPlayerController.item = tabItem
            }
            audioPlayerController.modalPresentationStyle = .custom
            print("audioPlayerController open")
            let controller = UIApplication.shared.keyWindow?.rootViewController
            controller?.present(audioPlayerController, animated: true, completion: nil)
          
//            controller?.navigationController?.navigationBar.barStyle = .black
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBarStyle1"), object: self)
    }
    @objc func changeSlider(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        print("sliderValueChanged button\(currentTime)")
    }
    
    @objc func updateMiniPlay(){
        //        print("How many times updateMiniPlay observe run?")
        self.isHidden = false
        if let item = TabBarAudioContent.sharedInstance.item{
            player = TabBarAudioContent.sharedInstance.player
            self.playStatus.text = item.headline
            updateProgressSlider()
            updatePlayButtonUI()
        }
    }
    func updateProgressSlider(){
        // MARK: - Update audio play progress
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
            if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
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
    }
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        self.playDuration.text = "-\((duration-time).durationText)"
        self.playTime.text = time.durationText
    }
    @objc func reloadAudioView(){
        if let item = TabBarAudioContent.sharedInstance.item,let audioUrlStrFromList = item.caudio  {
            print("audioUrlStrFromList--\(audioUrlStrFromList)")
            self.playStatus.text = item.headline
            //           为什么 TabBarAudioContent.sharedInstance.audioHeadLine 一直保持初始值？因为点击首页播放按钮触发的赋值动作，collectionView中cell监听的动作只要其他地方监听会一直触发动作（有待继续核实）
            
        }
        print("audioUrlStrFromList isplaying？--\(TabBarAudioContent.sharedInstance.isPlaying)")
        
        //        updatePlayButtonUI()
        //        反着的原因是可能是初始监控为true的原因
        if TabBarAudioContent.sharedInstance.isPlaying{
            self.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
        }else{
            self.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
        }
    }
    @objc public func updatePlayButtonUI() {
        if TabBarAudioContent.sharedInstance.isPlaying{
            self.playAndPauseButton.setImage(UIImage(named:"HomePauseBtn"), for: UIControlState.normal)
        }else{
            self.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
        }
    }
}
