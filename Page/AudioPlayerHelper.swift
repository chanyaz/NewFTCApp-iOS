//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/4.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit


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
            let playerHeight: CGFloat = 50
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
            // MARK: tell the childviewcontroller it's contained in it's parent
            controller.didMove(toParentViewController: self)
            view.insertSubview(audioPlayerView, aboveSubview: tabBar)

        }
    }
    
}
