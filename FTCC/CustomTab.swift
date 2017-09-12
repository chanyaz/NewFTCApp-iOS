//
//  CustomTab.swift
//  Page
//
//  Created by huiyun.he on 28/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import MediaPlayer
class CustomTab: UIView {
    
    var isHideMessage:Bool?
    let playAndPauseButton = UIButton()
    let audioLable = UILabel()
    let progressSlider = UISlider()
    let playTime = UILabel()
    let playDuration = UILabel()
    
    let upSwipeButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.frame = frame
        //        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        
        playAndPauseButton.frame = CGRect(x:10,y:36,width:50,height:50)
        playAndPauseButton.attributedTitle(for: UIControlState.normal)
        audioLable.frame = CGRect(x:70,y:36,width:250,height:50)
        
        playTime.frame = CGRect(x:5,y:8,width:50,height:20)
        playTime.text = "00:00"
        playTime.textColor = UIColor.white
        
        progressSlider.frame = CGRect(x:60,y:8,width:width - 140,height:20)
        //        progressSlider.value = 0.3
        let progressThumbImage = UIImage(named: "SliderImg")
        let aa = progressThumbImage?.imageWithImage(image: progressThumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        progressSlider.setThumbImage(aa, for: .normal)
        progressSlider.maximumTrackTintColor = UIColor.white
        progressSlider.minimumTrackTintColor = UIColor(hex: "#05d5e9")
        
        
        
        playDuration.frame = CGRect(x:width-60,y:8,width:70,height:20)
        playDuration.text = "00:00"
        playDuration.textColor = UIColor.white
        audioLable.text = "单曲鉴赏"
        audioLable.textColor = UIColor.white
        
        upSwipeButton.frame = CGRect(x:width-60,y:50,width:30,height:30)
        upSwipeButton.setTitle("上滑", for: .normal)
        upSwipeButton.backgroundColor = UIColor.blue
        self.addSubview(audioLable)
        self.addSubview(playAndPauseButton)
        self.addSubview(progressSlider)
        self.addSubview(playTime)
        self.addSubview(playDuration)
        self.addSubview(upSwipeButton)
        isHideMessage = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMiniPlay),
            name: Notification.Name(rawValue: "updateMiniPlay"),
            object: nil
        )
    }
    func updateMiniPlay(){
        audioLable.text=TabBarAudioContent.sharedInstance.item?.headline
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
        //        let playerItem = TabBarAudioContent.sharedInstance.playerItem
        //        let player = TabBarAudioContent.sharedInstance.player
        //        if let player = player{
        if TabBarAudioContent.sharedInstance.isPlaying{
            //                print("isPlaying true")
            playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
            //                player.play()
            //                player.replaceCurrentItem(with: playerItem)
        }else{
            //                print("isPlaying false")
            playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            //                player.pause()
        }
        //        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
