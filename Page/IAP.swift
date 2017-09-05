//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/31.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import StoreKit

struct IAP {
    // MARK: - The key name for purchase information in user defaults
    public static let myPurchasesKey = "My Purchases"
    public static let purchaseHistoryKey = "purchase history"
    
    public static func get(_ products: [SKProduct], in group: String?) -> [ContentItem] {
        var contentItems = [ContentItem]()
        for oneProduct in FTCProducts.allProducts {
            if let id = oneProduct["id"] as? String {
                // MARK: If product group doesn't fit, fall through the loop immediately
                let productGroup = oneProduct["group"] as? String ?? ""
                if let groupFilterString = group, groupFilterString != productGroup {
                    continue
                }
                
                // MARK: - Get product information from bundle
                var productTitle = oneProduct["title"] as? String ?? ""
                
                // print ("product title is now: \(productTitle)")
                let productImage = oneProduct["image"] as? String ?? ""
                let productTeaser = oneProduct["teaser"] as? String ?? ""
                
                let productGroupTitle = oneProduct["groupTitle"] as? String ?? ""
                let isDownloaded = { () -> Bool in
                    if Download.checkFilePath(fileUrl: id, for: .documentDirectory) == nil {
                        return false
                    } else {
                        return true
                    }
                }()
                // MARK: - Get product information from StoreKit
                var isPurchased = FTCProducts.store.isProductPurchased(id)
                
                // MARK: - Membership Benefits
                var benefitsString = ""
                if let benefits = oneProduct["benefits"] as? [String] {
                    for benefit in benefits {
                        benefitsString += ",'\(benefit)'"
                    }
                }
                
                if benefitsString != "" {
                    benefitsString = ",benefits:[\(benefitsString)]".replacingOccurrences(of: "[,", with: "[")
                }
                
                // MARK: - If isPurchaed is false, check the user default
                // FIXME: - This might be a potential loophole later if we are selling more expensive products
                if isPurchased == false {
                    if Download.getPropertyFromUserDefault(id, property: "purchased") == "Y" {
                        isPurchased = true
                    }
                }
                
                // MARK: - Get expire date from user default
                var expireDateString = ""
                var periodString = ""
                if let priodLenth = oneProduct["period"] as? String {
                    let expireDateUnix = getExpireDateFromPurchaseHistory(id, periodLength: priodLenth)
                    if let expireDateUnix = expireDateUnix {
                        let expireDate = Date(timeIntervalSince1970: expireDateUnix)
                        let dayTimePeriodFormatter = DateFormatter()
                        dayTimePeriodFormatter.dateFormat = "YYYY年MM月dd日"
                        let dateString = dayTimePeriodFormatter.string(from: expireDate)
                        expireDateString = ",expire:'\(dateString)',expireDateUnix:\(expireDateUnix)"
                    }
                    periodString = ",period:'\(priodLenth)'"
                }
                
                var productPrice: String = ""
                var productDescription: String = ""
                for product in products {
                    if id == product.productIdentifier {
                        let priceFormatter: NumberFormatter = {
                            let formatter = NumberFormatter()
                            formatter.formatterBehavior = .behavior10_4
                            formatter.numberStyle = .currency
                            formatter.locale = product.priceLocale
                            return formatter
                        }()
                        productPrice = priceFormatter.string(from: product.price) ?? ""
                        productDescription = product.localizedDescription
                        
                        if product.localizedTitle != "" {
                            productTitle = product.localizedTitle
                        }
                        //print ("product title changed to: \(productTitle)")
                        break
                    }
                }
                
                // MARK: if product description cannot be retrieved, use teaser
                if productDescription == "" {
                    // MARK: if product description is empty, try get it from user default
                    productDescription = Download.getPropertyFromUserDefault(id, property: "description") ?? productTeaser
                } else {
                    // MARK: save product description to user default
                    savePurchase(id, property: "description", value: productDescription)
                }
                
                //productDescription = "<p>\(productDescription.replacingOccurrences(of: "\n", with: "</p><p>", options: .regularExpression))</p>"
                
                //                let productString = "{title: '\(productTitle)',description: '\(productDescription)',price: '\(productPrice)',id: '\(id)',image: '\(productImage)', teaser: '\(productTeaser)', isPurchased: \(isPurchased), isDownloaded: \(isDownloaded), group: '\(productGroup)', groupTitle: '\(productGroupTitle)'\(benefitsString)\(expireDateString)\(periodString)}"
                //                productsString += ",\(productString)"
                let contentItem = ContentItem(
                    id: id,
                    image: productImage,
                    headline: productTitle,
                    lead: productTeaser,
                    type: productGroup,
                    preferSponsorImage: "",
                    tag: productGroup,
                    customLink: "",
                    timeStamp: 0,
                    section: 0,
                    row: 0
                )
                contentItem.cbody = productDescription
                contentItem.productGroupTitle = productGroupTitle
                contentItem.isDownloaded = isDownloaded
                contentItem.expireDateString = expireDateString
                contentItem.periodString = periodString
                contentItem.productPrice = productPrice
                contentItems.append(contentItem)
            }
        }
        
        return contentItems
    }
    
    
    
    
    
