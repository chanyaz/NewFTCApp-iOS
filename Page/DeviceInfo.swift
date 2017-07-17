//
//  DeviceInfo.swift
//  Page
//
//  Created by Oliver Zhang on 2017/7/13.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit

struct DeviceInfo {
    public static func checkDeviceType() -> String {
        let deviceType: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceType = "iPad"
        } else {
            deviceType  = "iPhone"
        }
        return deviceType
    }
}
