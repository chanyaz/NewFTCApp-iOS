//
//  PortraitTableViewCell.swift
//  FTCC
//
//  Created by huiyun.he on 31/10/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PortraitTableViewCell: UITableViewCell {
    @IBOutlet weak var portraitImageView: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapPortraitGesture))
//        portraitImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func clickLoginButton(_ sender: UIButton) {
        print("click portrait")
//        openHTMLInBundle("account", title: "注册", isFullScreen: false, hidesBottomBar: true)
    }
    @IBAction func tapPortraitGesture(_ recognizer: UIButton) {
        print("tap portrait")
        
    }
//    @objc open func tapPortraitGesture(_ recognizer: UIButton) {
//        print("tap portrait")
//
//    }
    
}
