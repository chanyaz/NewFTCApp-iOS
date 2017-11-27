//
//  WKWebview.swift
//  Page
//
//  Created by Oliver Zhang on 2017/11/27.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    
    func snapshots(completion: @escaping (_ image:  UIImage?)->()) {
        let frameHeight = frame.size.height
        let contentHeight = scrollView.contentSize.height
        if frameHeight == 0 {
            completion(nil)
        }
        var scrollHeight: CGFloat = frameHeight
        var images: [UIImage] = []
        var isEndOfSnapShot = false
        if #available(iOS 10.0, *) {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                if let image = self?.snapshot() {
                    print ("scroll height is \(scrollHeight) and image is \(image)")
                    images.append(image)
                }
                let scrollPoint = CGPoint(x: 0, y: scrollHeight)
                self?.scrollView.setContentOffset(scrollPoint, animated: true)
                scrollHeight += frameHeight
                if isEndOfSnapShot == true {
                    timer.invalidate()
                } else if scrollHeight > contentHeight - frameHeight {
                    isEndOfSnapShot = true
                    let image = ShareHelper.stitchImages(images: images, isVertical: true)
                    //let image = images[0]
                    completion(image)
                }
            }
        }
        
    }
    
}
