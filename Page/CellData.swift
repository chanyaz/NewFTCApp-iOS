//
//  CellData.swift
//  Page
//
//  Created by wangyichen on 04/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation
enum Member {
    case robot
    case you
    case no
}
struct CellData {
    var headImage: String = ""
    var whoSays: Member = .no
    var saysWhat: String = ""
    var bubbleImage: String = ""
    
    init(whoSays who: Member, saysWhat say: String) {
        if who == .robot {
            self.headImage = "robot.jpeg"
            self.bubbleImage = "robotBubble.png"
        } else if who == .you {
            self.headImage = "you.jpeg"
            self.bubbleImage = "youBubble.png"
        }
        self.whoSays = who
        self.saysWhat = say
    }
    init(){
        
    }
    
}
