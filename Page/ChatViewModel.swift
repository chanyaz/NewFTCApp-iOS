//
//  CellData.swift
//  Page
//
//  Created by wangyichen on 04/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

// MODEL: UI Independent

import Foundation

/********* 几种和table数据关系密切的数据类型 **********************/
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

struct SaysWhat { //MARK:其仅仅没有处理talkData的member字段
    var type = Infotype.text
    var content = ""
    var url = ""
    var title = ""
    var description = ""
    var coverUrl = ""
    var impressionId = ""
    var storyId = ""
    /* talkData:[String:String] =
         [
             "member":"",
             "type":"",
             "content":"",
             "url":"",
             "title":"",
             "description":"",
             "coverUrl":""
         ]
     */
    init(_ talkData: [String:String]) {
        if let type = talkData["type"] {
            switch type {
            case "text":
                self.type = .text
            case "image":
                self.type = .image
            case "card":
                self.type = .card
            default:
                self.type = .error
            }
            
            
            if self.type == .text {
                if let contentStr = talkData["content"] {
                    self.content = contentStr
                }
                
            } else if self.type == .image {
                if let urlStr = talkData["url"] {
                    self.url = urlStr
                }
                
            } else if self.type == .card {
                if let titleStr = talkData["title"] {
                    self.title = titleStr
                }
                if let descriptionStr = talkData["description"] {
                    self.description = descriptionStr
                }
                if let coverUrlStr = talkData["coverUrl"] {
                    self.coverUrl = coverUrlStr
                }
                if let urlStr = talkData["url"] {
                    self.url = urlStr
                }
                if let impressionIdStr = talkData["impressionId"] {
                    self.impressionId = impressionIdStr
                }
                if let storyIdStr = talkData["storyId"] {
                    self.storyId = storyIdStr
                }
            }
        }

    }

    //空构造器
    init() { //NOTE:对于Struct而言，空构造器不会自动获得，想要有的话还是需要写一下；而Class是可以自动获得空构造器的（如果所有属性都带有初始值）
        
    }
    
}


class CellData {
   
    //MARK:属性类型1：用以区分不同类型的Cell（包括3种Cell:历史记录分割线Cell、获取更多历史数据提示Cell、正常Cell）
    var isHistoryCutline = false  //是否为历史记录分割线
    var isGetMoreHistory = false //是否为获取更多历史数据的提示语单元
    
    //MARK:属性类型2：历史记录分隔线Cell相关特性
    let cutlineCellHeight = CGFloat(50)//历史记录分割线Cell的高度
    let cutlineCellContent = "———— 以上为历史聊天内容 ————"//历史记录分割线Cell的text
    let cutlineFont = UIFont.systemFont(ofSize:10)//历史记录分割线Cell的font
    let cutlineColor = UIColor(hex: "#999999")//历史记录分割线Cell的textColor
    
    
    //MARK:属性类型3：获取更多历史数据Cell相关特性
    let getMoreHistoryHeight = CGFloat(50)//获取更多历史数据Cell的高度
    var getMoreHistorySignContent = ""//获取更多历史数据Cell的text
    let getMoreHistoryFont = UIFont.systemFont(ofSize:14)//获取更多历史数据Cell的font
    let getMoreHistoryColor = UIColor(hex: "#999999")//获取更多历史数据Cell的textColor

    //MARK:属性类型4.1：正常Cell相关特性：数据基本字段初始化，需要在构造器中根据参数赋值
    var whoSays: Member = .no

    var saysType: Infotype = .text
    var saysWhat = SaysWhat()
    
    
    //MARK:属性类型4.2：正常Cell相关特性：基本尺寸,包括一些固定边距、固定长度
    let bubbleShorterLen = CGFloat(0)
    var bubbleImageInsets = UIEdgeInsetsMake(8, 20, 10, 12)//文字嵌入气泡的边距//需要在构造器中根据条件得到
    var bubbleStrechInsets = UIEdgeInsetsMake(18.5, 24, 18.5, 18.5)//气泡点九拉伸时的边距 //需要在构造器中根据条件得到
    var cellInsets = UIEdgeInsetsMake(10, 5, 15, 5)//头像嵌入Cell的最小边距
    var bubbleInsets = UIEdgeInsetsMake(15, 5, 15, 5)//气泡嵌入Cell的最小边距，其中左右边距和cellInsets的左右边距值相等
    var headImageLength = CGFloat(50) //正方形头像边长
    var betweenHeadAndBubble = CGFloat(5) //头像和气泡的左右距离
    var headImageWithInsets: CGFloat { //依赖于上述尺寸
        get {
            return cellInsets.left + headImageLength + betweenHeadAndBubble
        }
    }
    
