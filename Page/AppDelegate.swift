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
        
        // MARK: - Don't Set the default background overall color. It will affect the action sheet
        // window?.tintColor = UIColor(hex: Color.Content.background)
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                //print("authorization granted: \(granted)")
                
            }
            //print("register for remote notifications")
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Fallback on earlier versions
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
        startCheckImpressionTimer()
        setupGoogleAnalytics()
        
        // WeChat API
        WXApi.registerApp(WeChat.appId)
        
        
        // MARK: Show the Launch Screen as an Overlay
//                if AppLaunch.sharedInstance.launched == false {
//                    if let launchScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen") as? LaunchScreen {
//                        if let window = self.window, let rootViewController = window.rootViewController {
//                            var currentController = rootViewController
//                            let navViewController = currentController.childViewControllers[0]
//                            let pageViewController = navViewController.childViewControllers[0]
//                            
//                            pageViewController.present(launchScreenViewController, animated: false, completion: nil)
//                            
//                        }
//        
//                    }
//                    AppLaunch.sharedInstance.launched = true
//                }

        
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
    
    
    public func checkImpressions() {
        //print ("check impressions")
        Impressions.retry()
    }
    
    // MARK: - Received device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        self.forwardTokenToServer(deviceToken: deviceToken)
    }
    
    // MARK: - Post device token to server
    func forwardTokenToServer(deviceToken token: Data) {
        let hexEncodedToken = token.map { String(format: "%02hhX", $0) }.joined()
        print("device token: \(hexEncodedToken)")
        
        var appNumber: String
        var deviceType: String
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            deviceType = "pad"
            appNumber = "1"
            
        case .phone:
            deviceType = "phone"
            appNumber = "2"
            
        default:
            deviceType = "unspecified"
            appNumber = "0"
        }
        
        let timeZone = TimeZone.current.abbreviation() ?? ""
        
        let urlEncoded = "d=\(hexEncodedToken)&t=\(timeZone)&s=start&p=&dt=\(deviceType)&a=\(appNumber)"
        
        PostData.sendDeviceToken(body: urlEncoded)
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
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        checkImpressions()
        checkImpressionTimer?.invalidate()
        if AppLaunch.sharedInstance.launched == true {
            if let rootViewController = window?.rootViewController as? CustomTabBarController {
                rootViewController.showLaunchScreen()
            }
        }
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
    
}

// MARK: - WeChat authorized login
extension AppDelegate: WXApiDelegate {
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func onReq(_ req: BaseReq!) {
        // do optional stuff
    }
    
    func onResp(_ resp: BaseResp!) {
        if let authResp = resp as? SendAuthResp {
            if let wechatAuthCode = authResp.code {
                let wechatAccessTokenLink = WeChat.accessTokenPrefix + "appid=" + WeChat.appId + "&secret=" + WeChat.appSecret + "&code=" + wechatAuthCode + "&grant_type=authorization_code"
                if let url = URL(string: wechatAccessTokenLink) {
                    Download.getDataFromUrl(url) { (data, response, error)  in
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
                                    Download.getDataFromUrl(userInfoUrl) { (data, response, error)  in
                                        DispatchQueue.main.async { () -> Void in
                                            guard let data = data , error == nil else { return }
                                            print ("Get Wechat Login Data \(data)")
                                            if let JSONString = String(data: data, encoding: .utf8) {
                                                print ("json string is \(JSONString)")
                                                if let topViewController = UIApplication.topViewController() as? ContentItemViewController {
                                                    let jsCode = "socialLogin('wechat', '\(JSONString)');"
                                                    print(jsCode)
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


