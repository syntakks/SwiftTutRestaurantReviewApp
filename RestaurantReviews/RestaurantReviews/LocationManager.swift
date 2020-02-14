//
//  LocationManager.swift
//  RestaurantReviews
//
//  Created by Stephen Wall on 2/13/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case unknownError
    case disallowedByUser
    case unableToFindLocation
}

protocol LocationPermissionsDelegate: class {
    func authorizationSucceeded()
    func authorizationFailed(_ status: CLAuthorizationStatus)
}

protocol LocationManagerDelegate: class {
    func obtainedCoordinates(_ coordinate: Coordinate)
    func failedWithError(_ error: LocationError)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    weak var permissionsDelegate: LocationPermissionsDelegate?
    weak var delegate: LocationManagerDelegate?
    
    static var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }
    
    init(delegate: LocationManagerDelegate?, permissionsDelegate: LocationPermissionsDelegate?) {
        self.delegate = delegate
        self.permissionsDelegate = permissionsDelegate
        super.init()
        manager.delegate = self
        //manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Request Location Permission
    func requestLocationAuthorization() throws {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        // User has restricted or denied permission. GTFO
        if authorizationStatus == .restricted || authorizationStatus == .denied {
            throw LocationError.disallowedByUser
        
        // Need to determine authorization status. Prompt the user for permission: (Paweeeeze?)
        } else if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            
        // User has already given permission. GTFO
        } else {
            return
        }
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    // MARK: - Location Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            permissionsDelegate?.authorizationSucceeded()
        } else {
            permissionsDelegate?.authorizationFailed(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {
            delegate?.failedWithError(.unknownError)
            return
        }
        switch error.code {
        case .locationUnknown, .network: delegate?.failedWithError(.unableToFindLocation)
        case .denied: delegate?.failedWithError(.disallowedByUser)
        default: return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.failedWithError(.unableToFindLocation)
            return
        }
        printData(for: location)
        let coordinate = Coordinate(location: location)
        delegate?.obtainedCoordinates(coordinate)
    }
    
    func printData(for location: CLLocation) {
        print("-------------------------CLLocation------------------------")
        print("Altitude: \( location.altitude)")
        print("Coordinate: \( location.coordinate)")
        print("Course: \( location.course)")
        print("Floor of the Building!!: \(String(describing: location.floor))")
        print("Speed (M/Sec): \(location.speed)")
        print("-----------------------------------------------------------")
    }
    
}
