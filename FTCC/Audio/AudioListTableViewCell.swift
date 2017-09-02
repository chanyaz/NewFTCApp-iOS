//
//  AudioListTableViewCell.swift
//  Page
//
//  Created by huiyun.he on 30/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class AudioListTableViewCell: UITableViewCell {

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
