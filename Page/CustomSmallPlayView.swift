//
//  CustomSmallPlayView.swift
//  Page
//
//  Created by huiyun.he on 27/09/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomSmallPlayView: UIView {

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
        
        
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
