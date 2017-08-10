//
//  TalkRequest.swift
//  Page
//
//  Created by niweiguo on 10/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation

typealias CompletionHandler = () -> Void

class MySessionDelegate: URLSessionStreamTask, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var completionHandlers: [String: CompletionHandler] = [:]
}

func createTalkRequest () {
    let defaultConfiguration = URLSessionConfiguration.default
    let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let cacheURL = cachesDirectoryURL.appendingPathComponent("MyCache")
    let diskPath = cacheURL.path
    let cache = URLCache(memoryCapacity: 16384, diskCapacity: 268435456, diskPath: diskPath)
    defaultConfiguration.urlCache = cache
    defaultConfiguration.requestCachePolicy = .useProtocolCachePolicy
    
    /*
    let delegate = MySessionDelegate()
    let operationQueue = OperationQueue.main
    
    
    let defaultSession = URLSession(configuration: defaultConfiguration, delegate: delegate, delegateQueue: operationQueue)
    */
    
    
    //let sessionWithoutADelegate = URLSession(configuration: defaultConfiguration)
    
    
    let bodyString = "{\"query\":\"你喜欢夏天还是冬天?\",\"messageType\":\"text\"}"
    let urlString = "https://sai-pilot.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15-Int"
    
    
    let appId = "rcCfylzCxuMtwpt5VWMRPrGkopPs4H0PvlU4dqlN"
    //let priSecret = "ebU2LDatLK56UUECdpm5Hw3jiId0NsZP5EnQGv0Qzk2SutY6B9QTVyq9RHV8M4t4"
    //let secSecret = "KCKPd4jilYotOlBTHGoLVa1iNLzu9SFRuMxnfjo2DX2DrP90a8xQdzbMw6o4P6MN"
    
    let timestamp = DateFormatter().string(from: Date())//生成时间戳
    let userId = "10adc3949ba59abbe56e057f20f883e"
    
    if let url = URL(string: urlString),
       let body = bodyString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) { // 将String转化为Data
        var talkRequest = URLRequest(url:url)
        talkRequest.httpMethod = "POST"
        talkRequest.httpBody = body
        talkRequest.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        talkRequest.setValue(appId, forHTTPHeaderField: "x-msxiaoice-request-app-id")
        talkRequest.setValue(timestamp, forHTTPHeaderField: "x-msxiaoice-request-timestamp")
        talkRequest.setValue(userId, forHTTPHeaderField: "x-msxiaoice-request-user-id")
        
    }
    /*
        (sessionWithoutADelegate.uploadTask(with: request, from: body) {
            (data, response, error) in
            if let error = error {
                print("Error:\(error)"
            } else if let response = response, let data = data, let string = String(data: data, encoding: .utf8) {
                print("Response:\(response)")
                print("DATA:\n\(string) \n End DATA \n")
            }
        }).resume()
    */
}


func computeSignature(verb:String, url:String, paramList:[String], headerList:[String],body:String,timestamp:String,secretKey:String) -> String {
    let verbStr = verb.lowercased()
    let urlStr = url.lowercased()
    let paramListStr = paramList.sorted().joined(separator: "&")
    
    var headerListNew = [String]()
    for (index,value) in headerList.enumerated() {
        headerListNew[index] = value.lowercased()
    }
    
    let headerListStr = headerListNew.sorted().joined(separator: ",")
    //base64EncodedString()
    let bodyStr = body
    let timestampStr = timestamp
    let secretKeyStr = secretKey
    
    let concatenatedStr = "\(verbStr);\(urlStr);\(paramListStr);\(headerListStr);\(bodyStr);\(timestampStr);\(secretKeyStr)"
    
    //let secretKeyByte = [UInt8](secretKeyStr.utf8)//NOTE:将string转化为byte数组，待再理解
    
    
    return concatenatedStr
}
