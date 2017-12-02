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
 
    static var sharedInstance = PlayerAPI()
    let nowPlayingCenter = NowPlayingCenter()
    var player = TabBarAudioContent.sharedInstance.player
    var playerItem = TabBarAudioContent.sharedInstance.playerItem
    var fetchAudioResults = TabBarAudioContent.sharedInstance.fetchResults

    func openPlay(){
//        var player = TabBarAudioContent.sharedInstance.player
//        var playerItem = TabBarAudioContent.sharedInstance.playerItem
        var audioUrlString:String = ""
        self.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime.rawValue, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "updateMiniPlay"), object: nil)
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
//        需要使用body，因为有2种语言
        let body = TabBarAudioContent.sharedInstance.body
        if let audioFileUrl = body["audioFileUrl"]{
            audioUrlString = self.parseAudioUrl(urlString: audioFileUrl)
            getPlayingUrl(audioFileUrl, fetchAudioResults: fetchAudioResults)
//            print("tabbar playing index\(index)")
        }
        
        
        if let url = URL(string: audioUrlString) {
            let audioUrl = url
            let asset = AVURLAsset(url: audioUrl)
            playerItem = AVPlayerItem(asset: asset)
            if player != nil {
                print("item player exist")
            }else {
                print("item player do not exist")
                player = AVPlayer()
            }
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
        }

        let url = (playerItem?.asset as? AVURLAsset)?.url
        
        TabBarAudioContent.sharedInstance.player = player
        
        print("item first url-\(String(describing: url))")
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
            TabBarAudioContent.sharedInstance.isPlaying = true
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
            self.addObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime.rawValue, #selector(self.playerDidFinishPlaying), object: playerItem)
            if let title = TabBarAudioContent.sharedInstance.body["title"],let _ = player{
                print("NowPlayingCenter updatePlayingInfo \(title)")
                NowPlayingCenter().updatePlayingCenter()
            }
        }else{
            print("player item do not exist")
            return
        }
    }
    
    @objc func playerDidFinishPlaying() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playFinish"), object: UIApplication.shared.keyWindow?.rootViewController)
        print("player finish play")
        TabBarAudioContent.sharedInstance.player?.pause()
        TabBarAudioContent.sharedInstance.isPlayFinish = true
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: kCMTimeZero)
      NowPlayingCenter().updateTimeForPlayerItem(TabBarAudioContent.sharedInstance.player)
        orderPlay()
    }
    public func addObserver(_ observer: Any,name:String, _ actionSection: Selector, object anObject: Any?) {
//        NotificationCenter.default.addObserver(observer,selector:actionSection, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: anObject)
        NotificationCenter.default.addObserver(observer,selector:actionSection, name: NSNotification.Name(rawValue: name), object: anObject)
       
    }

    public func removeObserver(_ observer: Any,name:String,object anObject: Any?) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: name), object: anObject)
    }
    public func postObserver(name:String,object anObject: Any?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: anObject)
    }

    public func parseAudioUrl(urlString:String)-> String {
        var parsedUrlString:String = ""
        parsedUrlString = urlString.replacingOccurrences(
            of: "^(http).+(album/)",
            with: "https://du3rcmbgk4e8q.cloudfront.net/album/",
            options: .regularExpression
        )
        parsedUrlString =  parsedUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return parsedUrlString
    }
    public func getUrlAccordingToAudioLanguageIndex(item:ContentItem?)-> String{
       let actualAudioLanguageIndex = UserDefaults.standard.integer(forKey: Key.audioLanguagePreference)
        var cleanUrl = ""
        if actualAudioLanguageIndex == 1{
            if let eaudioUrl = item?.eaudio{
                cleanUrl = eaudioUrl
            }else if let caudioUrl = item?.caudio, item?.eaudio==nil{
                cleanUrl = caudioUrl
            }
        }else{
            if let caudioUrl = item?.caudio{
                cleanUrl = caudioUrl
            }
        }
        return cleanUrl
    }
    

    public func getToPlayIndex(_ urlString:String,fetchAudioResults:[ContentSection]?) ->Int{
        var toPlayIndex = 0
        if let fetchAudioResults = fetchAudioResults {
            for (index, item0) in fetchAudioResults[0].items.enumerated() {
                let fileUrl = getUrlAccordingToAudioLanguageIndex(item: item0)
                if urlString == fileUrl{
                    toPlayIndex = index
                }
            }
        }
        print("urlString toPlayIndex--\(toPlayIndex)")
        return toPlayIndex
    }
