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
    let smallView = UIView()
    
    let upSwipeButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.frame = frame
        //        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        
        playAndPauseButton.frame = CGRect(x:10,y:36,width:50,height:50)
        playAndPauseButton.attributedTitle(for: UIControlState.normal)
        playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
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
        
        upSwipeButton.frame = CGRect(x:width-60,y:50,width:40,height:40)
        upSwipeButton.setTitle("上滑", for: .normal)
        upSwipeButton.backgroundColor = UIColor.blue
        self.smallView.addSubview(audioLable)
        self.smallView.addSubview(playAndPauseButton)
        self.smallView.addSubview(progressSlider)
        self.smallView.addSubview(playTime)
        self.smallView.addSubview(playDuration)
//        self.smallView.addSubview(upSwipeButton)
        smallView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.9)
        smallView.frame = CGRect(x:0,y:0,width:width,height:90)
        self.addSubview(smallView)
        
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(updateMiniPlay),
//            name: Notification.Name(rawValue: "updateMiniPlay"),
//            object: nil
//        )
        
    }
    
    
    func taptextField(sender: UIButton) {
        //        let deltaY = self.audioPlayerView.bounds.height
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.transform = CGAffineTransform(translationX: 0,y: -40)
            self.setNeedsUpdateConstraints()
            
        }, completion: { (true) in
            print("up animate finish")
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
