//
//  SubscribeInstructionViewController.swift
//  FTCC
//
//  Created by huiyun.he on 05/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class SubscribeInstructionViewController: UIViewController {

    @IBOutlet weak var toSubscribeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        toSubscribeButton.layer.borderWidth = 1
        toSubscribeButton.layer.borderColor = UIColor(hex: Color.PersonInfo.border).cgColor
        toSubscribeButton.setTitleColor(UIColor(hex: Color.PersonInfo.border), for: .normal)
        toSubscribeButton.contentEdgeInsets = UIEdgeInsetsMake(5,45,5,45)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clickToSubscribe(_ sender: UIButton) {
        if let subscribeSchemeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubscribeSchemeViewController") as? SubscribeSchemeViewController {
            navigationController?.pushViewController(subscribeSchemeViewController, animated: true)
            
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
