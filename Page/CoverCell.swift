//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class CoverCell: UICollectionViewCell {
    
    // MARK: - Style settings for this class
    let imageWidth = 408   // 16 * 52
    let imageHeight = 234  // 9 * 52
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headlineLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headlineTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    func updateUI() {
        

        
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        headline.textColor = UIColor(hex: AppNavigation.sharedInstance.headlineColor)
        headline.font = headline.font.bold()
        
        lead.textColor = UIColor(hex: AppNavigation.sharedInstance.leadColor)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        
        
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        let headlineActualWidth: CGFloat?
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
            let headlineLeading = headlineLeadingConstraint.constant
            let headlineTrailing = headlineTrailingConstraint.constant
            headlineActualWidth = containerWidth - headlineLeading - headlineTrailing
        } else {
            headlineActualWidth = nil
        }
        
        
        // MARK: - Update dispay of the cell
        let headlineString = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
//        let headlineString: String?
//        headlineString = "南五环边上学梦：北京首所打工子弟"
        headline.text = headlineString
        
        // MARK: - Prevent widows in the second line
        if let headlineActualWidth = headlineActualWidth {
        if headline.hasWidowInSecondLine(headlineActualWidth) == true {
            headline.numberOfLines = 1
        }
        }
        
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        if let loadedImage = itemCell?.largeImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadLargeImage(width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.largeImage
            })
            //print ("should load image here")
        }
        

        
    }
    
}

extension UILabel {
    func hasWidowInSecondLine(_ labelActuralWidth: CGFloat) -> Bool {
        guard let text = self.text else { return false }
        guard let font = self.font else { return false }
        //let rect = self.frame
        let rect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: labelActuralWidth, height: self.frame.height)
        
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(String(kCTFontAttributeName), value: CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil), range: NSMakeRange(0, attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        guard let line = (CTFrameGetLines(frame) as! [CTLine]).first else { return false }
        let lineString = text[text.startIndex...text.index(text.startIndex, offsetBy: CTLineGetStringRange(line).length-2)]
        let firstLineLenth = lineString.characters.count
        let textLength = text.characters.count
        if (textLength - firstLineLenth) <= 2 {
            return true
        }
        return false
    }

}
