//
//  Download.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Download {
    public static let serverNotRespondingKey = "Server Not Responding Key"
    
    public static func handleServerError(_ urlString: String, error: NSError?) {
        let statusType = Connection.current()
        guard statusType != "no" else {
            return
        }
        markServerAsNotResponding(urlString)
        //Track.catchError("\(urlString) Request Error: \(String(describing: error))", withFatal: 1)
        Track.event(category: "CatchError", action: "Fail to Connect on \(statusType)", label: urlString)
    }
    
    public static func markServerAsNotResponding(_ urlString: String) {
        // MARK: get the server part of the the url string
        let serverNotResponding = urlString.replacingOccurrences(of: "^(http[s]*://[^/]+/).*$", with: "$1", options: .regularExpression)
        // MARK: save the server that has returned error so that the APIs knows it should look for the backup server
        UserDefaults.standard.set(serverNotResponding, forKey: Download.serverNotRespondingKey)
        print ("\(serverNotResponding) marked as not responding")
    }
    
    public static func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        let listTask = URLSession.shared.dataTask(with: url, completionHandler:{(data, response, error) in
            completion(data, response, error as NSError?)
            return ()
        })
        listTask.resume()
    }
    
    public static func downloadUrl(_ urlString: String, to: FileManager.SearchPathDirectory, as fileExtension: String?) {
        if let url = URL(string: urlString) {
            getDataFromUrl(url) {(data, response, error)  in
                if let data = data, error == nil {
                    saveFile(data, filename: urlString, to: to, as: fileExtension)
                }
            }
        }
    }
    
    public static func saveFile(_ data: Data, filename: String, to: FileManager.SearchPathDirectory, as fileExtension: String?) {
            // MARK: - If the file is JSON, it should be validated first
            // TODO: - Find out why JSONSerialization.isValidJSONObject(data) doesn't work
            if fileExtension == "json" {
                let JSON = try? JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
                if let _ = JSON as? NSDictionary{
                } else {
                    if let _ = JSON as? NSArray {
                    } else {
                        Track.event(category: "CatchError", action: "JSON Validation Failure", label: filename)
                        return
                    }
                }
            }
            if let directoryPathString = NSSearchPathForDirectoriesInDomains(to, .userDomainMask, true).first {
                if let directoryPath = URL(string: directoryPathString) {
                    let realFileName = getFileNameFromUrlString(filename, as: fileExtension)
                    let filePath = directoryPath.appendingPathComponent(realFileName)
                    let fileManager = FileManager.default
                    _ = fileManager.createFile(atPath: filePath.absoluteString, contents: nil, attributes: nil)
                    // MARK: - Write that JSON to the file created earlier
                    do {
                        let file = try FileHandle(forWritingTo: filePath)
                        file.write(data)
                        //print("write to file: \(realFileName) successfully!")
                    } catch _ as NSError {
                        //print("Couldn't write to file: \(error.localizedDescription). created: \(created)")
                    }
                }
            }
    }
    
    public static func readFile(_ urlString: String, for directory: FileManager.SearchPathDirectory, as fileExtension: String?) -> Data? {
        let fileName = getFileNameFromUrlString(urlString, as: fileExtension)
        do {
            let DocumentDirURL = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent(fileName)
            //print ("read file of \(fileURL)")
            return (try? Data(contentsOf: fileURL))
        } catch {
            return nil
        }
    }
    
    public static func getFilePath(_ urlString: String, for directory: FileManager.SearchPathDirectory, as fileExtension: String?) -> String? {
        let fileName = getFileNameFromUrlString(urlString, as: fileExtension)
        do {
            let DocumentDirURL = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            let templatepathInDocument = DocumentDirURL.appendingPathComponent(fileName)
            var templatePath: String? = nil
            if FileManager().fileExists(atPath: templatepathInDocument.path) {
                templatePath = templatepathInDocument.path
            }
            return templatePath
        } catch {
            return nil
        }
    }
    
    public static func checkFilePath(fileUrl: String, for directory: FileManager.SearchPathDirectory) -> String? {
        let url = NSURL(string:fileUrl)
        if let lastComponent = url?.lastPathComponent {
            let templatepathInBuddle = Bundle.main.bundlePath + "/" + lastComponent
            do {
                let DocumentDirURL = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
                let templatepathInDocument = DocumentDirURL.appendingPathComponent(lastComponent)
                var templatePath: String? = nil
                if FileManager.default.fileExists(atPath: templatepathInBuddle) {
                    templatePath = templatepathInBuddle
                } else if FileManager().fileExists(atPath: templatepathInDocument.path) {
                    templatePath = templatepathInDocument.path
                }
                return templatePath
            } catch {
                return nil
            }
        }
        return nil
    }
    
    public static func cleanFile(_ types: [String], for directory: FileManager.SearchPathDirectory) {
        if let documentsUrl =  FileManager.default.urls(for: directory, in: .userDomainMask).first {
            do {
                // MARK: Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
                
                // MARK: Filter the directory contents
                let files: [URL]
                if types.count > 0 {
                    files = directoryContents.filter{ types.contains($0.pathExtension) }
                } else {
                    files = directoryContents
                }
                
                for file in files {
                    print("found file \(file.lastPathComponent) in \(directory) folder")
                    let fileName = file.lastPathComponent
                    try FileManager.default.removeItem(at: file)
                    print("remove file from \(directory) folder: \(fileName)")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    public static func manageFiles(_ types: [String], for directory: FileManager.SearchPathDirectory) {
        if let documentsUrl =  FileManager.default.urls(for: directory, in: .userDomainMask).first {
            do {
                // MARK: Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
                
                // MARK: Filter the directory contents
                let files: [URL]
                if types.count > 0 {
                    files = directoryContents.filter{ types.contains($0.pathExtension) }
                } else {
                    files = directoryContents
                }
                var totalSize: UInt64 = 0
                let earlyDate = Date().addingTimeInterval(-60 * 60 * 24 * APIs.expireDay)
                for file in files {
                    let fileName = file.lastPathComponent
                    let filePath = file.path
                    do {
                        let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                        if let fileSize = attr[FileAttributeKey.size] as? UInt64,
                            let fileDate = attr[FileAttributeKey.modificationDate] as? Date {
                            
                            if fileDate < earlyDate {
                                try FileManager.default.removeItem(at: file)
                                print("Manage File remove: \(fileName), expire date: \(earlyDate), now: \(Date()). ")
                            } else {
                                totalSize += fileSize
                                print("Manage File keep: date: \(fileDate), size: \(fileSize), name: \(fileName)")
                            }
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
                Track.event(category: "Cache", action: "Keep", label: "\(totalSize)")
                print ("total size of the files is now \(totalSize)")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    private static func getFileNameFromUrlString(_ urlString: String, as fileExtension: String?) -> String {
        var fileName = urlString
        if fileName.range(of: "mp.weixin.qq.com") != nil {
            fileName = fileName.md5()
        } else {
            fileName = fileName.replacingOccurrences(of: "^http[s]*://[^/]+/",with: "",options: .regularExpression)
                .replacingOccurrences(of: ".html?.*pageid=", with: "-", options: .regularExpression)
                .replacingOccurrences(of: "[?].*", with: "", options: .regularExpression)
                .replacingOccurrences(of: "[/?=]", with: "-", options: .regularExpression)
                .replacingOccurrences(of: "-type-json", with: ".json")
                .replacingOccurrences(of: "\\.([a-zA-Z-]+\\.[a-zA-Z-]+$)", with: "-$1", options: .regularExpression)
                .replacingOccurrences(of: "%", with: "")
        }
        if fileName == "" {
            fileName = "home"
        }
        if let ext = fileExtension {
            let forceFileName = fileName.replacingOccurrences(of: ".\(ext)", with: "")
                .replacingOccurrences(of: ".", with: "")
            let finalFileName = "\(forceFileName).\(ext)"
            //print ("\(urlString) is converted into file name of \(finalFileName)")
            return finalFileName
        }
        //print ("\(urlString) is converted into file name of \(fileName)")
        return fileName
    }
    
    public static func removeFiles(_ fileTypes: [String]){
        if let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                // MARK: Get the directory contents urls, including subfolders urls
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
                // MARK: filter the directory contents
                let creativeTypes = fileTypes
                let creativeFiles = directoryContents.filter{ creativeTypes.contains($0.pathExtension) }
                for creativeFile in creativeFiles {
                    let creativeFileString = creativeFile.lastPathComponent
                    try FileManager.default.removeItem(at: creativeFile)
                    print("remove file from documents folder: \(creativeFileString)")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    public static func encodingGBK() -> String.Encoding {
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let gbEncoding = String.Encoding(rawValue: enc)
        return gbEncoding
    }
    
    public static func save(_ item: ContentItem, to: String, uplimit: Int, action: String) {
        let headline = item.headline
        let image = item.image
        let lead = item.lead
        let id = item.id
        let type = item.type
        let key = "Saved \(to)"
        var savedItems = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? [[String: String]]()
        savedItems = savedItems.filter {
            id != $0["id"]
        }
        let item = [
            "id": id,
            "headline": headline,
            "type": type,
            "lead": lead,
            "image": image
        ]
        if action == "save" {
            savedItems.insert(item, at: 0)
        }
        var newSavedItems = [[String: String]]()
        for (index, value) in savedItems.enumerated() {
            if index < uplimit {
                newSavedItems.append(value)
            }
        }
        UserDefaults.standard.set(newSavedItems, forKey: key)
        //print ("saved item is now: \(newSavedItems)")
    }
    
    public static func get(_ from: String) -> [ContentItem] {
        let key = "Saved \(from)"
        let savedItems = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? [[String: String]]()
        var contentItems = [ContentItem]()
        for item in savedItems {
            let contentItem = ContentItem(
                id: item["id"] ?? "",
                image: item["image"] ?? "",
                headline: item["headline"] ?? "",
                lead: item["lead"] ?? "",
                type: item["type"] ?? "",
                preferSponsorImage: item["preferSponsorImage"] ?? "",
                tag: item["tag"] ?? "",
                customLink: item["customLink"] ?? "",
                timeStamp: 0,
                section: 0,
                row: 0
            )
            contentItems.append(contentItem)
        }
        return contentItems
    }
    
    
    // MARK: - Retrieve a property value from the user default's "my purchase" key
    public static func getPropertyFromUserDefault(_ id: String, property: String) -> String? {
        if let myPurchases = UserDefaults.standard.dictionary(forKey: IAP.myPurchasesKey) as? [String: Dictionary<String, String>] {
            return myPurchases[id]?[property]
        }
        return nil
    }
    
    // MARK: - Add a version parameter for request
    public static func addVersionAndTimeStamp(_ urlString: String) -> String {
        // MARK: Get a new time stamp every x minutes so that user won't be stuck with a very old cache.
        let cacheMinute = 10
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let minutesTrucated = cacheMinute*Int(minutes/cacheMinute)
        let timeStamp = "&t=\(year)\(month)\(day)\(hour)\(minutesTrucated)"
        let versionFromBundle: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let connector = (urlString.range(of: "?") == nil) ? "?": "&"
        return "\(urlString)\(connector)v=\(versionFromBundle)\(timeStamp)&device=\(DeviceInfo.checkDeviceType())"
    }
    
    public static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    public static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    public static func grabHTMLResource(_ listAPI: String, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //MARK: Do this only when user is using wifi
        if IJReachability().connectedToNetworkOfType() == .wiFi {
            Track.event(category: "Background Download", action: "Request", label: listAPI)
            let listAPIString = APIs.convert(Download.addVersionAndTimeStamp(listAPI))
            if let url = URL(string: listAPIString) {
                getDataFromUrl(url) {(data, response, error)  in
                    print ("response from get data from url: \(listAPI)")
                    if error != nil {
                        handleServerError(listAPIString, error: error)
                        Track.event(category: "Background Download", action: "Fail", label: listAPI)
                        completionHandler(.noData)
                    }
                    if let data = data,
                        error == nil,
                        HTMLValidator.validate(data, url: listAPIString) {
                        saveFile(data, filename: listAPI, to: .cachesDirectory, as: "html")
                        Track.event(category: "Background Download", action: "Success", label: listAPI)
                        DispatchQueue.main.async { () -> Void in
                            UIApplication.shared.applicationIconBadgeNumber = 1
                        }
                        // MARK: - Continue to parse the HTML and download story json files
                        if let htmlCode = String(data: data, encoding: .utf8){
                            let storyIdPatterns = "data-id=\"([0-9]+)\" data-type=\"story\""
                            let storyIds = matches(for: storyIdPatterns, in: htmlCode)
                            for storyIdString in storyIds {
                                if let storyId = storyIdString.matchingFirstString(regex: storyIdPatterns) {
                                    let apiUrl = APIs.get(storyId, type: "story")
                                    downloadUrl(apiUrl, to: .cachesDirectory, as: "json")
                                }
                            }
                        }

                        completionHandler(.newData)

                    } else {
                        Track.event(category: "Background Download", action: "HTML Valid Fail", label: listAPI)
                        completionHandler(.noData)
                    }
                }
            } else {
                Track.event(category: "Background Download", action: "Illegal Url", label: listAPI)
                completionHandler(.noData)
            }
        } else {
            Track.event(category: "Background Download", action: "Abort for Lack of Wifi", label: listAPI)
            completionHandler(.noData)
        }
    }
    
    public static func saveFiles(_ data: Data,directoryName: String, filename: String, to: FileManager.SearchPathDirectory, as fileExtension: String?) {
        if let directoryPath = getDirectoryUrlFromDirectory(directoryName, for: to){
            let realFileName = getFileNameFromUrlString(filename, as: fileExtension)
            let filePath = directoryPath.appendingPathComponent(realFileName)
            let fileManager = FileManager.default
            if FileManager().fileExists(atPath: filePath.path) {
                do {
                    let file = try FileHandle(forWritingTo: filePath)
                    file.write(data)
                    print("again write data to file : \(data) successfully!")
                } catch _ as NSError {
                    //print("Couldn't again write to file: \(error.localizedDescription)")
                }
            }else{
                let created = fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
                do {
                    let file = try FileHandle(forWritingTo: filePath)
                    file.write(data)
                    print("write data to file : \(realFileName) successfully!")
                } catch let error as NSError {
                    print("Couldn't write data to file: \(error.localizedDescription)--created:\(created)")
                }
            }
        }
    }
    
    public static func readFileData(_ urlString: String, directoryName: String, for directory: FileManager.SearchPathDirectory, as fileExtension: String?) -> Data?{
        var data:Data? = nil
        if let directoryPath = getDirectoryUrlFromDirectory(directoryName, for: directory){
            let fileName = getFileNameFromUrlString(urlString, as: fileExtension)
            let fileURL = directoryPath.appendingPathComponent(fileName)
            if FileManager().fileExists(atPath: fileURL.path) {
                let file = FileHandle(forReadingAtPath: fileURL.path)
                if let file = file{
                    data = file.readDataToEndOfFile()
                    print("read data from file: \(String(describing: data)) ")
                }
            }
            return data
        }
        return nil
    }
    
    public static func readFileDataWithTime(_ urlString: String, directoryName: String, for directory: FileManager.SearchPathDirectory, as fileExtension: String?) -> [String:Any]?{
        var data:Data? = nil
        var content = [String:Any]()
        let fileManager =  FileManager.default
        if let directoryPath = getDirectoryUrlFromDirectory(directoryName, for: directory){
            let fileName = getFileNameFromUrlString(urlString, as: fileExtension)
            let fileURL = directoryPath.appendingPathComponent(fileName)
            if FileManager().fileExists(atPath: fileURL.path) {
                do {
                    let attributes =  try fileManager.attributesOfItem(atPath: fileURL.path)
                    let file = FileHandle(forReadingAtPath: fileURL.path)
                    if let file = file,let time = attributes[FileAttributeKey.creationDate] as? Date{
                        data = file.readDataToEndOfFile()
                        content["data"] = data
                        content["time"] = time.timeIntervalSince1970
                        print("read data from file: \(String(describing: data)) ")
                        print("subDirectry file time is:\(time.timeIntervalSince1970)")
                        return content
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            return nil
        }
        return nil
    }
    
    public static func readSubFilesInDirectory(directoryName: String, for directory: FileManager.SearchPathDirectory, as fileExtension: String?) -> [String]?{
        do {
            let fileManager =  FileManager.default
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                let subDirectories = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: [])
                var subDirectoriesNamesString = [String]()
                    for subDirectry in subDirectories {
                        let creativeFileString = subDirectry.lastPathComponent
                        subDirectoriesNamesString.append(creativeFileString)
            
                        
                        print("subDirectry file name is: \(creativeFileString)")
                    }
                return subDirectoriesNamesString
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        return nil
    }
    
    public static func removeFile(_ urlString: String,for directory: FileManager.SearchPathDirectory, as fileExtension: String?){
        let fileName = getFileNameFromUrlString(urlString, as: fileExtension)
        do {
            let DocumentDirURL = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent(fileName)
            try FileManager.default.removeItem(atPath: fileURL.path)
           
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
//  Create Directory
    public static func createDirectory(directoryName: String,to: FileManager.SearchPathDirectory) {
         do {
            if let directoryPathString = NSSearchPathForDirectoriesInDomains(to, .userDomainMask, true).first {
                if let directoryPath = URL(string: directoryPathString) {
                    let filePath = directoryPath.appendingPathComponent(directoryName)
                    if FileManager().fileExists(atPath: filePath.path) {
                        return
                    }else{
                        try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                    }
                }
            }
         } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

//    Get the path according to the file name
    public static func getDirectoryUrlFromDirectory(_ directoryName: String,for directory: FileManager.SearchPathDirectory) -> URL? {
        var fileURL :URL? = nil
        do {
            let directoryURL = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            if directoryName != ""{
                fileURL = directoryURL.appendingPathComponent(directoryName)
            }else{
                fileURL = directoryURL
            }
            return fileURL
        } catch {
            return nil
        }
    }
    // To do:gets the filename under the directory
    
    // delete Directory
    public static func removeDirectory(directoryName: String,for directory: FileManager.SearchPathDirectory){
        do {
            let fileManager =  FileManager.default
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                try fileManager.removeItem(at: directoryUrl)
                print("remove directory \(directoryUrl)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
//    Remove the corresponding type of file under this path according to the path
    public static func removeDirectoryAccordingToType(directoryName: String,for directory: FileManager.SearchPathDirectory,_ fileTypes: [String]){
        do {
            let fileManager =  FileManager.default
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                let subDirectories = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: [])
                let creativeTypes = fileTypes
                let creativeFiles = subDirectories.filter{ creativeTypes.contains($0.pathExtension) }
                for creativeFile in creativeFiles {
                    let creativeFileString = creativeFile.lastPathComponent
                    try fileManager.removeItem(at: creativeFile)
                    print("remove file according to type from directory: \(creativeFileString)")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    public static func removeFileAccordingToFilePrefixName(_ filePrefixName: String,directoryName: String,for directory: FileManager.SearchPathDirectory){
        do {
            let fileManager =  FileManager.default
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                let subDirectories = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: [])

                let creativeFiles = subDirectories.filter{($0.lastPathComponent).contains(filePrefixName) }
//                let creativeFiles = subDirectories.filter{filePrefixName.contains(($0.lastPathComponent).components(separatedBy: ".")[0]) }
                for creativeFile in creativeFiles {
                    let creativeFileString = creativeFile.lastPathComponent
                    try fileManager.removeItem(at: creativeFile)
                    print("remove file according to file prefix name: \(creativeFileString)")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
//  Delete file under a certain path according to filename
    public static func removeFileAccordingToFileName(_ urlString: String,directoryName: String,for directory: FileManager.SearchPathDirectory, as fileExtension: String?){
        let fileName = getFileNameFromUrlString(urlString, as: fileExtension)
        do {
            let fileManager =  FileManager.default
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                let fileUrl = directoryUrl.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileUrl)
                print("remove file according to fileName from directory: \(fileUrl)")
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
//   Rename file or directory
    public static func renameFile(oldFileName:String,newFileName:String,directoryName: String,for directory: FileManager.SearchPathDirectory){
        do {
            let fileManager =  FileManager.default
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                let oldFileUrl = directoryUrl.appendingPathComponent(oldFileName)
                let newFileUrl = directoryUrl.appendingPathComponent(newFileName)
                try fileManager.moveItem(at: oldFileUrl, to: newFileUrl)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    public static func getFileCreatedTime(fileName:String,directoryName: String,for directory: FileManager.SearchPathDirectory)->Date{
//        let time = Date()
        do {
            let fileManager =  FileManager.default
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                
                let fileUrl = directoryUrl.appendingPathComponent(fileName)
                let attributes =  try fileManager.attributesOfItem(atPath: fileUrl.path)
                if let time = attributes[FileAttributeKey.creationDate] as? Date{
                    print("created file time is:\(time.timeIntervalSince1970)")
                    
                    return time
                }
            }
            return Date(timeIntervalSince1970: 0)
        } catch {
            return Date(timeIntervalSince1970: 0)
        }
    }
    public static func getDownloadedFilePathInDirectory(_ url: String,directoryName: String,for directory: FileManager.SearchPathDirectory) -> String? {
//        let url = URL(string:url)
//        if let lastComponent = url?.lastPathComponent {
//            print("Downloaded File lastComponent is:\(lastComponent)")
            if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
                let templatepathInDocument = directoryUrl.appendingPathComponent(url)
                var templatePath: String? = nil
                if  FileManager().fileExists(atPath: templatepathInDocument.path) {
                    templatePath = templatepathInDocument.path
                }
                return templatePath
            }
//        }
       
        return nil
    }
    
    public static func getFileExtension(_ urlString: String) -> String? {
        let url = URL(string:urlString)
        if let imageNameExtension = url?.pathExtension{
            return imageNameExtension
        }
        return nil
    }
    
    public static func checkDownloadedFileInDirectory(_ url: String,directoryName: String,for directory: FileManager.SearchPathDirectory) -> String? {
        
        if let directoryUrl = getDirectoryUrlFromDirectory(directoryName, for: directory){
            let templatepathInDocument = directoryUrl.appendingPathComponent(url)
            var templatePath: String? = nil
            if  FileManager().fileExists(atPath: templatepathInDocument.path) {
                templatePath = templatepathInDocument.path
            }
            return templatePath
        }else{
            return nil
        }
        
    }
 
}


