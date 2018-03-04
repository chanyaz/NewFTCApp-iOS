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
    
    init(adDisplay: AdDisplay, englishText: Bool, englishAudio: Bool, exclusiveContent: Bool, editorsChoice: Bool) {
        self.adDisplay = adDisplay
        self.englishText = englishText
        self.englishAudio = englishAudio
        self.exclusiveContent = exclusiveContent
        self.editorsChoice = editorsChoice
    }
    
    init() {
        self.adDisplay = .all
        self.englishText = false
        self.englishAudio = false
        self.exclusiveContent = false
        self.editorsChoice = false
    }

}

struct PrivilegeHelper {
    
    static func updateFromDevice() {
        let memberships = IAPProducts.memberships
        for membership in memberships {
            if let id = membership["id"] as? String {
                let purchased = UserDefaults.standard.bool(forKey: id)
                //print ("IAP: \(id) purchase status is \(purchased)")
                if purchased == true {
                    if let privilege = membership["privilege"] as? Privilege {
                        Privilege.shared = privilege
                        print ("IAP: check locally and privilege is \(privilege)")
                    }
                }
            }
        }
    }
    
    static func updateFromReceipt(_ receipt: [String: AnyObject]) {
        if let status = receipt["status"] as? Int,
            status == 0,
            let receipts = receipt["receipt"] as? [String: Any],
            let receiptItems = receipts["in_app"] as? [[String: Any]] {
            
            var products = [String: ProductStatus]()
            for item in receiptItems {
                if let id = item["product_id"] as? String {
                    if let expiresDate = item["expires_date"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
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
            // MARK: Now compare dates and save to device
            for (id, status) in products {
                if let date = status.expireDate {
                    // MARK: handle subscrition expiration date
                    if date >= Date() {
                        //print ("\(id) is valid! ")
                        UserDefaults.standard.set(true, forKey: id)
                    } else {
                        print ("\(id) has expired at \(date), today is \(Date()). Detail Below")
                        // MARK: Don't kick user out yet. We need to make sure validation is absolutely correct.
                        //UserDefaults.standard.set(false, forKey: id)
                        if let environment = receipt["environment"] as? String {
                            print ("environment is \(environment)")
                            if environment == "Production" {
                                print (receipt)
                            }
                        }
                    }
                } else {
                    // MARK: Not a subscription
                    //print ("\(id) is valid! ")
                    UserDefaults.standard.set(true, forKey: id)
                }
                
            }
            
            // MARK: update the privileges connected to buying
            updateFromDevice()
            //print (products)
        }
    }
    
    static func updateFromNetwork() {
        let memberships = IAPProducts.memberships
        for membership in memberships {
            if let id = membership["id"] as? String {
                let purchased = IAP.checkStatus(id)
                //print ("IAP: \(id) purchase status is \(purchased)")
                if purchased != "new" {
                    if let privilege = membership["privilege"] as? Privilege {
                        Privilege.shared = privilege
                        print ("IAP: check from network and privilege is \(privilege)")
                    }
                } else {
                    UserDefaults.standard.set(false, forKey: id)
                    print ("IAP: check from network and \(id)'s purchase status is set to false")
                }
            }
        }
    }
    
    static func isPrivilegeIncluded(_ privilegeType: PrivilegeType, in privilge: Privilege) -> Bool {
        switch privilegeType {
        case .EnglishAudio:
            return privilge.englishAudio
        case .ExclusiveContent:
            return privilge.exclusiveContent
        case .EditorsChoice:
            return privilge.editorsChoice
        }
    }
    
    // TODO: Need to get the correct words
    static func getDescription(_ privilegeType: PrivilegeType) -> (title: String, body: String) {
        switch privilegeType {
        case .EnglishAudio:
            return ("付费功能", "收听英文语音需要付费")
        case .ExclusiveContent:
            return ("付费功能", "查看独家内容需要付费")
        case .EditorsChoice:
            return ("付费功能", "阅读编辑精选需要付费")
        }
    }
    
    // MARK: Get all privileges for web
    static func getPrivilegesForWeb() -> String {
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
    var expireDate: Date?
}

enum AdDisplay {
    case no
    case reasonable
    case all
}

enum PrivilegeType {
    case EnglishAudio
    case ExclusiveContent
    case EditorsChoice
}
