//
//  AudioModel.swift
//  Page
//
//  Created by huiyun.he on 22/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation
import MediaPlayer
class TabBarAudioContent {
    static let sharedInstance = TabBarAudioContent()
    var body = [String: String]()
    var item: ContentItem?
    var player:AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    var audioHeadLine: String? = nil
    var audioUrl: URL? = nil
    var duration: CMTime? = nil
    var time:CMTime? = nil
    var sliderValue:Float? = nil
    var isPlaying:Bool=false
    var isPlayFinish:Bool=false
    var isPlayStart:Bool=false
    var fetchResults: [ContentSection]?
    var mode:Int?
    var playingIndex:Int?
    init(){
        
    }
    init(item: ContentItem?){
        self.item = item
    }
    init (body:  [String: String],
          item: ContentItem?,
          player: AVPlayer?,
          playerItem: AVPlayerItem?,
          audioUrl: URL?,
          duration: CMTime?,
          time: CMTime?,
          sliderValue: Float?,
          isPlaying: Bool,
          fetchResults: [ContentSection]?,
          mode:Int?,
          playingIndex:Int?
        ) {
        self.body = body
        self.item = item
        self.player = player
        self.playerItem = playerItem
        self.audioUrl = audioUrl
        self.duration = duration
        self.time = time
        self.sliderValue = sliderValue
        self.isPlaying = isPlaying
        self.fetchResults = fetchResults
        self.mode = mode
        self.playingIndex = playingIndex
    }
}
//class TabBarAudioData {
//    static let sharedInstance = TabBarAudioContent()
//    var body = [String: String]()
//    var item: ContentItem?
//    var player:AVPlayer? = nil
//    var playerItem: AVPlayerItem? = nil
//    var audioHeadLine: String? = nil
//    var audioUrl: URL? = nil
//    var duration: CMTime? = nil
//    var time:CMTime? = nil
//    var sliderValue:Float? = nil
//    var isPlaying:Bool=false
//    var isPlayFinish:Bool=false
//    var isPlayStart:Bool=false
//    var fetchResults: [ContentSection]?
//    var mode:Int?
//    var playingIndex:Int?
//
//    init(){
//
//    }
//    init(item: ContentItem?){
//        self.item = item
//    }
//    init (body:  [String: String],
//          item: ContentItem?,
//          player: AVPlayer?,
//          playerItem: AVPlayerItem?,
//          audioUrl: URL?,
//          duration: CMTime?,
//          time: CMTime?,
//          sliderValue: Float?,
//          isPlaying: Bool,
//          fetchResults: [ContentSection]?,
//          mode:Int?,
//          playingIndex:Int?
//        ) {
//        self.body = body
//        self.item = item
//        self.player = player
//        self.playerItem = playerItem
//        self.audioUrl = audioUrl
//        self.duration = duration
//        self.time = time
//        self.sliderValue = sliderValue
//        self.isPlaying = isPlaying
//        self.fetchResults = fetchResults
//        self.mode = mode
//        self.playingIndex = playingIndex
//    }
//}

