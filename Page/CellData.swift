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
enum Infotype {
    case text // 文本
    case image // 图片
    case card // 图文
}
struct CellData {
    //基本字段
    var headImage: String = ""
    var whoSays: Member = .no
    var saysWhat: String = ""
    var bubbleImage: String = ""
    var saysType: Infotype = .text
    //基本尺寸
    var bubbleImageInsets = UIEdgeInsetsMake(10, 20, 10, 20)//气泡嵌入文字UILabelView的边距
    var cellInsets = UIEdgeInsetsMake(5, 5, 5, 5)//cell嵌入头像和气泡的最小边距
    var headImageLength = CGFloat(50) //正方形头像边长
    var betweenHeadAndBubble = CGFloat(5) //头像和气泡的左右距离
    
    //计算得到的图形实际尺寸
    var bubbleImageWidth = CGFloat() //气泡宽度
    var bubbleImageHeight = CGFloat() //气泡高度
    var saysWhatWidth = CGFloat() // 文字宽度
    var saysWhatHeight = CGFloat() //文字高度
    
    //计算得到的cell的几种高度
    var cellHeightByHeadImage:CGFloat {
        get {
            return headImageLength + cellInsets.top + cellInsets.bottom //60
        }
    }
    var cellHeightByBubble: CGFloat {
        get {
            return bubbleImageHeight + cellInsets.top + cellInsets.bottom
        }
    }
    
    //构造器1
    init(whoSays who: Member, saysWhat say: String) {
        if who == .robot {
            self.headImage = "robot.jpeg"
            self.bubbleImage = "robotBub"
        } else if who == .you {
            self.headImage = "you.jpeg"
            self.bubbleImage = "youBub"
        }
        self.whoSays = who
        self.saysWhat = say
        
        
        // 根据对话文字长短得到图形实际尺寸
        let font = UIFont.systemFont(ofSize:12)
        let width = 150, height = 10000.0
        let atts = [NSFontAttributeName: font]
        let saysWhatNSString = saysWhat as NSString
        
        let size = saysWhatNSString.boundingRect(
            with: CGSize(width:CGFloat(width), height:CGFloat(height)),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        let computeWidth = size.size.width * 1.4//修正计算错误 //QUEST:boundingRect为什么不能直接得到正确结果？而且为什么
        let computeHeight = size.size.height * 1.6
        
        
        self.bubbleImageWidth = computeWidth + bubbleImageInsets.left + bubbleImageInsets.right
        self.bubbleImageHeight = computeHeight + bubbleImageInsets.top + bubbleImageInsets.bottom
        
        self.saysWhatWidth = computeWidth
        self.saysWhatHeight = computeHeight

    }
    //构造器2
    init(){
        
    }
    
}
