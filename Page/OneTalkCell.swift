//
//  OneTalkCell.swift
//  talkRobot
//
//  Created by wangyichen on 03/08/2017.
//  Copyright © 2017 Ftc. All rights reserved.
//
import UIKit
import Foundation

class OneTalkCell: UITableViewCell {
    // 头像View
    var headImageView = UIImageView(image: UIImage(named: "you.jpeg"))
    
    // 文本背景气泡
    var bubbleImageView = UIImageView()
    
    var saysImageView = UIImageView()
    var coverView = UIImageView()
    var cellData = CellData()
    
    
    var cardUrl = ""
    
    // MARK:存储已获取到的图片
    var storedCoverImage:UIImage? = UIImage()
    var savedImageFile:String? = ""
    
    // MARK: 重写Frame:费了好长好长时间才找到解决办法。。。
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.size.width = UIScreen.main.bounds.width
            super.frame = newFrame
        }
    }
    
    init(_ data:CellData, reuseId cellId:String) {//NOTE: View通过ChatViewController得到Model的数据
        self.cellData = data
        super.init(style: UITableViewCellStyle.default, reuseIdentifier:cellId)
        if data.isHistoryCutline == true  {//生成分割线的cell
           buildCutlineCell()
        } else if data.isGetMoreHistory == true {//生成加载更多历史数据相关cell
           buildGetMoreHistoryCell()
        } else {//生成普通的聊天数据cell
           buildTheCell()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    @objc func tapClick(_ sender:UIView){
        //NOTE:通过openLink方法对cardUrl进行判断，如果是站内文章，就打开app内文章；如果是站外文章，就在app内打开浏览器
        if let openUrl = URL(string:self.cardUrl) {
            //print("myopenUrl:\(openUrl)")
            if let topController = UIApplication.topViewController() {
                
                if let theController = self.parentViewController {
                    print("theController:\(theController is ChatViewController)")
                    if let theRealController = theController as? ChatViewController {
                        print("get the real controller")
                        theRealController.inputBlock.resignFirstResponder()
                    }
                }
                topController.openLink(openUrl)
            }
        }
    }
    
    //MARK:异步加载image：
    private func asyncBuildImage(url imageUrl: String, completion: @escaping (_ loadedImage: UIImage?) -> Void) {
        let optimizedUrl = self.optimizedImageURL(imageUrl, width: 240, height: 135)
        //print("ImageUrl:\(imageUrl)")
        //print("OptimizedUrl:\(String(describing: optimizedUrl))")
        if let imgUrl = optimizedUrl {
            let imgRequest = URLRequest(url: imgUrl)
            
            URLSession.shared.dataTask(with: imgRequest, completionHandler: {
                (data, response, error) in
                if error != nil{
                    DispatchQueue.main.async {//返回主线程更新UI
                        completion(nil)
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                let myUIImage = UIImage(data: data) //NOTE: 由于闭包可以在func范围之外生存，闭包中如果有参数类型是struct/enum，那么它将被复制一个新值作为参数。如果这个闭包会允许这个参数发生改变（即以闭包为其中一个参数的func是mutate的），那么闭包会产生一个副本,造成不必要的后果。所以struct中的mutate func中的escape closure的参数不能是self，也不能在closure内部改变self的属性。改为class，则可以。
                
                if let realUIImage = myUIImage { //如果成功获取了图片
                    //cellData.downLoadImage = realUIImage
                    DispatchQueue.main.async {
                        completion(realUIImage)
                    }
                    
                    
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }).resume()
            
        }
    }
    private func loadCoverImage() {
        DispatchQueue.global().async { //NOTE: 耗时操作在后台完成
            if let realStoredImage = self.storedCoverImage {
                DispatchQueue.main.async { //NOTE：耗时操作执行完毕后在主线程更细UI界面！
                    self.coverView.image = realStoredImage
                }
                print("Load image from RAM")
            } else if let imageFileName = self.savedImageFile {
                let savedImage = Download.readFile(imageFileName, for:.cachesDirectory, as: "jpg")
                if let realSavedImage = savedImage {
                    let coverImage = UIImage(data: realSavedImage)
                    DispatchQueue.main.async {
                        self.coverView.image = coverImage
                        print("Load image from cache")
                    }
                }
            } else {
                self.asyncBuildImage(url: self.cellData.saysWhat.coverUrl, completion: { downloadedImg in
                    if let realImage = downloadedImg {
                        //cellData.downLoadImage = realImage
                        //self.coverView.image = realImage
                        
                        DispatchQueue.main.async {
                            UIView.transition(with: self.coverView,
                                              duration: 0.3,
                                              options: .transitionCrossDissolve,
                                              animations: {
                                                self.coverView.image = realImage
                                              },
                                              completion: nil
                            )
                        }
                        
                    }
                })
            }
        }
    }
    private func optimizedImageURL(_ imageUrl: String, width: Int, height: Int) -> URL? { //MARK:该方法copy自Content/ContentItem.swift: getImageURL
        let urlString: String
        if let u = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            urlString = ImageService.resize(u, width: width, height: height)
        } else {
            urlString = imageUrl
        }
        if let url =  URL(string: urlString) {
            return url
        }
        return nil
    }
    private func buildCutlineCell(){
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor(hex: "#fff1e0")

        let cutlineContentView = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.cellData.cutlineCellHeight))
        cutlineContentView.text = "———— 以上为历史聊天内容 ————"
        cutlineContentView.font = self.cellData.cutlineFont
        cutlineContentView.textColor = self.cellData.cutlineColor
        cutlineContentView.textAlignment = .center
        self.addSubview(cutlineContentView)
        
    }
    private func buildGetMoreHistoryCell() {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor(hex: "#fff1e0")
        
        let cutlineContentView = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.cellData.getMoreHistoryHeight))
        cutlineContentView.text = self.cellData.getMoreHistorySignContent
        cutlineContentView.font = self.cellData.getMoreHistoryFont
        cutlineContentView.textColor = self.cellData.getMoreHistoryColor
        cutlineContentView.textAlignment = .center
        self.addSubview(cutlineContentView)
    }
    
    private func addBubbleView (x theX: CGFloat, y theY: CGFloat, width theWidth: CGFloat, height theHeight: CGFloat) {
        if self.cellData.bubbleImage != "" {
            let bubbleImageName = self.cellData.bubbleImage
            let bubbleImage = UIImage(named: bubbleImageName)
            
            
            if let realBubbleImage = bubbleImage {
                let bubbleImageStreched = realBubbleImage.resizableImage(withCapInsets: self.cellData.bubbleStrechInsets, resizingMode: UIImageResizingMode.stretch)//该方式可实现部分拉伸
                
                self.bubbleImageView = UIImageView(image: bubbleImageStreched)
                //self.bubbleImageView.frame = CGRect(x: bubbleImageX, y: bubbleImageY, width: self.cellData.bubbleImageWidth, height: self.cellData.bubbleImageHeight) // NOTE:任何一个View都要先初始化再设置属性
                self.bubbleImageView.frame = CGRect(x: theX, y: theY, width: theWidth, height: theHeight) // NOTE:任何一个View都要先初始化再设置属性
                self.addSubview(self.bubbleImageView)
                
                
            }
            
        }
    }
    private func buildTheCell() {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        let whoSays = self.cellData.whoSays
        self.backgroundColor = UIColor(hex: "#fff1e0")

        
        // 显示头像
        if(self.cellData.headImage != "") {
            let headImageName = self.cellData.headImage //The name of the image in tha app's maini bundler, which including the extension except for PNG
            let headImage = UIImage(named: headImageName)
            self.headImageView = UIImageView(image: headImage)
            
            // 头像高、宽都为50CGFloat
            // 头像的位置x: robot头像在左，you头像在右
            let headImageViewX = (whoSays == .robot) ? self.cellData.cellInsets.left : self.frame.width - self.cellData.headImageLength - self.cellData.cellInsets.right
            // 头像的位置y:
            let headImageViewY = self.frame.minY + self.cellData.cellInsets.top
            
            // 绘制头像view
            self.headImageView.frame = CGRect(x:headImageViewX,y:headImageViewY,width:self.cellData.headImageLength,height:self.cellData.headImageLength)
            self.addSubview(self.headImageView)
      }
        
        
        // 根据self.frame尺寸得到相关尺寸
        let maxBubbleImageWidth = self.frame.width - self.cellData.headImageLength - self.cellData.cellInsets.left - self.cellData.cellInsets.right - self.cellData.bubbleInsets.right - self.cellData.bubbleShorterLen - self.cellData.headImageLength
        let maxTextWidth = maxBubbleImageWidth - self.cellData.bubbleImageInsets.left - self.cellData.bubbleImageInsets.right
        let imageWidth = maxTextWidth
        let imageHeight = maxTextWidth / 16 * 9
        let coverWidth = maxTextWidth
        let coverHeight = maxTextWidth / 16 * 9
        
        //let bubbleImageX = (whoSays == .robot) ? self.cellData.headImageWithInsets : self.frame.width - self.cellData.headImageWithInsets - self.cellData.bubbleImageWidth
        //let bubbleImageX = (whoSays == .robot) ? self.cellData.headImageWithInsets : self.frame.width - self.cellData.headImageWithInsets - maxBubbleImageWidth //默认是按照maxBubbleImage来，text类型需要重新计算bubbleImageWidth
        let bubbleImageY = self.frame.minY + self.cellData.bubbleInsets.top
        
        //let saysWhatX = bubbleImageX + self.cellData.bubbleImageInsets.left
        let saysWhatY = bubbleImageY + self.cellData.bubbleImageInsets.top
        
        
        
        // 显示对话气泡背景
        /*
        if self.cellData.bubbleImage != "" {
            let bubbleImageName = self.cellData.bubbleImage
            let bubbleImage = UIImage(named: bubbleImageName)

            
            if let realBubbleImage = bubbleImage {
                let bubbleImageStreched = realBubbleImage.resizableImage(withCapInsets: self.cellData.bubbleStrechInsets, resizingMode: UIImageResizingMode.stretch)//该方式可实现部分拉伸
                
                self.bubbleImageView = UIImageView(image: bubbleImageStreched)
                //self.bubbleImageView.frame = CGRect(x: bubbleImageX, y: bubbleImageY, width: self.cellData.bubbleImageWidth, height: self.cellData.bubbleImageHeight) // NOTE:任何一个View都要先初始化再设置属性
                self.bubbleImageView.frame = CGRect(x: bubbleImageX, y: bubbleImageY, width: maxBubbleImageWidth, height: self.cellData.bubbleImageHeight) // NOTE:任何一个View都要先初始化再设置属性
                self.addSubview(self.bubbleImageView)
  

            }
            
        }
        */
        
        // 显示对话内容 // NOTE:内容在bubble上方才能不被bubble遮挡
        if self.cellData.saysType == .text {
            //Step1:动态计算文字宽、高
            let atts = [NSAttributedStringKey.font: self.cellData.normalFont]
            let saysWhatNSString = self.cellData.saysWhat.content as NSString
            
            let size = saysWhatNSString.boundingRect(
                with: CGSize(width: maxTextWidth, height:self.cellData.maxTextHeight),
                options: .usesLineFragmentOrigin,
                attributes: atts,
                context: nil)
            let computeWidth = max(size.size.width,20)
            let computeHeight = size.size.height
            
            //Step2：根据文字宽、高得到气泡图片的宽、高、X,添加气泡View
            let bubbleImageWidth = computeWidth + self.cellData.bubbleImageInsets.left + self.cellData.bubbleImageInsets.right
            let bubbleImageHeight = computeHeight + self.cellData.bubbleImageInsets.top + self.cellData.bubbleImageInsets.bottom
            let bubbleImageX = (whoSays == .robot) ? self.cellData.headImageWithInsets : self.frame.width - self.cellData.headImageWithInsets - bubbleImageWidth
            self.cellData.cellHeightByBubble = bubbleImageHeight + self.cellData.bubbleInsets.top + self.cellData.bubbleImageInsets.bottom
            self.addBubbleView(x: bubbleImageX, y: bubbleImageY, width: bubbleImageWidth, height: bubbleImageHeight)
            
            //Step3：添加文字内容View
            let saysWhatX = bubbleImageX + self.cellData.bubbleImageInsets.left
            let saysContentView = UILabel(frame: CGRect(x: saysWhatX, y: saysWhatY, width: computeWidth, height: computeHeight))
            saysContentView.numberOfLines = 0
            saysContentView.lineBreakMode = NSLineBreakMode.byWordWrapping
            saysContentView.text = self.cellData.saysWhat.content
            saysContentView.font = self.cellData.normalFont
            saysContentView.textColor = self.cellData.textColor
             //saysContentView.backgroundColor = UIColor.green
            self.addSubview(saysContentView)
            
            
        } else if self.cellData.saysType == .image {
            //Step1：根据最大宽、高得到气泡图片的宽、高、X,添加气泡View
            let bubbleImageWidth = maxBubbleImageWidth
            let bubbleImageHeight = imageHeight + self.cellData.bubbleImageInsets.top + self.cellData.bubbleImageInsets.bottom
             self.cellData.cellHeightByBubble = bubbleImageHeight + self.cellData.bubbleInsets.top + self.cellData.bubbleImageInsets.bottom
            let bubbleImageX = (whoSays == .robot) ? self.cellData.headImageWithInsets : self.frame.width - self.cellData.headImageWithInsets - bubbleImageWidth
            self.addBubbleView(x: bubbleImageX, y: bubbleImageY, width: bubbleImageWidth, height: bubbleImageHeight)
            
            //Step2：添加图片内容View
            let saysWhatX = bubbleImageX + self.cellData.bubbleImageInsets.left
            self.saysImageView.frame = CGRect(x: saysWhatX, y: saysWhatY, width: imageWidth, height: imageHeight)
            self.saysImageView.backgroundColor = UIColor(hex: "#f7e9d8")
            self.saysImageView.contentMode = .scaleToFill
            
            self.asyncBuildImage(url: self.cellData.saysWhat.url, completion: {
                downloadedImg in
                
                
                if let realImage = downloadedImg { //如果成功获取了图片
                    //self.saysImageView.image = realImage
                    DispatchQueue.main.async {
                        UIView.transition(with: self.saysImageView,
                                          duration: 0.3,
                                      options: .transitionCrossDissolve,
                                          animations: {
                                            self.saysImageView.image = realImage
                        },
                                          completion: nil
                        )
                    }
                }
 
                
            })
            self.addSubview(self.saysImageView)
            
            
        } else if self.cellData.saysType == .card {
            
            
           
            
            // Step1:计算几个View的相关尺寸
            var descriptionWidth = CGFloat(0)
            var descriptionHeight = CGFloat(0)
            var descriptionY = CGFloat(0)
            /// titleView:
            let atts = [NSAttributedStringKey.font: self.cellData.titleFont]
            let titleNSString = self.cellData.saysWhat.title as NSString
            let size = titleNSString.boundingRect(
                with: CGSize(width: maxTextWidth, height:self.cellData.maxTextHeight),
                options: .usesLineFragmentOrigin,
                attributes: atts,
                context: nil)
            let titleWidth = size.size.width
            let titleHeight = size.size.height
            /// coverView:
            let coverY = saysWhatY + titleHeight
            /// descriptionView:
            if(self.cellData.saysWhat.description != "") {
                let descriptionAtts = [NSAttributedStringKey.font: self.cellData.descriptionFont]
                let descriptionNSString = self.cellData.saysWhat.description as NSString
                let descriptionSize = descriptionNSString.boundingRect(
                    with: CGSize(width:maxTextWidth, height:self.cellData.maxTextHeight),
                    options: .usesLineFragmentOrigin,
                    attributes: descriptionAtts,
                    context: nil)
                descriptionWidth = descriptionSize.size.width
                descriptionHeight = descriptionSize.size.height
                descriptionY = coverY + coverHeight
            }
            /// bubbleView:
            let bubbleImageWidth = maxBubbleImageWidth
            let bubbleImageHeight = titleHeight + coverHeight + descriptionHeight + self.cellData.bubbleImageInsets.top + self.cellData.bubbleImageInsets.bottom
             self.cellData.cellHeightByBubble = bubbleImageHeight + self.cellData.bubbleInsets.top + self.cellData.bubbleImageInsets.bottom
            let bubbleImageX = (whoSays == .robot) ? self.cellData.headImageWithInsets : self.frame.width - self.cellData.headImageWithInsets - bubbleImageWidth
            
            // Step2:依次添加这几个View
            /// bubbleView:
            self.addBubbleView(x: bubbleImageX, y: bubbleImageY, width: bubbleImageWidth, height: bubbleImageHeight)
            
            /// titleView:
            let saysWhatX = bubbleImageX + self.cellData.bubbleImageInsets.left
            let titleView = UILabel(frame: CGRect(x: saysWhatX, y: saysWhatY, width: titleWidth, height: titleHeight))
            titleView.numberOfLines = 0
            titleView.lineBreakMode = NSLineBreakMode.byWordWrapping
            titleView.text = self.cellData.saysWhat.title
            titleView.font = self.cellData.titleFont
            titleView.textColor = self.cellData.textColor
            self.addSubview(titleView)
            
            /// coverView:
            self.coverView = UIImageView(frame: CGRect(x:saysWhatX, y:coverY,width:coverWidth,height:coverHeight))
            coverView.backgroundColor = UIColor(hex: "#f7e9d8")

            coverView.contentMode = .scaleToFill
            
            self.asyncBuildImage(url: self.cellData.saysWhat.coverUrl, completion: { downloadedImg in
                if let realImage = downloadedImg {
                    //cellData.downLoadImage = realImage
                    //self.coverView.image = realImage
                    
                    DispatchQueue.main.async {
                        UIView.transition(with: self.coverView,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: {
                                            self.coverView.image = realImage
                        },
                                          completion: nil
                        )
                    }
                    
                }
            })
            self.addSubview(coverView)
            
            /// descriptionView:
            if(self.cellData.saysWhat.description != "") {
                let descriptionView = UILabel(frame: CGRect(x: saysWhatX, y: descriptionY, width: descriptionWidth, height: descriptionHeight))
                descriptionView.numberOfLines = 0
                descriptionView.lineBreakMode = NSLineBreakMode.byWordWrapping
                descriptionView.text = self.cellData.saysWhat.description
                descriptionView.font = self.cellData.descriptionFont
                //descriptionView.backgroundColor = UIColor.green
                descriptionView.textColor = self.cellData.textColor
                self.addSubview(descriptionView)
            }
            
            // Step3:添加点击跳转方法
            self.bubbleImageView.isUserInteractionEnabled = true//打开用户交互属性
            self.cardUrl = self.cellData.saysWhat.url
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapClick))
            self.bubbleImageView.addGestureRecognizer(tap)
            
        }
    }
}



extension UIView {
    //MARK:计算属性parentViewController获取本view所在的controller
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