    // MARK: - Get the expire date of non-renewing subscriptions from purchase history
    private static func getExpireDateFromPurchaseHistory(_ productId: String, periodLength: String) -> TimeInterval? {
        if let purchaseHistories = UserDefaults.standard.dictionary(forKey: purchaseHistoryKey) as? [String: Array<TimeInterval>] {
            if let purchaseHistory = purchaseHistories[productId] {
                let onePeriod:Double
                switch periodLength{
                case "month":
                    onePeriod = Double(31 * 24 * 60 * 60)
                case "week":
                    onePeriod = Double(7 * 24 * 60 * 60)
                case "day":
                    onePeriod = Double(2 * 24 * 60 * 60)
                default:
                    onePeriod =  Double(366 * 24 * 60 * 60)
                }
                let purchaseHistoryInOrder = purchaseHistory.sorted()
                var expireTime: Double?
                for purchaseTime in purchaseHistoryInOrder {
                    // MARK: - renewal
                    if let newExpireTime = expireTime {
                        if newExpireTime > purchaseTime {
                            expireTime = newExpireTime + onePeriod
                        } else {
                            expireTime = purchaseTime + onePeriod
                        }
                    } else {
                        // MARK: - the first purchase
                        expireTime = purchaseTime + onePeriod
                    }
                }
                let finalExpireTime = expireTime as TimeInterval?
                return finalExpireTime
            }
        }
        return nil
    }
    
    
    // MARK: - Save one piece of information into the user default's "my purchase" key
    private static func savePurchase(_ productId: String, property: String, value: String) {
        if var myPurchases = UserDefaults.standard.dictionary(forKey: myPurchasesKey) as? [String: Dictionary<String, String>] {
            if myPurchases[productId] != nil {
                myPurchases[productId]?[property] = value
                //print ("updated my purchase \(productId) \(property): ")
            } else {
                myPurchases[productId] = [property: value]
                //print ("updated my purchase \(productId) by adding \(property): ")
            }
            UserDefaults.standard.set(myPurchases, forKey: myPurchasesKey)
            //print (myPurchases)
        } else {
            let myPurchases = [productId: [property: value]]
            UserDefaults.standard.set(myPurchases, forKey: myPurchasesKey)
            //print ("created my purchase status: ")
            //print (myPurchases)
        }
    }
    
    
    
    public static func buy(_ id: String) {
//        print (urlString)
//        let productId = urlString.replacingOccurrences(of: "buy://", with: "")
        let product = findSKProductByID(id)
        if let product = product {
            FTCProducts.store.buyProduct(product)
            // MARK: Update the interface go let users know the buying is in process
//            let jsCode = "iapActions('\(productId)', 'pending');"
//            self.webView.evaluateJavaScript(jsCode) { (result, error) in
//            }
            trackIAPActions("buy", productId: id)
        } else {
            print ("cannot find the product id, try load product again")
            FTCProducts.store.requestProducts{success, products in
                if success {
                    if let products = products {
                        IAPs.shared.products = products
                        if let productNew = self.findSKProductByID(id) {
                            FTCProducts.store.buyProduct(productNew)
                            // MARK: Update the interface go let users know the buying is in process
//                            let jsCode = "iapActions('\(productId)', 'pending');"
//                            self.webView.evaluateJavaScript(jsCode) { (result, error) in
//                            }
                        }
//                        self.productToJSCode(self.products, jsVariableName: "displayProductsOnHome", jsVariableType: "function")
//                        self.productToJSCode(self.products, jsVariableName: "iapProducts", jsVariableType: "object")
                    }
                } else {
                    print ("cannot connect to app store right now!")
                    // MARK: - pop up alert to let user know about this
                    let alert = UIAlertController(title: "交易失败", message: "现在无法连接到App Store进行购买，请在网络状况比较好的情况下重试", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.default, handler: nil))
                    //self.present(alert, animated: true, completion: nil)
                    if let topController = UIApplication.topViewController() {
                        topController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    
    
    private static func findSKProductByID(_ productID: String) -> SKProduct? {
        var product: SKProduct?
        for p in IAPs.shared.products {
            if p.productIdentifier == productID {
                product = p
                print ("product id matched: \(p.productIdentifier)")
                break
            }
        }
        return product
    }
    
    private static func trackIAPActions(_ actionType: String, productId: String) {
        Track.event(category: "In-App Purchase", action: actionType, label: productId)
    }
    
    
}

