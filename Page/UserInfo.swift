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
    var uniqueVisitorId: String?
    var subscriptionType: String?
    var subscriptionExpire: Double?
    var shouldRequestUserToAllowNotification = true
    private static let userNameKey = "User Name Key"
    private static let userIdKey = "User Id Key"
    private static let uniqueVisitorIdKey = "unique visitor id key"
    private static let subscriptionTypeKey = "Subscription Type Key"
    private static let subscriptionExpireKey = "Subscription Expire Key"
    
    static func updateUserInfo(with body: [String: String]) {
        print ("user info body: \(body)")
        if let userName = body["username"],
            let userId = body["userId"] {
            UserInfo.shared.userName = userName
            UserInfo.shared.userId = userId
            UserDefaults.standard.set(userName, forKey: userNameKey)
            UserDefaults.standard.set(userId, forKey: userIdKey)
            print ("update user name: \(userName); user id: \(userId)")
            UserInfo.shared.subscriptionType = body["paywall"]
            UserDefaults.standard.set(UserInfo.shared.subscriptionType, forKey: subscriptionTypeKey)
            if let subscriptionExpireString = body["paywallExpire"],
                let subscriptionExpire = Double(subscriptionExpireString) {
                UserInfo.shared.subscriptionExpire = Double(subscriptionExpire)
                UserDefaults.standard.set(subscriptionExpire, forKey: subscriptionExpireKey)
            } else {
                UserInfo.shared.subscriptionExpire = nil
                UserDefaults.standard.set(nil, forKey: subscriptionExpireKey)
            }
            // MARK: Update user privilege immediately
            // PrivilegeHelper.updateFromDevice()
            // TODO: Remove the following Test Code
//            UserInfo.shared.subscriptionType = "premium"
//            UserInfo.shared.subscriptionExpire = 1553843894.598611
//            UserDefaults.standard.set(UserInfo.shared.subscriptionType, forKey: subscriptionTypeKey)
//            UserDefaults.standard.set(UserInfo.shared.subscriptionExpire, forKey: subscriptionExpireKey)
        }
        if let uniqueVisitorId = body["uniqueVisitorId"] {
            UserInfo.shared.uniqueVisitorId = uniqueVisitorId
            UserDefaults.standard.set(uniqueVisitorId, forKey: uniqueVisitorIdKey)
            print ("Unique Visitor Id: \(uniqueVisitorId)")
        }
    }
    
    static func updateUserInfoFromNative() {
        // MARK: Get user information from user default so that user name will be available even when you haven't visited any story page
        UserInfo.shared.userName = UserDefaults.standard.string(forKey: userNameKey)
        UserInfo.shared.userId = UserDefaults.standard.string(forKey: userIdKey)
        UserInfo.shared.uniqueVisitorId = UserDefaults.standard.string(forKey: uniqueVisitorIdKey)
        UserInfo.shared.subscriptionType = UserDefaults.standard.string(forKey: subscriptionTypeKey)
        UserInfo.shared.subscriptionExpire = UserDefaults.standard.double(forKey: subscriptionExpireKey)
        print ("user name: \(String(describing: UserInfo.shared.userName)); user id: \(String(describing: UserInfo.shared.userId)); unique visitor id: \(String(describing: UserInfo.shared.uniqueVisitorId))")
    }
    
    static func showAccountPage() {
        if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController,
            let dataForAccountPage = AppNavigation.getChannelData(of: "myft/account") {
            dataViewController.dataObject = dataForAccountPage
            dataViewController.pageTitle = "登入"
            if let topViewController = UIApplication.topViewController() {
                topViewController.navigationController?.pushViewController(dataViewController, animated: true)
            }
        }
    }
    
}
