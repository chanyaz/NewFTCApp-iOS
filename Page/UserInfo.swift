//
//  UserLogin.swift
//  Page
//
//  Created by ZhangOliver on 2018/1/2.
//  Copyright © 2018年 Oliver Zhang. All rights reserved.
//

import Foundation
struct UserInfo {
    static var shared = UserInfo()
    var userName: String?
    var userId: String?
    private static let userNameKey = "User Name Key"
    private static let userIdKey = "User Id Key"
    static func updateUserInfo(with body: [String: String]) {
        if let userName = body["username"],
            let userId = body["userId"] {
            UserInfo.shared.userName = userName
            UserInfo.shared.userId = userId
            UserDefaults.standard.set(userName, forKey: userNameKey)
            UserDefaults.standard.set(userId, forKey: userIdKey)
            print ("user name: \(userName); user id: \(userId)")
        }
    }
    static func getUserInfoFromNative() -> (name: String?, id: String?) {
        // TODO: Get user information from user default
        
        return (nil, nil)
    }
}
