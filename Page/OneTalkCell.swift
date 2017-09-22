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
        buildTheCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapClick(_ sender:UIView){
        //NOTE:通过openLink方法对cardUrl进行判断，如果是站内文章，就打开app内文章；如果是站外文章，就在app内打开浏览器
        if let openUrl = URL(string:self.cardUrl) {
            if let topController = UIApplication.topViewController() {
                topController.openLink(openUrl)
            }
        }
        //print("Click card")
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
        
        
        // 根据对话内容长短及self.frame尺寸得到相关位置尺寸,更新self.cellData
        //let headImageWithInsets = self.cellData.cellInsets.left + self.cellData.headImageLength + self.cellData.betweenHeadAndBubble //60
        let bubbleImageX = (whoSays == .robot) ? self.cellData.headImageWithInsets : self.frame.width - self.cellData.headImageWithInsets - self.cellData.bubbleImageWidth
        let bubbleImageY = self.frame.minY + self.cellData.bubbleInsets.top
        
        let saysWhatX = bubbleImageX + self.cellData.bubbleImageInsets.left
        let saysWhatY = bubbleImageY + self.cellData.bubbleImageInsets.top
       
        
        // 显示对话气泡背景
        if self.cellData.bubbleImage != "" {
            let bubbleImageName = self.cellData.bubbleImage
            let bubbleImage = UIImage(named: bubbleImageName)

            
            if let realBubbleImage = bubbleImage {
                let bubbleImageStreched = realBubbleImage.resizableImage(withCapInsets: self.cellData.bubbleStrechInsets, resizingMode: UIImageResizingMode.stretch)//该方式可实现部分拉伸
                
                self.bubbleImageView = UIImageView(image: bubbleImageStreched)
                self.bubbleImageView.frame = CGRect(x: bubbleImageX, y: bubbleImageY, width: self.cellData.bubbleImageWidth, height: self.cellData.bubbleImageHeight) // NOTE:任何一个View都要先初始化再设置属性
                self.addSubview(self.bubbleImageView)
  

            }
            
        }
        
        
        // 显示对话内容 // NOTE:内容在bubble上方才能不被bubble遮挡
        if self.cellData.saysType == .text {
            let saysContentView = UILabel(frame: CGRect(x: saysWhatX, y: saysWhatY, width: self.cellData.saysWhatWidth, height: self.cellData.saysWhatHeight))
            saysContentView.numberOfLines = 0
            saysContentView.lineBreakMode = NSLineBreakMode.byWordWrapping
            saysContentView.text = self.cellData.saysWhat.content
            saysContentView.font = self.cellData.normalFont
            saysContentView.textColor = self.cellData.textColor
             //saysContentView.backgroundColor = UIColor.green
            self.addSubview(saysContentView)
            
            
        } else if self.cellData.saysType == .image {
            
           self.saysImageView.frame = CGRect(x: saysWhatX, y: saysWhatY, width: self.cellData.defaultImageWidth, height: self.cellData.defaultImageHeight)
            //saysContentView.image = self.cellData.saysImage
          self.saysImageView.backgroundColor = UIColor(hex: "#f7e9d8")
          self.saysImageView.contentMode = .scaleToFill
                   self.addSubview(self.saysImageView)
            
            
        } else if self.cellData.saysType == .card {
            
            
            let coverY = saysWhatY + self.cellData.titleHeight
            let descriptionY = coverY + self.cellData.coverHeight
            
            //titleView:
            let titleView = UILabel(frame: CGRect(x: saysWhatX, y: saysWhatY, width: self.cellData.titleWidth, height: self.cellData.titleHeight))
            titleView.numberOfLines = 0
            titleView.lineBreakMode = NSLineBreakMode.byWordWrapping
            titleView.text = self.cellData.saysWhat.title
            titleView.font = self.cellData.titleFont
            titleView.textColor = self.cellData.textColor
            self.addSubview(titleView)
            
            //coverView:
            self.coverView = UIImageView(frame: CGRect(x:saysWhatX, y:coverY,width:self.cellData.coverWidth,height:self.cellData.coverHeight))
            coverView.backgroundColor = UIColor(hex: "#f7e9d8")

            coverView.contentMode = .scaleToFill
            self.addSubview(coverView)
            print("Execut 1st")
            
            //descriptionView:
            if(self.cellData.saysWhat.description != "") {
                let descriptionView = UILabel(frame: CGRect(x: saysWhatX, y: descriptionY, width: self.cellData.descriptionWidth, height: self.cellData.descriptionHeight))
                descriptionView.numberOfLines = 0
                descriptionView.lineBreakMode = NSLineBreakMode.byWordWrapping
                descriptionView.text = self.cellData.saysWhat.description
                descriptionView.font = self.cellData.descriptionFont
                //descriptionView.backgroundColor = UIColor.green
                descriptionView.textColor = self.cellData.textColor
                self.addSubview(descriptionView)
            }
            
            
            self.bubbleImageView.isUserInteractionEnabled = true//打开用户交互属性
            self.cardUrl = self.cellData.saysWhat.url
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapClick))
            self.bubbleImageView.addGestureRecognizer(tap)
            
        }
    }
}
