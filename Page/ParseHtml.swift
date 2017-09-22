//
//  ParseHtml.swift
//  Page
//
//  Created by 倪卫国 on 09/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.

// MARK: - Commented out as there are imcopatibility issues in SWIFT 4
/*
import Foundation

struct Tag {
    static let noName: String = "anonymous"
    var name: String = Tag.noName
    var attributes: [String: String]?
    var text: String?
    
    // `Tag` is usually created when the scanner encounters an opening tag.
    // When opening tag is detected without attributes
    // `text` might be added in the next loop when corresponding closing tag detected.
    init(name: String) {
        self.name = name
    }
    
    // For opening tags with attributes
    init(name: String, attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }
    
    // For text outside of any tag
    // This initializer is called in three places
    // 1. Only closing tag is encountered (indicating wrong HTML markup, thus discard the tag)
    // 2. Scanned anything before the opening tag (indicating the text is outside of any inline tag)
    // 3. Scanned to the end of the string whithout encountering any `<` (indicating this string has no markup)
    init(text: String) {
        self.name = Tag.noName
        self.text = text
    }
}

extension Scanner {
    private func nextStep() {
        if isAtEnd {
            print("Scanner reached the end of string. Stop")
            return
        }
        let current = scanLocation
        
        scanLocation = current + 1
        print("Forward one step to \(scanLocation)")
    }
    
    func parseHtml() -> [Tag] {
        var tags = [Tag]()
        scanLocation = 0
        
        while (!isAtEnd) {
            // every loop starts with empty varaibles
            var textOutsideBracket: NSString?
            var textInBracket: NSString?
            
            scanUpTo("<", into: &textOutsideBracket)
            print("Scanned content up to `<`")
            
            // If scanner reached the end of string, and no `<` is found
            // Stop the loop and put `text` in `anonumous` tag
            if isAtEnd, let text = textOutsideBracket?.trimmingCharacters(in: .whitespaces) {
                print("No more tags found. Break")
                let tag = Tag(text: text)
                tags.append(tag)
                break
            }
            
            // add one step to prevent inifinite loop
            nextStep()
            
            
            scanUpTo(">", into: &textInBracket)
            print("Scanned content inside `<...>`")
            
            if let tagContent = textInBracket?.trimmingCharacters(in: .whitespaces) {
                // If this is a closing tag
                if tagContent.hasPrefix("/") {
                    // extract the tagName
                    let tagName = tagContent.substring(from: tagContent.index(after: tagContent.startIndex)).trimmingCharacters(in: .whitespaces)
                    print("Closing tag: \(tagName)")
                    
                    // If in the previous scanning process something were put into `textOutsideBracket`
                    if let text = textOutsideBracket?.trimmingCharacters(in: .whitespaces) {
                        // Ensure this closing tag matches the opening tag scanned in the last loop
                        if tags.last?.name == tagName {
                            // If the closnig tag matches the last scanned opening tag, add the scanned text.
                            // Not you cannot use `tags.last` here. `tags.last` is a copied value while `tags[index]` is a reference.
                            tags[tags.count - 1].text = text
                        } else {
                            // If the closing tag does not matches the last scanned opeing tag, generate a new anonymous Tag with `text`, although this shoudl not happen as it indicates the HTML is written in a wrong way.
                            // In such cases the tagName is discarded as we do not know what's the purpose of only having a closing HTML tag.
                            let tag = Tag(text: text)
                            tags.append(tag)
                        }
                    }
                } else {
                    // It is assumed to be an opening tag without `/` prefix.
                    if let text = textOutsideBracket?.trimmingCharacters(in: .whitespaces) {
                        // `text` before opening tag is assumed not enclosed in any tag (here we ignore the parent tree and make everything flat), put in an `anonymous` tag
                        let tag = Tag(text: text)
                        tags.append(tag)
                    }
                    
                    // Begin to analyse strings inside `<...>`, excluding the bracket
                    // Spit them by a space. Filter out multiple whitespace.
                    let tagContentArray = tagContent.components(separatedBy: " ").filter { !$0.isEmpty}
                    
                    // If the array length is larger than 1, Array[0] should be the tage name.
                    // The tag's attributes start from Array[1] onward.
                    if tagContentArray.count >= 1 {
                        let tagName = tagContentArray[0]
                        print("Opening tag: \(tagName)")
                        
                        // Collect the attributes into a dictionary
                        var tagAttributes = [String: String]()
                        
                        for index in 1..<tagContentArray.count {
                            let pair = tagContentArray[index].components(separatedBy: "=")
                            print("Attribute pair: \(pair)")
                            let key = pair[0]
                            var value: String
                            if pair.count > 1 {
                                value = pair[1].trimmingCharacters(in: ["\"", "'"])
                            } else {
                                value = "true"
                            }
                            tagAttributes[key] = value
                        }
                        
                        // In the next loop, if closing tag detected and scanned some text, `text` property is modified.
                        if tagAttributes.isEmpty {
                            // If this tag does not have attributes
                            let tag = Tag(name: tagName)
                            tags.append(tag)
                        } else {
                            // If this tag has attributes
                            let tag = Tag(name: tagName, attributes: tagAttributes)
                            tags.append(tag)
                        }
                    }
                    
                }
            }
            
            nextStep()
            
            print("============")
        }
        
        return tags
    }
}
*/
