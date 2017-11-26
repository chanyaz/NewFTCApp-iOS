//
//  RemoteDownloadHelper.swift
//  Page
//
//  Created by huiyun.he on 22/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation
class RemoteDownloadHelper: NSObject,URLSessionDownloadDelegate {
    public var directory: String
    public let remoteDownloadStatusNotificationName = "download status change"
    public let remoteDownloadProgressNotificationName = "download progress change"
    public var currentStatus: DownloadStatus = .remote
    init(directory: String) {
        self.directory = directory
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
 
}