//    可以直接获取播放playItem，获取item和fetchAudioResults,获取对应的index和playItem，考虑需不需要合并到一起呢，当下一首的时候index添加，
    private var queuePlayer:AVQueuePlayer?
    private var playerItems: [AVPlayerItem]? = []
    private var urlOrigStrings: [String] = []
    private var urlTempString = ""
    private var playingUrlStr:String? = ""
    private var playingIndex:Int = 0

    var count:Int = 0
    private func getPlayingUrl(_ urlString:String,fetchAudioResults:[ContentSection]?){
         playingIndex = 0
         urlOrigStrings = []
        var playerItemTemp : AVPlayerItem?
        if let fetchAudioResults = fetchAudioResults {
            for (index, item0) in fetchAudioResults[0].items.enumerated() {
                let fileUrl = getUrlAccordingToAudioLanguageIndex(item: item0)
                urlOrigStrings.append(fileUrl)
                if urlString == fileUrl{
                    print("fileUrl:\(fileUrl)--urlString:\(urlString)")
                    playingUrlStr = fileUrl
                    playingIndex = index
                }
                urlTempString = parseAudioUrl(urlString: fileUrl)
                
                if let urlAsset = URL(string: urlTempString){
                    playerItemTemp = AVPlayerItem(url: urlAsset) //可以用于播放的playItem
                    playerItems?.append(playerItemTemp!)
                }

            }
        }
        print("filtered audio urlString --\(urlString)")
        
        print("urlString playingIndex--\(playingIndex)")
        TabBarAudioContent.sharedInstance.playingIndex = playingIndex
        
    }
    @objc func playerFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        nowPlayingCenter.updateTimeForPlayerItem(player)
        let mode = TabBarAudioContent.sharedInstance.mode
        print("mode11 \(String(describing: mode))")
        if let mode = TabBarAudioContent.sharedInstance.mode {
            switch mode {
            case 0:
                orderPlay()
            case 1:
                onePlay()
            case 2:
                randomPlay()
            default:
                orderPlay()
            }
        }
        else{
            print("mode is nil orderPlay")
            orderPlay()
        }
    }
    func orderPlay(){
        count = urlOrigStrings.count
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playingIndex += 1
        if playingIndex >= count{
            playingIndex = 0
        }
        print("when orderPlay, urlString playingIndex---\(playingIndex)")
        updateSingleTonData(fetchAudioResults: fetchAudioResults)
        openPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        if let nextItem = playerItems?[playingIndex]{
            queuePlayer?.advanceToNextItem()
            currentItem?.seek(to: kCMTimeZero)
            queuePlayer?.insert(nextItem, after: currentItem)
            self.player?.play()
        }
        
    }
    func randomPlay(){
        let randomIndex = Int(arc4random_uniform(UInt32(urlOrigStrings.count)))
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playingIndex = randomIndex
        print("when randomPlay,urlString playingIndex---\(playingIndex)")
        updateSingleTonData(fetchAudioResults: fetchAudioResults)
        openPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        if let nextItem = playerItems?[playingIndex]{
            queuePlayer?.advanceToNextItem()
            currentItem?.seek(to: kCMTimeZero)
            queuePlayer?.insert(nextItem, after: currentItem)
            self.player?.play()
        }
    }
    func onePlay(){
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    func updateSingleTonData(fetchAudioResults:[ContentSection]?){
        if let fetchAudioResults = fetchAudioResults{
            getSingletonItem(item: fetchAudioResults[0].items[playingIndex])
            TabBarAudioContent.sharedInstance.playingIndex = playingIndex
//                parseAudioMessage()
        }
        
    }
//    private func parseAudioMessage() {
//        let body = TabBarAudioContent.sharedInstance.body
//        print(" body--\(body)")
//        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
//            audioUrlString = audioFileUrl
//            print("parsed audioUrlString--\(audioUrlString)")
//
//        }
//    }
    
    public func getSingletonItem(item: ContentItem?) {
        if let item = item {
            let audioFileUrl = getUrlAccordingToAudioLanguageIndex(item: item)
            TabBarAudioContent.sharedInstance.body["title"] = item.headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(item.id)"
            TabBarAudioContent.sharedInstance.item = item
            print("singleton item\(item.headline)")
        }
    }
    public  func getDirectoryName(_ name: String) -> String {
        var directoryName = ""
        directoryName = name
        return directoryName
    }

    
}

class UIButtonDownloadedChange: UIButton {
    var progress: Float = 0 {
        didSet {
            circleShape.strokeEnd = CGFloat(self.progress)
            print("progress--\(progress)")
        }
    }
    
    var circleShape = CAShapeLayer()
    public func drawCircle() {
        let x: CGFloat = 0.0
        let y: CGFloat = 0.0
        let circlePath = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: self.frame.height, height: self.frame.height), cornerRadius: self.frame.height / 2).cgPath
        circleShape.path = circlePath
        circleShape.lineWidth = 3
        circleShape.strokeColor = UIColor.white.cgColor
        circleShape.strokeStart = 0
        circleShape.strokeEnd = 0
        circleShape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(circleShape)
    }
    
    // MARK: - Update the download status
    var status: DownloadStatus = .remote {
        didSet{
            var buttonImageName = ""
            switch self.status {
            case .remote:
                buttonImageName = "DownLoadBtn"
            case .downloading:
                buttonImageName = "PauseBtn"
            case .success:
                buttonImageName = "DownLoadEndBtn"
            case .paused:
                buttonImageName = "DownLoadBtn"
            case .resumed:
                buttonImageName = "PauseBtn"
            }
            self.setImage(UIImage(named: buttonImageName), for: .normal)
        }
    }
}




