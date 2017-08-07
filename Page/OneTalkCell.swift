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
    var headImageView = UIImageView(image: UIImage(named: "Images/you.jpeg"))
    // 文本
    var saysContentView = UILabel(frame:CGRect(x:0, y:0, width:200,height:50))
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
        print(data)
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
            print(self.headImageView.frame.minX)
            print(self.headImageView.frame.maxX)
            self.addSubview(self.headImageView)
        }
        
        
        
        var size = CGRect()
        var finalWidth = CGFloat()
        var finalHeight = CGFloat()
        var finalX = CGFloat()
        var finalY = CGFloat()
        // 显示对话内容
        if(self.cellData.saysWhat != "") {
            
            let font = UIFont.systemFont(ofSize:12)
            let width = 250, height = 10000.0
            let atts = [NSFontAttributeName: font]
            
            let saysWhatNSString = self.cellData.saysWhat as NSString
            
            size = saysWhatNSString.boundingRect(
                with: CGSize(width:CGFloat(width), height:CGFloat(height)),
                options: .truncatesLastVisibleLine,
                attributes: atts,
                context: nil)
       
            finalWidth = size.size.width * 1.4 //修正计算错误
            finalHeight = size.size.height * 1.4
            finalX = (whoSays == .robot) ? 60: self.frame.width - 60 - finalWidth
            finalY = self.frame.minY + 5
            saysContentView = UILabel(frame: CGRect(x: finalX, y: finalY, width: finalWidth, height: finalHeight))
            saysContentView.numberOfLines = 0
            saysContentView.lineBreakMode = NSLineBreakMode.byCharWrapping
            saysContentView.text = self.cellData.saysWhat

            self.addSubview(saysContentView)
        }
        
        // 对话气泡背景
        /*
        if self.cellData.bubbleImage != "" {
            let bubbleImageName = self.cellData.bubbleImage
            let bubbleImage = UIImage(named: bubbleImageName)
            var bubbleImageStreched:UIImage
            if whoSays == .robot{
                bubbleImageStreched = bubbleImage!.stretchableImage(withLeftCapWidth: 21, topCapHeight: 14) //图片左右中间的拉伸位置，和上下中间的拉伸位置
            } else {
                bubbleImageStreched = bubbleImage!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14)
            }
            self.bubbleImageView.image = bubbleImageStreched
            
            self.bubbleImageView.frame = CGRect(x: finalX, y: finalY, width: finalWidth, height: finalHeight)
            
            self.addSubview(self.bubbleImageView)
        }
        */
        
        
        
    }
}
