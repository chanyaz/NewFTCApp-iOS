//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class BigImageCell: CustomCell {
    
    // MARK: - Style settings for this class
    let imageWidth = 408   // 16 * 52
    let imageHeight = 234  // 9 * 52
    
    
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headlineLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headlineTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var soundButton: UIButton!
    
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var loveCount: UILabel!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentCount: UILabel!
    
    @IBOutlet weak var imageBorder: UIView!
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    override func updateUI() {
        
        // MARK: - Set Top Border Color
        if let row = itemCell?.row,
            row > 0,
            itemCell?.hideTopBorder != true {
            topBorder.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            // MARK: - set first item's border color to transparent
            topBorder.backgroundColor = nil
        }
        
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
        headline.font = headline.font.bold()
        
        lead.textColor = UIColor(hex: Color.Content.lead)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        
        // MARK: sound Button, love buttons and other FTCC buttons
        if let themeColorString = self.themeColor {
            let themeColor = UIColor(hex: themeColorString, alpha: 0.7)
            soundButton.layer.backgroundColor = themeColor.cgColor
            soundButton.layer.cornerRadius = 17.5
        }
        if let themeColorString = self.themeColor {
            let themeColor = UIColor(hex: themeColorString)
            // MARK: border for the image bottom
            imageBorder.backgroundColor = themeColor
            tagButton.backgroundColor = themeColor
            tagButton.setTitleColor(UIColor.white, for: .normal)
            tagButton.contentEdgeInsets = UIEdgeInsetsMake(5,15,5,15)
            
            // MARK: get item tag
            if let firstTag = itemCell?.tag.getFirstTag(Meta.reservedTags) {
                tagButton.setTitle(firstTag, for: .normal)
            } else {
                tagButton.isHidden = true
            }
        }
        lead.font = UIFont(name: "Helvetica-Light", size: 16.0)
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        //let headlineActualWidth: CGFloat?
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
        
        
        // MARK: - Update dispay of the cell
        let headlineString = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        //        let headlineString: String?
        //        headlineString = "南五环边上学梦：北京首所打工子弟"
        headline.text = headlineString
        
        // MARK: - Prevent widows in the second line
        //        if let headlineActualWidth = headlineActualWidth {
        //        if headline.hasWidowInSecondLine(headlineActualWidth) == true {
        //            headline.numberOfLines = 1
        //        }
        //        }
        
        
        if let leadText = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.4
            paragraphStyle.lineBreakMode = .byTruncatingTail
            let setStr = NSMutableAttributedString.init(string: leadText)
            setStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, (leadText.characters.count)))
            lead.attributedText = setStr
        }
        
        
        
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        if let loadedImage = itemCell?.coverImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type:"cover", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.coverImage
            })
            //print ("should load image here")
        }
        
        
    }
    
    @IBAction func tapSoundButton(_ sender: Any) {
   
//        if let rootViewController = window?.rootViewController as? UITabBarController {
//            rootViewController.showAudioPlayer()
//        }
        
        if let itemCell = itemCell,let audioFileUrl = itemCell.audioFileUrl {
            TabBarAudioContent.sharedInstance.body["title"] = itemCell.headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(itemCell.id)"
//            AudioContent.sharedInstance.body["title"] = itemCell.headline
//            AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
//            AudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(itemCell.id)"
            TabBarAudioContent.sharedInstance.item = itemCell
            TabBarAudioContent.sharedInstance.audioHeadLine = itemCell.headline
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
    
        print("TabBarAudioContent.sharedInstance.body\(TabBarAudioContent.sharedInstance.body)")
        
    }
    
    @IBAction func tapTagButton(_ sender: UIButton) {
        if let tag = sender.currentTitle {
            if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
                let tagAPI = APIs.get(tag, type: "tag")
                
                dataViewController.dataObject = ["title": tag,
                                                 "api": tagAPI,
                                                 "url":"",
                                                 "screenName":"tag/\(tag)"]
                dataViewController.pageTitle = tag
                if let topViewController = UIApplication.topViewController() {
                    topViewController.navigationController?.pushViewController(dataViewController, animated: true)
                }
            }
        }
    }
    var isLove:Bool = false
    @IBAction func tapLoveButton(_ sender: UIButton) {
        if !isLove{
            loveButton.setImage(UIImage(named:"LoveActive"), for: UIControlState.normal)
            isLove = true
        }else{
            loveButton.setImage(UIImage(named:"Love"), for: UIControlState.normal)
            isLove = false
        }
        
    }
    var isComment:Bool = false
    @IBAction func tapCommentButton(_ sender: UIButton) {
        if !isComment{
            commentButton.setImage(UIImage(named:"CommentActiveCount"), for: UIControlState.normal)
            isComment = true
        }else{
            commentButton.setImage(UIImage(named:"CommentCount"), for: UIControlState.normal)
            isComment = false
        }
        
    }
    
}
