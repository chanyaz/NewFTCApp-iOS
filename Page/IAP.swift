//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/31.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import StoreKit
// import FolioReaderKit

enum PurchaseStatus {
    case All
    case Purchased
    case NotPurchased
}

struct IAP {
    // MARK: - The key name for purchase information in user defaults
    public static let myPurchasesKey = "My Purchases"
    public static let purchaseHistoryKey = "purchase history"
    public static let purchasedPropertyString = "purchased"
    private static let productPricesKey = "Product Prices Key"
    public static let expiresKey = "expires"
    public static let buyErrorString = "buy or restore error"
    
    
    public static func get(_ products: [SKProduct], in group: String?, with privilege: PrivilegeType?, include purchaseStatus: PurchaseStatus) -> [ContentItem] {
        var contentItems = [ContentItem]()
        
        for oneProduct in IAPProducts.allProducts {
            if let id = oneProduct["id"] as? String {
                // MARK: If product group doesn't fit, fall through the loop immediately
                let productGroup = oneProduct["group"] as? String ?? ""
                if let groupFilterString = group, groupFilterString != productGroup {
                    continue
                }
                
                // MARK: - If the privilege type doesn't fit, fall through the loop immediately
                if let privilege = privilege,
                    let productPrivilege = oneProduct["privilege"] as? Privilege,
                    PrivilegeHelper.isPrivilegeIncluded(privilege, in: productPrivilege) == false {
                    print ("Privilge Check: \(privilege) not included in \(productPrivilege)")
                    continue
                }
                
                // MARK: - Get product information from bundle
                var productTitle = oneProduct["title"] as? String ?? ""
                
                // print ("product title is now: \(productTitle)")
                let productImage = oneProduct["image"] as? String ?? ""
                let productTeaser = oneProduct["teaser"] as? String ?? ""
                
                let productGroupTitle = oneProduct["groupTitle"] as? String ?? ""
                let isDownloaded = { () -> Bool in
                    let fileName = getFileName(id)
                    if Download.checkFilePath(fileUrl: fileName, for: .documentDirectory) == nil {
                        return false
                    } else {
                        return true
                    }
                }()
                // MARK: - Get product information from StoreKit
                var isPurchased = IAPProducts.store.isProductPurchased(id)
                //print ("IAP Product First Check. isPurchased: \(isPurchased)")
                
                // MARK: - Membership Benefits
                //var benefitsString = ""
                //                if let benefits = oneProduct["benefits"] as? [String] {
                //                    for benefit in benefits {
                //                        benefitsString += ",'\(benefit)'"
                //                    }
                //                }
                let productBenefits = oneProduct["benefits"] as? [String]
                
                //
                //                if benefitsString != "" {
                //                    benefitsString = ",benefits:[\(benefitsString)]".replacingOccurrences(of: "[,", with: "[")
                //                }
                
                // MARK: - If isPurchaed is false, check the user default
                // FIXME: - This might be a potential loophole later if we are selling more expensive products
                if isPurchased == false {
                    if Download.getPropertyFromUserDefault(id, property: purchasedPropertyString) == "Y" {
                        isPurchased = true
                    }
                }
                
                //print ("IAP Product Second Check. isPurchased: \(isPurchased)")
                
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
                        productPrice = priceFormatter.string(from: product.price) ?? getPriceInfoFromLocal(id)
                        productDescription = product.localizedDescription
                        
                        if product.localizedTitle != "" {
                            productTitle = product.localizedTitle
                        }
                        //print ("product title changed to: \(productTitle)")
                        break
                    }
                }
                
                if let productDescriptionFromBundle = oneProduct["description"] as? String {
                    productDescription = productDescriptionFromBundle
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
                contentItem.productBenefits = productBenefits
                let productPurchaseStatus: PurchaseStatus = (isPurchased) ? .Purchased: .NotPurchased
                if purchaseStatus == .All || productPurchaseStatus == purchaseStatus {
                    contentItems.append(contentItem)
                    //print ("IAP Product Displayed. Product Purchase Status: \(productPurchaseStatus). Purchase Status: \(purchaseStatus)")
                } else {
                    //print ("IAP Product NOT Displayed. Product Purchase Status: \(productPurchaseStatus). Purchase Status: \(purchaseStatus)")
                }
            }
        }
        
