//
//  Service.swift
//  WeatherBrick
//
//  Created by Dmytro Horodyskyi on 23.02.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func createUrlAndExecuteDataTaskWith(latitude: Double?, longitude: Double? )
}

class LocationService: NSObject {
    
    private let locationManager = CLLocationManager()
    var delegate: LocationServiceDelegate?
    
    func getCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}


extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        delegate?.createUrlAndExecuteDataTaskWith(latitude: lastLocation?.coordinate.latitude,
                                                  longitude: lastLocation?.coordinate.longitude)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
