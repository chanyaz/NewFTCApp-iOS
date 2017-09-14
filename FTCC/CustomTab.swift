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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playFinish),
            name: Notification.Name(rawValue: "playFinish"),
            object: nil
        )
        
        
    }
    
    
    func playFinish(){
        print("playFinish000----")
        // seek(to: kCMTimeZero)只能放到此处，并且值为kCMTimeZero，有时间可以适当调整duration 和time之间的差值
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: kCMTimeZero)
        TabBarAudioContent.sharedInstance.isPlaying = false
        //        点击相同的语音就不会运行此处，点击不同的会运行
        //       progressSlider.value = 0
        //       playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        //       upSwipeButton.backgroundColor = UIColor.red
        
    }
    //    不能放在外面，因为此处不会运行，该放在能及时更新的地方
    //   此函数执行了切换后的值，最后面跳回去是什么原因呢？
    //    最终还执行这里
    func updateMiniPlay(){
        
        audioLable.text=TabBarAudioContent.sharedInstance.item?.headline
        let duration = TabBarAudioContent.sharedInstance.duration
        let time = TabBarAudioContent.sharedInstance.time
        print("playFinish11----\(String(describing: duration?.durationText))")
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
            if duration == time{
                print("playFinish22----")
                progressSlider.value = 0
                playDuration.text = "-\(duration.durationText)"
                playTime.text = "00:00"
                playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
            }
        }
        //       放在此处合适么？放此处是一直处于监控状态
        if TabBarAudioContent.sharedInstance.isPlaying{
            playAndPauseButton.setImage(UIImage(named:"BigPauseButton"), for: UIControlState.normal)
            
        }else{
            playAndPauseButton.setImage(UIImage(named:"BigPlayButton"), for: UIControlState.normal)
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
