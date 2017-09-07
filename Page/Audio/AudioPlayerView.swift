//
//  AudioPlayerView.swift
//  Page
//
//  Created by huiyun.he on 07/09/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class AudioPlayerView: UIView {

    let audioLable = UILabel()
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.frame = frame

        audioLable.frame = CGRect(x:10,y:0,width:70,height:50)
        audioLable.text = "单曲鉴赏"
        self.addSubview(audioLable)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
