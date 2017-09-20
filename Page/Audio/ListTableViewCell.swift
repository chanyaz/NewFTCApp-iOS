//
//  ListTableViewCell.swift
//  Page
//
//  Created by huiyun.he on 04/09/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var playHint: UIButton!
    @IBOutlet weak var playHeadline: UILabel!
    //    var itemCell: ContentItem?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    func updateUI() {
        playHeadline.text = itemCell?.headline
        self.contentView.backgroundColor = UIColor.white
        playHeadline.textColor = UIColor.black
        playHeadline.font = UIFont(name: "Helvetica-Light", size: 16.0)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
