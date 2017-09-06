//
//  IAPView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/5.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

class IAPView: UIView {
    var themeColor: String?
    var dataObject: ContentItem?
    let buyButton = UIButton()
    let tryButton = UIButton()
    let downloadingView = UIView()
    let progressView = UIProgressView()
    let cancelButton = UIButton()
    let downloadingStatus = UILabel()
    
    public func initUI() {
        if let price = dataObject?.productPrice {
            setButton(buyButton, title: "购买：\(price)", disabledTitle: "连接中...", position: .right, backgroundColor: Color.Button.highlight)
            buyButton.addTarget(self, action: #selector(buy(_:)), for: .touchUpInside)
        }
        setButton(tryButton, title: "试读", disabledTitle: "下载中...", position: .left, backgroundColor: Color.Button.standard)
        tryButton.addTarget(self, action: #selector(tryProduct(_:)), for: .touchUpInside)
        
        setDownloadingView()
        
        // MARK: listen to in-app purchase transaction notification. There's no need to remove it in code after iOS 9 as the system will do that for you. https://useyourloaf.com/blog/unregistering-nsnotificationcenter-observers-in-ios-9/
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseNotification(_:)),
            name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
            object: nil
        )
        
        IAPs.shared.downloadDelegate = self
        
    }
    
    private func setButton(_ button: UIButton, title: String, disabledTitle: String,  position: NSLayoutAttribute, backgroundColor: String) {
        let buttonPadding: CGFloat = 0
        let buttonWidth = self.frame.width/2 - 2*buttonPadding
        let buttonHeight = self.frame.height
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        button.layer.masksToBounds = true
        button.setTitle(title, for: .normal)
        button.setTitle(disabledTitle, for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: backgroundColor)
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundColor(color: .gray, forState: .disabled)
        self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: -buttonPadding))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -buttonPadding))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: position, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: position, multiplier: 1, constant: -buttonPadding))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
    }
    
    private func setDownloadingView() {
        // MARK: downloading view takes the full IAPView
        downloadingView.isHidden = true
        let viewHeight = self.frame.height
        downloadingView.frame = CGRect(x: 0, y: 0, width: 300, height: self.frame.height)
        downloadingView.backgroundColor = UIColor(hex: Color.Content.background)
        downloadingView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(downloadingView)
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
        
        // MARK: progress bar
        let progressHeight: CGFloat = 2
        progressView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: progressHeight)
        progressView.backgroundColor = UIColor(hex: Color.Ad.background)
        if let themeColor = themeColor {
            progressView.progressTintColor = UIColor(hex: themeColor)
        }
        progressView.progress = 0.25
        downloadingView.addSubview(progressView)
        
        // MARK: progress label
        let statusPadding: CGFloat = 14
        downloadingStatus.frame = CGRect(
            x: statusPadding,
            y: progressHeight,
            width: self.frame.width - statusPadding * 2 - viewHeight,
            height: viewHeight - progressHeight
        )
        downloadingStatus.text = "正在准备下载，点击暂停"
        downloadingStatus.textColor = UIColor(hex: Color.Content.lead)
        downloadingStatus.font = downloadingStatus.font.withSize(13)
        downloadingStatus.textAlignment = .left
        downloadingView.addSubview(downloadingStatus)
        
        // MARK: cancel button
        let buttonWidth = viewHeight - progressHeight
        cancelButton.frame = CGRect(
            x: self.frame.width - buttonWidth,
            y: progressHeight,
            width: buttonWidth,
            height: buttonWidth
        )
        if let image = UIImage(named: "Close") {
            cancelButton.setImage(image, for: .normal)
        }
        cancelButton.tintColor = UIColor(hex: Color.Ad.background)
        cancelButton.addTarget(self, action: #selector(cancelDownload(_:)), for: .touchUpInside)
        downloadingView.addSubview(cancelButton)
        
    }
    
    public func buy(_ sender: UIButton) {
        print ("buy product")
        sender.isEnabled = false
        if let id = dataObject?.id {
            IAP.buy(id)
        }
    }
    
    public func tryProduct(_ sender: UIButton) {
        sender.isEnabled = false
        print ("try product")
    }
    
    public func cancelDownload(_ sender: UIButton) {
        downloadingView.isHidden = true
        if let id = dataObject?.id {
            IAP.cancelDownload(id)
        }
    }
    
    
    // MARK: This should be public, as it will be called by other classes
    public func handlePurchaseNotification(_ notification: Notification) {
        if let notificationObject = notification.object as? [String: Any?]{
            // MARK: when user buys or restores a product, we should display relevant information
            if let productID = notificationObject["id"] as? String, let actionType = notificationObject["actionType"] as? String {
                for (_, product) in IAPs.shared.products.enumerated() {
                    guard product.productIdentifier == productID else { continue }
                    //var iapAction: String = "success"
                    let currentProduct = IAP.findProductInfoById(productID)
                    let productGroup = currentProduct?["group"] as? String
                    // MARK: - If it's an eBook, download immediately and update UI to "downloading"
                    if productGroup == "ebook" {
                        // iapAction = "downloading"
                        IAP.downloadProduct(productID)
                        IAP.savePurchase(productID, property: "purchased", value: "Y")
                        downloadingView.isHidden = false
                        
                    } else if actionType == "buy success" {
                        // MARK: Otherwise if it's a buy action, save the purchase information and update UI accordingly
                        let transactionDate = notificationObject["date"] as? Date
                        IAP.updatePurchaseHistory(productID, date: transactionDate)
                        downloadingView.isHidden = true
                        /*
                         if let periodLength = currentProduct?["period"] as? String {
                         if let expire = getExpireDateFromPurchaseHistory(productID, periodLength: periodLength) {
                         let expireDate = Date(timeIntervalSince1970: expire)
                         let dayTimePeriodFormatter = DateFormatter()
                         dayTimePeriodFormatter.dateFormat = "YYYY年MM月dd日"
                         expireDateString = dayTimePeriodFormatter.string(from: expireDate)
                         }
                         }
                         */
                    }
                    //                    jsCode = "iapActions('\(productID)', '\(iapAction)')"
                    //                    print(jsCode)
                    //                    self.webView.evaluateJavaScript(jsCode) { (result, error) in
                    //                    }
                    IAP.trackIAPActions(actionType, productId: productID)
                }
            } else if let errorObject = notification.object as? [String : String?] {
                // MARK: - When there is an error
                if let productId = errorObject["id"]{
                    let errorMessage = (errorObject["error"] ?? "") ?? ""
                    let productIdForTracking = productId ?? ""
                    // MARK: - If user cancel buying, no need to pop out alert
                    if errorMessage == "usercancel" {
                        IAP.trackIAPActions("cancel buying", productId: productIdForTracking)
                    } else {
                        let alert = UIAlertController(title: "交易失败，您的钱还在口袋里", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
                        if let topViewController = UIApplication.topViewController() {
                            topViewController.present(alert, animated: true, completion: nil)
                        }
                        IAP.trackIAPActions("buy or restore error", productId: "\(productIdForTracking): \(errorMessage)")
                    }
                    // MARK: update the buy button
                    buyButton.isEnabled = true
                    
                    // MARK: - For subscription types, should consider the situation of Failing to Renew in the webview's JavaScript Code of function iapActions, which means the UI should go back to renew button and display expire date
                    //                    jsCode = "iapActions('\(productId ?? "")', 'fail')"
                    //                    self.webView.evaluateJavaScript(jsCode) { (result, error) in
                    //                    }
                }
            }
        } else {
            // MARK: When the transaction fail without any error message (NSError)
            let alert = UIAlertController(title: "交易失败，您的钱还在口袋里", message: "未知错误", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
            if let topViewController = UIApplication.topViewController() {
                topViewController.present(alert, animated: true, completion: nil)
            }
            buyButton.isEnabled = true
            //            jsCode = "iapActions('', 'fail')"
            //            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            //            }
            IAP.trackIAPActions("buy or restore error", productId: "")
        }
    }
    
}

extension IAPView: URLSessionDownloadDelegate {
    //MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        if let productId = session.configuration.identifier {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentDirectoryPath:String = path[0]
            let fileManager = FileManager()
            let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(productId)"))
            
            print ("\(productId) file downloaded to: \(location.absoluteURL)")
            if fileManager.fileExists(atPath: destinationURLForFile.path){
                //showFileWithPath(path: destinationURLForFile.path)
                print ("the file exists, you can open it. ")
            } else {
                do {
                    try fileManager.moveItem(at: location, to: destinationURLForFile)
                    print ("file moved. you can open it")
                    
                    // MARK: - Remove excerpt file when user downloaded the full file
                    if !productId.hasPrefix("try") {
                        let exerptPath = "try." + destinationURLForFile.path
                        if fileManager.fileExists(atPath: exerptPath){
                            try FileManager.default.removeItem(atPath: exerptPath)
                            print ("removed the excerpt file")
                        }
                    }
                    
                    // MARK: - Save the purchase information in the user default
                    if !productId.hasPrefix("try") {
                        IAP.savePurchase(productId, property: "purchased", value: "Y")
                    }
                    
                    IAP.trackIAPActions("download success", productId: productId)
                    if productId.hasPrefix("try") {
                        // TODO: - This is a trial file, open it immediately
                        /*
                         print ("open the try book")
                         let config = FolioReaderConfig()
                         config.scrollDirection = .horizontal
                         config.allowSharing = false
                         config.tintColor = UIColor(netHex: 0x9E2F50)
                         config.menuBackgroundColor = UIColor(netHex: 0xFFF1E0)
                         config.enableTTS = false
                         let jsCode = "iapActions('\(productId.replacingOccurrences(of: "try.", with: ""))', 'fail');"
                         self.webView.evaluateJavaScript(jsCode) { (result, error) in
                         }
                         */
                        if let fileLocation = Download.checkFilePath(fileUrl: productId, for: .documentDirectory) {
                            DispatchQueue.main.async {
                                // TODO: uncomment after installing the Folio reader
                                /*
                                 FolioReader.presentReader(parentViewController: self, withEpubPath: fileLocation, andConfig: config)
                                 */
                                print ("should open the file at \(fileLocation)")
                                IAP.trackIAPActions("download excerpt success", productId: productId)
                            }
                        }
                        return
                    }
                }catch{
                    print("An error occurred while moving file to destination url")
                    IAP.trackIAPActions("save fail", productId: productId)
                }
            }
            downloadingView.isHidden = true
            //            let jsCode = "iapActions('\(productId)', 'success');"
            //            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            //            }
        }
    }
    
    
    
    // MARK: - Get progress status for download tasks and update UI
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        // MARK: - evaluateJavaScript is very energy consuming, do this only every 1k download
        if let productId = session.configuration.identifier {
            let totalMBsWritten = String(format: "%.1f", Float(totalBytesWritten)/1000000)
            let percentageNumber = 100 * Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            if totalMBsWritten == "0.0" {
                IAPs.shared.downloadProgresses[productId] = "0.0"
            }
            if IAPs.shared.downloadProgresses[productId] != totalMBsWritten {
                IAPs.shared.downloadProgresses[productId] = totalMBsWritten
                let totalMBsExpectedToWrite = String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)
                // TODO: update UI in the view
                print ("updateDownloadProgress('\(productId)', '\(percentageNumber)%', '\(totalMBsWritten)M / \(totalMBsExpectedToWrite)M')")
                downloadingStatus.text = "\(totalMBsWritten)M / \(totalMBsExpectedToWrite)M 点击暂停"
                progressView.progress = percentageNumber/100
                //                let jsCode = "updateDownloadProgress('\(productId)', '\(percentageNumber)%', '\(totalMBsWritten)M / \(totalMBsExpectedToWrite)M')"
                //                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                //                }
            }
        }
    }
    
    // MARK: - Deal with errors in download process
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        if let error = error {
            print(error.localizedDescription)
            Alert.present("下载失败，您可以稍后再试", message: error.localizedDescription)
            if let productId = session.configuration.identifier {
                // TODO: Update UI in the view
                //                let jsCode = "iapActions('\(productId)', 'pendingdownload');"
                //                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                //                }
                IAP.trackIAPActions("download fail", productId: productId)
            }
            downloadingView.isHidden = true
            
        }
    }
    
}
