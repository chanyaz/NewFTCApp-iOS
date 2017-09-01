//
//  CustomTab.swift
//  Page
//
//  Created by huiyun.he on 28/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomTab: UIView {

    var isHideMessage:Bool?
    let button = UIButton()
    let audioLable = UILabel()
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.frame = frame
        button.frame = CGRect(x:180,y:0,width:50,height:50)
        button.attributedTitle(for: UIControlState.normal)
        button.backgroundColor = UIColor.blue
        audioLable.frame = CGRect(x:10,y:0,width:70,height:50)
        
//        button.setTitle("播放", for: UIControlState.normal)
        audioLable.text = "单曲鉴赏"
        self.addSubview(audioLable)
        self.addSubview(button)
        isHideMessage = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
