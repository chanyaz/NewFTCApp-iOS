//
//  CoverCellRegular.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/23.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class CoverCellRegular: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!


    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    func updateUI() {

        

    
    }
}

//extension UILabel {
//    func hasWidowInSecondLine(_ labelActuralWidth: CGFloat) -> Bool {
//        guard let text = self.text else { return false }
//        guard let font = self.font else { return false }
//        //let rect = self.frame
//        let rect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: labelActuralWidth, height: self.frame.height)
//        
//        let attStr = NSMutableAttributedString(string: text)
//        attStr.addAttribute(String(kCTFontAttributeName), value: CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil), range: NSMakeRange(0, attStr.length))
//        
//        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
//        let path = CGMutablePath()
//        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100))
//        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
//        
//        guard let line = (CTFrameGetLines(frame) as! [CTLine]).first else { return false }
//        let lineString = text[text.startIndex...text.index(text.startIndex, offsetBy: CTLineGetStringRange(line).length-2)]
//        let firstLineLenth = lineString.characters.count
//        let textLength = text.characters.count
//        if (textLength - firstLineLenth) <= 2 {
//            return true
//        }
//        return false
//    }
//    
//}
