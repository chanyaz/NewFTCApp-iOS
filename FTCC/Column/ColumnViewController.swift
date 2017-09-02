//
//  columnViewController.swift
//  Page
//
//  Created by huiyun.he on 21/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//
import UIKit
import Foundation
class ColumnViewController: UICollectionViewController, UINavigationControllerDelegate {
    var pageTitle: String = ""
    override func viewDidLoad() {
        navigationController?.title = pageTitle
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "columnCell", for: indexPath) as! ColumnCollectionViewCell
        
        cell.backgroundColor = UIColor.red
//        print("11111\(cell)")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("2222")
        return CGSize(width: 150, height: 40)
    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        <#code#>
//    }
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let columnAllListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColumnAllListViewController") as? ColumnAllListViewController {
            
            navigationController?.pushViewController(columnAllListViewController, animated: true)
        }
        return true
    }
}
