//
//  LocationHelper.swift
//  Page
//
//  Created by Oliver Zhang on 2018/4/3.
//  Copyright © 2018年 Oliver Zhang. All rights reserved.
//

import Foundation
import CoreLocation

// Ask for Authorisation from the User.
// locationManager.requestAlwaysAuthorization()

struct LocationHelper {
    public static let shared = LocationHelper()
    // For use in foreground
    private let locationManager = CLLocationManager()
    
    public func get() -> (latitude: Double, longtitude: Double)? {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            if let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate {
                //print("locations = \(locValue.latitude) \(locValue.longitude)")
                let latitude = Double(locValue.latitude)
                let longitude = Double(locValue.longitude)
                return (latitude, longitude)
            }
            //            locationManager.startUpdatingLocation()
        }
        return nil
    }
}



