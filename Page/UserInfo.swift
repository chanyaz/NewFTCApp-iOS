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
    var deviceToken: String?
    private static let userNameKey = "User Name Key"
    private static let userIdKey = "User Id Key"
    
    static func updateUserInfo(with body: [String: String]) {
        if let userName = body["username"],
            let userId = body["userId"] {
            UserInfo.shared.userName = userName
            UserInfo.shared.userId = userId
            UserDefaults.standard.set(userName, forKey: userNameKey)
            UserDefaults.standard.set(userId, forKey: userIdKey)
            print ("update user name: \(userName); user id: \(userId)")
        }
    }
    
    static func updateUserInfoFromNative()  {
        // MARK: Get user information from user default so that user name will be available even when you haven't visited any story page
        UserInfo.shared.userName = UserDefaults.standard.string(forKey: userNameKey)
        UserInfo.shared.userId = UserDefaults.standard.string(forKey: userIdKey)
        print ("user name: \(String(describing: UserInfo.shared.userName)); user id: \(String(describing: UserInfo.shared.userId))")
    }
    
    static func showAccountPage() {
        if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
            dataViewController.dataObject = [
                "title": "账户",
                "type": "account",
                "url":"http://www.ftchinese.com/account.html",
                //"url":"http://app003.ftmailbox.com/iphone-2014.html",
                "screenName":"myft/account"
            ]
            dataViewController.pageTitle = "登入"
            if let topViewController = UIApplication.topViewController() {
                topViewController.navigationController?.pushViewController(dataViewController, animated: true)
            }
        }
    }
    
}
