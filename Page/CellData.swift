//
//  CellData.swift
//  Page
//
//  Created by wangyichen on 04/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import Foundation
enum Member {
    case robot
    case you
    case no
}
struct CellData {
    var headImage: String = ""
    var whoSays: Member = .no
    var saysWhat: String = ""
    
}
