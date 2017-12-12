//
//  Benefits.swift
//  Page
//
//  Created by Oliver Zhang on 2017/12/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct Privilege {
    
    static var shared = Privilege()
    
    var adDisplay: AdDisplay = .all
    var englishText = false
    var englishAudio = false
    var exclusiveContent = false
    var editorsChoice = false
    
    init(adDisplay: AdDisplay, englishText: Bool, englishAudio: Bool, exclusiveContent: Bool, editorsChoice: Bool) {
        self.adDisplay = adDisplay
        self.englishText = englishText
        self.englishAudio = englishAudio
        self.exclusiveContent = exclusiveContent
        self.editorsChoice = editorsChoice
    }
    
    init() {
        self.adDisplay = .all
        self.englishText = false
        self.englishAudio = false
        self.exclusiveContent = false
        self.editorsChoice = false
    }

}

struct PrivilegeHelper {
    
    static func updateFromDevice() {
        let memberships = IAPProducts.memberships
        for membership in memberships {
            if let id = membership["id"] as? String {
                let purchased = UserDefaults.standard.bool(forKey: id)
                //print ("IAP: \(id) purchase status is \(purchased)")
                if purchased == true {
                    if let privilege = membership["privilege"] as? Privilege {
                        Privilege.shared = privilege
                        print ("IAP: check locally and privilege is \(privilege)")
                    }
                }
            }
        }
    }
    
    static func updateFromNetwork() {
        let memberships = IAPProducts.memberships
        for membership in memberships {
            if let id = membership["id"] as? String {
                let purchased = IAP.checkStatus(id)
                //print ("IAP: \(id) purchase status is \(purchased)")
                if purchased != "new" {
                    if let privilege = membership["privilege"] as? Privilege {
                        Privilege.shared = privilege
                        print ("IAP: check from network and privilege is \(privilege)")
                    }
                } else {
                    UserDefaults.standard.set(false, forKey: id)
                    print ("IAP: check from network and \(id)'s purchase status is set to false")
                }
            }
        }
    }
}


enum AdDisplay {
    case no
    case reasonable
    case all
}

