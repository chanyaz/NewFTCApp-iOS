//
//  TalkRequest.swift
//  Page
//
//  Created by wangyichen on 10/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation



func createResponseCellData(data:Data) -> CellData? {
    var robotSaysWhat = SaysWhat()
    var robotCellData:CellData? = nil
    do {
        let jsonAny = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        if let jsonDictionary = jsonAny as? NSDictionary,let answer = jsonDictionary["Answer"],let answerArray = answer as? NSArray {
            let oneAnswer = answerArray[0]
            
            if let oneAnswerDic = oneAnswer as? NSDictionary,
                let type = oneAnswerDic["Type"], let typeStr = type as? String {
                
                print(typeStr)
                switch typeStr {
                case "Text":
                    if let content = oneAnswerDic["Content"]{
                        
                        let contentStr = content as? String
                        robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                       
                        
                    } else {
                        let contentStr = "This is a Text, the data miss some important fields."
                        robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                    }
                    
                case "Image":
                    if let url = oneAnswerDic["Url"] {
                         let urlStr = url as? String
                        robotSaysWhat = SaysWhat(saysType: .image, saysImage:urlStr)
                        
                        print("This is a Image")
                    } else {
                        let contentStr = "This is a Image, the data miss some important fields."
                        robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                    }
                    
                case "Card":
                    print("This is a Card")
                    
                    if let title = oneAnswerDic["Title"],
                        let description = oneAnswerDic["Description"],
                        let coverUrl = oneAnswerDic["CoverUrl"],
                        let cardUrl = oneAnswerDic["Url"] {
                        
                        let titleStr = title as? String
                        let cardUrlStr = cardUrl as? String
                        let coverUrlStr = coverUrl as? String
                        let descriptionStr = description as? String
                        robotSaysWhat = SaysWhat(saysType: .card, saysTitle: titleStr, saysDescription: descriptionStr, saysCover: coverUrlStr, saysUrl: cardUrlStr)
                        
                    } else {
                        let contentStr = "This is a Card, the data miss some important fields."
                        robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                        
                    }
                    
                    
                default:
                    print("An unknow type response data.")
                    let contentStr = "An unknow type response data."
                    robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                }
                
            } else {
                let contentStr = "There is some Error on parsing data Step2"
                robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
            }
            
        } else {
            let contentStr = "There is some Error on parsing data Step1"
            robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
        }
        robotCellData = CellData(whoSays: .robot, saysWhat: robotSaysWhat)
        return robotCellData
        
    } catch {
        return nil
    }
    
    
}

func computeSignature(verb:String, path:String, paramList:[String], headerList:[String],body:String,timestamp:Int,secretKey:String) -> String {
    print("Execute computeSignature")
    
    let verbStr = verb.lowercased()
    print("verbStr:\(verbStr)")
    
    let pathStr = path.lowercased()
    print("pathStr:\(pathStr)")
    
    let paramListStr = paramList.sorted().joined(separator: "&")
    print("paramListStr:\(paramListStr)")
    
    var headerListNew = Array(repeating: "", count: headerList.count)
    for (index,value) in headerList.enumerated() {
        headerListNew[index] = value.lowercased()
    }
    print("headerListNew:\(headerListNew)")
    
    let headerListStr = headerListNew.sorted().joined(separator: ",")
    //base64EncodedString()
    let bodyStr = body
    
    let secretKeyStr = secretKey
    print("secretKeyStr:\(secretKeyStr)")
    
    let messageStr = "\(verbStr);\(pathStr);\(paramListStr);\(headerListStr);\(bodyStr);\(timestamp);\(secretKeyStr)"
    
    print("messageStr:\(messageStr)")
    
    let signature = messageStr.HmacSHA1(key: secretKeyStr)
    return signature
}

extension String {
    
    /// HmacSHA1 Encrypt
    ///
    /// -Parameter key: secret key
    ///
    func HmacSHA1(key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        if let realCKey = cKey, let realCData = cData {
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), realCKey, Int(strlen(realCKey)), realCData, Int(strlen(realCData)), &result)
            let hmacData:NSData = NSData(bytes: result, length: (Int(CC_SHA1_DIGEST_LENGTH)))
            let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
            return String(hmacBase64)
        } else {
            return ""
        }
        
        
    }
}



