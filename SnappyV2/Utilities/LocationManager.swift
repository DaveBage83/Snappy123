//
//  LocationManager.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/04/2022.
//

import Foundation
import CoreLocation
import OSLog

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    enum LocationManagerError: Swift.Error {
        case noLocationFound
    }
    
    private let locationManager = CLLocationManager()
    private var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    
    @Published var showDeniedLocationAlert: Bool = false
    @Published var showLocationUnknownAlert: Bool = false
    @Published var showUnknownErrorAlert: Bool = false
    
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
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        Logger.locationService.info("Location status: \(self.statusString)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        Logger.locationService.info("Last location: \(location)")
    }
    
    #warning("Add more error handling")
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error {
            case CLError.denied:
                showDeniedLocationAlert = true
            case CLError.locationUnknown:
                showLocationUnknownAlert = true
            default:
                showUnknownErrorAlert = true
            }
        } else {
            // additional error handling
        }
    }
}
