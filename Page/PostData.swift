//
//  PostData.swift
//  Page
//
//  Created by niweiguo on 13/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation

struct PostData {
    private static let deviceTokenCollector = "https://noti.ftimg.net/iphone-collect.php"
    
    static func sendDeviceToken(body: String) {
        guard let url = URL(string: deviceTokenCollector) else {
            return
        }
        
        guard let bodyData = body.data(using: .utf8) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let res = String(data: data, encoding: .utf8) {
                print(res)
            }
            if let res = response {
                print(res)
            }
            if let err = error {
                print(err)
            }
        }
        dataTask.resume()
    }
}
