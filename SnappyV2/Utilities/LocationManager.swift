//
//  LocationManager.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/04/2022.
//

import Foundation
import CoreLocation
import OSLog

class LocationManager: NSObject, ObservableObject {
    
    let locationManager = CLLocationManager()
    var locationStatus: CLAuthorizationStatus?
    var isRequestingLocation = false

    @Published var lastLocation: CLLocation?
    
    @Published var showDeniedLocationAlert: Bool = false
    @Published var showLocationUnknownAlert: Bool = false
    @Published var showUnknownErrorAlert: Bool = false
    
    @Published var error: Error?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    func dismissAlert() {
        showUnknownErrorAlert = false
        showDeniedLocationAlert = false
        showLocationUnknownAlert = false
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        switch locationStatus {
        case .some(.restricted), .some(.denied):
            showDeniedLocationAlert = true
        case .some(.authorizedAlways), .some(.authorizedWhenInUse):
                locationManager.requestLocation()
        default:
            locationManager.requestWhenInUseAuthorization()
            isRequestingLocation = true //Attempt to get location after the authorisation status has been changed
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        Logger.locationService.info("Location status: \(self.statusString)")
        if isRequestingLocation {
            isRequestingLocation = false
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        #warning("TODO: Put in sanity check last result for within 60 metres")
        lastLocation = location
        Logger.locationService.info("Last location: \(location)")
    }
    
    #warning("Improve error handling, utilising AppState")
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            self.error = error
            switch error {
            case CLError.denied:
                showDeniedLocationAlert = true
            case CLError.locationUnknown:
                showLocationUnknownAlert = true
            default:
                showUnknownErrorAlert = true
            }
        } else {
            self.error = error
        }
    }
    
}
