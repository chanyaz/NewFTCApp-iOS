//
//  Benefits.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
enum KickOutIAPReason {
    case Expired
    case NoPurchaseRecord
    case AbusedPurchase
}

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
    var hasRefreshedReceipt = false
}

enum PurchaseSource: String {
    case AppleIAP = "Apple"
    case Site = "Site"
}

struct PrivilegeHelper {
    public static let dateFormatString = "yyyy-MM-dd HH:mm:ss VV"
    public static let dateFormatStringSimple = "yyyy年MM月dd日HH:mm"
    public static let purchaseSourceKey = "source"
    public static let originalTransactionIdKey = "original_transaction_id"
    private static let iapCardInfoKey = "IAP Card Info Key"
    
    public static func updateFromDevice() {
        var finalPrivilge = Privilege()
        let memberships = IAPProducts.memberships
        for membership in memberships {
            if let id = membership["id"] as? String,
                let key = membership["key"] as? String {
                var purchased = UserDefaults.standard.bool(forKey: id)
                if purchased == false,
                    UserInfo.shared.card != .Red {
                    //MARK: - No app store purchase, set the privilege to empty
                    //print ("IAP: No app store purchase, check the key of \(key)")
                    if UserInfo.shared.subscriptionType == key,
                        let expireDate = UserInfo.shared.subscriptionExpire {
                        //print ("IAP: No app store purchase, found the key of \(key)")
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
                        //print ("IAP: No app store purchase, \(id) expires at \(expireDateString)")
                        IAP.savePurchase(id, property: IAP.expiresKey, value: expireDateString)
                        IAP.savePurchase(id, property: purchaseSourceKey, value: PurchaseSource.Site.rawValue)
                    }
                }
                //print ("IAP: \(id) purchase status is \(purchased)")
                if purchased == true {
                    if let privilege = membership["privilege"] as? Privilege {
                        finalPrivilge = privilege
                        //print ("IAP: check locally and privilege is \(privilege)")
                    }
                    // MARK: get users's membership purchase history
                    if InAppPurchases.shared.memberships.contains(id) == false {
                        InAppPurchases.shared.memberships.append(id)
                    }
                }
            }
        }
        Privilege.shared = finalPrivilge
    }
    
