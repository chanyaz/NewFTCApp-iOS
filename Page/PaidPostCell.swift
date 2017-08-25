//
//  ChannelCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import SafariServices

// TODO: Paid Post Cell is just a copy from Channel Cell. Should seperate two sets of code.
// MARK: It is important that this is a seperate XIB and class otherwise some normal content cells will not be able to be selected, as a result of some weird bug in collection view. 
class PaidPostCell: UICollectionViewCell, SFSafariViewControllerDelegate {
    
    // MARK: - Style settings for this class
    let imageWidth = 152
    let imageHeight = 114
    //var adModel: AdModel?
    var pageTitle = ""
    
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
        setupLayout()
        requestAd()
        sizeCell()
    }
    
 
    
    private func requestAd() {
        containerView.backgroundColor = UIColor(hex: Color.Ad.background)
        border.backgroundColor = nil
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Content.background)
        
        
        // MARK: - if adModel is already available from itemCell, no need to get the data from internet
        
        if let adModel = itemCell?.adModel, adModel.headline != nil {
            //self.adModel = adModel
            showAd()
            print ("Paid Post: use data from fetches to layout this cell! ")
            return
        } else {
            print ("Paid Post: there is no headline from adMoel. Clear the view")
            imageView.image = nil
            headline.text = nil
            lead.text = nil
            sign.text = nil
        }
    }
    
    private func showAd() {
        if let adModel = itemCell?.adModel {
            headline.text = adModel.headline
            lead.text = adModel.lead
            sign.text = "广告"
            
            //            let randomIndex = Int(arc4random_uniform(UInt32(2)))
            //            if randomIndex == 1 {
            //                headline.text = "卡地亚广告"
            //            }
            
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
    
    
    
    
    // FIXME: These three functions are same as those in the AdView, should find a way to put them in one place
    private func addTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let link = self.itemCell?.adModel?.link, let url = URL(string: link) {
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

//TODO: Paid Post Ad should be moved to a subclass rather than the channel cell



