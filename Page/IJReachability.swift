
//  IJReachability.swift
//  IJReachability
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//


import Foundation
import SystemConfiguration

struct Connection {
    static func current() -> String {
        let statusType = IJReachability().connectedToNetworkOfType()
        var connectionType = "unknown"
        switch statusType {
        case .wwan:
            connectionType = "data"
        case .wiFi:
            connectionType =  "wifi"
        case .notConnected:
            connectionType =  "no"
        }
        return connectionType
    }
}

public enum IJReachabilityType {
    case wwan,
    wiFi,
    notConnected
}

open class IJReachability {
    // MARK: - Original post - http://www.chrisdanielson.com/2009/07/22/iphone-network-connectivity-test-example/
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func connectedToNetworkOfType() -> IJReachabilityType {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notConnected
        }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notConnected
        }
        
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        
        if(isReachable && isWWAN){
            return .wwan
        }
        if(isReachable && !isWWAN){
            return .wiFi
        }
        return .notConnected
    }
    
}