    public static func updateFromReceipt(_ receipt: [String: AnyObject]) {
        // MARK: if the receipt is flagged by server side as being abused, we should refresh
        var shouldRefreshReceipt = false
        var allProductIds = [String: (keep: Bool, status: ProductStatus, reason: KickOutIAPReason?)]()
        let emptyStatus = ProductStatus.init(expireDate: nil)
        
        // MARK: Analyze the receipt to decide which purchases and subscriptions are valid
        if let status = receipt["status"] as? Int,
            status == 0,
            let receipts = receipt["receipt"] as? [String: Any],
            let receiptItems = receipts["in_app"] as? [[String: Any]],
            receiptItems.count > 0 {
            
            //print ("IAP Check: \(receipt)")
            
            // MARK: 1. Loop through all the IAP orders to update products information
            var products = [String: ProductStatus]()
            for item in receiptItems {
                if let id = item["product_id"] as? String {
                    if let expiresDate = item["expires_date"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = dateFormatString
                        if let date = dateFormatter.date(from: expiresDate) {
                            if let currentLatestExpireDate = products[id]?.expireDate,
                                date < currentLatestExpireDate {                                
                            } else {
                                // MARK: Only when the expire date is later than the current latest expire date. This way we get the latest expire date from receipt.
                                products[id] = ProductStatus.init(expireDate: date)
                            }
                        } else {
                            products[id] = emptyStatus
                        }
                    } else {
                        products[id] = emptyStatus
                    }
                }
            }
            
            // MARK: 2. Parse pending_renewal_info to get information about the user's auto_renew_status
            if let pendingRenewalInfo = receipt["pending_renewal_info"] as? [[String: Any]] {
                for item in pendingRenewalInfo {
                    if let id = item["auto_renew_product_id"] as? String,
                        let status = item["auto_renew_status"] as? String {
                        IAP.savePurchase(id, property: "auto_renew_status", value: status)
                        if let originalTransactionId = item[originalTransactionIdKey] as? String {
                            IAP.savePurchase(id, property: originalTransactionIdKey, value: originalTransactionId)
                            recordTransactionId(originalTransactionId)
                            // MARK: - if the IAP purchase is flagged as abused
                            let transactionIdStatus = checkTransactionId(originalTransactionId)
                            if transactionIdStatus != .Clear {
                                // MARK: - Refresh the receipt if the IAP purchase gets a yellow card
                                shouldRefreshReceipt = true
                                // MARK: - Kick the user out if the IAP purchase gets a red card
                                if transactionIdStatus == .Red {
                                    allProductIds[id] = (false, emptyStatus, .AbusedPurchase)
                                    // MARK: remove the value from products dictionary so that it won't be looped through
                                    products.removeValue(forKey: id)
                                }
                            }
                        }
                    }
                }
            }
            
            print ("IAP Check: Products: \(products)")
            // MARK: 3. Loop through the valid ids generated from previous steps, keep the valid ones and keep out invalid or expired ones
            for (id, status) in products {
                if let date = status.expireDate {
                    // MARK: handle subscrition expiration date
                    if date >= Date() {
                        //UserDefaults.standard.set(true, forKey: id)
                        allProductIds[id] = (true, status, nil)
                    } else {
                        //kickOutFromIAP(id, with: receipt, for: .Expired)
                        allProductIds[id] = (false, status, .Expired)
                    }
                } else {
                    // TODO: Not a subscription, deal with this later
                    //UserDefaults.standard.set(true, forKey: id)
                    allProductIds[id] = (true, status, nil)
                }
            }
            
            // MARK: 4. Loop through all memberships and kick out those that are not included in the receipt
            for membership in IAPProducts.memberships {
                if let id = membership["id"] as? String {
                    // MARK: Check all membership ids and kick out those not included
                    if let product = products[id],
                        let expireDate = product.expireDate,
                        expireDate >= Date() {
                        // MARK: Check if the server side has recorded the purchase correctly
                        IAP.checkMembershipStatus(id)
//                        print ("IAP Check: \(id) expires at \(expireDate)")
//                        allProductIds[id] = (true, status, nil)
                    } else {
                        print ("IAP Check: \(id) is not valid")
                        allProductIds[id] = (false, emptyStatus, .NoPurchaseRecord)
                        //kickOutFromIAP(id, with: receipt, for: .NoPurchaseRecord)
                    }
                }
            }
            print ("IAP Check: all product id: \(allProductIds)")
            
            // MARK: 5. Take actions with what we get from the receipt
            for (id, value) in allProductIds {
                if value.keep == true {
                    UserDefaults.standard.set(true, forKey: id)
                    print ("IAP Check: Keep \(id)")
                    if let date = value.status.expireDate {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = dateFormatString
                        let expireDateString = dateFormatter.string(from: date)
                        IAP.savePurchase(id, property: IAP.expiresKey, value: expireDateString)
                        IAP.savePurchase(id, property: purchaseSourceKey, value: PurchaseSource.AppleIAP.rawValue)
                        print ("IAP Check: update \(id) with expiration date of \(expireDateString)")
                    }
                } else {
                    kickOutFromIAP(id, with: receipt, for: value.reason)
                }
            }
            
            // MARK: update the privileges connected to buying
            updateFromDevice()
            // MARK: post notification about the receipt validation event
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: IAPHelper.receiptValidatedNotification),
                object: "Receipt Validate Done! "
            )
        } else {
            shouldRefreshReceipt = true
            kickOut(IAPProducts.memberships, with: receipt, for: .NoPurchaseRecord)
        }
        // MARK: Request a new receipt, but only once to avoid infinite loop.
        print ("IAP Check: deciding whether to refresh the receipt. should refresh receipt: \(shouldRefreshReceipt). has refreshed: \(InAppPurchases.shared.hasRefreshedReceipt)")
        if shouldRefreshReceipt && InAppPurchases.shared.hasRefreshedReceipt == false {
            InAppPurchases.shared.hasRefreshedReceipt = true
            print ("IAP Check: refresh the receipt")
            ReceiptHelper.refresh()
        }
    }
    
    private static func kickOutFromIAP(_ id: String, with receipt: [String: AnyObject], for reason: KickOutIAPReason?) {
        // MARK: Don't kick user out yet. We need to make sure validation is absolutely correct.
        print ("IAP Check: Kick Out \(id) for \(String(describing: reason))")
        UserDefaults.standard.set(false, forKey: id)
        IAP.savePurchase(id, property: IAP.purchasedPropertyString, value: "N")
        // MARK: remove the purchase record entirely from user defaults if it is kicked out for reasons other than expiration
        if reason == .AbusedPurchase || reason == .NoPurchaseRecord {
            IAP.removePurchase(id)
        }
        //IAP.savePurchase(id, property: "auto_renew_status", value: "0")
        if let environment = receipt["environment"] as? String {
            if environment == "Production" {
                let trackLabel = UserInfo.shared.userId ?? UserInfo.shared.userName ?? UserInfo.shared.deviceToken ?? ""
                Track.event(category: "iOS Subscription Expires", action: id, label: "\(trackLabel)")
            }
        }
    }
    
    private static func kickOut(_ memberships:  [Dictionary<String, Any>], with receipt: [String: AnyObject], for reason: KickOutIAPReason?) {
        for membership in memberships {
            if let id = membership["id"] as? String {
                kickOutFromIAP(id, with: receipt, for: reason)
            }
        }
    }
    
    // MARK: Send Transaction ID, time stamp and Device Id to server for validation and black listing
    private static func recordTransactionId(_ originalTransactionId: String) {
        print ("IAP Check: updating original transaction id: \(originalTransactionId)")
        //        let purchaseInfo = [
        //            "user_id": userId,
        //            "product_id": id,
        //            "expires_date": expireDate,
        //            "token": tokenWithSalt,
        //            "originalTransactionId": originalTransactionId
        //            ] as [String : String]
        //        //print ("send ios iap info to server: \(urlString). expire date: \(expireDate). with: \(purchaseInfo)")
        //        do {
        //            let jsonData = try JSONSerialization.data(withJSONObject: purchaseInfo, options: .init(rawValue: 0))
        //            if let siteServerUrl = Foundation.URL(string:urlString) {
        //                var request = URLRequest(url: siteServerUrl)
        //                request.httpMethod = "POST"
        //                request.httpBody = jsonData
        //                let session = URLSession(configuration: URLSessionConfiguration.default)
        //                let task = session.dataTask(with: request) { data, response, error in
        //                    if let receivedData = data,
        //                        let httpResponse = response as? HTTPURLResponse,
        //                        error == nil,
        //                        httpResponse.statusCode == 200 {
        //                        do {
        //                            if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>,
        //                                let status = jsonResponse["errmsg"] as? String,
        //                                status == "success" {
        //                                // MARK: - parse and verify the required informatin in the jsonResponse
        //                                //print ("send ios iap info to server: success: \(jsonResponse)")
        //                                UserInfo.shared.iapMembershipReadyForCrossPlatform = true
        //                            } else {
        //                                print ("send ios iap info to server: fail to cast: \(String(describing: String(data: receivedData, encoding: .utf8)))")
        //                            }
        //                        } catch {
        //
        //                        }
        //                    }
        //                }
        //                task.resume()
        //            } else {
        //                //print("receipt validation from func receiptValidation: Couldn't convert string into URL. Check for special characters.")
        //            }
        //        } catch {
        //            //print("receipt validation from func receiptValidation: Couldn't create JSON with error: " + error.localizedDescription)
        //        }
        //        Track.event(category: "iOS IAP Membership: \(key)", action: userId, label: expireDate)
    }
    
    private static func checkTransactionId(_ originalTransactionId: String) -> CardType {
        //return .Yellow
        // TEST: Use oliver's id
//        if originalTransactionId == "1000000378980806" {
//            return .Red
//        }
        if let cardInfo = UserDefaults.standard.dictionary(forKey: iapCardInfoKey) as? [String: [String]] {
            if let redCards = cardInfo["red"],
                redCards.contains(originalTransactionId){
                return .Red
            }
            if let yellowCards = cardInfo["yellow"],
                yellowCards.contains(originalTransactionId) {
                return .Yellow
            }
        }
        return .Clear
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
                        UserDefaults.standard.set(true, forKey: id)
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
