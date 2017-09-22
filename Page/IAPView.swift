//
//  IAPView.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/5.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
// import FolioReaderKit

class IAPView: UIView {
    
    var themeColor: String?
    var dataObject: ContentItem?
    var buttons: [String: UIButton] = [
        "buy": UIButton(),
        "try": UIButton(),
        "open": UIButton(),
        "delete": UIButton(),
        "download": UIButton()
    ]
    var action: String?
    var verticalPadding: CGFloat = 10
    let horizontalPadding: CGFloat = 14
    let tryButton = UIButton()
    let downloadingView = UIView()
    let progressView = UIProgressView()
    let cancelButton = UIButton()
    let downloadingStatus = UILabel()
    var currentDownloadStatus: DownloadStatus = .remote
    
    
    public func initUI() {
        self.backgroundColor = UIColor(hex: Color.Content.background)
        if let price = dataObject?.productPrice {
            setButton(buttons["buy"], title: "购买：\(price)", disabledTitle: "连接中...", positions: [.right], width: "half", type: "highlight")
            buttons["buy"]?.addTarget(self, action: #selector(buy(_:)), for: .touchUpInside)
        }
        setButton(buttons["try"], title: "试读", disabledTitle: "下载中...", positions: [.left], width: "half", type: "standard")
        buttons["try"]?.addTarget(self, action: #selector(tryProduct(_:)), for: .touchUpInside)
        
        setButton(buttons["open"], title: "打开", disabledTitle: "打开中...", positions: [.left], width: "half", type: "highlight")
        buttons["open"]?.addTarget(self, action: #selector(openProduct(_:)), for: .touchUpInside)
        
        setButton(buttons["delete"], title: "删除", disabledTitle: "删除中...", positions: [.right], width: "half", type: "standard")
        buttons["delete"]?.addTarget(self, action: #selector(removeDownload(_:)), for: .touchUpInside)
        
        setButton(buttons["download"], title: "下载", disabledTitle: "下载中...", positions: [.left, .right], width: "full", type: "standard")
        buttons["download"]?.addTarget(self, action: #selector(download(_:)), for: .touchUpInside)
        
        
        setDownloadingView()
        
        
        // MARK: listen to in-app purchase transaction notification. There's no need to remove it in code after iOS 9 as the system will do that for you. https://useyourloaf.com/blog/unregistering-nsnotificationcenter-observers-in-ios-9/
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseNotification(_:)),
            name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
            object: nil
        )
        
        IAPs.shared.downloadDelegate = self
        
        updateUI()
        if let action = action {
            takeAction(action)
        }
    }
    
    private func updateUI() {
        if let id = dataObject?.id {
            let status = IAP.checkStatus(id)
            switchUI(status)
        }
    }
    
    private func takeAction(_ action: String) {
        switch action {
        case "buy":
            if let id = dataObject?.id {
                let status = IAP.checkStatus(id)
                switch status {
                case "success":
                    switchUI("success")
                    let alert = UIAlertController(title: "无需付款", message: "您之前已经购买过该产品，无需重复付款", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 = UIAlertAction(title: "打开", style: .default, handler: { (action) -> Void in
                        IAP.readBook(id)
                    })
                    alert.addAction(action1)
                    alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
                    if let topViewController = UIApplication.topViewController() {
                        topViewController.present(alert, animated: true, completion: nil)
                    }
                case "pendingdownload":
                    switchUI("downloading")
                    Alert.present("无需付款，免费下载", message: "您之前已经购买过该产品，无需重复付款，请点击下载即可")
                    let alert = UIAlertController(title: "无需付款，免费下载", message: "您之前已经购买过该产品，无需重复付款，请点击下载即可", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 = UIAlertAction(title: "下载", style: .default, handler: { (action) -> Void in
                        IAP.downloadProduct(id)
                    })
                    alert.addAction(action1)
                    alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
                    if let topViewController = UIApplication.topViewController() {
                        topViewController.present(alert, animated: true, completion: nil)
                    }
                case "new", "fail":
                    switchUI("pending")
                    IAP.buy(id)
                default:
                    break
                }
            }
        case "read":
            if let id = dataObject?.id {
                let status = IAP.checkStatus(id)
                switch status {
                case "pendingdownload":
                    switchUI("downloading")
                    Alert.present("无需付款，免费下载", message: "您之前已经购买过该产品，无需重复付款，请点击下载即可")
                    let alert = UIAlertController(title: "无需付款，免费下载", message: "您之前已经购买过该产品，无需重复付款，请点击下载即可", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 = UIAlertAction(title: "下载", style: .default, handler: { (action) -> Void in
                        IAP.downloadProduct(id)
                    })
                    alert.addAction(action1)
                    alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
                    if let topViewController = UIApplication.topViewController() {
                        topViewController.present(alert, animated: true, completion: nil)
                    }
                case "new", "fail":
                    switchUI("pending")
                    IAP.buy(id)
                default:
                    IAP.readBook(id)
                }
            }
        default:
            break
        }
    }
    
    public func switchUI(_ actionType: String) {
        switch actionType {
        case "success":
            print ("show open and delete button")
            hideAll()
            buttons["open"]?.isHidden = false
            buttons["delete"]?.isHidden = false
        case "pendingdownload":
            print ("show download view only")
            hideAll()
            downloadingView.isHidden = false
            buttons["download"]?.isHidden = false
        case "downloading":
            print ("show downloading view")
            hideAll()
            downloadingView.isHidden = false
        case "pending":
            print ("show buy and try button. buy button disabled. ")
            hideAll()
            buttons["buy"]?.isHidden = false
            buttons["buy"]?.isEnabled = false
            buttons["try"]?.isHidden = false
        case "fail", "new":
            print ("show buy and try button")
            hideAll()
            buttons["buy"]?.isHidden = false
            buttons["buy"]?.isEnabled = true
            buttons["try"]?.isHidden = false
        default:
            break
        }
    }
    
    private func hideAll() {
        for (_, button) in buttons {
            button.isHidden = true
        }
        downloadingView.isHidden = true
    }
    
    
    private func setButton(_ button: UIButton?, title: String, disabledTitle: String,  positions: [NSLayoutAttribute], width: String, type: String) {
        if let button = button {
            let maxButtonWidth: CGFloat = 200
            let frameWidth = frame.width
            var buttonWidth: CGFloat
            switch width {
            case "half":
                buttonWidth = frameWidth/2 - horizontalPadding - horizontalPadding/2
            default:
                buttonWidth = frameWidth
            }
            
            let buttonHeight = self.frame.height
            button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
            button.layer.masksToBounds = true
            button.setTitle(title, for: .normal)
            button.setTitle(disabledTitle, for: .disabled)
            switch type {
            case "highlight":
                button.setTitleColor(UIColor(hex: Color.Button.highlightFont), for: .normal)
                button.backgroundColor = UIColor(hex: Color.Button.highlight)
                button.layer.borderColor = UIColor(hex: Color.Button.highlightBorder).cgColor
                button.layer.borderWidth = 1
            default:
                button.setTitleColor(UIColor(hex: Color.Button.standardFont), for: .normal)
                button.backgroundColor = UIColor(hex: Color.Button.standard)
                button.layer.borderColor = UIColor(hex: Color.Button.standardBorder).cgColor
                button.layer.borderWidth = 1
            }
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            self.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            var buttonPadding = horizontalPadding
            if buttonWidth > maxButtonWidth {
                buttonWidth = maxButtonWidth
                buttonPadding = (frameWidth-horizontalPadding)/2 - buttonWidth
            }
            self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: verticalPadding))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
            for position in positions {
                if position == .right {
                    buttonPadding = -buttonPadding
                }
                self.addConstraint(NSLayoutConstraint(item: button, attribute: position, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: position, multiplier: 1, constant: buttonPadding))
            }
            self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        }
    }
    
    private func setDownloadingView() {
        // MARK: downloading view takes the full IAPView
        downloadingView.isHidden = true
        let viewHeight = self.frame.height
        downloadingView.frame = CGRect(x: 0, y: 0, width: 300, height: self.frame.height)
        downloadingView.backgroundColor = UIColor(hex: Color.Content.background)
        downloadingView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(downloadingView)
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: verticalPadding))
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: downloadingView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
        
        // MARK: progress bar
        let progressHeight: CGFloat = 2
        progressView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: progressHeight)
        progressView.backgroundColor = UIColor(hex: Color.Ad.background)
        progressView.progressTintColor = UIColor(hex: Color.Button.highlight)
        downloadingView.addSubview(progressView)
        
        // MARK: progress label
        let statusPadding: CGFloat = 14
        downloadingStatus.frame = CGRect(
            x: statusPadding,
            y: progressHeight,
            width: self.frame.width - statusPadding * 2 - viewHeight,
            height: viewHeight - progressHeight
        )
        downloadingStatus.text = "点击此处开始下载"
        downloadingStatus.textColor = UIColor(hex: Color.Content.lead)
        downloadingStatus.font = downloadingStatus.font.withSize(13)
        downloadingStatus.textAlignment = .left
        downloadingStatus.isUserInteractionEnabled = true
        let downloadStatusTapGesture = UITapGestureRecognizer(target:self, action:#selector(tapDownloadingStatus(_:)))
        downloadingStatus.addGestureRecognizer(downloadStatusTapGesture)
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
    
    @objc public func buy(_ sender: UIButton) {
        print ("buy product")
        sender.isEnabled = false
        if let id = dataObject?.id {
            IAP.buy(id)
        }
    }
    
    @objc public func tryProduct(_ sender: UIButton) {
        print ("try product")
        if let id = dataObject?.id {
            IAP.tryBook(id)
        }
    }
    
    @objc public func openProduct(_ sender: UIButton) {
        print ("open product")
        if let id = dataObject?.id {
            IAP.readBook(id)
        }
    }
    
    @objc public func removeDownload(_ sender: UIButton) {
        print ("remove downloaded product")
        if let id = dataObject?.id {
            let newStatus = IAP.removeDownload(id)
            switchUI(newStatus)
            progressView.progress = 0
            downloadingStatus.text = "点击此处重新下载"
        }
    }
    
    @objc public func download(_ sender: Any) {
        print ("start downloading product")
        downloadingStatus.text = "准备下载，点击此处取消"
        if let id = dataObject?.id {
            IAP.downloadProduct(id)
        }
        switchUI("downloading")
    }
    
    @objc public func tapDownloadingStatus(_ recognizer: UITapGestureRecognizer) {
        print ("current download status is now \(currentDownloadStatus)")
        switch currentDownloadStatus {
        case .remote:
            print ("should start downloading")
            if let id = dataObject?.id {
                IAP.downloadProduct(id)
            }
        case .downloading, .resumed:
            print ("should pause downloading")
            currentDownloadStatus = .paused
            if let id = dataObject?.id {
                IAP.pauseDownload(id)
            }
            downloadingStatus.text = "下载暂停，点击继续"
        case .paused:
            print ("should resume download")
            currentDownloadStatus = .resumed
            if let id = dataObject?.id {
                IAP.resumeDownload(id)
            }
            downloadingStatus.text = "下载中，点击暂停"
        case .success:
            print ("should close downloading view")
            switchUI("success")
        }
        print ("current download status changed to \(currentDownloadStatus)")
    }
    
    @objc public func cancelDownload(_ sender: UIButton) {
        if let id = dataObject?.id {
            IAP.cancelDownload(id)
        }
        switchUI("pendingdownload")
        self.currentDownloadStatus = .remote
        downloadingStatus.text = "点击此处重新加载"
    }
    
    
    // MARK: This should be public, as it will be called by other classes
    @objc public func handlePurchaseNotification(_ notification: Notification) {
        if let notificationObject = notification.object as? [String: Any?]{
            // MARK: when user buys or restores a product, we should display relevant information
            if let productID = notificationObject["id"] as? String, let actionType = notificationObject["actionType"] as? String {
                var newStatus = "new"
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
                        newStatus = "downloading"
                        
                    } else if actionType == "buy success" {
                        // MARK: Otherwise if it's a buy action, save the purchase information and update UI accordingly
                        let transactionDate = notificationObject["date"] as? Date
                        IAP.updatePurchaseHistory(productID, date: transactionDate)
                        newStatus = "success"
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
                    DispatchQueue.main.async(execute: {
                        self.switchUI(newStatus)
                    })
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
                    DispatchQueue.main.async(execute: {
                        self.switchUI("fail")
                    })
                    
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
            DispatchQueue.main.async(execute: {
                self.switchUI("fail")
            })
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
            var newStatus = "new"
            
            print ("\(productId) file downloaded to: \(location.absoluteURL)")
            if fileManager.fileExists(atPath: destinationURLForFile.path){
                //showFileWithPath(path: destinationURLForFile.path)
                print ("the file exists, you can open it. ")
                newStatus = "success"
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
                    newStatus = "success"
                    if productId.hasPrefix("try") {
                        // TODO: - This is a trial file, open it immediately
                        print ("open the try book")
                        
                        /*
                        let config = FolioReaderConfig()
                        config.scrollDirection = .horizontal
                        config.allowSharing = false
                        config.tintColor = UIColor(netHex: 0x9E2F50)
                        config.menuBackgroundColor = UIColor(netHex: 0xFFF1E0)
                        config.enableTTS = false
                        
                        newStatus = "new"
                        if let fileLocation = Download.checkFilePath(fileUrl: productId, for: .documentDirectory) {
                            DispatchQueue.main.async {
                                if let topController = UIApplication.topViewController() {
                                    let folioReader = FolioReader()
                                    folioReader.presentReader(parentViewController: topController, withEpubPath: fileLocation, andConfig: config)
                                }
                                print ("should open the file at \(fileLocation)")
                                IAP.trackIAPActions("download excerpt success", productId: productId)
                            }
                        }
 */
                        
                    }
                }catch{
                    print("An error occurred while moving file to destination url")
                    IAP.trackIAPActions("save fail", productId: productId)
                    switchUI("fail")
                }
                DispatchQueue.main.async(execute: {
                    self.switchUI(newStatus)
                })
            }
            
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
            // MARK: Since we have moved to native, we can update UI as frequently as we want.
            //if IAPs.shared.downloadProgresses[productId] != totalMBsWritten {
            IAPs.shared.downloadProgresses[productId] = totalMBsWritten
            let totalMBsExpectedToWrite = String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)
            // MARK: update UI in main queue
            DispatchQueue.main.async(execute: {
                self.downloadingStatus.text = "\(totalMBsWritten)M / \(totalMBsExpectedToWrite)M 点击暂停"
                self.progressView.progress = percentageNumber/100
            })
            currentDownloadStatus = .downloading
            print ("updateDownloadProgress('\(productId)', '\(percentageNumber)%', '\(totalMBsWritten)M / \(totalMBsExpectedToWrite)M')")
            //}
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
                DispatchQueue.main.async(execute: {
                    self.switchUI("pendingdownload")
                })
                IAP.trackIAPActions("download fail", productId: productId)
            }
            DispatchQueue.main.async(execute: {
                self.switchUI("pendingdownload")
                self.currentDownloadStatus = .remote
                self.progressView.progress = 0
                self.downloadingStatus.text = "点击此处重新下载"
            })
        }
    }
    
}
