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
        //var contentHeight = scrollView.contentSize.height
        if frameHeight == 0 {
            completion(nil)
        }
        var scrollHeight: CGFloat = frameHeight
        let oldScrollHeight = scrollView.contentOffset.y
        var images: [UIImage] = []
        var isEndOfSnapShot = false
        if #available(iOS 10.0, *) {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            // MARK: Pop a view controller to hide the screen shot behind it
            let vc = screenShotStatusViewController()
            if parentViewController is DataViewController {
                vc.modalPresentationStyle = .overCurrentContext
            }
            parentViewController?.present(vc, animated: false, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                if let image = self?.snapshot() {
                    images.append(image)
                }
                // MARK: content height might change when scrolling
                if let contentHeight = self?.scrollView.contentSize.height {
                    let scrollPoint = CGPoint(x: 0, y: scrollHeight)
                    self?.scrollView.setContentOffset(scrollPoint, animated: true)
                    scrollHeight += frameHeight
                    if isEndOfSnapShot == true {
                        timer.invalidate()
                        //statusView.removeFromSuperview()
                        vc.dismiss(animated: false, completion: {
                            print ("Screen Shot Done!")
                        })
                        let scrollPointOld = CGPoint(x: 0, y: oldScrollHeight)
                        self?.scrollView.setContentOffset(scrollPointOld, animated: false)
                    } else if scrollHeight >= contentHeight + frameHeight {
                        isEndOfSnapShot = true
                        let image = ShareHelper.stitchImages(images: images, isVertical: true)
                        completion(image)
                    }
                }
            }
        }
    }
}

class screenShotStatusViewController: UIViewController {
    override func loadView() {
        super.loadView()
        addStatusView()
    }
    private func addStatusView() {
        // MARK: An activity indicator screen so that users won't think there's something wrong with the screenshot
        print ("status view frame is \(view.frame)")
        let statusView = UIView(frame: view.frame)
        statusView.backgroundColor = UIColor(hex: Color.Content.background)
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.frame = view.frame
        activityIndicator.center = statusView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        statusView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        let statusLabel = UILabel()
        statusLabel.frame = CGRect(
            x: 0,
            y: view.frame.height/2 + 44,
            width: view.frame.width,
            height: 44
        )
        statusLabel.textAlignment = .center
        statusLabel.text = "图像处理中，请耐心等待"
        statusLabel.textColor = UIColor(hex: Color.Content.headline)
        statusView.addSubview(statusLabel)
        view.addSubview(statusView)
    }
}
