//
//  Benefits.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Privilege {
    
    static var shared = Privilege()
    
    var adDisplay: AdDisplay = .all
    var englishText = false
    var englishAudio = false
    var exclusiveContent = false
    var editorsChoice = false
    var speedreading = false
    var radio = false
    var archive = false
    var book = false
    
    init(adDisplay: AdDisplay, englishText: Bool, englishAudio: Bool, exclusiveContent: Bool, editorsChoice: Bool, speedreading: Bool, radio: Bool, archive: Bool, book: Bool) {
        self.adDisplay = adDisplay
        self.englishText = englishText
        self.englishAudio = englishAudio
        self.exclusiveContent = exclusiveContent
        self.editorsChoice = editorsChoice
        self.speedreading = speedreading
        self.radio = radio
        self.archive = archive
        self.book = book
    }
    
    init() {
        self.adDisplay = .all
        self.englishText = false
        self.englishAudio = false
        self.exclusiveContent = false
        self.editorsChoice = false
        self.speedreading = false
        self.radio = false
        self.archive = false
        self.book = false
    }

}

// MARK: Quick way to indicate membership purchases
struct InAppPurchases {
    static var shared = InAppPurchases()
    var memberships: [String] = []
}
enum PurchaseSource: String {
    case AppleIAP = "Apple"
    case Site = "Site"
}
struct PrivilegeHelper {
    public static let dateFormatString = "yyyy-MM-dd HH:mm:ss VV"
    public static let dateFormatStringSimple = "yyyy年MM月dd日HH:mm"
    public static let purchaseSourceKey = "source"
    public static func updateFromDevice() {
        let memberships = IAPProducts.memberships
        for membership in memberships {
            if let id = membership["id"] as? String,
                let key = membership["key"] as? String {
                var purchased = UserDefaults.standard.bool(forKey: id)
                if purchased == false {
                    //print ("No app store purchase, check the key of \(key)")
                    if UserInfo.shared.subscriptionType == key,
                        let expireDate = UserInfo.shared.subscriptionExpire{
                        //print ("No app store purchase, found the key of \(key)")
                        let today = Double(Date().timeIntervalSince1970)
                        if expireDate >= today {
                            //print ("No app store purchase, the expire date is in the future")
                            purchased = true
                        } else {
                            //print ("No app store purchase, the expire date is in the past")
                        }
                        
                        let date = Date(timeIntervalSince1970: expireDate)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = dateFormatString
                        let expireDateString = dateFormatter.string(from: date)
                        //print ("No app store purchase, \(id) expires at \(expireDateString)")
                        IAP.savePurchase(id, property: "expires", value: expireDateString)
                        IAP.savePurchase(id, property: purchaseSourceKey, value: PurchaseSource.Site.rawValue)
                    }
                }
                //print ("IAP: \(id) purchase status is \(purchased)")
                if purchased == true {
                    if let privilege = membership["privilege"] as? Privilege {
                        Privilege.shared = privilege
                        //print ("IAP: check locally and privilege is \(privilege)")
                    }
                    // MARK: get users's membership purchase history
                    if InAppPurchases.shared.memberships.contains(id) == false {
                        InAppPurchases.shared.memberships.append(id)
                    }
                }
            }
        }
    }
    
