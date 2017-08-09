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
    // 文本
    var saysContentView : UILabel!
    // 文本背景气泡
    var bubbleImageView : UIImageView!
    
    var cellData:CellData
    
    // MARK: 重写Frame:费了好长好长时间才找到解决办法。。。
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.size.width = UIScreen.main.bounds.width
            super.frame = newFrame
        }
    }
    
    init(_ data:CellData, reuseId cellId:String) {
        self.cellData = data
        super.init(style: UITableViewCellStyle.default, reuseIdentifier:cellId)
        buildTheCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func buildTheCell() {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        let whoSays = self.cellData.whoSays
        
        
        // 显示头像
        if(self.cellData.headImage != "") {
            let headImageName = self.cellData.headImage //The name of the image in tha app's maini bundler, which including the extension except for PNG
            let headImage = UIImage(named: headImageName)
            self.headImageView = UIImageView(image: headImage)
            
            // 头像高、宽都为50CGFloat
            // 头像的位置x: robot头像在左，you头像在右
            let xForHeadImageView = (whoSays == .robot) ? 5 : self.frame.width - 55
            // 头像的位置y:
            let yForHeadImageView = self.frame.minY + 5
            
            // 绘制头像view
            self.headImageView.frame = CGRect(x:xForHeadImageView,y:yForHeadImageView,width:50,height:50)
            self.addSubview(self.headImageView)
        }
        
        
        
        
        
        
        // 根据对话文字长短得到相关尺寸
        let font = UIFont.systemFont(ofSize:12)
        let width = 150, height = 10000.0
        let atts = [NSFontAttributeName: font]
        
        let saysWhatNSString = self.cellData.saysWhat as NSString
        
        let size = saysWhatNSString.boundingRect(
            with: CGSize(width:CGFloat(width), height:CGFloat(height)),
            options: .usesLineFragmentOrigin,
            attributes: atts,
            context: nil)
        let computeWidth = size.size.width * 1.4//修正计算错误 //QUEST:boundingRect为什么不能直接得到正确结果？而且为什么
        let computeHeight = size.size.height * 1.6
        
        
        let bubbleImageWidth = computeWidth + self.cellData.bubbleImageInsets.left + self.cellData.bubbleImageInsets.right
        let bubbleImageHeight = computeHeight + self.cellData.bubbleImageInsets.top + self.cellData.bubbleImageInsets.bottom
        print("bubbleImageHeight:\(bubbleImageHeight)")
        let saysWhatWidth = computeWidth
        let saysWhatHeight = computeHeight
        print("saysWhatHeight:\(saysWhatHeight)")
        let bubbleImageX = (whoSays == .robot) ? 60: self.frame.width - 60 - bubbleImageWidth
        let bubbleImageY = self.frame.minY + 5
        
        let saysWhatX = bubbleImageX + self.cellData.bubbleImageInsets.left
        let saysWhatY = bubbleImageY + self.cellData.bubbleImageInsets.top
        
        
        
        
        // 对话气泡背景
        if self.cellData.bubbleImage != "" {
            //self.addSubview(self.bubbleImageView)
            let bubbleImageName = self.cellData.bubbleImage
            let bubbleImage = UIImage(named: bubbleImageName)
            
            
            
            //let bubbleImageStreched = bubbleImage!.stretchableImage(withLeftCapWidth: 100, topCapHeight: 100)
            let bubbleImageStreched = bubbleImage!.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 30, 20, 30), resizingMode: UIImageResizingMode.stretch)//该方式可实现部分拉伸
            //self.bubbleImageView.contentMode = .scaleToFill //NOTE:该方式可实现全部拉伸
            
            
            self.bubbleImageView = UIImageView(frame: CGRect(x: bubbleImageX, y: bubbleImageY, width: bubbleImageWidth, height: bubbleImageHeight)) // NOTE:任何一个View都要先初始化再设置属性
            self.addSubview(self.bubbleImageView)
            self.bubbleImageView.backgroundColor = UIColor.lightGray
            self.bubbleImageView.image =  bubbleImageStreched
            
            
            //print("bubbleImageView:\(self.bubbleImageView.frame)")
            
            
            
        }
        
        // 对话内容 // NOTE:内容在bubble上方才能不被bubble遮挡
        saysContentView = UILabel(frame: CGRect(x: saysWhatX, y: saysWhatY, width: saysWhatWidth, height: saysWhatHeight))
        //print("saysContentView:\(saysContentView.frame)")
        saysContentView.numberOfLines = 0
        saysContentView.lineBreakMode = NSLineBreakMode.byWordWrapping
        saysContentView.text = self.cellData.saysWhat
        saysContentView.backgroundColor = UIColor.green
        self.addSubview(saysContentView)
        
        
        
        
        
    }
}
