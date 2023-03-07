//
//  Service.swift
//  WeatherBrick
//
//  Created by Dmytro Horodyskyi on 23.02.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationServiceDelegate {
    func createUrlAndExecuteDataTaskWith(latitude: Double?, longitude: Double?)
    func geolocationError()
}

class LocationService: NSObject {
    
    private var locationManager: CLLocationManager?
    var delegate: LocationServiceDelegate?
    static let shared = LocationService()
    
    
    func getCurrentLocation() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
    }
}


extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager?.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        delegate?.createUrlAndExecuteDataTaskWith(latitude: lastLocation?.coordinate.latitude,
                                                  longitude: lastLocation?.coordinate.longitude)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.geolocationError()
    }
}
