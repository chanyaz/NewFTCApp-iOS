//
//  TalkRequest.swift
//  Page
//
//  Created by niweiguo on 10/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation


func createTalkRequest () {
    
    print("Execute createTalkRequest")
    
    let bodyString = "{\"query\":\"你喜欢夏天还是冬天?\",\"messageType\":\"text\"}"
    let urlString = "https://sai-pilot.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15-Int"
    
    let appIdField = "x-msxiaoice-request-app-id"
    let appId = "XI36GDstzRkCzD18Fh"
    let secret = "5c3c48acd5434663897109d18a2f62c5"


    let timestampField = "x-msxiaoice-request-timestamp"
    let timestamp = Int(Date().timeIntervalSince1970)//生成时间戳
    print("timestamp:\(timestamp)")
    
    let userIdField = "x-msxiaoice-request-user-id"
    let userId = "e10adc3949ba59abbe56e057f20f883e"
    
    let signatureField = "x-msxiaoice-request-signature"
    print("signatureField:\(signatureField)")
    let signature = computeSignature(verb: "post", path: "/api/Conversation/GetResponse", paramList: ["api-version=2017-06-15-Int"], headerList: ["\(appIdField):\(appId)","\(userIdField):\(userId)"], body: bodyString, timestamp: timestamp, secretKey: secret)
    
    print("signature:\(signature)")
    
    if let url = URL(string: urlString),
        let body = bodyString.data(using: .utf8)
        { // 将String转化为Data
        var talkRequest = URLRequest(url:url)
        talkRequest.httpMethod = "POST"
        talkRequest.httpBody = body
        talkRequest.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        talkRequest.setValue(appId, forHTTPHeaderField: appIdField)
        talkRequest.setValue(String(timestamp), forHTTPHeaderField: timestampField)
        talkRequest.setValue(signature, forHTTPHeaderField: signatureField)
        talkRequest.setValue(userId, forHTTPHeaderField: userIdField)
            
        let talkRequestContentLengthValue = talkRequest.value(forHTTPHeaderField: "Content-Length") ?? ""
        let talkRequestUserIdValue = talkRequest.value(forHTTPHeaderField: userIdField) ?? ""
        print("talkRequest' userIdField value:\(talkRequestUserIdValue)")
        print("talkRequest' ContentLengthField value:\(talkRequestContentLengthValue)")
            
        (URLSession.shared.dataTask(with: talkRequest) {
            (data,response,error) in
            /*
                if let response = response,
                    let data = data,
                    let string = String(data: data, encoding: .utf8) {
                    print("Response:\(response)")
                    print("DATA:\n\(string) \n End DATA \n")
                    
                } else if let error = error {
                    print("Error:\(error)")
                }
            */
            if error != nil {
                /* wycNOTE:
                 * guard语句的执行取决于一个表达式的布尔值。可以使用guard语句来要求条件必须为真时，以执行guard语句后面的代码。不同于if语句，一个guard语句总是有一个else从句，条件不为真则执行else从句中的代码
                 */
                print("Error:(error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Status code is not 200. It is \(httpStatus.statusCode)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8){
                print("Overview Data:\(dataString)")
                createResponseCellData(data: data)
            }
            
        }).resume()
        
    }
   }
func createResponseCellData(data:Data) {
    do {
        let jsonAny = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        if let jsonDictionary = jsonAny as? NSDictionary,let answer = jsonDictionary["Answer"],let answerArray = answer as? NSArray {
            let oneAnswer = answerArray[0]
            
            if let oneAnswerDic = oneAnswer as? NSDictionary,
                let type = oneAnswerDic["Type"], let typeStr = type as? String {
               
                print(typeStr)
                
                switch typeStr {
                    case "Text":
                        if let content = oneAnswerDic["Content"], let contentStr = content as? String {
                            /*
                            let robotSaysWhat = SaysWhat(saysType: .text, saysContent: contentStr)
                            let robotCellData = CellData(whoSays: .robot, saysWhat: robotSaysWhat)
                            */
                            //ChatView.talkData.append(robotCellData)
                            print(contentStr)
                        }
                    
                    case "Image":
                        print("This is a Image")
                    case "Card":
                        print("This is a Card")
                    default:
                        print("An unknow type response data.")
                }
                
                
                
            }
          
        }
        
        
    } catch {
        
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
