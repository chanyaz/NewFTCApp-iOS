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
    
    public static func downloadUrl(_ urlString: String, to: FileManager.SearchPathDirectory) {
        if let url = URL(string: urlString) {
            getDataFromUrl(url) {(data, response, error)  in
                if let data = data, error == nil {
                    saveFile(data, filename: urlString, to: to)
                }
            }
        }
    }
    
    public static func saveFile(_ data: Data, filename: String, to: FileManager.SearchPathDirectory) {
        if let directoryPathString = NSSearchPathForDirectoriesInDomains(to, .userDomainMask, true).first {
            if let directoryPath = URL(string: directoryPathString) {
                let realFileName = getFileNameFromUrlString(filename)
                let filePath = directoryPath.appendingPathComponent(realFileName)
                let fileManager = FileManager.default
                let created = fileManager.createFile(atPath: filePath.absoluteString, contents: nil, attributes: nil)
                if created {
                    print("\(realFileName) created ")
                } else {
                    print("Couldn't create file for some reason")
                }
                // Write that JSON to the file created earlier
                do {
                    let file = try FileHandle(forWritingTo: filePath)
                    file.write(data)
                    print("File data was written to the \(realFileName) successfully!")
                } catch let error as NSError {
                    print("Couldn't write to file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private static func getFileNameFromUrlString(_ urlString: String) -> String {
        let fileName = urlString.replacingOccurrences(
            of: "^http[s]*://[^/]+/",
            with: "",
            options: .regularExpression
            ).replacingOccurrences(
                of: "/",
                with: "-"
        )
        return fileName
    }
    
}
