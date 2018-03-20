//
//  PlaySpeech.swift
//  FT中文网
//
//  Created by ZhangOliver on 2017/3/26.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

import MediaPlayer

// MARK: Further Reading: http://www.appcoda.com/text-to-speech-ios-tutorial/


// MARK: - Use singleton pattern to pass speech data between view controllers. It's better in in term of code style than prepare segue.
class SpeechContent {
    static let sharedInstance = SpeechContent()
    var body = [String: String]()
}

// MARK: - Remove HTML Tags from the Text
extension String {
    private func deleteHTMLTag(_ tag:String) -> String {
        return self.replacingOccurrences(of: "(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression)
    }
    
    func deleteHTMLTags(_ tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTMLTag(tag)
        }
        return mutableString
    }
}


class PlaySpeech: UIViewController, AVSpeechSynthesizerDelegate,UIPopoverPresentationControllerDelegate {
    
    private lazy var mySpeechSynthesizer:AVSpeechSynthesizer? = nil
    private lazy var audioText: NSMutableAttributedString? = nil
    private var audioLanguage = ""
    private var eventCategory = ""
    private var audioTitle = "FT中文网"
    private var audioId = ""
    private lazy var previouseRange: NSRange? = nil
    let speechDefaultVoice = SpeechDefaultVoice()
    
    
    @IBOutlet weak var buttonPlayPause: UIBarButtonItem!
    
