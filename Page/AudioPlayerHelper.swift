//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/4.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

struct BottomAudioPlayer {
    static var sharedInstance = BottomAudioPlayer()
    var playerShowed = false
}


extension UITabBarController {

    
    public func showAudioPlayer() {
        if BottomAudioPlayer.sharedInstance.playerShowed == true {
            print ("audio already initiated")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "AudioPlayerController") as? AudioPlayerController {
            BottomAudioPlayer.sharedInstance.playerShowed = true
            let audioPlayerView = UIView()
            //            let playerHeight: CGFloat = AudioPlayerStyle.height
            let playerHeight: CGFloat = 250
//            audioPlayerView.backgroundColor = UIColor.clear
            
            
            let playerX = UIScreen.main.bounds.origin.x
            let playerY = UIScreen.main.bounds.origin.y + UIScreen.main.bounds.height - playerHeight
            let playerWidth = UIScreen.main.bounds.width
            
            
            audioPlayerView.frame = CGRect(x: playerX, y: playerY, width: playerWidth, height: playerHeight)
            audioPlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // MARK: add as a childviewcontroller
            addChildViewController(controller)
            // MARK: Add the child's View as a subview
            audioPlayerView.addSubview(controller.view)
            controller.view.frame = audioPlayerView.bounds
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            controller.view.backgroundColor = UIColor(hex: "#12a5b3", alpha: 0)
            // MARK: tell the childviewcontroller it's contained in it's parent
            controller.didMove(toParentViewController: self)
            view.insertSubview(audioPlayerView, aboveSubview: tabBar)

        }
    }
    
}

public func setLastPlayAudio(){
    if  TabBarAudioContent.sharedInstance.audioUrl != nil {
        var audioHeadLineHistory = UserDefaults.standard.string(forKey: Key.audioHistory[0]) ?? String()
        var audioUrlHistory = UserDefaults.standard.url(forKey: Key.audioHistory[1]) ?? URL(string: "")
        var audioIdHistory = UserDefaults.standard.string(forKey: Key.audioHistory[2]) ?? String()
        var audioLastPlayTimeHistory = UserDefaults.standard.float(forKey: Key.audioHistory[3])
        
        //应该放在能保存下来的地方，点击一下保存一下，点击不同的会替换当前的
        if let audioHeadLine = TabBarAudioContent.sharedInstance.audioHeadLine{
            audioHeadLineHistory = audioHeadLine
        }
        if let audioUrl = TabBarAudioContent.sharedInstance.audioUrl{
            audioUrlHistory = audioUrl
        }
        if let audioId = TabBarAudioContent.sharedInstance.body["interactiveUrl"]{
            audioIdHistory = audioId
        }
        
        if let time = TabBarAudioContent.sharedInstance.time{
            print("getLastPlayAudioUrl time")
            audioLastPlayTimeHistory = Float((CMTimeGetSeconds(time)))
        }else{
            print("getLastPlayAudioUrl 0")
            audioLastPlayTimeHistory = 0.0
        }
        UserDefaults.standard.set(audioHeadLineHistory, forKey: Key.audioHistory[0])
        UserDefaults.standard.set(audioUrlHistory, forKey: Key.audioHistory[1])
        UserDefaults.standard.set(audioIdHistory, forKey: Key.audioHistory[2])
        UserDefaults.standard.set(audioLastPlayTimeHistory, forKey: Key.audioHistory[3])
    }
}
struct PlayerObserver {
    public func addPlayerItemObservers(_ observer: Any, _ actionSection: Selector, object anObject: Any?) {
        NotificationCenter.default.addObserver(observer,selector:actionSection, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: anObject)
       
    }

    public func removePlayerItemObservers(_ observer: Any,object anObject: Any?) {
        NotificationCenter.default.removeObserver(observer, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: anObject)
    }

}



