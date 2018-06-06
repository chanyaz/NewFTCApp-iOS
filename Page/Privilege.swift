//
//  Benefits.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
enum KickOutIAPReason: String {
    case Expired  = "Expired"
    case NoPurchaseRecord = "No Purchase Record"
    case AbusedPurchase = "Abused Purchase"
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
    var warningPresented = false
}

enum PurchaseSource: String {
    case AppleIAP = "Apple"
    case Site = "Site"
}


typealias ProductIdInfo = (keep: Bool, status: ProductStatus, reason: KickOutIAPReason?)
typealias ProductIdsInfo = [String: ProductIdInfo]
struct PrivilegeHelper {
    public static let dateFormatString = "yyyy-MM-dd HH:mm:ss VV"
    public static let dateFormatStringSimple = "yyyy年MM月dd日HH:mm"
    public static let purchaseSourceKey = "source"
    public static let originalTransactionIdKey = "original_transaction_id"
    private static let iapCardInfoKey = "IAP Card Info Key"
    
    public static func updatePrivilges() {
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
    
    public static func updatePurchases(_ receipt: [String: AnyObject]) {
        
        func initiateProducts(_ receiptItems: [[String : Any]]) -> [String: ProductStatus] {
            let emptyStatus = ProductStatus.init(expireDate: nil)
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
            return products
        }
        
        func addRenewalInfo(_ products: [String : ProductStatus], with receipt: [String: AnyObject]) -> (allProductIds: ProductIdsInfo, products: [String : ProductStatus], shouldRefreshReceipt: Bool){
            var products = products
            var allProductIds = ProductIdsInfo()
            var shouldRefreshReceipt = false
            let emptyStatus = ProductStatus.init(expireDate: nil)
            if let pendingRenewalInfo = receipt["pending_renewal_info"] as? [[String: Any]] {
                for item in pendingRenewalInfo {
                    if let id = item["auto_renew_product_id"] as? String,
                        let status = item["auto_renew_status"] as? String {
                        IAP.savePurchase(id, property: "auto_renew_status", value: status)
                        if let originalTransactionId = item[originalTransactionIdKey] as? String {
                            IAP.savePurchase(id, property: originalTransactionIdKey, value: originalTransactionId)
                            recordTransactionId(originalTransactionId, for: id)
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
            return (allProductIds, products, shouldRefreshReceipt)
        }
        
        func combine(_ allProductIds:  ProductIdsInfo, with products: [String : ProductStatus]) ->  ProductIdsInfo {
            var allProductIds = allProductIds
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
            return allProductIds
        }
        
        func updateMemberships(_ allProductIds: ProductIdsInfo, with products: [String : ProductStatus], from shouldRefreshReceipt: Bool) -> (allProductIds: ProductIdsInfo, shouldRefreshReceipt: Bool) {
            var allProductIds = allProductIds
            var foundValidMembershipPurchase = false
            let emptyStatus = ProductStatus.init(expireDate: nil)
            var shouldRefreshReceipt = shouldRefreshReceipt
            for membership in IAPProducts.memberships {
                if let id = membership["id"] as? String {
                    // MARK: If the expiration date is in the future, connect the purchase to server side user id
                    if let product = products[id],
                        let expireDate = product.expireDate,
                        expireDate >= Date() {
                        // MARK: Check if the server side has recorded the purchase correctly
                        IAP.checkMembershipStatus(id)
                        foundValidMembershipPurchase = true
                    }
                    if products[id] == nil {
                        print ("IAP Check: \(id) is not valid")
                        allProductIds[id] = (false, emptyStatus, .NoPurchaseRecord)
                        //kickOutFromIAP(id, with: receipt, for: .NoPurchaseRecord)
                    }
                }
            }
            // MARK: If there's not even one valid membership purchase, refresh receipt just once
            if foundValidMembershipPurchase == false {
                shouldRefreshReceipt = true
            }
            print ("IAP Check: all product id: \(allProductIds)")
            return (allProductIds, shouldRefreshReceipt)
        }
        
        func actOn(_ allProductIds: ProductIdsInfo) {
            for (id, productInfo) in allProductIds {
                // MARK: Keep the product or kick out
                if productInfo.keep == true {
                    UserDefaults.standard.set(productInfo.keep, forKey: id)
                    print ("IAP Check: keep \(id). keep: \(productInfo.keep)")
                } else {
                    kickOutFromIAP(id, with: receipt, for: productInfo.reason)
                    print ("IAP Check: kick \(id). keep: \(productInfo.keep)")
                }
                // MARK: If the product is valid, or if it is kicked out because of expiration
                if productInfo.keep || productInfo.reason == .Expired {
                    saveExpirationDate(id, productInfo: productInfo)
                }
            }
        }
        
        func saveExpirationDate(_ id: String, productInfo: ProductIdInfo) {
            if let date = productInfo.status.expireDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateFormatString
                let expireDateString = dateFormatter.string(from: date)
                IAP.savePurchase(id, property: IAP.expiresKey, value: expireDateString)
                IAP.savePurchase(id, property: purchaseSourceKey, value: PurchaseSource.AppleIAP.rawValue)
                print ("IAP Check: update \(id) with expiration date of \(expireDateString)")
            }
        }
        
        // MARK: if the receipt is flagged by server side as being abused, we should refresh
        var shouldRefreshReceipt = false
        
        // MARK: Analyze the receipt to decide which purchases and subscriptions are valid
        if let status = receipt["status"] as? Int,
            status == 0,
            let receipts = receipt["receipt"] as? [String: Any],
            let receiptItems = receipts["in_app"] as? [[String: Any]],
            receiptItems.count > 0 {
            // print ("IAP Check: \(receipt)")
            
            // MARK: 1. Loop through all the IAP orders to update products information
            var products = initiateProducts(receiptItems)
            
            // MARK: 2. Parse pending_renewal_info to get information about the user's auto_renew_status
            let productWithRenewalInfo = addRenewalInfo(products, with: receipt)
            var allProductIds = productWithRenewalInfo.allProductIds
            products = productWithRenewalInfo.products
            shouldRefreshReceipt = productWithRenewalInfo.shouldRefreshReceipt
            
            // MARK: 3. Loop through the valid ids generated from previous steps, keep the valid ones and keep out invalid or expired ones
            allProductIds = combine(allProductIds, with: products)
            
            // MARK: 4. Loop through all memberships and kick out those that are not included in the receipt
            let membershipInfo = updateMemberships(allProductIds, with: products, from: shouldRefreshReceipt)
            allProductIds = membershipInfo.allProductIds
            shouldRefreshReceipt = membershipInfo.shouldRefreshReceipt
            
            // MARK: 5. Take actions with what we get from the receipt
            actOn(allProductIds)
            
            // MARK: 6. post notification about the receipt validation event
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
        // MARK: update the privileges connected to buying
        updatePrivilges()
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
    
    // MARK: Send Transaction ID and Device Id to server for validation and black listing
    private static func recordTransactionId(_ originalTransactionId: String, for productId: String) {
        print ("IAP Check: updating original transaction id: \(originalTransactionId)")
        let userId = UserInfo.shared.userId ?? ""
        let token = UserInfo.shared.deviceToken ?? ""
        let purchaseInfo = [
            "user_id": userId,
            "product_id": productId,
            "token": token,
            "originalTransactionId": originalTransactionId
        ]
        let urlString = APIs.getiOSOriginalTransactionIdTrackUrlString()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: purchaseInfo, options: .init(rawValue: 0))
            if let siteServerUrl = Foundation.URL(string:urlString) {
                var request = URLRequest(url: siteServerUrl)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let task = session.dataTask(with: request) { data, response, error in
                    if let receivedData = data,
                        let httpResponse = response as? HTTPURLResponse,
                        error == nil,
                        httpResponse.statusCode == 200 {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>,
                                let status = jsonResponse["errmsg"] as? String,
                                status == "success" {
                                // MARK: - The
                            } else {
                            }
                        } catch {
                            
                        }
                    }
                }
                task.resume()
            } else {
            }
        } catch {
        }
    }
    
    public static func checkTransactionId(_ originalTransactionId: String) -> CardType {
        func presentWarning(_ cardType: CardType, with originalTransactionId: String) {
            if InAppPurchases.shared.warningPresented {
                return
            }
            InAppPurchases.shared.warningPresented = true
            switch cardType {
            case .Red:
                Alert.present("亲爱的读者", message: "我们检测到您使用的苹果应用商店Apple ID被用在多个设备上，当前使用的这个Apple ID已经被禁止使用我们的订阅服务。请您使用自己的Apple ID来购买FT中文网的服务。")
            case .Yellow:
                Alert.present("温馨提示", message: "我们检测到您使用的苹果应用商店Apple ID被用在多个设备上，请您使用自己的Apple ID来购买FT中文网的服务。")
            default:
                break
            }
            let userId = UserInfo.shared.userId ?? ""
            let token = UserInfo.shared.deviceToken ?? ""
            let cardTypeString = cardType.rawValue
            Track.event(category: "IAP: \(originalTransactionId)", action: "Show \(cardTypeString)", label: "u:\(userId),t:\(token)")
        }
        // TEST: Use oliver's id
//        if originalTransactionId == "1000000378980806" {
//            presentWarning(.Red, with: originalTransactionId)
//            return .Red
//        }
        let cards: [CardType] = [.Red, .Yellow]
        for card in cards {
            let cardKey = getCardKey(card)
            if let cardInfo = UserDefaults.standard.array(forKey: cardKey) as? [String],
                cardInfo.contains(originalTransactionId) {
                presentWarning(card, with: originalTransactionId)
                return card
            }
        }
        return .Clear
    }
    
    private static func getCardKey(_ type: CardType) -> String {
        let cardKey = "\(iapCardInfoKey): \(type.rawValue)"
        return cardKey
    }
    
    public static func getBlackListForTransactionIds() {
        let cards: [(type: CardType, url: String)] = [
            (.Red, APIs.get("redcard_ios", type: "iosBlackList", forceDomain: nil)),
            (.Yellow, APIs.get("yellowcard_ios", type: "iosBlackList", forceDomain: nil))
        ]
        for card in cards {
            let urlString = card.url
            let cardKey = getCardKey(card.type)
            if let url = URL(string: urlString) {
                Download.getDataFromUrl(url) {(data, response, error) in
                    if let data = data,
                        let results = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)),
                        let ids = results as? [String] {
                        UserDefaults.standard.set(ids, forKey: cardKey)
                    }
                }
            }
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
