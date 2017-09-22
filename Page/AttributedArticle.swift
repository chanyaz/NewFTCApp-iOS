//
//  AttributedArticle.swift
//  Page
//
//  Created by 倪卫国 on 09/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

enum Language {
    case chinese
    case english
}

/*
struct AttributedArticle {
    
    let content: ContentItem
    let contentWidth: CGFloat
    var lineWidth: CGFloat {
        return contentWidth - Styles.paragraphIndent * 2
    }
    
    init(content: ContentItem, contentWidth: CGFloat) {
        self.content = content
        self.contentWidth = contentWidth
    }
    
    var chinese: NSAttributedString {
        let article = NSMutableAttributedString()
        article.append(headline)
        article.append(lead)
        article.append(cover)
        article.append(byline)
        article.append(chineseBody)
        return article
    }
    
    var english: NSAttributedString {
        let article = NSMutableAttributedString()
        article.append(headline)
        article.append(lead)
        article.append(cover)
        article.append(byline)
        article.append(englishBody)
        return article
    }
    
    var bilingual: NSAttributedString {
        let article = NSMutableAttributedString()
        article.append(headline)
        article.append(lead)
        article.append(cover)
        article.append(byline)
        article.append(bilingualBody)
        return article
    }
    
    var bilingualBody: NSAttributedString {
        let attributedBody = NSMutableAttributedString()
        let cnBodyArray = convertBody(forLanguage: .chinese, keepImage: false)
        let enBodyArray = convertBody(forLanguage: .english, keepImage: false)
        
        for (cn, en) in zip(cnBodyArray, enBodyArray) {
            attributedBody.append(cn)
            attributedBody.append(en)
        }
        
        let cnCount = cnBodyArray.count
        let enCount = enBodyArray.count
        let minCount = min(cnCount, enCount)
        
        if cnCount > minCount {
            for index in minCount..<cnCount {
                attributedBody.append(cnBodyArray[index])
            }
        }
        
        if enCount > minCount {
            for index in minCount..<enCount {
                attributedBody.append(enBodyArray[index])
            }
        }
        
        return attributedBody
    }
    
    var chineseBody: NSAttributedString {
        let attributedBody = NSMutableAttributedString()
        let bodyArray = convertBody(forLanguage: .chinese)
        for paragraph in bodyArray {
            attributedBody.append(paragraph)
        }
        return attributedBody
    }
    
    var englishBody: NSAttributedString {
        let attributedBody = NSMutableAttributedString()
        let bodyArray = convertBody(forLanguage: .english)
        for paragraph in bodyArray {
            attributedBody.append(paragraph)
        }
        return attributedBody
    }
    
    var headline: NSAttributedString {
        
        let mutableAttrString = content.headline.toAttributedString(
            textStyle: UIFontTextStyle.title1, bold: true)
        mutableAttrString.addParagraphAttributes()
        mutableAttrString.appendParagraphSeparator()
        
        return mutableAttrString
    }
    
    var lead: NSAttributedString {
        
        let mutableAttrString = content.lead.toAttributedString(
            textStyle: UIFontTextStyle.subheadline, color: "#777")
        mutableAttrString.addParagraphAttributes()
        mutableAttrString.appendParagraphSeparator()
        
        return mutableAttrString
    }
    
    var cover: NSAttributedString {

        let mutableAttrString = content.image.toAttributedImage(width: lineWidth)
        mutableAttrString.addParagraphAttributes()
        mutableAttrString.appendParagraphSeparator()
        
        return mutableAttrString
    }
    
    var byline: NSAttributedString {
        let mutableAttrString = NSMutableAttributedString()
        
        let interval = Double(content.timeStamp)
        let date = Date(timeIntervalSince1970: interval)
        let dateString = Styles.dateFormatter.string(from: date)
        let attrDateString = "更新于\(dateString) ".toAttributedString(color: "#8b572a")
        mutableAttrString.append(attrDateString)
        
//        if let organization = json["cbyline_description"].string {
//            mutableAttrString.append("\(organization) ".toAttributedString())
//        }
        
        // zip author and location
//        let authors = (json["cauthor"].string ?? "").components(separatedBy: ",")
//        var locations = (json["cbyline_status"].string ?? "").components(separatedBy: ",")
        
        let authors = (content.cauthor ?? "").components(separatedBy: ",")
        var locations = (content.locations ?? "").components(separatedBy: ",")
        let count = authors.count
        
        if locations.count < count {
            for _ in locations.count..<count {
                locations.insert("", at: 0)
            }
        }
        
        for (index, pair) in zip(authors, locations).enumerated() {
            let author = pair.0
            let location = pair.1
            
            mutableAttrString.append("\(author) ".toAttributedString(color: "#9e2f50"))
            mutableAttrString.append(location.toAttributedString())
            
            if index != count-1 {
                mutableAttrString.append(", ".toAttributedString())
            }
        }
        
        mutableAttrString.addParagraphAttributes(textStyle: UIFontTextStyle.caption1)
        mutableAttrString.appendParagraphSeparator()
        
        return mutableAttrString
    }
    
    func convertBody(forLanguage language: Language, keepImage: Bool = true) -> [NSAttributedString] {
        
        var body: String
        
        switch language {
        case .chinese:
            body = content.cbody ?? ""
            
        case .english:
            body = content.ebody ?? ""
        }
        
        if body.isEmpty {
            return [NSAttributedString()]
        }
        
        var attributedBodyArray = [NSMutableAttributedString]()
        let range = body.startIndex..<body.endIndex
        
        // Enuerate each paragraph inside body
        body.enumerateSubstrings(in: range, options: .byParagraphs) {
            (substring, _, _, _) in
            guard let paragraph = substring else {
                return
            }
            
            let attributedParagraph = NSMutableAttributedString()
            
            // Scan current paragraph and parse it into an array of `Tag`
            let scanner = Scanner(string: paragraph)
            let tags = scanner.parseHtml()
            
            // Loop over tags and covert each tag to attributed string according to the tag's name
            for tag in tags {
                attributedParagraph.append(self.convertTag(tag, keepImage: keepImage))
            }
            attributedParagraph.addParagraphAttributes()
            attributedParagraph.appendParagraphSeparator()
            attributedBodyArray.append(attributedParagraph)
        }
        return attributedBodyArray
    }
    
    private func convertTag(_ tag: Tag, keepImage: Bool) -> NSAttributedString {
        var attrString: NSAttributedString = NSAttributedString()
        
        switch tag.name {
        case "i":
            if let text = tag.text {
                attrString = text.toAttributedString(oblique: true)
            }
            
        case "b":
            if let text = tag.text {
                attrString = text.toAttributedString(bold: true)
            }
            
        case "a":
            if let text = tag.text {
                // If `attributes` does not exit, href = nil
                //if `attributes` exits but `attributes["href"]` does not exit, href = nil
                attrString = text.toAttributedString(withLink: tag.attributes?["href"])
            }
            
        case "img":
            if !keepImage {
                break
            }
            if let attributes = tag.attributes, let src = attributes["src"] {
                attrString = src.toAttributedImage(width: lineWidth)
            }
            
        default:
            if let text = tag.text {
                attrString = text.toAttributedString()
            }
        }
        
        return attrString
    }
}
*/
