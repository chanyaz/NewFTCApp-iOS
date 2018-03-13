//
//  AppDelegate.swift
//  Page
//
//  Created by Oliver Zhang on 2017/5/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import Google


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var checkImpressionTimer: Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // MARK: - Important: Don't Set the default background overall color. It will affect the action sheet
        // window?.tintColor = UIColor(hex: Color.Content.background)
        
        // MARK: Register for notification
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Fallback on earlier versions
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
        
        // if launched from a tap on a notification
        NotificationHelper.handle(launchOptions)
        startCheckImpressionTimer()
        setupGoogleAnalytics()
        AdMobTrack.launch()
        
        // WeChat API
        WXApi.registerApp(WeChat.appId)
        
        // MARK: Show the Launch Screen only when there is tabbar controller
        if AppLaunch.shared.launched == false {
            if let rootViewController = window?.rootViewController as? UITabBarController,
                Color.Ad.showFullScreenAdWhenLaunch == true {
                rootViewController.showLaunchScreen()
                AppLaunch.shared.launched = true
            } else {
                AppLaunch.shared.fullScreenDismissed = true
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        Track.event(category: "\(DeviceInfo.checkDeviceType()) App Launch", action: "Success", label: Bundle.main.bundleIdentifier ?? "")
                
        // MARK: - Get current language preference
        LanguageSetting.shared.currentPrefence = Setting.getCurrentOption("language-preference").index
        
        // MARK: - Update User Login
        UserInfo.updateUserInfoFromNative()
        
        // MARK: - Update membership status
        PrivilegeHelper.updateFromDevice()

        // MARK: - Don't delete this. It's very useful.
        //GB2Big5.createDict()
        //let _ = GB2Big5.makeMyDict()
        
        


        return true
    }
    
    
    private func setupGoogleAnalytics() {
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError? = nil
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        //gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
    }
    
    
    @objc public func checkImpressions() {
        //print ("check impressions")
        Impressions.retry()
    }
    
    // MARK: - Received device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DeviceToken.forwardTokenToServer(deviceToken: deviceToken)
    }
    
    
    
    // MARK: - Register device errorred.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error)")
    }
    
    // MARK: - Register notification settings
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print(notificationSettings)
    }
    
    // MARK: - Received remote notification
    //    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    //        print(userInfo)
    //
    //
    //    }
    

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? NSDictionary {
            let title: String = (aps["alert"] as? [String:String])?["title"] ?? "为您推荐"
            //let lead: String = (aps["alert"] as? [String:String])?["body"] ?? ""
            
            if let notiAction = userInfo["action"],
                let id = userInfo["id"] as? String {
                if let isContentAvailable = aps["content-available"] as? Int,
                    isContentAvailable == 1 {
                    print ("received a silent notification with the value of \(isContentAvailable)")
                    Download.grabHTMLResource(id, aps: aps, completionHandler: { (fetchResult) in
                        // MARK: - Make sure to always execute completionHandler correctly. Otherwise the system will not let you access internet for ensuing silent notifications.
                        completionHandler(fetchResult)
                    })
                } else if application.applicationState == .inactive || application.applicationState == .background{
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    NotificationHelper.open(notiAction as? String, id: id, title: title)
                    //rootViewController.openNotification(notiAction as? String, id: id as? String, title: title)
                } else {
                    //                        let alert = UIAlertController(title: title, message: lead, preferredStyle: UIAlertControllerStyle.alert)
                    //                        alert.addAction(UIAlertAction(title: "去看看", style: .default, handler: { (action: UIAlertAction) in
                    //                            rootViewController.openNotification(notiAction as? String, id: id as? String, title: title)
                    //                        }))
                    //                        alert.addAction(UIAlertAction(title: "不感兴趣", style: UIAlertActionStyle.default, handler: nil))
                    //                        rootViewController.present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        checkImpressions()
        checkImpressionTimer?.invalidate()
        UIApplication.shared.applicationIconBadgeNumber = 0
        Engagement.save()
        
        //        if AppLaunch.sharedInstance.launched == true {
        //            if let rootViewController = window?.rootViewController {
        //                rootViewController.showAudioPlayer()
        //            }
        //        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Download.manageFiles(APIs.expireFileTypes, for: .cachesDirectory)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        startCheckImpressionTimer()
        checkNotificationStatus()
        checkTokenForSubscriber()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // MARK: clean the cache
        // Download.manageFiles(APIs.expireFileTypes, for: .cachesDirectory)
    }
    
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func startCheckImpressionTimer() {
        checkImpressions()
        if checkImpressionTimer == nil || checkImpressionTimer?.isValid == false {
            checkImpressionTimer = Timer.scheduledTimer(
                timeInterval: 30,
                target: self,
                selector: #selector(checkImpressions),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    private func checkNotificationStatus() {
        // MARK: Prompt the Alert to Request user to allow notification
        if UserInfo.shared.shouldRequestUserToAllowNotification == false {
            return
        }
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            // MARK: Check for user's notification status
            center.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    // Notification permission has not been asked yet, go for it!
                    print ("Notification not asked! ")
                    self.requestUserToAllowNotification()
                }
                if settings.authorizationStatus == .denied {
                    // Notification permission was previously denied, go to settings & privacy to re-enable
                    print ("Notification denied! ")
                    self.requestUserToAllowNotification()
                }
                if settings.authorizationStatus == .authorized {
                    // Notification permission was already granted
                    print ("Notification allowed! ")
                }
            })
        } else {
            // Fallback on earlier versions
            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
            if isRegisteredForRemoteNotifications == false {
                // Show alert user is not registered for notification
                requestUserToAllowNotification()
                print ("Notification allowed! ")
            }
        }

    }

    private func requestUserToAllowNotification() {
        if UserInfo.shared.shouldRequestUserToAllowNotification && Privilege.shared.exclusiveContent {
            let title = "重要通知"
            let lead = "亲爱的订户，为了保障您的权益，请在您设备的设置中允许本应用向您发送通知推送，以便我们保证把您购买的内容发送给您。"
            let alert = UIAlertController(title: title, message: lead, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "立即设置", style: .default, handler: { (action: UIAlertAction) in
                //rootViewController.openNotification(notiAction as? String, id: id as? String, title: title)
                if let settingUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl) {
                        UIApplication.shared.openURL(settingUrl)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "以后再说", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            UserInfo.shared.shouldRequestUserToAllowNotification = false
        }
    }
    
    private func checkTokenForSubscriber() {
        if Privilege.shared.exclusiveContent {
            Track.token()
        }
    }

    
}

// MARK: - WeChat authorized login
extension AppDelegate: WXApiDelegate {
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if let urlScheme = url.scheme {
            switch urlScheme {
            case "ftchinese":
                print ("this is a ftchinese url")
            default:
                return WXApi.handleOpen(url, delegate: self)
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let urlScheme = url.scheme {
            switch urlScheme {
            case "ftchinese":
                NotificationHelper.handle(url)
                return true
            default:
                return WXApi.handleOpen(url, delegate: self)
            }
        }
        return false
        
    }
    
    func onReq(_ req: BaseReq!) {
        // do optional stuff
    }
    
    func onResp(_ resp: BaseResp!) {
        if let authResp = resp as? SendAuthResp {
            if let wechatAuthCode = authResp.code {
                let wechatAccessTokenLink = WeChat.accessTokenPrefix + "appid=" + WeChat.appId + "&secret=" + WeChat.appSecret + "&code=" + wechatAuthCode + "&grant_type=authorization_code"
                if let url = URL(string: wechatAccessTokenLink) {
                    Download.getDataFromUrl(url) {(data, response, error)  in
                        DispatchQueue.main.async { () -> Void in
                            guard let data = data , error == nil else { return }
                            do {
                                let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
                                guard let JSONDictionary = JSON as? NSDictionary else  {
                                    print ("WeChat Return Value is Wrong")
                                    return
                                }
                                guard let accessToken = JSONDictionary["access_token"] as? String else {
                                    print ("WeChat Access Token is not a string")
                                    return
                                }
                                guard let openId = JSONDictionary["openid"] as? String else {
                                    print ("WeChat Open Id is not a string")
                                    return
                                }
                                let userInfoUrlString = "\(WeChat.userInfoPrefix)access_token=\(accessToken)&openid=\(openId)"
                                if let userInfoUrl = URL(string: userInfoUrlString) {
                                    Download.getDataFromUrl(userInfoUrl) {(data, response, error)  in
                                        guard let data = data , error == nil else { return }
                                        print ("Get Wechat Login Data \(data)")
                                        if let JSONString = String(data: data, encoding: .utf8) {
                                            print ("json string is \(JSONString)")
                                            let jsCode = "socialLogin('wechat', '\(JSONString)');"
                                            print(jsCode)
                                            DispatchQueue.main.async { () -> Void in
                                                if let topViewController = UIApplication.topViewController() as? ContentItemViewController {
                                                    topViewController.webView?.evaluateJavaScript(jsCode) { (result, error) in
                                                        if result != nil {
                                                            print (result ?? "unprintable JS result")
                                                        }
                                                    }
                                                } else if let topViewController = UIApplication.topViewController() as? DataViewController {
                                                    topViewController.webView?.evaluateJavaScript(jsCode) { (result, error) in
                                                        if result != nil {
                                                            print (result ?? "unprintable JS result")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } catch let JSONError as NSError {
                                print("\(JSONError)")
                            }
                        }
                    }
                }
            } else {
            }
        } else {
        }
    }
    // code related to wechat authorization end
}


