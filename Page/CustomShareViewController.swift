//
//  CustomShareViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/11/23.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
class CustomShareViewController: UIViewController {
    let dismissButton:UIButton! = UIButton(type:.custom)
    var imageName = "pizza_sm"
    var text = "BBQ Chicken Pizza!!!!"
    
    let myLabel = UILabel()
    
    func pizzaDidFinish(){
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Build a programmatic view
        view.isOpaque = false
        //Set the Background color of the view.
        view.backgroundColor = UIColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0.7
        )
        view.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(close))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        
        //        // Add the image to the view
        //        let myImage:UIImage! = UIImage(named: imageName)
        //        let myImageView = UIImageView(image: myImage)
        //        myImageView.frame = view.frame
        //        myImageView.frame = CGRect(
        //            x: 10,
        //            y: 10,
        //            width: 200,
        //            height: 200)
        //        view.addSubview(myImageView)
        //        // Add the label to the view
        //        myLabel.text = text
        //        myLabel.frame = CGRect(
        //            x: 220,
        //            y: 10,
        //            width: 300,
        //            height: 150)
        //        myLabel.font = UIFont(
        //            name: "Helvetica",
        //            size: 24)
        //        myLabel.textAlignment = .left
        //        view.addSubview(myLabel)
        //
        //        //Add the Done button to the view.
        //        let normal = UIControlState(rawValue: 0) //UIControlState.normal doesn't exist in beta(#27105189). This is a workaround.
        //        dismissButton.setTitle("Done", for: normal)
        //        dismissButton.setTitleColor(UIColor.white, for: normal)
        //        dismissButton.backgroundColor = UIColor.blue
        //        dismissButton.titleLabel!.font = UIFont(
        //            name: "Helvetica",
        //            size: 24)
        //        dismissButton.titleLabel?.textAlignment = .left
        //        dismissButton.frame = CGRect(
        //            x:10,
        //            y:275,
        //            width:400,
        //            height:50)
        //        //dismissButton.addTarget(self,action: #selector(self.pizzaDidFinish),for: .touchUpInside)
        //        view.addSubview(dismissButton)
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
}
