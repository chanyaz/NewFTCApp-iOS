//
//  SubscribeManageViewController.swift
//  FTCC
//
//  Created by huiyun.he on 05/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class SubscribeManageViewController: UIViewController {

    let yesButton = UIButton()
    let noButton = UIButton()
    let okButton = UIButton()
    let yesLabel = UILabel()
    let noLabel = UILabel()
    let titleLabel = UILabel()
    
    @IBOutlet weak var isContinueSubscribe: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        isContinueSubscribe.layer.borderWidth = 1
        isContinueSubscribe.layer.borderColor = UIColor(hex: Color.PersonInfo.border).cgColor
        isContinueSubscribe.setTitleColor(UIColor(hex: Color.PersonInfo.border), for: .normal)
//        isContinueSubscribe.setTitle("确定", for: .normal)
//        isContinueSubscribe.titleEdgeInsets =  UIEdgeInsetsMake(0,0,0,4)
        isContinueSubscribe.contentEdgeInsets = UIEdgeInsetsMake(5,45,5,45)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clickContinueSubscribe(_ sender: UIButton) {
        if let subscribeInstructionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubscribeInstructionViewController") as? SubscribeInstructionViewController {
            navigationController?.pushViewController(subscribeInstructionViewController, animated: true)
            
        }
        
    }

}
