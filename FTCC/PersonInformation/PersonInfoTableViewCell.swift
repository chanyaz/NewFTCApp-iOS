//
//  PersonInfoTableViewCell.swift
//  FTCC
//
//  Created by huiyun.he on 31/10/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PersonInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