        return contentItems
    }
    
    
    public static func getJSON(_ products: [SKProduct], in group: String?, shuffle: Bool, filter: [String]?) -> String {
        var contentItems = get(products, in: group, with: nil, include: .All)
        if shuffle {
            contentItems = contentItems.shuffled()
        }
        if let ids = filter {
            contentItems = contentItems.filter{
                ids.contains($0.id)
            }
        }
        var json = ""
        for (index, contentItem) in contentItems.enumerated() {
            if index > 0 {
                json += ","
            }
            json += "{"
            json += "id:\"\(contentItem.id)\","
            json += "image:\"\(contentItem.image)\","
            json += "headline:\"\(contentItem.headline)\","
            json += "lead:\"\(contentItem.lead)\","
            json += "type:\"\(contentItem.type)\","
            json += "tag:\"\(contentItem.tag)\","
            json += "isDownloaded:\(contentItem.isDownloaded),"
            json += "expireDateString:\"\(contentItem.expireDateString ?? "")\","
            json += "periodString:\"\(contentItem.periodString ?? "")\","
            json += "productPrice:\"\(contentItem.productPrice ?? "")\""
            json += "}"
        }
        json = json.replacingOccurrences(of: "[\r\n]", with: "", options: .regularExpression)
        json = "[\(json)]"
        return json
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
    public static func savePurchase(_ productId: String, property: String, value: String) {
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
    
    // MARK: - Remove one piece of information into the user default's "my purchase" key
    public static func removePurchase(_ productId: String) {
        if var myPurchases = UserDefaults.standard.dictionary(forKey: myPurchasesKey) as? [String: Dictionary<String, String>] {
            if myPurchases[productId] != nil {
                myPurchases.removeValue(forKey: productId)
                UserDefaults.standard.set(myPurchases, forKey: myPurchasesKey)
            }
        }
    }
    
    // MARK: - Check if one piece of IAP is in the user default's "my purchase" key
    public static func checkPurchaseInDevice(_ productId: String, property: String) -> String? {
        if let myPurchases = UserDefaults.standard.dictionary(forKey: myPurchasesKey) as? [String: Dictionary<String, String>] {
            if let myPurchase = myPurchases[productId] {
                // print ("myPurchase: \(myPurchase)")
                if let value = myPurchase[property]{
                    return value
                }
            }
        }
        return nil
    }
    
    public static func updatePurchaseHistory(_ productId: String, date: Date?) {
        // MARK: - Use the date from app store's API and fall back to today's date
        let transactionDate: Date = date ?? Date()
        let unixDateStamp = round(transactionDate.timeIntervalSince1970)
        if var purchaseHistory = UserDefaults.standard.dictionary(forKey: purchaseHistoryKey) as? [String: Array<TimeInterval>] {
            if purchaseHistory[productId] != nil {
                purchaseHistory[productId]?.append(unixDateStamp)
                //print ("updated \(productId) by adding \(unixDateStamp): ")
            } else {
                purchaseHistory[productId] = [unixDateStamp]
                //print ("create \(productId) with \(unixDateStamp): ")
            }
            UserDefaults.standard.set(purchaseHistory, forKey: purchaseHistoryKey)
            //print (purchaseHistory)
        } else {
            let purchaseHistory = [productId: [unixDateStamp]]
            UserDefaults.standard.set(purchaseHistory, forKey: purchaseHistoryKey)
            //print ("created purchase history record")
            //print (purchaseHistory)
        }
    }
    
    
    
    public static func buy(_ id: String) {
        let product = findSKProductByID(id)
        if let product = product {
            IAPProducts.store.buyProduct(product)
            trackIAPActions("buy", productId: id)
        } else {
            print ("cannot find the product id for \(id), try load product again")
            IAPProducts.store.requestProducts{success, products in
                if success {
                    if let products = products {
                        IAPs.shared.products = products
                        if let productNew = findSKProductByID(id) {
                            IAPProducts.store.buyProduct(productNew)
                        }
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
    
    
    // MARK: - Read the excerpt of eBook
    public static func tryBook(_ productIdentifier: String) {
        let tryBookFileName = "try.\(productIdentifier).html"
        // MARK: - check if the file exists locally
        if let fileLocation = Download.checkFilePath(fileUrl: tryBookFileName, for: .documentDirectory) {
            if let topController = UIApplication.topViewController() {
                topController.openHTMLBook(fileLocation, productId: productIdentifier)
            }
        } else {
            print ("file not found: download it")
            let alert = UIAlertController(title: "文件还没有下载，要现在下载吗？", message: "下载到本地可以打开并阅读", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "立即下载",
                                          style: UIAlertActionStyle.default,
                                          handler: {_ in IAP.downloadProductForTrying(productIdentifier)}
            ))
            alert.addAction(UIAlertAction(title: "以后再说", style: UIAlertActionStyle.default, handler: nil))
            if let topController = UIApplication.topViewController() {
                topController.present(alert, animated: true, completion: nil)
            }
        }
        trackIAPActions("try", productId: productIdentifier)
    }
    
    public static func getFileName(_ productId: String) -> String {
        if productId.hasSuffix(".html") == false {
            return "\(productId).html"
        } else {
            return productId
        }
    }
    
    public static func downloadProductForTrying(_ productID: String) {
        print ("Download this product for trying by id: \(productID), you can continue to download and/or display the information to user")
        if let fileDownloadUrl = findProductInfoById(productID)?["downloadfortry"] as? String {
            print ("download this file: \(fileDownloadUrl)")
            var newStatus = ""
            let productIdForTrying = "try." + productID
            let fileNameForTrying = getFileName(productIdForTrying)
            if Download.checkFilePath(fileUrl: fileNameForTrying, for: .documentDirectory) == nil {
                // MARK: - Download the file through the internet
                print ("The file does not exist. Download from \(fileDownloadUrl)")
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: productIdForTrying)
                let backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: IAPs.shared.downloadDelegate, delegateQueue: IAPs.shared.downloadQueue)
                if let url = URL(string: fileDownloadUrl) {
                    print ("download try product at \(url)")
                    let request = URLRequest(url: url)
                    IAPs.shared.downloadTasks[productIdForTrying] = backgroundSession.downloadTask(with: request)
                    IAPs.shared.downloadTasks[productIdForTrying]?.resume()
                    newStatus = "downloadingtrial"
                } else {
                    newStatus = "fail"
                }
            } else {
                // MARK: - Update interface to change the button action into read
                print ("The file already exists. No need to download. Update Interface")
                newStatus = "fail"
            }
            IAPs.shared.downloadDelegate?.switchUI(newStatus)
            trackIAPActions("download excerpt", productId: productID)
        }
    }
    
    
    public static func downloadProduct(_ productID: String) {
        if let fileDownloadUrl = findProductInfoById(productID)?["download"] as? String {
            print ("download this file: \(fileDownloadUrl)")
            var newStatus = ""
            let fileName = getFileName(productID)
            if Download.checkFilePath(fileUrl: fileName, for: .documentDirectory) == nil {
                // MARK: - Download the file through the internet
                print ("The file does not exist. Download from \(fileDownloadUrl)")
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: productID)
                let backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: IAPs.shared.downloadDelegate, delegateQueue: IAPs.shared.downloadQueue)
                if let url = URL(string: fileDownloadUrl) {
                    let request = URLRequest(url: url)
                    IAPs.shared.downloadTasks[productID] = backgroundSession.downloadTask(with: request)
                    IAPs.shared.downloadTasks[productID]?.resume()
                    newStatus = "downloading"
                    //jsCode = "iapActions('\(productID)', 'downloading')"
                } else {
                    newStatus = "pendingdownload"
                    //jsCode = "iapActions('\(productID)', 'pendingdownload')"
                }
            } else {
                // MARK: - Update interface to change the button action into read
                print ("The file already exists. No need to download. Update Interface")
                newStatus = "success"
                //jsCode = "iapActions('\(productID)', 'success')"
            }
            IAPs.shared.downloadDelegate?.switchUI(newStatus)
            //self.webView.evaluateJavaScript(jsCode) { (result, error) in
        }
        trackIAPActions("download", productId: productID)
    }
    
    
    // MARK: - use Folio reader to read eBook
    public static func readBook(_ productIdentifier: String) {
        // MARK: - check if the file exists locally
        let fileName = getFileName(productIdentifier)
        if let fileLocation = Download.checkFilePath(fileUrl: fileName, for: .documentDirectory) {
            /*
             let config = FolioReaderConfig()
             config.scrollDirection = .horizontal
             config.allowSharing = false
             config.tintColor = UIColor(netHex: 0x9E2F50)
             config.menuBackgroundColor = UIColor(netHex: 0xFFF1E0)
             config.enableTTS = false
             if let topController = UIApplication.topViewController() {
             let folioReader = FolioReader()
             folioReader.presentReader(parentViewController: topController, withEpubPath: fileLocation, andConfig: config)
             }
             */
            
            if let topController = UIApplication.topViewController() {
                topController.openHTMLBook(fileLocation, productId: productIdentifier)
            }
        } else {
            print ("file not found: download it")
            let alert = UIAlertController(title: "文件还没有下载，要现在下载吗？", message: "下载到本地可以打开并阅读", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "立即下载",
                                          style: UIAlertActionStyle.default,
                                          handler: {_ in self.downloadProduct(productIdentifier)}
            ))
            alert.addAction(UIAlertAction(title: "以后再说", style: UIAlertActionStyle.default, handler: nil))
            if let topController = UIApplication.topViewController() {
                topController.present(alert, animated: true, completion: nil)
            }
        }
        trackIAPActions("read", productId: productIdentifier)
    }
    
    public static func checkStatus(_ id: String) -> String {
        let fileName = getFileName(id)
        if Download.checkFilePath(fileUrl: fileName, for: .documentDirectory) != nil {
            savePurchase(id, property: purchasedPropertyString, value: "Y")
            return "success"
        } else if IAPProducts.store.isProductPurchased(id) == true || PrivilegeHelper.isPrivilegeIncluded(.Book, in: Privilege.shared) {
            savePurchase(id, property: purchasedPropertyString, value: "Y")
            return "pendingdownload"
        }
        return "new"
    }
    
    public static func removeDownload(_ productId: String) -> String {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return "pendingdownload"
        }
        let fileName = getFileName(productId)
        let filePath = "\(dirPath)/\(fileName)"
        trackIAPActions("remove download", productId: productId)
        do {
            try fileManager.removeItem(atPath: filePath)
            print ("removed the file at \(filePath)")
            savePurchase(productId, property: purchasedPropertyString, value: "Y")
        } catch let error as NSError {
            print(error.debugDescription)
        }
        return "pendingdownload"
    }
    
    public static func pauseDownload(_ productId: String) {
        IAPs.shared.downloadTasks[productId]?.suspend()
        trackIAPActions("pause download", productId: productId)
    }
    
    public static func resumeDownload(_ productId: String) {
        IAPs.shared.downloadTasks[productId]?.resume()
        trackIAPActions("resume download", productId: productId)
    }
    
    
    public static func cancelDownload(_ productId: String) {
        IAPs.shared.downloadTasks[productId]?.cancel()
        trackIAPActions("cancel download", productId: productId)
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
    
    public static func findProductInfoById(_ productID: String) -> [String: Any]? {
        var product: [String: Any]?
        for p in IAPProducts.allProducts {
            if let id = p["id"] as? String {
                if id == productID {
                    product = p
                    break
                }
            }
        }
        return product
    }
    
    public static func trackIAPActions(_ actionType: String, productId: String) {
        Track.event(category: "In-App Purchase", action: actionType, label: productId)
        if let deviceToken = UserInfo.shared.deviceToken {
            Track.event(category: "IAP: \(actionType)", action: productId, label: deviceToken)
        }
        Track.eventToAll(category: "Privileges", action: "\(actionType): \(productId)", label: ConversionTracker.shared.item?.eventLabel ?? "")
        // MARK: If the user is tring to buy but Apple's server is down, record his/her user id so that we can check and contact her later
        if actionType == buyErrorString,
            let userId = UserInfo.shared.userId {
            Track.event(category: "IAP: \(actionType) User Id", action: productId, label: userId)
        }
    }
    
    public static func savePriceInfo(_ products: [SKProduct]) {
        var productPrices: [String: String] = [:]
        for product in products {
            let id = product.productIdentifier
            let price = product.price
            let priceFormatter: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.formatterBehavior = .behavior10_4
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                return formatter
            }()
            let productPrice = priceFormatter.string(from: price) ?? ""
            productPrices[id] = productPrice
        }
        UserDefaults.standard.set(productPrices, forKey: productPricesKey)
    }
    
    public static func getPriceInfoFromLocal(_ id: String) -> String {
        if let productPrices = UserDefaults.standard.dictionary(forKey: productPricesKey) as? [String: String]{
            if let productPrice = productPrices[id] {
                return productPrice
            }
        }
        return ""
    }
    
    // MARK: If user has bought with iOS in-app and logged in, check if his/her subscriptionType (set by our serve using coookie as of April 2018) is set correctly. 
    public static func checkMembershipStatus(_ id: String) {
        for membership in IAPProducts.memberships {
            if UserInfo.shared.iapMembershipReadyForCrossPlatform != true,
                id == membership["id"] as? String,
                let key = membership["key"] as? String,
                let userId = UserInfo.shared.userId,
                userId != "",
                UserInfo.shared.subscriptionType == nil,
                let expireDate = IAP.checkPurchaseInDevice(id, property: expiresKey),
                expireDate != "" {
                UserInfo.shared.iapMembershipReadyForCrossPlatform = false
                //print ("\(id) expires in \(String(describing: expireDate))")
                let userId = UserInfo.shared.userId ?? ""
                let urlString = APIs.get("", type: "vip", forceDomain: nil)
                let token = "\(userId)\(id)\(expireDate)".uppercased()
                let tokenWithSalt = "\(token)Ftchinese_iOS_App".md5()
                let originalTransactionId = IAP.checkPurchaseInDevice(id, property: PrivilegeHelper.originalTransactionIdKey) ?? ""
                let purchaseInfo = [
                    "user_id": userId,
                    "product_id": id,
                    "expires_date": expireDate,
                    "token": tokenWithSalt,
                    "originalTransactionId": originalTransactionId
                    ] as [String : String]
                print ("send ios iap info to server: \(urlString). expire date: \(expireDate). with: \(purchaseInfo)")
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
                                error == nil {
                                if httpResponse.statusCode == 200 {
                                    do {
                                        if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>,
                                            let status = jsonResponse["errmsg"] as? String  {
                                            if status == "success" {
                                                // MARK: - parse and verify the required informatin in the jsonResponse
                                                //print ("send ios iap info to server: success: \(jsonResponse)")
                                                UserInfo.shared.iapMembershipReadyForCrossPlatform = true
                                                if let userName = UserInfo.shared.userName,
                                                    userName != "" {
                                                    Alert.present("恭喜您：\(userName)", message: "您在苹果应用商店购买的订阅服务已经和您的FT中文网用户名成功绑定，您也可以在电脑上登录FT中文网，阅读付费内容。")
                                                }
                                            } else {
                                                
                                            }
                                        } else {
                                            print ("send ios iap info to server: fail to cast: \(String(describing: String(data: receivedData, encoding: .utf8)))")
                                        }
                                    } catch {
                                        print("send ios iap info to server: fail to convert data to json dictionary")
                                    }
                                } else {
                                    print ("send ios iap info to server: \(httpResponse.statusCode)")
                                    if let returnData = String(data: receivedData, encoding: .utf8) {
                                        print ("send ios iap info to server: \(returnData)")
                                    }
                                }
                            }
                        }
                        task.resume()
                    } else {
                        //print("receipt validation from func receiptValidation: Couldn't convert string into URL. Check for special characters.")
                    }
                } catch {
                    //print("receipt validation from func receiptValidation: Couldn't create JSON with error: " + error.localizedDescription)
                }
                Track.event(category: "iOS IAP Membership: \(key)", action: userId, label: expireDate)
                break
            }
        }
    }
    
}
