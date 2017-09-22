//
//  NowPlayingCenter.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/10.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import MediaPlayer
import WebKit

struct NowPlayingCenter {
    func updateInfo(title: String, artist: String, albumArt: UIImage?, currentTime: NSNumber, mediaLength: NSNumber, PlaybackRate: Double){
        if let artwork = albumArt {
            let mediaInfo: Dictionary <String, Any> = [
                MPMediaItemPropertyTitle: title,
                MPMediaItemPropertyArtist: artist,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: artwork),
                // MARK: - Useful for displaying Background Play Time under wifi
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
                MPMediaItemPropertyPlaybackDuration: mediaLength,
                MPNowPlayingInfoPropertyPlaybackRate: PlaybackRate
            ]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
        }
    }
    func updateTimeForPlayerItem(_ player: AVPlayer?) {
        if let player = player {
        if let playerItem = player.currentItem, var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            let duration = CMTimeGetSeconds(playerItem.duration)
            let currentTime = CMTimeGetSeconds(playerItem.currentTime())
            let rate = player.rate
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
            print ("Update: \(currentTime)/\(duration)/\(rate)")
        }
        }
    }
    func updatePlayingInfo(_ player: AVPlayer?,title: String) {
        if let player = player {
            if let playerItem = player.currentItem, var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                let duration = CMTimeGetSeconds(playerItem.duration)
                let currentTime = CMTimeGetSeconds(playerItem.currentTime())
                let rate = player.rate
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
                nowPlayingInfo[MPMediaItemPropertyTitle] = title
                print ("Update: --\(currentTime)--/\(duration)--/\(rate)--/\(title)")
            }
        }
        
    }
    
    func updatePlayingCenter(){
        var mediaLength: NSNumber = 0
        if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
            let duration = CMTimeGetSeconds(d)
            if duration.isNaN == false {
                mediaLength = duration as NSNumber
            }
        }
        
        var currentTime: NSNumber = 0
        if let c = TabBarAudioContent.sharedInstance.playerItem?.currentTime() {
            let currentTime1 = CMTimeGetSeconds(c)
            if currentTime1.isNaN == false {
                currentTime = currentTime1 as NSNumber
            }
        }
        if  let title = TabBarAudioContent.sharedInstance.audioHeadLine {
            updateInfo(
                title: title,
                artist: "FT中文网",
                albumArt: UIImage(named: "cover.jpg"),
                currentTime: currentTime,
                mediaLength: mediaLength,
                PlaybackRate: 1.0
            )
        }
        updateTimeForPlayerItem(TabBarAudioContent.sharedInstance.player)
        
    }
}
