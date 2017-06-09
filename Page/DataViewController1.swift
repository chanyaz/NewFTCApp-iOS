//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/5/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class DataViewController1: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Set Styles
        self.view.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        
        // MARK: - Test code to add gesture to a label
        //let tap = UITapGestureRecognizer(target: self, action: Selector(("tapFunction:")))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        dataLabel.isUserInteractionEnabled = true
        dataLabel.addGestureRecognizer(tapGestureRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = dataObject
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier ?? "not found")
    }
    
    open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        //navigationController?.performSegue(withIdentifier: "Show News Detail", sender: self)
        //performSegue(withIdentifier: "Show Detail Content", sender: self)
        if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
            let titleForDetailView: String
            if let recognizerView = recognizer.view as? UILabel {
                titleForDetailView = recognizerView.text ?? "No Title From the Label"
            } else {
                titleForDetailView = "Not a Label"
            }
            detailViewController.viewTitle = "Detail View Clicked From \(titleForDetailView)"
            navigationController?.pushViewController(detailViewController, animated: true)
        }
        
    }
    


}

