//
//  LineCell.swift
//  Page
//
//  Created by ZhangOliver on 2017/7/29.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class LineCell: UICollectionViewCell {
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var borderTrailing: NSLayoutConstraint!
    @IBOutlet weak var borderWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var borderLeading: NSLayoutConstraint!
    var cellWidth: CGFloat? {
        didSet {
            updateUI()
        }
    }
    
    var pageTitle = ""
    
    var itemCell: ContentItem? {
        didSet {
            requestAd()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hex: Color.Content.background)
        border.backgroundColor = UIColor(hex: Color.Content.border)
    }
    
    private func updateUI() {
        if let cellWidth = cellWidth {
            //MARK: Use this to suppress useless warnings in log
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            borderWidthConstraint.constant = cellWidth - borderTrailing.constant - borderLeading.constant
            //print ("border width constraint is now \(borderWidthConstraint.constant)")
        }
    }
    
    private func requestAd() {
        if let adid = itemCell?.id, let url = AdParser.getAdUrlFromDolphin(adid) {
            print ("Paid Post id is \(adid), url is \(url.absoluteString)")
            Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                DispatchQueue.main.async { () -> Void in
                    //print ("get paid post data of \(data)")
                    // MARK: - Dolphin uses GBK as encoding
                    guard let data = data, error == nil, let adCode = String(data: data, encoding: Download.encodingGBK()) else {
                        print ("Paid Post ad Fail: Request Ad From \(url). Error: \(String(describing: error))")
                        let adModel = AdModel(
                            imageString: nil,
                            link: nil,
                            video: nil,
                            impressions: [],
                            headline: nil,
                            adName: nil,
                            bgColor: "0",
                            lead: nil,
                            adCode: "")
                        self?.itemCell?.adModel = adModel
                        self?.postNotificationForPaidPostUpdate()
                        return
                    }
                    //                    print ("Paid Post success: Request Ad From \(url)")
                    //                    print ("Paid Post ad code is: \(adCode)")
                    let adModel = AdParser.parseAdCode(adCode)
                    //                    print ("info ad ad model retrieved as \(adModel)")
                    self?.itemCell?.adModel = adModel
                    self?.postNotificationForPaidPostUpdate()
                }
            }
        }
    }
    
    private func postNotificationForPaidPostUpdate() {
        // MARK: Tell the collection layout view to reflow the layout
        let object = itemCell
        let name = Notification.Name(rawValue: Event.paidPostUpdate(for: pageTitle))
        NotificationCenter.default.post(name: name, object: object)
    }
}
