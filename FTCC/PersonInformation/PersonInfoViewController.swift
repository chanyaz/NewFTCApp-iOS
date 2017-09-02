//
//  PersonInfoViewController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PersonInfoViewController: UITableViewController {
    
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var subscribeTableViewCell: UITableViewCell!
    @IBOutlet weak var downloadTableViewCell: UITableViewCell!
    @IBOutlet weak var favoritesTableViewCell: UITableViewCell!
    @IBOutlet weak var settingTableViewCell: UITableViewCell!
    @IBOutlet weak var walletTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoTableView.separatorStyle = .none
//        self.infoTableView.rowHeight = 60
//        self.subscribeTableViewCell.frame.height = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section==1 && indexPath.row == 0{
            if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MySubscribeViewController") as? MySubscribeViewController {
                
                navigationController?.pushViewController(mySubscribeViewController, animated: true)
            }
        }
        if indexPath.section==1 && indexPath.row == 1{
            if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyDownloadViewController") as? MyDownloadViewController {
     
                navigationController?.pushViewController(mySubscribeViewController, animated: true)
            }
        }
        
        if indexPath.section==1 && indexPath.row == 2{
            if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyFavoritesViewController") as? MyFavoritesViewController {
                
                navigationController?.pushViewController(mySubscribeViewController, animated: true)
            }
        }
        if indexPath.section==1 && indexPath.row == 3{
            if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MySettingViewController") as? MySettingViewController {
                
                navigationController?.pushViewController(mySubscribeViewController, animated: true)
            }
        }
        if indexPath.section==1 && indexPath.row == 4{
            if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletViewController") as? MyWalletViewController {
                
                navigationController?.pushViewController(mySubscribeViewController, animated: true)
            }
        }
        
    }



}
