//
//  SubscribeManageViewController.swift
//  FTCC
//
//  Created by huiyun.he on 05/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class SubscribeManageViewController: UIViewController {

    @IBOutlet weak var isContinueSubscribe: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
