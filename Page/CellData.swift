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

struct SaysWhat {
    var type = Infotype.text
    var content: String = ""
    var url: String = ""
    var title: String = ""
    var description: String = ""
    var coverUrl: String = ""
    
    //文本类型构造器
    init(saysType type: Infotype, saysContent content: String) {
        self.type = type
        if(self.type == .text) {
            self.content = content
        }
    }
    
    //图片类型构造器
    init(saysType type: Infotype, saysImage url: String){
        self.type = type
        if(self.type == .image){
            self.url = url
        }
    }
    
    //图文类型构造器
    init(saysType type: Infotype, saysTitle title: String, saysDescription description: String, saysCover coverUrl: String) {
        self.type = type
        if(type == .card) {
            self.title = title
            self.description = description
            self.coverUrl = coverUrl
        }
    }
    
    //空构造器
    init() {
        
    }
    
}


struct CellData {
    //基本字段
    var headImage: String = ""
    var whoSays: Member = .no
    var bubbleImage: String = ""
    
    var saysType: Infotype = .text
    var saysWhat = SaysWhat()

    
    //基本尺寸
    var bubbleImageInsets = UIEdgeInsetsMake(10, 20, 10, 20)//气泡嵌入文字UILabelView的边距
    var cellInsets = UIEdgeInsetsMake(5, 5, 5, 5)//cell嵌入头像和气泡的最小边距
    var headImageLength = CGFloat(50) //正方形头像边长
    var betweenHeadAndBubble = CGFloat(5) //头像和气泡的左右距离
    var maxImageWidth = CGFloat(200) //图像消息的图片最大宽度
    var maxImageHeight = CGFloat(400) //图像消息的图片最大高度
    var coverWidth = CGFloat(240)
    var coverHeight = CGFloat(135)//Cover图像统一是16*19的，这里统一为240*135
    
    //计算得到的图形实际尺寸
    var bubbleImageWidth = CGFloat() //气泡宽度
    var bubbleImageHeight = CGFloat() //气泡高度
    var saysWhatWidth = CGFloat() // 文字宽度
    var saysWhatHeight = CGFloat() //文字高度
    var titleWidth = CGFloat()
    var titleHeight = CGFloat()
    var descriptionWidth = CGFloat()
    var descriptionHeight = CGFloat()
    
    // 一些必须在数据里生成的和view相关的对象
    var saysImage = UIImage()
    var coverImage = UIImage()
    
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
    
    
    init(whoSays who: Member, saysWhat say: SaysWhat) {
        if who == .robot {
            self.headImage = "robot.jpeg"
            self.bubbleImage = "robotBub"
        } else if who == .you {
            self.headImage = "you.jpeg"
            self.bubbleImage = "youBub"
        }
        self.whoSays = who
        self.saysWhat = say
        
       
        
        if say.type == .text { // 根据对话文字长短得到图形实际尺寸
            print("hereherehere")
            let font = UIFont.systemFont(ofSize:12)
            let width = 150, height = 10000.0
            let atts = [NSFontAttributeName: font]
            let saysWhatNSString = say.content as NSString
            
            let size = saysWhatNSString.boundingRect(
                with: CGSize(width:CGFloat(width), height:CGFloat(height)),
                options: .usesLineFragmentOrigin,
                attributes: atts,
                context: nil)
            let computeWidth = size.size.width * 1.6//修正计算错误 //QUEST:boundingRect为什么不能直接得到正确结果？而且为什么
            let computeHeight = size.size.height * 1.6
            
            
            self.bubbleImageWidth = computeWidth + bubbleImageInsets.left + bubbleImageInsets.right
            self.bubbleImageHeight = computeHeight + bubbleImageInsets.top + bubbleImageInsets.bottom
            
            self.saysWhatWidth = computeWidth
            self.saysWhatHeight = computeHeight
            
        } else if say.type == .image { //缩放图片大小得到实际图形尺寸
    
             self.saysImage = UIImage(named: say.url)!
             let saysImageWidth = self.saysImage.size.width
             let saysImageHeight = self.saysImage.size.height
             let saysRwh = saysImageWidth / saysImageHeight
            
             var adjustImageWidth = CGFloat()
             var adjustImageHeight = CGFloat()
            
             let standardRwh = maxImageWidth/maxImageHeight
             if saysRwh > standardRwh {
                adjustImageWidth = maxImageWidth
                adjustImageHeight = adjustImageWidth * saysImageHeight / saysImageWidth
             } else {
                adjustImageHeight = maxImageHeight
                adjustImageWidth = adjustImageHeight * saysImageWidth / saysImageHeight
             }
            
             self.saysWhatWidth = adjustImageWidth
             self.saysWhatHeight = adjustImageHeight
             self.bubbleImageWidth = adjustImageWidth + bubbleImageInsets.left + bubbleImageInsets.right
             self.bubbleImageHeight = adjustImageHeight + bubbleImageInsets.top + bubbleImageInsets.bottom
            
            
        } else if say.type == .card {
            //总宽度就是240
            let width = 150, height = 10000.0
            
            //处理title
            let titleFont = UIFont.systemFont(ofSize:20)
            
            let atts = [NSFontAttributeName: titleFont]
            let titleNSString = say.title as NSString
            
            let size = titleNSString.boundingRect(
                with: CGSize(width:CGFloat(width), height:CGFloat(height)),
                options: .usesLineFragmentOrigin,
                attributes: atts,
                context: nil)
            self.titleWidth = size.size.width * 1.6//修正计算错误 //QUEST:boundingRect为什么不能直接得到正确结果？而且为什么
            self.titleHeight = size.size.height * 1.6
            
            
            //处理cover
            self.coverImage = UIImage(named: say.coverUrl)!
           
            
            //处理description
            let descriptionFont = UIFont.systemFont(ofSize:12)
            let descriptionAtts = [NSFontAttributeName: descriptionFont]
            let descriptionNSString = say.description as NSString
            
            let descriptionSize = descriptionNSString.boundingRect(
                with: CGSize(width:CGFloat(width), height:CGFloat(height)),
                options: .usesLineFragmentOrigin,
                attributes: descriptionAtts,
                context: nil)
            self.descriptionWidth = descriptionSize.size.width * 1.6//修正计算错误 //QUEST:boundingRect为什么不能直接得到正确结果？而且为什么
            self.descriptionHeight = descriptionSize.size.height * 1.6
            
            self.saysWhatWidth = self.coverWidth
            self.saysWhatHeight = self.titleHeight + self.coverHeight + self.descriptionHeight
            self.bubbleImageWidth = self.saysWhatWidth + self.bubbleImageInsets.left + self.bubbleImageInsets.right
            self.bubbleImageHeight = self.saysWhatHeight + self.bubbleImageInsets.top + self.bubbleImageInsets.bottom
        }
        
       

    }
    //构造器2
    init(){
        
    }
    
}
