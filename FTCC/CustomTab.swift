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
        let homeTabBarHeight: CGFloat = 95
        let playAndPauseBtnBottomMargin: CGFloat = 12
        playAndPauseButton.attributedTitle(for: UIControlState.normal)
        playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)

        self.playAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item:  self.playAndPauseButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -playAndPauseBtnBottomMargin))
        self.addConstraint(NSLayoutConstraint(item:  self.playAndPauseButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: self.playAndPauseButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: homePlayBtnWidth))
        self.addConstraint(NSLayoutConstraint(item: self.playAndPauseButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: homePlayBtnHeight))
        
        
//        playStatus.frame = CGRect(x:70,y:36,width:250,height:50)
        playStatus.text = "单曲鉴赏"
        playStatus.textColor = UIColor.white
        playStatus.font = UIFont(name: "Helvetica-Light", size: 16.0)
        
        self.playStatus.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: playStatus, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.playAndPauseButton, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: playStatus, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.playAndPauseButton, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: playStatus, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -15))
  
        
//        playTime.frame = CGRect(x:5,y:8,width:50,height:20)
        playTime.text = "00:00"
        playTime.textColor = UIColor.white
        playTime.font = UIFont(name: "Helvetica-Light", size: 14.0)
        
        self.playTime.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: playTime, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: playTime, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.progressSlider, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
//        progressSlider.frame = CGRect(x:60,y:8,width:width - 140,height:20)
        //        progressSlider.value = 0.3
        let progressThumbImage = UIImage(named: "SliderImg")
        let aa = progressThumbImage?.imageWithImage(image: progressThumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        progressSlider.setThumbImage(aa, for: .normal)
        progressSlider.maximumTrackTintColor = UIColor.white
        progressSlider.minimumTrackTintColor = UIColor(hex: "#05d5e9")
        

        self.progressSlider.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -70))
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.playTime, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 15))
        self.addConstraint(NSLayoutConstraint(item: progressSlider, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.playDuration, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -15))
        
        
//        playDuration.frame = CGRect(x:width-60,y:8,width:70,height:20)
        playDuration.text = "00:00"
        playDuration.textColor = UIColor.white
        playDuration.font = UIFont(name: "Helvetica-Light", size: 14.0)
        self.playDuration.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: playDuration, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.smallView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10))
        self.addConstraint(NSLayoutConstraint(item: playDuration, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.progressSlider, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))

        
        upSwipeButton.frame = CGRect(x:width-60,y:50,width:40,height:40)
        upSwipeButton.setTitle("上滑", for: .normal)
        upSwipeButton.backgroundColor = UIColor.blue
        self.smallView.addSubview(playStatus)
        self.smallView.addSubview(playAndPauseButton)
        self.smallView.addSubview(progressSlider)
        self.smallView.addSubview(playTime)
        self.smallView.addSubview(playDuration)
//        self.smallView.addSubview(upSwipeButton)
        smallView.backgroundColor = UIColor(hex: "12a5b3", alpha: 0.9)
        smallView.frame = CGRect(x:0,y:0,width:width,height:homeTabBarHeight)
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
