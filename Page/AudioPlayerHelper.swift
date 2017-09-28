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
                self.addChildViewController(controller)
                self.view.addSubview(controller.view)
               controller.view.frame = CGRect(x:0,y:self.view.bounds.height-95,width:self.view.bounds.width,height:95)
               
                controller.didMove(toParentViewController: self)
                controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                controller.view.backgroundColor = UIColor(hex: "#12a5b3", alpha: 0)
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
class PlayerAPI {

    let nowPlayingCenter = NowPlayingCenter()
    func openPlay(){
        var player = TabBarAudioContent.sharedInstance.player
        var playerItem = TabBarAudioContent.sharedInstance.playerItem
        var audioUrlString:String = ""
        self.removePlayerItemObservers(self, object: playerItem)
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        print("player item exist url")
        
        let body = TabBarAudioContent.sharedInstance.body
        if let audioFileUrl = body["audioFileUrl"]{
            audioUrlString = audioFileUrl.replacingOccurrences(
                of: "^(http).+(album/)",
                with: "https://du3rcmbgk4e8q.cloudfront.net/album/",
                options: .regularExpression
            )
            audioUrlString =  audioUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            print("audioUrlString by encoding--\(audioUrlString)")
        }
        
        
        if let url = URL(string: audioUrlString) {
            let audioUrl = url
            let asset = AVURLAsset(url: audioUrl)
            
//            playerItem = AVPlayerItem(asset: asset)
            playerItem = AVPlayerItem(asset: asset)
            if player != nil {
                print("item player exist")
            }else {
                print("item player do not exist")
//                player = AVPlayer()
                player = AVPlayer()
            }
            TabBarAudioContent.sharedInstance.isPlaying = true
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
        }
        let url = (playerItem?.asset as? AVURLAsset)?.url
        
        TabBarAudioContent.sharedInstance.player = player
        
        print("item first url-0000-\(String(describing: url))")
        if (player != nil){
            if (TabBarAudioContent.sharedInstance.audioUrl) != nil {
                print("item second url---\(url == TabBarAudioContent.sharedInstance.audioUrl)")
                
                if url == TabBarAudioContent.sharedInstance.audioUrl {
                    print("item second same play---")
                    if let currrentPlayingTime = TabBarAudioContent.sharedInstance.time{
                        print("url item second currrentPlayingTime-\(String(describing: currrentPlayingTime))")
                        playerItem?.seek(to: currrentPlayingTime)
                    }
                }
                else{
                    print("item new second play url---\(String(describing: url))")
                    player?.replaceCurrentItem(with: playerItem)
                    player?.play()
                    //The current playback url is updated
                    TabBarAudioContent.sharedInstance.audioUrl = url
                }
                
            } else {
                TabBarAudioContent.sharedInstance.audioUrl = url
                player?.play()
                player?.replaceCurrentItem(with: playerItem)
                
            }
            
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: CustomTabBarController())
            self.addPlayerItemObservers(self, #selector(self.playerDidFinishPlaying), object: playerItem)
            if let title = TabBarAudioContent.sharedInstance.body["title"],let _ = player{
                print("NowPlayingCenter updatePlayingInfo \(title)")
                NowPlayingCenter().updatePlayingCenter()
            }
        }else{
            print("player item not isExist")
            return
        }
 
    }
    @objc func playerDidFinishPlaying() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playFinish"), object: CustomTabBarController())
        TabBarAudioContent.sharedInstance.player?.pause()
        TabBarAudioContent.sharedInstance.isPlayFinish = true
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: kCMTimeZero)
      NowPlayingCenter().updateTimeForPlayerItem(TabBarAudioContent.sharedInstance.player)
    }
    public func addPlayerItemObservers(_ observer: Any, _ actionSection: Selector, object anObject: Any?) {
        NotificationCenter.default.addObserver(observer,selector:actionSection, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: anObject)
       
    }

    public func removePlayerItemObservers(_ observer: Any,object anObject: Any?) {
        NotificationCenter.default.removeObserver(observer, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: anObject)
    }

}



