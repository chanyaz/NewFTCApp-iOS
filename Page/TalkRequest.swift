//
//  TalkRequest.swift
//  Page
//
//  Created by niweiguo on 10/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation
import Security
typealias CompletionHandler = () -> Void

class MySessionDelegate: URLSessionStreamTask, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var completionHandlers: [String: CompletionHandler] = [:]
}

func createTalkRequest () {
    /*
    let defaultConfiguration = URLSessionConfiguration.default
    let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let cacheURL = cachesDirectoryURL.appendingPathComponent("MyCache")
    let diskPath = cacheURL.path
    let cache = URLCache(memoryCapacity: 16384, diskCapacity: 268435456, diskPath: diskPath)
    defaultConfiguration.urlCache = cache
    defaultConfiguration.requestCachePolicy = .useProtocolCachePolicy
    
    
    let delegate = MySessionDelegate()
    let operationQueue = OperationQueue.main
    
    
    let defaultSession = URLSession(configuration: defaultConfiguration, delegate: delegate, delegateQueue: operationQueue)
    */
    
    
    //let sessionWithoutADelegate = URLSession(configuration: defaultConfiguration)
    print("Execute createTalkRequest")
    
    let bodyString = "{\"query\":\"你喜欢夏天还是冬天?\",\"messageType\":\"text\"}"
    let urlString = "https://sai-pilot.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15-Int"
    
    let appIdField = "x-msxiaoice-request-app-id"
    let appId = "XI36GDstzRkCzD18Fh"
    let secret = "5c3c48acd5434663897109d18a2f62c5"

    /*
     Prod:
     appid: XIeQemRXxREgGsyPki
     Secret:4b3f82a71fb54cbe9e4c8f125998c787
     */
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
       //let body = bodyString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
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
            if let response = response,
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                print("Response:\(response)")
                print("DATA:\n\(string) \n End DATA \n")
            } else if let error = error {
                print("Error:\(error)")
            }
            
        }).resume()
        
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
    //let secretKeyByte = [UInt8](secretKeyStr.utf8)//NOTE:将string转化为byte数组，待再理解
    //let messageByte = [UInt8](messageStr.utf8)
    
    /*
    let computedHash = secretKeyStr.hmac(algorithm: .SHA1, key:messageStr)
    
    let computedHashData = computedHash.data(using: .utf8)
    let computedHashBase64 = computedHashData!.base64EncodedString()
    */
    
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