    //MARK:属性类型4.3：正常Cell相关特性：基本样式，包括文字size、color等
    var normalFont = UIFont.systemFont(ofSize:18)
    var titleFont = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
    var descriptionFont = UIFont.systemFont(ofSize:18)
    var textColor = UIColor.black//需要在构造器中根据条件得到
    
    //MARK：属性类型5：基于当前屏幕宽度（即当前Cell宽度）得到的基本尺寸
    let screenWidth = SomeGlobal.screenWidth ?? CGFloat(375)
    var maxBubbleImageWidth:CGFloat {//气泡最大宽度
        return screenWidth - headImageLength - cellInsets.left - cellInsets.right - bubbleInsets.right - bubbleShorterLen - headImageLength
    }
    var maxTextWidth:CGFloat {//文字最大宽度
        return maxBubbleImageWidth - bubbleImageInsets.left - bubbleImageInsets.right
    }
    var maxTextHeight = CGFloat(10000.0) //文字最大高度
    var imageWidth:CGFloat {
        return maxTextWidth
    }
    var imageHeight:CGFloat{
        return maxTextWidth / 16 * 9
    }
    
    //MARK: 属性类型6：头像相关
    var headImageViewX:CGFloat? = nil//存储cell中计算结果
    var headImageViewY:CGFloat? = nil//存储cell中计算结果
    var headUIImage: UIImage? = nil//存储cell中计算结果
    var headImage = ""//需要在构造器中根据条件得到
   
    
    //MARK: 属性类型7：气泡及内容相关：根据（文字长短）动态计算得到的图形实际尺寸，后文会计算 ——会暴露给cell view!
    var bubbleImageWidth = CGFloat(0) //气泡宽度
    var bubbleImageHeight = CGFloat(0) //气泡高度
    var bubbleImageX = CGFloat(0)//气泡x坐标值
    var bubbleImageY:CGFloat? = nil //气泡的y坐标值，在cell view中计算得到，该值只能在cell view中计算
    
    var saysWhatWidth = CGFloat(0) // 对话内容文字宽度
    var saysWhatHeight = CGFloat(0) //对话内容文字高度
    var saysWhatX = CGFloat(0)//对话内容文字x坐标值
    var saysWhatY:CGFloat? = nil//对话内容内文字y坐标值，在cell view中计算得到，该只能在cell view中计算
    
    var titleWidth = CGFloat(0)
    var titleHeight = CGFloat(0)
        // titleX、titleY就是saysWhatX、saysWhatY,故不再重复设置属性
    
    var coverY:CGFloat? = nil//对话内容card类型其中的card的y坐标值，在cell view中计算得到，该只能在cell view中计算
        // coverWidth,coverHeight就是imageWidth、imageHeight，故不再重复设置属性
        // coverX就是saysWhatX，故不再重复设置属性
    
    var descriptionWidth = CGFloat(0)
    var descriptionHeight = CGFloat(0)
        // descriptionX就是saysWhatX，故不再重复设置属性
    var descriptionY:CGFloat? = nil
    
    var bubbleImage: String = ""//需要在构造器中根据条件得到
    
    //MARK：属性类型8：用于trackData
    var impressionId = ""
    var storyId = ""
    var channel = "综合"//待在构造器中通过storyId获取
    //MARK:关于Cell高度
    var cellHeightByHeadImage:CGFloat {//由头像得到的Cell高度
        get {
            return self.headImageLength + cellInsets.top + cellInsets.bottom //60
        }
    }
    var cellHeightByBubble = CGFloat(0)////需要在构造器中经过计算得到
    var talkCellHeight:CGFloat {//暴露给cell view的
        if(isHistoryCutline) {
            return cutlineCellHeight
        } else {
            return max(cellHeightByHeadImage, cellHeightByBubble)
        }
        
    }
 
