//
//  TalkRequest.swift
//  Page
//
//  Created by wangyichen on 10/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation



func createResponseCellData(data:Data) -> CellData? {
    do {
        var robotCellData:CellData? = nil
        let jsonAny = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        if let jsonDictionary = jsonAny as? NSDictionary,let answer = jsonDictionary["Answer"],let answerArray = answer as? NSArray {
            let oneAnswer = answerArray[0]
            
            if let oneAnswerDic = oneAnswer as? NSDictionary,
                let type = oneAnswerDic["Type"], let typeStr = type as? String {
               
                print(typeStr)
                
                switch typeStr {
                    case "Text":
                        if let content = oneAnswerDic["Content"], let contentStr = content as? String {
                            
                            let robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                            robotCellData = CellData(whoSays: .robot, saysWhat: robotSaysWhat)
                            
                            
                            print(contentStr)
                            
                        }
                    
                    case "Image":
                        if let url = oneAnswerDic["Url"], let urlStr = url as? String {
                           
                            let robotSaysWhat = SaysWhat(saysType: .image, saysImage:urlStr)
                            robotCellData = CellData(whoSays: .robot, saysWhat:robotSaysWhat)
                          
                            print("This is a Image")
                            print(urlStr)
                        }
                    
                    case "Card":
                        print("This is a Card")
                    
                    default:
                        print("An unknow type response data.")
                }
                
            }
          
        }
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
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        let hmacData:NSData = NSData(bytes: result, length: (Int(CC_SHA1_DIGEST_LENGTH)))
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return String(hmacBase64)
    }
}
