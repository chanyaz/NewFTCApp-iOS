/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// MARK: - IAP Tutorial 1: Basic Insfrastructure

import StoreKit
// MARK: - Product Identifier is used to find and retrieve products and download processes
public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

enum BuyState {
    case New
    case Purchasing
    case Purchased
}

open class IAPHelper : NSObject  {
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"
    fileprivate static let url = Bundle.main.appStoreReceiptURL
    fileprivate lazy var receipt: NSData? = nil
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            // MARK: - Saving the purchase information when you init the app again. If the user is not online or logged into apple account, he/she will not be able to use or see the products he already bought last time. So the user defaults need to be updated in the view controller event listeners when a purchase or download is successful. This is useful if the user switch to another device.
            // TODO: - User defaults may not be the best place to store information about purchased products in a real application. An owner of a jailbroken device could easily access your app’s UserDefaults plist, and modify it to ‘unlock’ purchases. If this sort of thing concerns you, then it’s worth checking out Apple’s documentation on Validating App Store Receipts – this allows you to verify that a user has made a particular purchase.
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            print ("\(productIdentifier) is set to \(purchased)")

            let downloaded = { () -> Bool in
                if Download.checkFilePath(fileUrl: productIdentifier, for: .documentDirectory) == nil {
                    return false
                } else {
                    return true
                }
            }()
            if downloaded {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("IAP Helper: Previously downloaded: \(productIdentifier)")
            } else if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("IAP Helper: Previously purchased: \(productIdentifier)")
            } else {
                print("IAP Helper: Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        // TODO: - If there's a receipt url, get the receipt
        if let url = IAPHelper.url {
            self.receipt = NSData(contentsOf: url)
        }
        //print (receipt ?? "no receipt is found")
        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API

extension IAPHelper {
    // MARK: Stage 1:  Retrieving Product Information
    // MARK: Request products from app store by passing product identifiers. Note that Apple doesn't allow you to request products if you don't already know the product ids.
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    // MARK: - Stage 2: Requesting Payment
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    // MARK: - Only non-consumable and auto-renewal subscriptions can be restored. For consumablables and non-renewal subscriptions, the developer needs to manage restoration by themselves.
    public func restorePurchases() {
        print ("restore purchase transaction")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - Stage 1:  Retrieving Product Information: Implement the SKProductsRequestDelegate protocol to handle product requests
extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
//        for p in products {
//            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
//        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - Stage 3: Delivering Products
extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                purchaseSuccess(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                // TODO: Defered Purchase!
                print ("defered state! should do something")
                break
            case .purchasing:
                print ("purchasing, user should know about this")
                break
            }
        }
    }
    
    private func purchaseSuccess(transaction: SKPaymentTransaction) {
        let actionType = "buy success"
        let productId = transaction.payment.productIdentifier
        savePurchaseInfoToDevice(transaction, actionType: actionType, productId: productId)
        deliverPurchaseNotificationFor(actionType, identifier: productId, date: transaction.transactionDate)
        PrivilegeHelper.updateFromDevice()
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        let actionType = "restore success"
        guard let productId = transaction.original?.payment.productIdentifier else { return }
        savePurchaseInfoToDevice(transaction, actionType: actionType, productId: productId)
        deliverPurchaseNotificationFor(actionType, identifier: productId, date: transaction.transactionDate)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError? {
            let productId = transaction.payment.productIdentifier
            print("\(productId) Transaction Error: \(String(describing: transaction.error?.localizedDescription))")
            switch (transactionError.code) {
            case SKError.paymentCancelled.rawValue:
                print("user cancelled the request")
                IAP.trackIAPActions("cancel buying", productId: productId)
                break
            default:
                let errorMessage = transactionError.localizedDescription
                IAP.trackIAPActions("buy or restore error", productId: "\(productId): \(errorMessage)")
                break
            }
            deliverPurchaseFailNotification(transactionError, productId: productId)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // MARK: Update Information that are stored in the device
    private func savePurchaseInfoToDevice(_ transaction: SKPaymentTransaction, actionType: String, productId: String) {
        let transactionDate = transaction.transactionDate
        // MARK: Update purchase history and Track here not in the IAP View or View Controller
        IAP.savePurchase(productId, property: IAP.purchasedPropertyString, value: "Y")
        IAP.updatePurchaseHistory(productId, date: transactionDate)
        IAP.trackIAPActions(actionType, productId: productId)
        purchasedProductIdentifiers.insert(productId)
        UserDefaults.standard.set(true, forKey: productId)
        // MARK: - save purchase history here, something like updatePurchaseHistory()
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Send notifications to iap view or view controller so that UI can be updated
    private func deliverPurchaseNotificationFor(_ actionType: String, identifier: String?, date: Date?) {
        if let identifier = identifier {
            let transactionSuccessObject = [
                "id": identifier,
                "actionType": actionType,
                "date": date as Any
                ] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: transactionSuccessObject)
        }
    }
    
    private func deliverPurchaseFailNotification(_ transactionError: NSError?, productId: String) {
        let errorMessage = transactionError?.localizedDescription
        let transactionErrorObject = [
            "id": productId,
            "error": errorMessage
        ]
        NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: transactionErrorObject)
    }
}
