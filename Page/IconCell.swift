//
//  IconCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/9/26.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class IconCell: CustomCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    let imageWidth = 250   // 16 * 52
    let imageHeight = 250  // 9 * 52
    
    override func updateUI() {
        title.text = itemCell?.headline
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Image.background)
        // MARK: - As the cell is reusable, asyn image should always be cleared first
        imageView.image = nil
        if let loadedImage = itemCell?.coverImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type:"cover", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.coverImage
            })
        }
    }
}
