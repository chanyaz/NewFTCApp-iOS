//
//  CustomTabBarController.swift
//  Page
//
//  Created by huiyun.he on 28/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices



class CustomTabBarController: UITabBarController,UITabBarControllerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {

        super.viewDidLoad()
        self.tabBar.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 0)
        self.tabBar.isHidden = true

    }

    override func viewWillAppear(_ animated: Bool) {


    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }

    

}
