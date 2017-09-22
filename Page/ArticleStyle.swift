//
//  ArticleStyle.swift
//  Page
//
//  Created by 倪卫国 on 09/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

struct Styles {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter
    }
//    static let paragraphIndent: CGFloat = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).pointSize
    static let paragraphIndent: CGFloat = 0
}

    /*
extension NSMutableAttributedString {

    func addParagraphAttributes(textStyle style: UIFontTextStyle? = nil) {
        var attributes: [String: Any] = [:]
        var lineHeight: CGFloat = 20.0
        
        // If you set font attributes here, get the lineHeight infor directly
        // Otherwise extract the font info.
        if let textStyle = style {
            let font = UIFont.preferredFont(forTextStyle: textStyle)
            lineHeight = font.lineHeight
            attributes[NSAttributedStringKey.font] = UIFont.preferredFont(forTextStyle: textStyle)
        } else {
            let existingAttributes = self.attributes(at: 0, effectiveRange: nil)
            if let font = existingAttributes[NSAttributedStringKey.font] as? UIFont {
                lineHeight = font.lineHeight
            }
        }
        // If the above operation failed, use default line height 20.0
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = Styles.paragraphIndent
        paragraphStyle.headIndent = Styles.paragraphIndent
        paragraphStyle.tailIndent = -Styles.paragraphIndent
        
        paragraphStyle.lineSpacing = lineHeight * 0.5
        paragraphStyle.paragraphSpacing = lineHeight * 0.5
        
        attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        
        let range = NSMakeRange(0, self.length)
        addAttributes(attributes, range: range)
    }
    
    func appendParagraphSeparator() {
        append(NSAttributedString(string: "\n"))
    }
}
*/

/*
extension String {
    
    func toAttributedString(textStyle style: UIFontTextStyle = UIFontTextStyle.body, oblique: Bool = false, bold: Bool = false, color: String = "#333", withLink link: String? = nil) -> NSMutableAttributedString {
        
        var attributes: [String: Any] = [:]
        var font = UIFont.preferredFont(forTextStyle: style)
        
        if bold {
            font = font.bold()
        }
        
        attributes[NSAttributedStringKey.font] = font
        attributes[NSAttributedStringKey.foregroundColor] = UIColor(hex: color)        
        
        if oblique {
            attributes[NSAttributedStringKey.obliqueness] = 0.2
        }
        
        if let href = link, let url = NSURL(string: href) {
            attributes = [NSAttributedStringKey.link.rawValue: url]
        }
        
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
    
    func toAttributedImage(width: CGFloat? = nil) -> NSMutableAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "414x232.png")
        
        if let imageWidth = width {
            let imageHeight = imageWidth * 0.5625
            imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        }
        
//        Alamofire.request(self).response { response -> Void in
//            if let data = response.data {
//                print("image downloaded")
//                imageAttachment.image = UIImage(data: data)
//            }
//        }
        
        return NSMutableAttributedString(attributedString: NSAttributedString(attachment: imageAttachment))
    }
}
*/
