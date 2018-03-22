//
//  SpeakWord.swift
//  Page
//
//  Created by Oliver Zhang on 2018/3/22.
//  Copyright © 2018年 Oliver Zhang. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

struct SpeakWord {
    public static func textToSpeech(_ text: String, language: String, title: String) {
        // MARK: - Continue audio even when device is set to mute. Do this only when user is actually playing audio because users might want to read FTC news while listening to music from other apps.
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        // MARK: - Continue audio when device is in background
        try? AVAudioSession.sharedInstance().setActive(true)
        
        let mySpeechSynthesizer = AVSpeechSynthesizer()
        let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string: text)
        // MARK: Set lguange. Chinese is zh-CN
        mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: language)
        // mySpeechUtterance.rate = 1.0
        mySpeechSynthesizer.speak(mySpeechUtterance)
    }
    
    public static func speak(_ word: String) {
        let text = word.replacingOccurrences(of: "speak://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
            .replacingOccurrences(of: "%0A", with: "")
            .replacingOccurrences(of: "%20", with: "")
        let language = "en-GB"
        textToSpeech(text, language: language, title: text)
        Track.event(category: "Listen to Word", action: text, label: language)
    }
}
