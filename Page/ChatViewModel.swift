//
//  CellData.swift
//  Page
//
//  Created by wangyichen on 04/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

// MODEL: UI Independent

import Foundation

/********* 几种Model的func中会用到的数据类型 **********************/
enum Member {
    case robot
    case you
    case no
}
enum Infotype {
    case text // 文本
    case image // 图片
    case card // 图文
    case error
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
    var coverWidth = CGFloat(240)//TODO:待修改，因为会超出iPhone 5的边界
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
        let atts = [NSAttributedStringKey.font: font]
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
    }
    
    
    //创建Card类型数据:
     func buildCardCellData(title titleStr: String, coverUrl coverUrlStr: String, description descriptionStr:String) {
        //处理title
        let titleFont = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        self.titleFont = titleFont
        let atts = [NSAttributedStringKey.font: titleFont]
        let titleNSString = titleStr as NSString
        let size = titleNSString.boundingRect(
            with: CGSize(width:self.maxTextWidth, height:self.maxTextHeight),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        self.titleWidth = 240
        self.titleHeight = size.size.height

        //处理cover:交给另一个线程asyncBuildImage处理
        
        //处理description
        if (descriptionStr != "") {
            let descriptionFont = UIFont.systemFont(ofSize:18)
            self.descriptionFont = descriptionFont
            let descriptionAtts = [NSAttributedStringKey.font: descriptionFont]
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

}

/******* Model: 提供一些方法，和数据联系紧密，Controller中会用到这些方法 ****/
class ChatViewModel {
    
    static func buildTalkData() -> [String: String] {
        return [
            "member":"",
            "type":"",
            "content":"",
            "url":"",
            "title":"",
            "description":"",
            "coverUrl":""
        ]
    }
    static let defaultTalkData = [
        "member":"robot",
        "type":"text",
        "content":"你好！我是微软小冰。\n- 想和我聊天？\n随便输入你想说的话吧，比如'我喜欢你'、'你吃饭了吗？'\n- 想看精美图片？\n试试输入'xx图片'，比如'玫瑰花图片'、'小狗图片'\n- 想看图文新闻？\n试试输入'新闻'、'热点新闻'"
    ]
    static let triggerGreetContent = "【端用户新对话打开信号，内容无法显示】"
    
    static let triggerNewsContent = "【端用户首次打开信号，推荐新闻】"
    

    static func buildCellData(_ oneTalkData:[String:String]) -> CellData {//根据historyTalkData数据得到CellData数据
        //let oneTalkData = self.historyTalkData[row]
        var saysWhat: SaysWhat
        var member:Member
        if let valueForMember = oneTalkData["member"] {
            switch valueForMember {
            case "robot":
                member = .robot
            case "you":
                member = .you
            default:
                member = .no
            }
        } else {
            member = .no
        }
        
        var type:Infotype
        if let valueForType = oneTalkData["type"] {
            switch valueForType {
            case "text":
                type = .text
                saysWhat = SaysWhat(saysType: type, saysContent: oneTalkData["content"])
            case "image":
                type = .image
                saysWhat = SaysWhat(saysType: type, saysImage: oneTalkData["url"])
            case "card":
                type = .card
                saysWhat = SaysWhat(saysType: type, saysTitle: oneTalkData["title"], saysDescription: oneTalkData["description"], saysCover: oneTalkData["coverUrl"], saysUrl: oneTalkData["url"])
            default:
                type = .error
                saysWhat = SaysWhat(saysType: .text, saysContent: "")
                
            }
        } else {
            saysWhat = SaysWhat(saysType: .text, saysContent: "")
        }
        
        
        let cellData = CellData(whoSays: member, saysWhat: saysWhat)
        return cellData
    }


    static func createResponseTalkData(data:Data) ->[String: String]? {
        //var robotSaysWhat = SaysWhat()
        //var robotCellData:CellData? = nil
        var talkData = [
            "member":"robot",
            "type":"text"
        ]
        do {
            let jsonAny = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            if let jsonDictionary = jsonAny as? NSDictionary,let answer = jsonDictionary["Answer"],let answerArray = answer as? NSArray {
                let oneAnswer = answerArray[0]
                
                if let oneAnswerDic = oneAnswer as? NSDictionary,
                    let type = oneAnswerDic["Type"], let typeStr = type as? String {
                    
                    print(typeStr)
                    switch typeStr {
                    case "Text":
                        if let content = oneAnswerDic["Content"]{
                            
                            let contentStr = content as? String
                            //robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                            talkData["content"] = contentStr
                            
                        } else {
                            let contentStr = "This is a Text, the data miss some important fields."
                            //robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                            talkData["content"] = contentStr
                        }
                        
                    case "Image":
                        
                        if let url = oneAnswerDic["Url"] {
                            let urlStr = url as? String
                            //robotSaysWhat = SaysWhat(saysType: .image, saysImage:urlStr)
                            print("This is a Image")
                            talkData["type"] = "image"
                            talkData["url"] = urlStr
                        } else {
                            let contentStr = "This is a Image, the data miss some important fields."
                            //robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                            talkData["content"] = contentStr
                        }
                        
                    case "Card":
                        print("This is a Card")
                        
                        if let title = oneAnswerDic["Title"],
                            let description = oneAnswerDic["Description"],
                            let coverUrl = oneAnswerDic["CoverUrl"],
                            let cardUrl = oneAnswerDic["Url"] {
                            
                            let titleStr = title as? String
                            let cardUrlStr = cardUrl as? String
                            let coverUrlStr = coverUrl as? String
                            let descriptionStr = description as? String
                            //robotSaysWhat = SaysWhat(saysType: .card, saysTitle: titleStr, saysDescription: descriptionStr, saysCover: coverUrlStr, saysUrl: cardUrlStr)
                            talkData["type"] = "card"
                            talkData["coverUrl"] = coverUrlStr
                            talkData["title"] = titleStr
                            talkData["url"] = cardUrlStr
                            talkData["description"] = descriptionStr
                            
                        } else {
                            let contentStr = "This is a Card, the data miss some important fields."
                            //robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                            talkData["type"] = "text"
                            talkData["content"] = contentStr
                            
                        }
                        
                        
                    default:
                        print("An unknow type response data.")
                        let contentStr = "An unknow type response data."
                        //robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                        talkData["type"] = "text"
                        talkData["content"] = contentStr
                    }
                    
                } else {
                    let contentStr = "There is some Error on parsing data Step2"
                    //robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                    talkData["type"] = "text"
                    talkData["content"] = contentStr
                }
                
            } else {
                let contentStr = "There is some Error on parsing data Step1"
                //robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                talkData["type"] = "text"
                talkData["content"] = contentStr
            }
            //robotCellData = CellData(whoSays: .robot, saysWhat: robotSaysWhat)
            return talkData
            
        } catch {
            return nil
        }
        
    }

    static func computeSignature(verb:String, path:String, paramList:[String], headerList:[String],body:String,timestamp:Int,secretKey:String) -> String {
        print("Execute computeSignature")
        
        let verbStr = verb.lowercased()
        print("verbStr:\(verbStr)")
        
        let pathStr = path.lowercased()
        print("pathStr:\(pathStr)")
        
        let paramListStr = paramList.sorted().joined(separator: "&")
        print("paramListStr:\(paramListStr)")
        
        var headerListNew = Array(repeating: "", count: headerList.count)
        for (index,value) in headerList.enumerated() {
            headerListNew[index] = value.lowercased()
        }
        print("headerListNew:\(headerListNew)")
        
        let headerListStr = headerListNew.sorted().joined(separator: ",")
        //base64EncodedString()
        let bodyStr = body
        
        let secretKeyStr = secretKey
        print("secretKeyStr:\(secretKeyStr)")
        
        let messageStr = "\(verbStr);\(pathStr);\(paramListStr);\(headerListStr);\(bodyStr);\(timestamp);\(secretKeyStr)"
        
        print("messageStr:\(messageStr)")
        
        let signature = messageStr.HmacSHA1(key: secretKeyStr)
        return signature
    }

}

extension String {
    
    /// HmacSHA1 Encrypt
    ///
    /// -Parameter key: secret key
    ///
    func HmacSHA1(key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        if let realCKey = cKey, let realCData = cData {
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), realCKey, Int(strlen(realCKey)), realCData, Int(strlen(realCData)), &result)
            let hmacData:NSData = NSData(bytes: result, length: (Int(CC_SHA1_DIGEST_LENGTH)))
            let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
            return String(hmacBase64)
        } else {
            return ""
        }
        
        
    }
}

