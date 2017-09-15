//
//  CellData.swift
//  Page
//
//  Created by wangyichen on 04/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

// MODEL: UI Independent

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
    init(saysType type: Infotype, saysContent content: String?) {
        self.type = type
        if(self.type == .text) {
            if let contentStr = content{
                self.content = contentStr
            } else {
                self.content = "The Content field is nil"
            }
            
        }
    }
    
    //图片类型构造器
    init(saysType type: Infotype, saysImage url: String?){
        self.type = type
        if(self.type == .image){
            if let urlStr = url {
                self.url = urlStr
            } else {
                self.url = "landscape.jpeg"
            }
            
        }
    }
    
    //图文类型构造器
    init(saysType type: Infotype, saysTitle title: String?, saysDescription description: String?, saysCover coverUrl: String?, saysUrl cardUrl:String?) {
        self.type = type
        if(type == .card) {
            if let titleStr = title {
                self.title = titleStr
            } else {
                self.title = "The Title field is nil"
            }
            
            if let descriptionStr = description {
                self.description = descriptionStr
            } else {
                self.description = ""
            }
            
            if let coverUrlStr = coverUrl {
                self.coverUrl = coverUrlStr
            } else {
                self.coverUrl = "landscape.jpeg"
            }
            
            if let urlStr = cardUrl {
                self.url = urlStr
            } else {
                self.url = "http://www.ftchinese.com/story/001074079"
            }
            
        }
    }
    
    //空构造器
    init() {
        
    }
    
}


class CellData {
    //基本字段
    var headImage: String = ""
    var whoSays: Member = .no
    var bubbleImage: String = ""
    
    var saysType: Infotype = .text
    var saysWhat = SaysWhat()
    var textColor = UIColor.black
    
    //基本尺寸
    var bubbleImageInsets = UIEdgeInsetsMake(8, 20, 10, 12)//文字嵌入气泡的边距
    var bubbleStrechInsets = UIEdgeInsetsMake(18.5, 24, 18.5, 18.5)//气泡点九拉伸时的边距
    var cellInsets = UIEdgeInsetsMake(10, 5, 15, 5)//头像嵌入Cell的最小边距
    var bubbleInsets = UIEdgeInsetsMake(15, 5, 15, 5)//气泡嵌入Cell的最小边距，其中左右边距和cellInsets的左右边距值相等
    var headImageLength = CGFloat(50) //正方形头像边长
    var betweenHeadAndBubble = CGFloat(5) //头像和气泡的左右距离
    
    var maxTextWidth = CGFloat(240)//文字最大宽度
    var maxTextHeight = CGFloat(10000.0) //文字最大高度
    var defaultImageWidth = CGFloat(240)//图片消息还未获取到图片数据时默认图片宽度
    var defaultImageHeight = CGFloat(135)//图片消息还未获取到图片数据时默认图片高度
    //var maxImageWidth = CGFloat(200) //图像消息的图片最大宽度
    //var maxImageHeight = CGFloat(400) //图像消息的图片最大高度
    var coverWidth = CGFloat(240)
    var coverHeight = CGFloat(135)//Cover图像统一是16*19的，这里统一为240*135
    
    //根据（文字长短）动态计算得到的图形实际尺寸，后文会计算
    var bubbleImageWidth = CGFloat(0) //气泡宽度
    var bubbleImageHeight = CGFloat(0) //气泡高度
    var saysWhatWidth = CGFloat(0) // 宽度
    var saysWhatHeight = CGFloat(0) //文字高度
    var titleWidth = CGFloat(0)
    var titleHeight = CGFloat(0)
    var descriptionWidth = CGFloat(0)
    var descriptionHeight = CGFloat(0)
    
    
    //计算属性：依赖于上述两种尺寸或者依赖于
    var headImageWithInsets: CGFloat {
        get {
            return cellInsets.left + headImageLength + betweenHeadAndBubble
        }
    }
    /*
    var bubbleImageX = CGFloat(0)//依赖oneTalkCell
    var bubbleImageY = CGFloat(0)
    var saysWhatX = CGFloat(0)
    var saysWhatY = CGFloat(0)
     */
    //计算得到的cell的几种高度
    var cellHeightByHeadImage:CGFloat {
        get {
            return self.headImageLength + cellInsets.top + cellInsets.bottom //60
        }
    }
    var cellHeightByBubble: CGFloat {
        get {
            return self.bubbleImageHeight + bubbleInsets.top + bubbleInsets.bottom
        }
    }
    
    // 一些必须在数据里生成的和view相关的对象
    var strechedBubbleImage = UIImage()

    //var downLoadImage: UIImage? = nil//用于存储异步加载的UIImage对象
    var normalFont = UIFont()
    var titleFont = UIFont()
    var descriptionFont = UIFont()
    
    
    
    
    
