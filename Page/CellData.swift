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
    init(saysType type: Infotype, saysTitle title: String, saysDescription description: String, saysCover coverUrl: String, saysUrl cardUrl:String) {
        self.type = type
        if(type == .card) {
            self.title = title
            self.description = description
            self.coverUrl = coverUrl
            self.url = cardUrl
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
    
    var maxTextWidth = CGFloat(240)//文字最大宽度
    var maxTextHeight = CGFloat(10000.0) //文字最大高度
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
    var normalFont = UIFont()
    var titleFont = UIFont()
    var descriptionFont = UIFont()
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
        
        self.saysType = say.type
        
        if say.type == .text { // 根据对话文字长短得到图形实际尺寸
            print("hereherehere")
          
            self.buildTextCellData(textContent: say.content)
        } else if say.type == .image { //缩放图片大小得到实际图形尺寸,并得到UIImage对象self.saysImage
            //let imageUrlStr = "http://ts1.mm.bing.net/th?id=OIP.UkcKcCStZUP_60o1QYH06wEoDS&pid=15.1"
            self.buildImageCellData(imageUrl: say.url)
            
        } else if say.type == .card {
            self.buildCardCellData(title: say.title, coverUrl:say.coverUrl, description:say.description)
        }

    }
    //构造器2
    init(){
        
    }
    
    //创建Text类型数据的可变方法
    mutating func buildTextCellData(textContent text: String) {//wycNOTE: mutating func:可以在mutating方法中修改结构体属性
        let font = UIFont.systemFont(ofSize:18)
        self.normalFont = font
        let atts = [NSFontAttributeName: font]
        let saysWhatNSString = text as NSString
        
        let size = saysWhatNSString.boundingRect(
            with: CGSize(width:self.maxTextWidth, height:self.maxTextHeight),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        let computeWidth = size.size.width //修正计算错误
        /* QUEST:boundingRect为什么不能直接得到正确结果？而且为什么
         * 已解决：因为此处的font大小和实际font大小不同，只有为UILabelView设置属性font为一样的UIFont对象，才能保证大小合适
         * 另说明：此处当文字多余一行时，自动就是宽度固定为最大宽度，高度自适应
         */
        let computeHeight = size.size.height
        
        
        self.bubbleImageWidth = computeWidth + bubbleImageInsets.left + bubbleImageInsets.right
        self.bubbleImageHeight = computeHeight + bubbleImageInsets.top + bubbleImageInsets.bottom
        
        self.saysWhatWidth = computeWidth
        self.saysWhatHeight = computeHeight
    }
    
    //创建Image类型数据的可变方法
    mutating func buildImageCellData(imageUrl imageUrlStr: String) {
        print(imageUrlStr)
        let fm = FileManager.default
        let path = "\(Bundle.main.resourcePath!)/\(imageUrlStr)"
        print(path)
        var myUIImage: UIImage? = nil
        if (fm.fileExists(atPath: path)) { //本地资源目录中有该文件
            myUIImage = UIImage(named: imageUrlStr)
        }
        else if let imageUrl = NSURL(string: imageUrlStr),let imageData = NSData(contentsOf: imageUrl as URL) { //使用绝对路径寻找该文件
            //let imageUrl = NSURL(string: imageUrlStr)!
            //let imageData = NSData(contentsOf: imageUrl as URL)!
            myUIImage = UIImage(data: imageData as Data)
        }
        
        if let realUIImage = myUIImage { //如果成功获取了图片
            self.saysImage = realUIImage
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
        } else { //如果没成功获取图片，则改为text类型回复
            self.saysType = .text
            self.buildTextCellData(textContent: "Sorry，没能成功得到图片")
        }
    }
    
    //创建Card类型数据的可变方法
    mutating func buildCardCellData(title titleStr: String, coverUrl coverUrlStr:String, description descriptionStr:String) {
        //处理title
        let titleFont = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        self.titleFont = titleFont
        let atts = [NSFontAttributeName: titleFont]
        let titleNSString = titleStr as NSString
        let size = titleNSString.boundingRect(
            with: CGSize(width:self.maxTextWidth, height:self.maxTextHeight),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        self.titleWidth = 240
        self.titleHeight = size.size.height
        
        
        //处理cover
        self.coverImage = UIImage(named: coverUrlStr)!
        
        
        //处理description
        let descriptionFont = UIFont.systemFont(ofSize:18)
        self.descriptionFont = descriptionFont
        let descriptionAtts = [NSFontAttributeName: descriptionFont]
        let descriptionNSString = descriptionStr as NSString
        
        let descriptionSize = descriptionNSString.boundingRect(
            with: CGSize(width:self.maxTextWidth, height:self.maxTextHeight),
            options: .usesLineFragmentOrigin,
            attributes: descriptionAtts,
            context: nil)
        self.descriptionWidth = 240
        self.descriptionHeight = descriptionSize.size.height
        self.saysWhatWidth = self.coverWidth
        self.saysWhatHeight = self.titleHeight + self.coverHeight + self.descriptionHeight
        self.bubbleImageWidth = self.saysWhatWidth + self.bubbleImageInsets.left + self.bubbleImageInsets.right
        self.bubbleImageHeight = self.saysWhatHeight + self.bubbleImageInsets.top + self.bubbleImageInsets.bottom
    }

    
}