    public static func updateFromReceipt(_ receipt: [String: AnyObject]) {
        
        if let status = receipt["status"] as? Int,
            status == 0,
            let receipts = receipt["receipt"] as? [String: Any],
            let receiptItems = receipts["in_app"] as? [[String: Any]] {
            var products = [String: ProductStatus]()
            for item in receiptItems {
                if let id = item["product_id"] as? String {
                    if let expiresDate = item["expires_date"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = dateFormatString
                        if let date = dateFormatter.date(from: expiresDate) {
                            if let currentExpireDate = products[id]?.expireDate,
                                currentExpireDate > date {
                                // MARK: If there's an existing expiration date and it's later than the current date, no need to update
                            } else {
                                products[id] = ProductStatus.init(expireDate: date)
                            }
                        } else {
                            products[id] = ProductStatus.init(expireDate: nil)
                        }
                    } else {
                        products[id] = ProductStatus.init(expireDate: nil)
                    }
                }
            }
            
            // MARK: Parse pending_renewal_info to get information about the user's auto_renew_status
            //var pendingRenewalProducts = [String: Bool]()
            if let pendingRenewalInfo = receipt["pending_renewal_info"] as? [[String: Any]] {
                for item in pendingRenewalInfo {
                    //print ("autorenewal product: \(item)")
                    if let id = item["auto_renew_product_id"] as? String,
                        let status = item["auto_renew_status"] as? String {
                        //pendingRenewalProducts[id] = (status == 1) ? true : false
                        IAP.savePurchase(id, property: "auto_renew_status", value: status)
                    }
                }
            }
            
            // MARK: Now compare dates and save to device
            for (id, status) in products {
                if let date = status.expireDate {
                    // MARK: handle subscrition expiration date
                    if date >= Date() {
                        //print ("\(id) is valid! ")
                        UserDefaults.standard.set(true, forKey: id)
                    } else {
                        //print ("\(id) has expired at \(date), today is \(Date()). Detail Below")
                        // MARK: Don't kick user out yet. We need to make sure validation is absolutely correct.
                        UserDefaults.standard.set(false, forKey: id)
                        IAP.savePurchase(id, property: "purchased", value: "N")
                        
                        if let environment = receipt["environment"] as? String {
                            //print ("environment is \(environment)")
                            if environment == "Production" {
                                let trackLabel = UserInfo.shared.userId ?? UserInfo.shared.userName ?? UserInfo.shared.deviceToken ?? ""
                                Track.event(category: "iOS Subscription Expires", action: id, label: "\(trackLabel)")
                                //print (receipt)
                            }
                        }
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = dateFormatString
                    let expireDateString = dateFormatter.string(from: date)
                    //print ("\(id) expires at \(expireDateString)")
                    IAP.savePurchase(id, property: "expires", value: expireDateString)
                    IAP.savePurchase(id, property: purchaseSourceKey, value: PurchaseSource.AppleIAP.rawValue)
                } else {
                    // MARK: Not a subscription
                    //print ("\(id) is valid! ")
                    UserDefaults.standard.set(true, forKey: id)
                }
                
            }
            
            //print(receipt)
            
            // MARK: update the privileges connected to buying
            updateFromDevice()
            
            // MARK: post notification about the receipt validation event
            NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelper.receiptValidatedNotification), object: "Receipt Validate Done! ")
            //print (products)
        }
    }
    
    public static func updateFromNetwork() {
        let memberships = IAPProducts.memberships
        for membership in memberships {
            if let id = membership["id"] as? String {
                let purchased = IAP.checkStatus(id)
                //print ("IAP: \(id) purchase status is \(purchased)")
                if purchased != "new" {
                    if let privilege = membership["privilege"] as? Privilege {
                        Privilege.shared = privilege
                        //print ("IAP: check from network and privilege is \(privilege)")
                    }
                } else {
                    UserDefaults.standard.set(false, forKey: id)
                    //print ("IAP: check from network and \(id)'s purchase status is set to false")
                }
            }
        }
    }
    
    public static func isPrivilegeIncluded(_ privilegeType: PrivilegeType, in privilge: Privilege) -> Bool {
        switch privilegeType {
        case .EnglishAudio:
            return privilge.englishAudio
        case .ExclusiveContent:
            return privilge.exclusiveContent
        case .EditorsChoice:
            return privilge.editorsChoice
        case .SpeedReading:
            return privilge.speedreading
        case .Radio:
            return privilge.radio
        case .EnglishText:
            return privilge.englishText
        case .Archive:
            return privilge.archive
        case .Book:
            return privilge.book
        }
    }
    
    public static func getDescription(_ privilegeType: PrivilegeType) -> (title: String, body: String) {
        switch privilegeType {
        case .EnglishAudio:
            return ("解锁英文语音", "购买会员服务，收听英文语音")
        case .ExclusiveContent:
            return ("解锁FT独家内容", "购买会员服务，阅读FT独家内容")
        case .EditorsChoice:
            return ("解锁编辑精选", "购买高端会员，阅读编辑精选")
        case .SpeedReading:
            return ("解锁金融英语速读", "购买会员服务，使用金融英语速读")
        case .Radio:
            return ("解锁英语电台", "购买会员服务，收听FT英语电台")
        case .EnglishText:
            return ("解锁英文和中英对照", "购买会员服务，阅读英文内容")
        case .Archive:
            return ("解锁档案文章", "购买会员服务，阅读七天前文章")
        case .Book:
            return ("解锁电子书", "高端会员免费阅读电子书")
        }
    }
    
    public static func getLabel(prefix: String, type: String, id: String, suffix: String) -> String {
        return ("\(prefix)/\(type)/\(id)\(suffix)")
    }
    
    // MARK: Get all privileges for web
    public static func getPrivilegesForWeb() -> String {
        var privileges: [String] = []
        if Privilege.shared.exclusiveContent == true {
            privileges.append("premium")
        }
        if Privilege.shared.editorsChoice == true {
            privileges.append("EditorChoice")
        }
        let jsCode = String(describing: privileges).replacingOccurrences(of: "\"", with: "'")
        return jsCode
    }
    
    
    // MARK: - DO NOT DELETE!!!
    // MARK: - Quick Test for playground. The aim is to crunch as many as possible receipts data to see if  the updateFromReceipt is 100% correct, which is important.
    /*
    static func runTest() {
        if let allFiles = Bundle.main.urls(forResourcesWithExtension: "log", subdirectory: nil) {
            for fileURL in allFiles {
                print ("\(fileURL.lastPathComponent): ")
                if let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) {
                    let contentDeliminated = content.replacingOccurrences(of: "[{\"user-id\":", with: "|[{\"user-id\":")
                    let contentArray = contentDeliminated.split(separator: "|")
                    for item in contentArray {
                        //print (item)
                        let data = item.data(using: .utf8)!
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,AnyObject>]
                            {
                                if jsonArray.count > 1 {
                                    updateFromReceipt(jsonArray[1])
                                }
                            } else {
                                print("bad json")
                            }
                        } catch _ as NSError {
                            //print(error)
                        }
                    }
                }
            }
        }
    }
    */
    
}

struct ProductStatus {
    public var expireDate: Date?
}

enum AdDisplay {
    case no
    case reasonable
    case all
}

enum PrivilegeType: String {
    case EnglishAudio = "EnglishAudio"
    case ExclusiveContent = "ExclusiveContent"
    case EditorsChoice = "EditorsChoice"
    case SpeedReading = "SpeedReading"
    case Radio = "Radio"
    case Archive = "Archive"
    case EnglishText = "EnglishText"
    case Book = "Book"
}
