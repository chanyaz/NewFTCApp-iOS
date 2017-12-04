//
//  RemoteDownloadHelper.swift
//  Page
//
//  Created by huiyun.he on 22/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation
class RemoteDownloadHelper: NSObject,URLSessionDownloadDelegate {
    private let playerAPI = PlayerAPI()
    public var directory: String
    public let downloadStatusNotificationName = "download status change"
    public let downloadProgressNotificationName = "download progress change"
    public var currentStatus: DownloadStatus = .remote
    init(directory: String) {
        self.directory = directory
    }
    // MARK: - The Download Operation Queue
    private lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
 
    
    
    //TODO: Deal with space in the file url
    public func startDownload(_ url: String,directoryName: String,for directory: FileManager.SearchPathDirectory,newFileName:String) {
        let fileName = newFileName + playerAPI.getFileName(urlString: url)
        if let localAudioFile = Download.getDownloadedFilePathInDirectory(fileName, directoryName: directoryName, for: directory){
            print ("localAudioFile already exists as \(localAudioFile). No need to download. ")
            postStatusChange(localAudioFile, status: .success)
        }else{
            let urlString = playerAPI.parseAudioUrl(urlString: url)
            if let url = URL(string: urlString){
                print ("The file does not exist. Download from \(url)")
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: fileName)
                let backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: downloadQueue)
                let request = URLRequest(url: url)
                downloadTasks[fileName] = backgroundSession.downloadTask(with: request)
                downloadTasks[fileName]?.resume()
                postStatusChange(fileName, status: .downloading)
            }
        }
    }
    
    
    public func takeActions(_ url: String, directoryName: String,for directory: FileManager.SearchPathDirectory,currentStatus: DownloadStatus,newFileName:String ) {
        print (currentStatus)
        switch currentStatus {
        case .remote:
            // MARK: - If a user is trying to download while not on wifi, pop out an alert with friendly suggestions
            let connectionType = IJReachability().connectedToNetworkOfType()
            if connectionType == IJReachabilityType.wwan {
                // MARK: Let the user know that this could cost data/money
                let alert = UIAlertController(title: "要用流量下载吗？", message: "您现在是用的数据，下载文件可能会产生流量费，您可以先连接Wi-Fi再下载", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "立即下载",
                                              style: UIAlertActionStyle.default,
                                              handler: {_ in self.startDownload(url, directoryName: directoryName, for: directory, newFileName: newFileName)}
                ))
                alert.addAction(UIAlertAction(title: "暂时不下载", style: UIAlertActionStyle.default, handler: nil))
                UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            } else if connectionType == IJReachabilityType.notConnected {
                // MARK: Let the user know that download is not available
                let alert = UIAlertController(title: "没有网络连接", message: "现在您没有连接到互联网，因此无法下载，请联网之后重试", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.default, handler: nil))
                UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            } else {
                startDownload(url,directoryName: directoryName,for: directory, newFileName: newFileName)
            }
            
        case .success:
            successDownload(url,directoryName: directoryName,for: directory, newFileName: newFileName)
            break
        case .downloading, .resumed:
            pauseDownload(url,directoryName: directoryName,for: directory, newFileName: newFileName)
        case .paused:
            resumeDownload(url,directoryName: directoryName,for: directory, newFileName: newFileName)
        }
    }

    public func successDownload(_ url: String, directoryName: String,for directory: FileManager.SearchPathDirectory,newFileName:String) {

        let fileName = newFileName + playerAPI.getFileName(urlString: url)
        if Download.getDownloadedFilePathInDirectory(fileName, directoryName: directoryName, for: directory) != nil{
//            removeDownloadedFile(localFileLocation, directoryName: directoryName, for: directory)
            postStatusChange(fileName, status: .success)
        }
    }
    public func removeDownload(_ url: String, directoryName: String,for directory: FileManager.SearchPathDirectory,newFileName:String) {
        let fileName = newFileName + playerAPI.getFileName(urlString: url)
        if let localFileLocation = Download.getDownloadedFilePathInDirectory(fileName, directoryName: directoryName, for: directory){
            removeDownloadedFile(localFileLocation, directoryName: directoryName, for: directory)
            postStatusChange(fileName, status: .remote)
        }
    }
    
    public func pauseDownload(_ url: String, directoryName: String,for directory: FileManager.SearchPathDirectory,newFileName:String) {
        let fileName = newFileName + playerAPI.getFileName(urlString: url)
        if Download.getDownloadedFilePathInDirectory(fileName, directoryName: directoryName, for: directory) != nil{
            downloadTasks[fileName]?.suspend()
            postStatusChange(fileName, status: .paused)
        }
    }
    
    public func resumeDownload(_ url: String, directoryName: String,for directory: FileManager.SearchPathDirectory,newFileName:String) {
        let fileName = newFileName + playerAPI.getFileName(urlString: url)
        if Download.getDownloadedFilePathInDirectory(fileName, directoryName: directoryName, for: directory) != nil{
            downloadTasks[fileName]?.resume()
            postStatusChange(fileName, status: .resumed)
        }

    }
    private func removeDownloadedFile(_ url: String, directoryName: String,for directory: FileManager.SearchPathDirectory) {
        do {
            let urlFileLocation = URL(fileURLWithPath: url)
            try FileManager.default.removeItem(at: urlFileLocation)
        } catch {
            print ("file \(url) cannot be deleted")
        }
    }
    
    public func checkDownloadedFileToUpdateStatus(_ url: String,directoryName: String,for directory: FileManager.SearchPathDirectory) -> String? {
        if let templatePath = Download.checkDownloadedFileInDirectory(url, directoryName: directoryName, for: directory){
            currentStatus = .success
            return templatePath
        }else{
            currentStatus = .remote
            return nil
        }
       
        
    }
    // MARK: keep a reference of all the Download Tasks
    private var downloadTasks = [String: URLSessionDownloadTask]()
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let id = session.configuration.identifier {
            let fileManager = FileManager()
            let documentDirectoryPath = Download.getDirectoryUrlFromDirectory(directory, for: .cachesDirectory)
            if let documentDirectoryPath = documentDirectoryPath?.appendingPathComponent(id){
            let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.path)
            print ("\(id) file downloaded to: \(location.absoluteURL)")
            if fileManager.fileExists(atPath: destinationURLForFile.path){
                print ("the file exists, you can open it. ")
                postStatusChange(id, status: .success)
            } else {
                do {
                    try fileManager.moveItem(at: location, to: destinationURLForFile)
                    // MARK: - Update UI and track download success
                    print("download success")
                    postStatusChange(id, status: .success)
                }catch{
                    print("An error occurred while moving file to destination url")
                    // MARK: - Update UI and track saving failure
                    postStatusChange(id, status: .resumed)
                }
            }
                
            }
        }
    }
    
    
    // MARK: - Keep a reference of all the Download Progress
    var downloadProgresses = [String: String]()
    
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
                downloadProgresses[productId] = "0.0"
            }
            downloadProgresses[productId] = totalMBsWritten
            let totalMBsExpectedToWrite = String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)
            // MARK: - Post notification about progress change
            let progressStatus = (
                id: productId,
                percentage: percentageNumber,
                downloaded: totalMBsWritten,
                total: totalMBsExpectedToWrite
            )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: downloadProgressNotificationName), object: progressStatus)
            
        }
    }
    
    // MARK: - Deal with errors in download process
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        if (error != nil) {
            print(error!.localizedDescription)
            if let productId = session.configuration.identifier {
                postStatusChange(productId, status:DownloadStatus.remote)
            }
        }
    }
    
    
    private func postStatusChange(_ id: String, status: DownloadStatus ) {
        let message = (id: id, status: status)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: downloadStatusNotificationName), object: message)
    }
 
}