    @IBAction func pauseSpeech(_ sender: UIBarButtonItem) {
        var image = UIImage(named: "PauseButton")
        if let mySpeechSynthesizer = mySpeechSynthesizer {
            if mySpeechSynthesizer.isPaused == false && mySpeechSynthesizer.isSpeaking == false {
                if let titleAndText = audioText?.string {
                    let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string: titleAndText)
                    mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: audioLanguage)
                    mySpeechSynthesizer.speak(mySpeechUtterance)
                    mySpeechSynthesizer.continueSpeaking()
                }
            } else if mySpeechSynthesizer.isPaused == false {
                mySpeechSynthesizer.pauseSpeaking(at: .word)
                image = UIImage(named: "PlayButton")
            } else {
                mySpeechSynthesizer.continueSpeaking()
            }
        }
        buttonPlayPause.image = image
    }
    
    @IBAction func stopSpeech(_ sender: UIBarButtonItem) {
        mySpeechSynthesizer?.stopSpeaking(at: .word)
        mySpeechSynthesizer = nil
        //print ("speech should stop now! ")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func setting() {
        if let SpeechSettingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpeechSettings") as? SpeechSettings {
            navigationController?.pushViewController(SpeechSettingsViewController, animated: true)
        }
    }
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var bodytext: UITextView!
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue:"Replay Needed"),
            object: nil
        )
        mySpeechSynthesizer?.delegate = nil
        mySpeechSynthesizer?.stopSpeaking(at: .word)
        mySpeechSynthesizer = nil
        print ("deinit PlaySpeech successfully")
    }
    
    override func loadView() {
        super.loadView()
        parseAudioMessage()
        enableBackGroundMode()
        displayText()
        // MARK: - listen to notifications about preference change
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue:"Replay Needed"),
            object: nil,
            queue: nil) { [weak self] notification in
                self?.replay(notification: notification)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()
        //        let settingsIcon = UIImage(named: "SettingsButton")
        //        let settingsButton = UIBarButtonItem(image: settingsIcon, style: .plain, target: self, action: #selector(setting))
        let settingsButton = UIBarButtonItem(title: "设置", style: .plain, target: self, action: #selector(setting))
        self.navigationItem.rightBarButtonItem = settingsButton
        
        // MARK: Set the back button to empty for pushed views
        let title = ""
        let backItem = UIBarButtonItem()
        backItem.title = title
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let screenName = "/\(DeviceInfo.checkDeviceType())/SpeechToText/\(audioId)/\(audioLanguage)/\(audioTitle)"
        Track.screenView(screenName, trackEngagement: true)
        let eventCategory = "Listen To Story"
        let body = SpeechContent.sharedInstance.body
        if let language = body["language"], let title = body["title"] {
            Track.event(category: eventCategory, action: "Start", label: "\(language): \(title.replacingOccurrences(of: "'", with: ""))")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if self.isMovingFromParentViewController {
            print ("Audio is being popped")
            mySpeechSynthesizer?.stopSpeaking(at: .word)
        } else {
            print ("Audio is not being popped")
        }
    }
    
    private func initStyle() {
        let defaultBackGroundColor = UIColor(hex: Color.Content.background)
        let tabBackGround = UIColor(hex: Color.Tab.background)
        let buttonTint = UIColor(hex: Color.Button.tint)
        view?.backgroundColor = defaultBackGroundColor
        bodytext?.backgroundColor = defaultBackGroundColor
        toolbar?.backgroundColor = tabBackGround
        toolbar?.barTintColor = tabBackGround
        toolbar?.isTranslucent = false
        
        // MARK: Set style for the bottom buttons
        buttonPlayPause?.tintColor = buttonTint
    }
    
    private func replay(notification:Notification) -> Void {
        mySpeechSynthesizer?.stopSpeaking(at: .word)
        parseAudioMessage()
        if let titleAndText = audioText?.string {
            let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string: titleAndText)
            mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: audioLanguage)
            mySpeechSynthesizer?.speak(mySpeechUtterance)
            buttonPlayPause.image = UIImage(named: "PauseButton")
        }
    }
    
    private func parseAudioMessage() {
        let body = SpeechContent.sharedInstance.body
        if let language = body["language"], let text = body["text"], let id = body["id"], let title = body["title"], let eventCategory = body["eventCategory"] {
            let speechLanguage = speechDefaultVoice.getVoiceByLanguage(language)
            self.audioLanguage = speechLanguage
            navigationItem.title = "当前语音：\(SpeechDefaultVoice.getLanguageName(speechLanguage))"
            self.eventCategory = eventCategory
            self.audioTitle = title
            self.audioId = id
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.paragraphSpacing = 20
            let titleAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 22),
                NSAttributedStringKey.paragraphStyle:titleParagraphStyle
            ]
            let bodyParagraphStyle = NSMutableParagraphStyle()
            bodyParagraphStyle.paragraphSpacing = 20
            bodyParagraphStyle.lineSpacing = 10
            
            let bodyAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.paragraphStyle:bodyParagraphStyle,
                ]
            let titleAttrString = NSMutableAttributedString(
                string: title,
                attributes: titleAttributes
            )
            // MARK: - Use deliminator so that the utterance will pause after the title
            let deliminatorAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor(netHex:0xFFF1E0),
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 0)
            ]
            // MARK: - If it's Chinese, use "。", otherwise use ". "
            let delimitorPeriodString: String
            if language == "ch" {
                delimitorPeriodString = "。"
            } else {
                delimitorPeriodString = ". "
            }
            let deliminatorAttrString = NSMutableAttributedString(
                string: "\(delimitorPeriodString)\r\n",
                attributes: deliminatorAttributes
            )
            let textFromHTML = text
                .replacingOccurrences(of: "[\r\n]", with: "", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "(</p><p>)+", with: "\r\n", options: .regularExpression, range: nil)
            let bodyAttrString = NSMutableAttributedString(
                string: textFromHTML.deleteHTMLTags(["a","p","div","img","span","b","i"]),
                attributes: bodyAttributes
            )
            let fullBodyAttrString = NSMutableAttributedString()
            fullBodyAttrString.append(titleAttrString)
            fullBodyAttrString.append(deliminatorAttrString)
            fullBodyAttrString.append(bodyAttrString)
            audioText = fullBodyAttrString
        }
    }
    
    
    
    private func textToSpeech(_ text: NSMutableAttributedString, language: String) {
        // MARK: - Continue audio even when device is set to mute
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        // MARK: - Continue audio when device is in background
        try? AVAudioSession.sharedInstance().setActive(true)
        
        
        mySpeechSynthesizer = AVSpeechSynthesizer()
        let titleAndText = text.string
        let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string: titleAndText)
        // MARK: Set language. Chinese is zh-CN
        mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: language)
        // mySpeechUtterance.rate = 1.0
        
        
        mySpeechSynthesizer?.delegate = self
        
        // FIXME: This line cause the view not being able to be deinit
        mySpeechSynthesizer?.speak(mySpeechUtterance)
        
        
        //MARK: - Update the Lock Screen Image
        NowPlayingCenter().updateInfo(
            title: audioTitle,
            artist: "FT中文网",
            albumArt: UIImage(named: "cover.jpg"),
            currentTime: 0,
            mediaLength: 0,
            PlaybackRate: 1.0
        )
        
    }
    
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            print("resume music")
            self?.mySpeechSynthesizer?.continueSpeaking()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.mySpeechSynthesizer?.pauseSpeaking(at: .word)
            return .success
        }
        //        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {event in
        //            print ("next audio")
        //            return .success
        //        }
        //        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {event in
        //            print ("previous audio")
        //            return .success
        //        }
    }
    
    private func displayText() {
        if let audioText = audioText {
            self.bodytext.attributedText = audioText
            self.bodytext.scrollRangeToVisible(NSRange(location:0, length:0))
            textToSpeech(audioText, language: audioLanguage)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if let mutableAttributedString = audioText {
            if let previouseRange = previouseRange {
                mutableAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: previouseRange)
            }
            mutableAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(netHex:0xF6801A), range: characterRange)
            self.bodytext.attributedText = mutableAttributedString
            self.bodytext.scrollRangeToVisible(characterRange)
        }
        previouseRange = characterRange
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let mutableAttributedString = audioText {
            if let previouseRange = previouseRange {
                mutableAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: previouseRange)
                self.bodytext.attributedText = mutableAttributedString
                self.bodytext.scrollRangeToVisible(previouseRange)
            }
        }
        let body = SpeechContent.sharedInstance.body
        
        
        if let language = body["language"], let title = body["title"] {
            // MARK: Should Send an Event
            Track.event(category: eventCategory, action: "Finish", label: "\(language): \(title.replacingOccurrences(of: "'", with: ""))")
        }
        let image = UIImage(named: "PlayButton")
        buttonPlayPause.image = image
    }
    
}