    //MARK:image下载存储相关
    var storedImage: UIImage? = nil//用于内存存储请求到的UIImage对象
    var savedImageFileName: String? = nil//用于存储向缓存请求的image文件名
    
    var cellFrameWidth: CGFloat? = nil
    var cellFrameMinY: CGFloat? = nil
    
    // 一些必须在数据里生成的和view相关的对象
    var strechedBubbleImage = UIImage()
    
    
    //MARK:构造器1：下拉加载更多历史记录时提示语CellData数据构造器：
    init(getMoreHistory getMoreHistoryData:Bool, signContent content: String) {
        self.isGetMoreHistory = getMoreHistoryData
        self.getMoreHistorySignContent = content
    }
    
    //MARK:构造器2：分割线CellData数据构造器：
    init(cutline isHistoryCutline:Bool) {
        self.isHistoryCutline = isHistoryCutline

    }
    
    //MARK:构造器3：对话CellData数据构造器：
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
        
        if say.type == .text {
            
            self.buildTextCellData(textContent: say.content)
            
        } else if say.type == .image {
            
            self.buildImageCellData()
            
        } else if say.type == .card {
            
            self.buildCardCellData(
                title: say.title,
                coverUrl: say.coverUrl,
                description:say.description,
                impressionId: say.impressionId,
                storyId: say.storyId
            )
        }
        
    }
    //构造器2
    init(){
        
    }
    
    //创建Text类型数据:
     func buildTextCellData(textContent text: String) {//wycNOTE: mutating func:可以在mutating方法中修改结构体属性
        //Step1:动态计算文字宽、高
        let atts = [NSAttributedStringKey.font: self.normalFont]
        let saysWhatNSString = text as NSString
     
        let size = saysWhatNSString.boundingRect(
            with: CGSize(width:self.maxTextWidth, height:self.maxTextHeight),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        let computeWidth = max(size.size.width,20)
        /* QUEST:boundingRect为什么不能直接得到正确结果？而且为什么
         * 已解决：因为此处的font大小和实际font大小不同，只用在cell view中为UILabelView设置属性font为一样的UIFont对象，才能保证大小合适
         * 另说明：此处当文字多于一行时，自动就是宽度固定为最大宽度，高度自适应
         */
        let computeHeight = size.size.height
     
        //Step2：根据文字宽、高得到气泡图片的宽、高、X,预备暴露给cell view
        self.bubbleImageWidth = computeWidth + bubbleImageInsets.left + bubbleImageInsets.right
        self.bubbleImageHeight = computeHeight + bubbleImageInsets.top + bubbleImageInsets.bottom
        self.bubbleImageX = (whoSays == .robot) ? headImageWithInsets : screenWidth - headImageWithInsets - bubbleImageWidth
         // self.bubbleImageY在cell view里面更新
        self.saysWhatWidth = computeWidth
        self.saysWhatHeight = computeHeight
        self.saysWhatX = bubbleImageX + bubbleImageInsets.left
         // self.saysWhatY在cell view里面更新
        
        self.cellHeightByBubble = bubbleImageHeight + bubbleInsets.top + bubbleImageInsets.bottom
    }
    
    //创建Image类型数据:
     func buildImageCellData() {
        self.bubbleImageWidth = self.imageWidth + self.bubbleImageInsets.left + self.bubbleImageInsets.right
        self.bubbleImageHeight = imageHeight + bubbleImageInsets.top + bubbleImageInsets.bottom
        self.bubbleImageX = (whoSays == .robot) ? headImageWithInsets : screenWidth - headImageWithInsets - bubbleImageWidth
         // self.bubbleImageY在cell view里面更新
        self.saysWhatWidth = imageWidth
        self.saysWhatHeight = imageHeight
        self.saysWhatX = bubbleImageX + bubbleImageInsets.left
         // self.saysWhatY在cell view里面更新
        self.cellHeightByBubble = bubbleImageHeight + bubbleInsets.top + bubbleImageInsets.bottom
    }
    
    //创建Card类型数据: //TODO:简化参数，直接为SaysWhat就好
    func buildCardCellData(title titleStr: String, coverUrl coverUrlStr: String, description descriptionStr:String, impressionId impressionIdStr: String, storyId storyIdStr: String) {

        self.bubbleImageWidth = self.imageWidth + self.bubbleImageInsets.left + self.bubbleImageInsets.right
            // self.bubbleImageHeight在此方法后文计算
        self.bubbleImageX = (whoSays == .robot) ? headImageWithInsets : screenWidth - headImageWithInsets - bubbleImageWidth
             // self.bubbleImageY在cell view里面更新
        self.saysWhatWidth = imageWidth
        self.saysWhatX = bubbleImageX + bubbleImageInsets.left
        
        // MAKR:处理title
        let atts = [NSAttributedStringKey.font: self.titleFont]
        let titleNSString = titleStr as NSString
        let size = titleNSString.boundingRect(
            with: CGSize(width:self.maxTextWidth, height:self.maxTextHeight),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        self.titleWidth = size.size.width
        self.titleHeight = size.size.height
         //x即为self.saysWhatX,Y在cell view里面更新
        
        // MARK:处理cover
         // width和height就为self.imageWidth和self.imageHeight
         // y在cell view里更新
        
        // MARK:处理description
        if (descriptionStr != "") {
            let descriptionAtts = [NSAttributedStringKey.font: self.descriptionFont]
            let descriptionNSString = descriptionStr as NSString
            let descriptionSize = descriptionNSString.boundingRect(
                with: CGSize(width: maxTextWidth, height: maxTextHeight),
                options: .usesLineFragmentOrigin,
                attributes: descriptionAtts,
                context: nil)
            self.descriptionWidth = descriptionSize.size.width
            self.descriptionHeight = descriptionSize.size.height
             //self.descriptionY在cell view里更新
        }
        
        self.saysWhatHeight = self.titleHeight + imageHeight + descriptionHeight
        self.bubbleImageHeight = self.saysWhatHeight + bubbleImageInsets.top + bubbleImageInsets.bottom
        self.cellHeightByBubble = bubbleImageHeight + bubbleInsets.top + bubbleImageInsets.bottom
        
        self.impressionId = impressionIdStr
        self.storyId = storyIdStr
        
        //TODO:获取文章频道self.channel的更新
        let getChannelUrl = "http://www.ftchinese.com/index.php/jsapi/getStoryChannel/\(storyIdStr)"
        if let url = URL(string: getChannelUrl) { // 将String转化为Data
            var getChannelRequest = URLRequest(url:url)
            getChannelRequest.httpMethod = "GET"
            
            (URLSession.shared.dataTask(with: getChannelRequest) {
                (data,response,error) in
                if error != nil {
                    print("GetChannel Error: start- \(String(describing: error)) -end")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("GetChannel Response statusCode is not 200: start- \(httpStatus) -end")
                    return
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8){
                    print("GetChannel Data: start- \(dataString) -end")
                    
                    
                    if let jsonAny = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    , let jsonArray = jsonAny as? NSArray {
                        var channelArr = [String]()
                        for oneChannel in jsonArray {
                            let transform = "Any-Hex/Java"
                            if let input = oneChannel as? NSString, let convertedString = input.mutableCopy() as? NSMutableString {
                                CFStringTransform(convertedString, nil, transform as NSString, true) //  NOTE:把unicode转换为string,待做成一个通用方法
                                let oneChannelStr = convertedString as String
                                channelArr.append(oneChannelStr)
                            }
                        }
                        print("GetChannel chanels:\(channelArr)")
                        if channelArr.count > 0 {
                            self.channel = channelArr[0]
                            print("GetChannel channel:\(self.channel)")
                        }
                    }
                }
            }).resume()
        }
    }

}

/******* Chat类: 提供一些方法，和小冰对话式推荐通讯关系密切 ****/
class Chat {
    let triggerGreetForOldUser = "【端用户新对话打开信号，内容无法显示】"
    let triggerGreetForNewUser = "【端用户首次打开信号，内容无法显示】"
    let triggerNewsContent = "【端用户首次打开信号，推荐新闻】"
    var iceUserInfo:(iceUserId:String, triggerGreetContent:String)? = nil
    var userId: String? = nil
    
    let appIdField = "x-msxiaoice-request-app-id"
    let userIdField = "x-msxiaoice-request-user-id"
    let timestampField = "x-msxiaoice-request-timestamp"
    let signatureField = "x-msxiaoice-request-signature"
    
    let appKey = "vAKjG4el8hL2MW3yD9QpgwcWJsdmEXoxqilLPTpy"
    let secret = "bJicIuWGOAYkh6hEcPXeF45KOi7opu7dDAw2SjJWvIf5VuAYk6tWMrLgfmYdhR1o"
    //小冰正式服务器
    let urlString = "https://service.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15"
    let appId = "XIeQemRXxREgGsyPki"
    let secretKey = "4b3f82a71fb54cbe9e4c8f125998c787"
    let paramList = ["api-version=2017-06-15"]
    //let secretUpload = "vAKjG4el8hL2MW3yD9QpgwcWJsdmEXoxqilLPTpy"
    //小冰测试服务器
    /*
     let urlString = "https://sai-pilot.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15-Int"
     let appId = "XI36GDstzRkCzD18Fh"
     let secretKey = "5c3c48acd5434663897109d18a2f62c5"
     let paramList = "api-version=2017-06-15-Int"
    */
    var timeStampFrom1970:Int { //用以对话请求的时间戳
        return Int(Date().timeIntervalSince1970)
    }
    
    var responseTalkDataArr = [[String: String]]()
    
    
    ///About Tracking click
    //小冰正式服务器
     //let trackUrlString = "https://sai-prod-recommstorage.azurewebsites.net/api/Recommender/UpdateUserBehavior" //错的
    let trackUrlString = "https://sai-prod-recommstorage.azurewebsites.net/api/Store/UpdateUserBehavior"
    //小冰测试服务器
     //let trackUrlString = "https://sai-int-recommstorage.azurewebsites.net/api/Recommender/UpdateUserBehavior" //错的
    //let trackUrlString = "https://sai-int-recommstorage.azurewebsites.net/api/Store/UpdateUserBehavior"
    var behaviorId:String {//唯一，标志某唯一行为 MARK:计算结果每次都不同，故使用计算属性生成
        return SomeGlobal.randomString(length: 16)
    }
    let deviceType = 0 //0表示iPhone, 1表示android
    var deviceId:String? = nil//MARK:计算结果为固定值，故只需在init中更新一次,而非使用计算属性
    var timeStampByFormat:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let convertedDate = dateFormatter.string(from:Date())
        return convertedDate
    }
    let actionType = 81
    //let sessionId = ""
    let pos = 1
    //var trackSign:String? = nil //MARK:计算结果为固定值，故只需在init中更新一次,而非使用计算属性
    var viewTime = 0 //需要通过阅读文章后再返回来计算
    let channel = "Chat"
    var cardReadStartTime = 0
    var cardReadEndTime = 0
    init() {
        self.iceUserInfo = self.determineUser()
        self.userId = self.iceUserInfo?.iceUserId
        self.deviceId = self.getDeviceId()
        //self.trackSign = self.computeTrackSign(secretKey: self.secretUpload, parameList: self.paramList)
        //print("track sign:\(self.trackSign ?? "")")
    }
    
    func determineUser() -> (iceUserId: String, triggerGreetContent: String){
        let userIdFromUserDefault = UserDefaults.standard.object(forKey: "iceUserId")
        var iceUserId: String? = nil
        var triggerGreet: String? = nil
        if let userIdFromUserDefaultReal = userIdFromUserDefault {
            let userIdStr = userIdFromUserDefaultReal as? String
            if let userIdStrReal = userIdStr, userIdStrReal.count == 32  {
                iceUserId = userIdStrReal
                triggerGreet = self.triggerGreetForOldUser
            }
        }
        if let iceUserIdReal = iceUserId, let triggerGreetReal = triggerGreet {
            return (
                iceUserIdReal,
                triggerGreetReal
            )
        } else {
            let newIceUserId = SomeGlobal.randomString(length: 32)
            UserDefaults.standard.set(newIceUserId, forKey: "iceUserId")
            return (
                newIceUserId,
                self.triggerGreetForNewUser
            )
        }
    }
    
    func getDeviceId() -> String {
        if let realIdVender = UIDevice.current.identifierForVendor {
            let uuidStr = realIdVender.uuidString
            if let regex = try? NSRegularExpression(pattern: "-", options:[]) {//NOTE:try? 将错误转换成可选值
                let cleanedUuidStr = regex.stringByReplacingMatches(in: uuidStr, options: [], range: NSMakeRange(0, uuidStr.count), withTemplate: "")
                
                return cleanedUuidStr
            }
        }
        return ""
    }
    
    func computeTalkSign(verb:String, path:String, paramList:[String], headerList:[String],body:String,timestamp:Int,secretKey:String) -> String {
        print("Ice Execute computeSignature")
        
        let verbStr = verb.lowercased()
        print("Ice verbStr:\(verbStr)")
        
        let pathStr = path.lowercased()
        print("Ice pathStr:\(pathStr)")
        
        let paramListStr = paramList.sorted().joined(separator: "&")
        print("Ice paramListStr:\(paramListStr)")
        
        var headerListNew = Array(repeating: "", count: headerList.count)
        for (index,value) in headerList.enumerated() {
            headerListNew[index] = value.lowercased()
        }
        print("Ice headerListNew: start- \(headerListNew) -end")
        
        let headerListStr = headerListNew.sorted().joined(separator: ",")
        //base64EncodedString()
        let bodyStr = body
        
        let secretKeyStr = secretKey
        print("Ice secretKeyStr: start- \(secretKeyStr) -end")
        
        let messageStr = "\(verbStr);\(pathStr);\(paramListStr);\(headerListStr);\(bodyStr);\(timestamp);\(secretKeyStr)"
        
        print("Ice messageStr: start- \(messageStr) -end")
        
        return messageStr.HmacSHA1Base64(key: secretKeyStr)
    }
    
    
    
    func createTalkRequest(myInputText inputText:String = "", completion: @escaping (_ talkDataArr:[[String:String]]?) -> Void) {
        let bodyString = "{\"query\":\"\(inputText)\",\"messageType\":\"text\"}"
        let timeStamp = self.timeStampFrom1970
        print("Ice Request bodyString: start- \(bodyString) -end")
        
        if let userId = self.userId {
            let signature = self.computeTalkSign(verb: "post", path: "/api/Conversation/GetResponse", paramList: paramList, headerList: ["\(appIdField):\(appId)","\(userIdField):\(userId)"], body: bodyString, timestamp: timeStamp, secretKey: secretKey)
            print("Ice signature: start- \(signature) -end")
            
            if let url = URL(string: urlString),let body = bodyString.data(using: .utf8) { // 将String转化为Data
                var talkRequest = URLRequest(url:url)
                talkRequest.httpMethod = "POST"
                talkRequest.httpBody = body
                talkRequest.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
                talkRequest.setValue(appId, forHTTPHeaderField: appIdField)
                talkRequest.setValue(String(timeStamp), forHTTPHeaderField: timestampField)
                talkRequest.setValue(signature, forHTTPHeaderField: signatureField)
                talkRequest.setValue(userId, forHTTPHeaderField: userIdField)
                
                (URLSession.shared.dataTask(with: talkRequest) {
                    (data,response,error) in
                    if error != nil {
                        print("Ice Error: start- \(String(describing: error)) -end")
                        DispatchQueue.main.async {//返回主线程更新UI
                            completion(nil)
                        }
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        //explainRobotTalk = "Status code is not 200. It is \(httpStatus.statusCode)"
                        print("Ice Response statusCode when not 200: start- \(httpStatus) -end")
                        DispatchQueue.main.async {//返回主线程更新UI
                            completion(nil)
                        }
                        return
                    }
                    if let data = data, let dataString = String(data: data, encoding: .utf8){
                        print("Ice Responce Data: start- \(dataString) -end")
                        self.parseResponseData(data: data)
                        DispatchQueue.main.async {//返回主线程更新UI
                            completion(self.responseTalkDataArr)
                        }
                    }
                }).resume()
            }
        }
    }
    
    
    func parseResponseData(data:Data) {
        var talkDataArr = [[String: String]]()
        
        do {
            let jsonAny = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            if let jsonDictionary = jsonAny as? NSDictionary,let impressionId = jsonDictionary["ImpressionID"], let answer = jsonDictionary["Answer"],let answerArray = answer as? NSArray {
                
                //MARK:answer字段是数组，有几条就显示几条
                for oneAnswer in answerArray {
                    
                    if let oneAnswerDic = oneAnswer as? NSDictionary,
                        let type = oneAnswerDic["Type"], let typeStr = type as? String {
                        var talkData = [
                            "member":"robot",
                            "type":"text"
                        ]
                        print(typeStr)
                        switch typeStr {
                        case "Text":
                            if let content = oneAnswerDic["Content"]{
                                let contentStr = content as? String
                                talkData["content"] = contentStr
                            }
                            
                        case "Image":
                            if let url = oneAnswerDic["Url"] {
                                let urlStr = url as? String
                                print("This is a Image")
                                talkData["type"] = "image"
                                talkData["url"] = urlStr
                            }
                            
                        case "Card":
                            let impressionIdStr = impressionId as? String
                            if let title = oneAnswerDic["Title"],
                                let description = oneAnswerDic["Description"],
                                let coverUrl = oneAnswerDic["CoverUrl"],
                                let cardUrl = oneAnswerDic["Url"] {
                                
                                let titleStr = title as? String
                                let cardUrlStr = cardUrl as? String
                                let coverUrlStr = coverUrl as? String
                                let descriptionStr = description as? String
    
                                talkData["type"] = "card"
                                talkData["coverUrl"] = coverUrlStr
                                talkData["title"] = titleStr
                                talkData["url"] = cardUrlStr
                                talkData["description"] = descriptionStr
                                
                                talkData["impressionId"] = impressionIdStr //用于user tracking的ImpressionID字段
                                if let realCardUrlStr = cardUrlStr, let storyId = realCardUrlStr.matchingStrings(regexes:LinkPattern.story) {//NOTE:此处借用了string已有的扩展方法matchingStrings
                                    talkData["storyId"] = storyId //用于user tracking的feedID字段
                                }
                            }
                            
                        default:
                            print("An unknow type response data.")
                        }
                        
                        talkDataArr.append(talkData)
                    }
                }
                
            }
            self.responseTalkDataArr = talkDataArr
            
        } catch {
            print("Catch Error in parsing Response Data")
        }
    }

    func computeTrackSign(secret:String, bodyDic:[String:Any]) -> String {
        _ = secret
        //let paramListStr = paramList.sorted().joined(separator: "&")
        //let messageStr = "\(secretStr);\(paramListStr)"
        //print("Track messageStr:\(messageStr)")
        //return messageStr.HmacSHA1UpperHex(key: secretStr)
        var body = bodyDic
        body.removeValue(forKey: "sign")
        let bodyKeyArr = body.keys.sorted()
        print("bodyKeyArr:\(bodyKeyArr)")
        var messageStr = self.secret
        for key in bodyKeyArr {
            if let value = body[key] {
               let valueStr = SomeGlobal.convertAnyToJsonStr(value)
               
               messageStr += "\(key)\(valueStr)"
            }
            
        }
        print("Track messageStr:\(messageStr)")
        return messageStr.HmacSHA1X2(key: self.secret)
    }
    
    
    func createTrackRequest(_ cellData: CellData) {
        //TODO：更新self.viewTime,这里有个问题是应该点击的时候发送，如果是回到此界面再发送的话有可能发送不了了（因为可能不回来了）
        //let trackSign = self.computeTrackSign(secret: self.secret, parameList: self.paramList)
        //let trackSign = "DB548632CAF019743AE89B56D48867619CA097DB"
        
        if let deviceId = self.deviceId, let userId = self.userId {
            let tsValue = self.timeStampFrom1970
            let behaviorIDValue = self.behaviorId
            let timeStampValue = self.timeStampByFormat
            var bodyDic:[String:Any] = [//Dic
                "appkey":self.appKey,
                "sign":"",
                "ts":tsValue,
                "userList":[ //Array
                    [//Dic
                        "userID":userId,
                        "behaviorList":[//Array
                            [//Dic
                                "behaviorID": behaviorIDValue,
                                "deviceType":self.deviceType,
                                "deviceID":deviceId,
                                "timeStamp": timeStampValue,
                                "actionType": self.actionType,
                                "impressionID":cellData.impressionId,
                                "channel":self.channel,
                                "feedID":cellData.storyId,
                                "viewTime":self.viewTime,
                                "pos": self.pos
                            ]
                        ]
                    ]
                ]
            ]
            let trackSign = self.computeTrackSign(secret: self.secret, bodyDic: bodyDic)
            print("track sign:\(trackSign)")
            bodyDic["sign"] = trackSign
            //let bodyString = "{\"appkey\":\"\(self.appKey)\",\"sign\":\"\(trackSign)\",\"ts\":\(self.timeStampFrom1970),\"userList\":[{\"userID\":\"\(userId)\",\"behaviorList\":[{\"behaviorID\":\"\(self.behaviorId)\",\"deviceType\":\(self.deviceType),\"deviceID\":\"\(deviceId)\",\"timeStamp\":\"\(self.timeStampByFormat)\",\"actionType\":\(self.actionType),\"impressionID\":\"\(cellData.impressionId)\",\"channel\":\"\(cellData.channel)\",\"feedID\":\"\(cellData.storyId)\",\"viewTime\":\(self.viewTime),\"pos\":\(self.pos)}]}]}"
            let bodyString = SomeGlobal.convertAnyToJsonStr(bodyDic)
            print("Track body:\(bodyString)")
            
            if  let url = URL(string: self.trackUrlString), let body = bodyString.data(using: .utf8) {
                var trackRequest = URLRequest(url:url)
                trackRequest.httpMethod = "POST"
                trackRequest.httpBody = body
                trackRequest.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
                
                (URLSession.shared.dataTask(with: trackRequest) {
                    (data,response,error) in
                    if error != nil {
                        print("Track Error: start- \(String(describing: error)) -end")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("Track Response statusCode is not 200: start- \(httpStatus) -end")
                        return
                    }
                    if let data = data, let dataString = String(data: data, encoding: .utf8){
                        print("Track Responce Data: start- \(dataString) -end")
                       
                    }
                }).resume()
            }
            
        }
        
    }
}

