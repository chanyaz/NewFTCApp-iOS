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
    
    var isEditting :Bool=false
//    var isSelect:Bool = false
    @IBAction func clickSelectedButton(_ sender: UIButton) {
//        if !isSelect{
//            selectedButton.setImage(UIImage(named:"LoveListActive"), for: UIControlState.normal)
//            isSelect = true
//        }else{
//            selectedButton.setImage(UIImage(named:"LoveList"), for: UIControlState.normal)
//            isSelect = false
//        }
//        sender.isSelected = !sender.isSelected
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.width = UIScreen.main.bounds.width + 45
        if (self.isEditting) {
            self.contentView.backgroundColor = UIColor.white
            self.frame.origin.x = 0
        }else{
            
            self.contentView.backgroundColor = UIColor.white
            self.frame.origin.x = -45
        }
    }
    
}
