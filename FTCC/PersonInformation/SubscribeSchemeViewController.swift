//
//  SubscribeSchemeViewController.swift
//  FTCC
//
//  Created by huiyun.he on 05/11/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class SubscribeSchemeViewController: UIViewController {

    @IBOutlet weak var toBuyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickToBuy(_ sender: UIButton) {
        print("click to buy")
        
    }

}
