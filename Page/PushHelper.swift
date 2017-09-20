//
//  PushHelper.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/18.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct PushHelper {
    static var sharedInstance = PushHelper()
    var postString = ""
    var deviceTokenSent = false
    var deviceTokenString = ""
    var deviceUserId = "no"
    var supportedSocialPlatforms = [String]()
    
    func sendDeviceToken() {
        if postString != "" && deviceUserId != "no" && deviceTokenSent == false {
            let url = URL(string: DeviceToken.url)
            let request = NSMutableURLRequest(url:url!)
            let postStringFinal = "\(postString)\(deviceUserId)"
            request.httpMethod = "POST"
            //print(postString)
            request.httpBody = postStringFinal.data(using: String.Encoding.utf8)
            let session = URLSession.shared
            //let task = URLSession.shared().dataTask(with: request as URLRequest) {
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            })
            task.resume()
        }
    }
}