/******* SomeGlobal: 提供一些全局性质的方法和属性 ****/

class SomeGlobal {
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
    static var screenWidth:CGFloat? = nil

    static func getTimeStampOfSeconds() -> Int{
        return Int(Date().timeIntervalSince1970)
    }
    static func getTimeStampOfDate() -> Date{
        return Date()
    }
    static func buildCellData(_ oneTalkData:[String:String]) -> CellData {//根据historyTalkData数据得到CellData数据
        var saysWhat: SaysWhat
        var member:Member
        //MARK:处理talkData的member字段，然后其他字段交给SaysWhat构造器处理
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
        saysWhat = SaysWhat(oneTalkData)
        let cellData = CellData(whoSays: member, saysWhat: saysWhat)
        return cellData
    }
 
    static func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    static func convertAnyToJsonStr(_ anyObj:Any) -> String { //仅针对Any是[String:Any]和[[String:Any]]有效
        var resultStr :String? = nil
           
        if ((anyObj as? [String:Any]) != nil) || ((anyObj as? [[String:Any]]) != nil) {
            let valueAny:Any?
            if let valueDic = anyObj as? [String:Any] {
                valueAny = valueDic
            } else if let valueArr = anyObj as? [[String:Any]] {
                valueAny = valueArr
            } else {
                valueAny = nil
            }
            if let realValueAny = valueAny {
                do {
                   let jsonData = try JSONSerialization.data(withJSONObject: realValueAny)
            
                    let convertedStr = String(data:jsonData, encoding:String.Encoding.utf8 )
                    resultStr = convertedStr
                } catch {
                    
                }
            }
        } else {
            resultStr = String(describing:anyObj)
        }
        
        return resultStr ?? ""
      
    }
    
}

extension String {
    /// HmacSHA1 Encrypt
    ///
    /// -Parameter key: secret key
    ///
    func HmacSHA1Base64(key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        if let realCKey = cKey, let realCData = cData {
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), realCKey, Int(strlen(realCKey)), realCData, Int(strlen(realCData)), &result)
            let hmacData:NSData = NSData(bytes: result, length: (Int(CC_SHA1_DIGEST_LENGTH)))
            let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
            print("Sign not base64:\(String(describing: hmacData))")
            return String(hmacBase64)
        } else {
            return ""
        }
    }
    func HmacSHA1X2(key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [UInt8](repeating:0, count:Int(CC_SHA1_DIGEST_LENGTH))

        if  let realCKey = cKey, let realCData = cData{
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), realCKey, Int(strlen(realCKey)), realCData, Int(strlen(realCData)), &result)
            let hexBytes = result.map {
                String(format:"%02hhX", $0)
            }
            return hexBytes.joined()
        } else {
            return ""
        }
        
    }
}