    init(whoSays who: Member, saysWhat say: SaysWhat) {
        
        if who == .robot {
            
            self.headImage = "robotPortrait"
            //self.bubbleImage = "robotBub"
            self.bubbleImage = "robotSayBubble"
            self.textColor = UIColor.black
            self.bubbleImageInsets = UIEdgeInsetsMake(8, 20, 10, 12 )
            self.bubbleStrechInsets = UIEdgeInsetsMake(18.5, 24, 18.5, 18.5)
            
        } else if who == .you {
            
            self.headImage = "youPortrait"
            //self.bubbleImage = "youBub"
            self.bubbleImage = "youSayBubble"
            self.textColor = UIColor.white
            self.bubbleImageInsets = UIEdgeInsetsMake(8, 12, 10, 20)
            self.bubbleStrechInsets = UIEdgeInsetsMake(18.5, 18.5, 18.5, 24)
        }
        
        self.whoSays = who
        self.saysWhat = say
        
        self.saysType = say.type
        
        if say.type == .text { // 根据对话文字长短得到图形实际尺寸
            print("hereherehere")
            
            self.buildTextCellData(textContent: say.content)
            
        } else if say.type == .image { //缩放图片大小得到实际图形尺寸,并得到UIImage对象self.saysImage
            //直接全部交给另一个线程处理
            self.buildImageCellData()
            
        } else if say.type == .card {
            
            self.buildCardCellData(
                title: say.title,
                coverUrl: say.coverUrl,
                description:say.description
            )
        }
        
    }
    //构造器2
    init(){
        
    }
    
    //创建Text类型数据:
     func buildTextCellData(textContent text: String) {//wycNOTE: mutating func:可以在mutating方法中修改结构体属性
        let font = UIFont.systemFont(ofSize:18)
        self.normalFont = font
        let atts = [NSFontAttributeName: font]
        let saysWhatNSString = text as NSString
        
        let size = saysWhatNSString.boundingRect(
            with: CGSize(width:self.maxTextWidth, height:self.maxTextHeight),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        let computeWidth = max(size.size.width,20) //修正计算错误
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
    

    //创建Image类型数据:
    
     func buildImageCellData() {
        
        self.bubbleImageWidth = self.defaultImageWidth + bubbleImageInsets.left + bubbleImageInsets.right
        self.bubbleImageHeight = self.defaultImageHeight + bubbleImageInsets.top + bubbleImageInsets.bottom

        /*
        let myUIImage = self.buidUIImage(url:imageUrlStr)
        
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
         */
    }
    
    
    //创建Card类型数据:
     func buildCardCellData(title titleStr: String, coverUrl coverUrlStr: String, description descriptionStr:String) {
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
        
        
        //处理cover:交给另一个线程asyncBuildImage处理
        // FIXME: This code always crash when network is off. As a good habit, never use force unwrap in your code.
        /*
        let myUIImage = self.buidUIImage(url: coverUrlStr)
        if let realUIImage = myUIImage {
            self.coverImage = realUIImage
        }
        */
        
        
        //处理description
        if (descriptionStr != "") {
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
        }
        
        
        //处理总bubble
        self.saysWhatWidth = self.coverWidth
        self.saysWhatHeight = self.titleHeight + self.coverHeight + self.descriptionHeight
        self.bubbleImageWidth = self.saysWhatWidth + self.bubbleImageInsets.left + self.bubbleImageInsets.right
        self.bubbleImageHeight = self.saysWhatHeight + self.bubbleImageInsets.top + self.bubbleImageInsets.bottom
    }
    
    //同步加载image的方法：
    /*
    func buidUIImage(url theUrl:String) -> UIImage? {
            let fm = FileManager.default
            let path = "\(Bundle.main.resourcePath!)/\(String(describing: theUrl))"
            print(path)
            var myUIImage: UIImage? = nil
            if (fm.fileExists(atPath: path)) { //本地资源目录中有该文件
                myUIImage = UIImage(named: theUrl)
            } else if let imageUrl = NSURL(string: theUrl),
                let imageData = NSData(contentsOf: imageUrl as URL) { //使用绝对路径寻找该文件
                myUIImage = UIImage(data: imageData as Data)
            }
            return myUIImage
    }
    */
   
 
}

/*
 func asnycBuildUIImage(url theUrl:String) -> UIImage? {
 if let imgUrl = URL(string: theUrl) {
 let imgRequest = URLRequest(url: imgUrl)
 
 URLSession.shared.dataTask(with: imgRequest, completionHandler: { (data, response, error) in
 if let data = data {
 self.saysUIImage(data: data)
 } else {
 let
 }
 
 }).resume()
 }
 
 }
 */
/*
 itemCell?.loadImage(type:"cover", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
 self?.imageView.image = cellContentItem.coverImage
 })
 */




