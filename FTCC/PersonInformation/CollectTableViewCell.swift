//
//  CollectTableViewCell.swift
//  FTCC
//
//  Created by huiyun.he on 31/10/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class CollectTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var selectedLabel: UILabel!
    
    var isSelect:Bool = false
    @IBAction func clickSelectedButton(_ sender: UIButton) {
        if !isSelect{
            selectedButton.setImage(UIImage(named:"LoveListActive"), for: UIControlState.normal)
            isSelect = true
        }else{
            selectedButton.setImage(UIImage(named:"LoveList"), for: UIControlState.normal)
            isSelect = false
        }
        
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
