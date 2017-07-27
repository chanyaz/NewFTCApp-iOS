//
//  Download.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Download {
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
        if let directoryPathString = NSSearchPathForDirectoriesInDomains(to, .userDomainMask, true).first {
            if let directoryPath = URL(string: directoryPathString) {
                let realFileName = getFileNameFromUrlString(filename, as: fileExtension)
                let filePath = directoryPath.appendingPathComponent(realFileName)
                let fileManager = FileManager.default
                let created = fileManager.createFile(atPath: filePath.absoluteString, contents: nil, attributes: nil)
//                if created {
//                    print("\(realFileName) created successfully")
//                } else {
//                    print("Couldn't create file for some reason")
//                }
                // Write that JSON to the file created earlier
                do {
                    let file = try FileHandle(forWritingTo: filePath)
                    file.write(data)
                    //print("File data was written to \(realFileName) successfully!")
                } catch let error as NSError {
                    print("Couldn't write to file: \(error.localizedDescription). created: \(created)")
                }
            }
        }
    }
    
    public static func readFile(_ urlString: String, for directory: FileManager.SearchPathDirectory, as fileExtension: String?) -> Data? {
        let fileName = getFileNameFromUrlString(urlString, as: fileExtension)
        do {
            let DocumentDirURL = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent(fileName)
            return (try? Data(contentsOf: fileURL))
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
        let fileName = urlString.replacingOccurrences(of: "^http[s]*://[^/]+/",with: "",options: .regularExpression)
            .replacingOccurrences(of: "[/?=]", with: "-", options: .regularExpression)
        .replacingOccurrences(of: "-type-json", with: ".json")
        .replacingOccurrences(of: "\\.([a-zA-Z-]+\\.[a-zA-Z-]+$)", with: "-$1", options: .regularExpression)
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
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
                // print(directoryContents)
                
                // if you want to filter the directory contents you can do like this:
                let creativeTypes = fileTypes
                let creativeFiles = directoryContents.filter{ creativeTypes.contains($0.pathExtension) }
                
                for creativeFile in creativeFiles {
                    // print(creativeFile.lastPathComponent)
                    let creativeFileString = creativeFile.lastPathComponent
                    try FileManager.default.removeItem(at: creativeFile)
                    print("remove file from documents folder: \(creativeFileString)")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
}

