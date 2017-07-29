//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import SafariServices


class ChannelCell: UICollectionViewCell, SFSafariViewControllerDelegate {
    
    // MARK: - Style settings for this class
    let imageWidth = 152
    let imageHeight = 114
    var adModel: AdModel?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sign: UILabel!
    
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    func updateUI() {
        if itemCell?.type != "ad" {
            updateContent()
        } else {
            requestAd()
        }
    }
    
    private func requestAd() {
        setupLayout()
        containerView.backgroundColor = UIColor(hex: Color.Ad.background)
        border.backgroundColor = nil
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        // MARK: - initialize image view as it will be reused. If you don't do this, the cell might show wrong image when you scroll.
        imageView.image = nil
        
        
        if let adid = itemCell?.id, let url = AdParser.getAdUrlFromDolphin(adid) {
            print ("feed ad id is \(adid), url is \(url.absoluteString)")
            Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                DispatchQueue.main.async { () -> Void in
                    guard let data = data , error == nil, let adCode = String(data: data, encoding: .utf8) else {
                        print ("feed ad Fail: Request Ad From \(url)")
                        return
                    }
//                    print ("feed ad success: Request Ad From \(url)")
//                    print ("feed ad code is: \(adCode)")
                    let adModel = AdParser.parseAdCode(adCode)
//                    print ("info ad ad model retrieved as \(adModel)")
                    self?.adModel = adModel
                    self?.showPaidPost()
                }
            }
        }
        sizeCell()
    }
    
    private func showPaidPost() {
        if let adModel = adModel {
            headline.text = adModel.headline
            lead.text = adModel.lead
            sign.text = "广告"
            
            // MARK: - Report Impressions
            Impressions.report(adModel.impressions)
            
            // MARK: - Add the tap
            addTap()
            
            if let imageString0 = adModel.imageString {
                let imageString = ImageService.resize(imageString0, width: imageWidth, height: imageHeight)
                // MARK: If the asset is already downloaded, no need to request from the Internet
                if let data = Download.readFile(imageString, for: .cachesDirectory, as: nil) {
                    showAdImage(data)
                    //print ("image already in cache:\(imageString)")
                    return
                }
                if let url = URL(string: imageString) {
                    Download.getDataFromUrl(url) { [weak self] (data, response, error)  in
                        guard let data = data else {
                            return
                        }
                        DispatchQueue.main.async { () -> Void in
                            self?.showAdImage(data)
                        }
                        Download.saveFile(data, filename: imageString, to: .cachesDirectory, as: nil)
                    }
                }
            }
        }
    }
    
    private func showAdImage(_ data: Data) {
        imageView.image = UIImage(data: data)
    }
    
    
    private func setupLayout() {
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
        headline.font = headline.font.bold()
        lead.textColor = UIColor(hex: Color.Content.lead)
        sign.textColor = UIColor(hex: Color.Ad.sign)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
    }
    
    private func sizeCell() {
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
        }
    }
    
    private func updateContent() {
        setupLayout()
        
        // MARK: - set the border color
        if let row = itemCell?.row,
            row > 0 {
            border.backgroundColor = UIColor(hex: Color.Content.border)
        } else {
            // MARK: - set first item's border color to transparent
            border.backgroundColor = nil
        }
        
        // MARK: - Update dispay of the cell
        headline.text = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        sign.text = ""
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        // MARK: - initialize image view as it will be reused. If you don't do this, the cell might show wrong image when you scroll.
        imageView.image = nil
        
        if let loadedImage = itemCell?.thumbnailImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type: "thumbnail", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.thumbnailImage
            })
        }
        
        //print ("update UI for the cell\(String(describing: itemCell?.lead))")
        sizeCell()
    }
    
    
    // FIXME: These three functions are same as those in the AdView, should find a way to put them in one place
    private func addTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let link = self.adModel?.link, let url = URL(string: link) {
            openLink(url)
        }
    }
    
    fileprivate func openLink(_ url: URL) {
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        if let topController = UIApplication.topViewController() {
            topController.present(webVC, animated: true, completion: nil)
        }
    }
    
}


