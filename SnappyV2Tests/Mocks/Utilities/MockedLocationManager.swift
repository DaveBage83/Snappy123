//
//  MockedLocationManager.swift
//  SnappyV2Tests
//
//  Created by Peter Whittle on 25/10/2022.
//

import Foundation
import CoreLocation
import XCTest

@testable import SnappyV2

/* Below approach inspired by partial mocks, as described in https://www.swiftbysundell.com/articles/mocking-in-swift/,
since using published variables in protocols is difficult and makes full mocking messy */

class MockedLocationManager: LocationManager {
    
    //Testing options
    public var testLocation: CLLocation?
    
    init(locationAuthStatus: CLAuthorizationStatus, setLocation: CLLocation?) {
        super.init()
        self.locationStatus = locationAuthStatus
        
        if let setLocation {
            testLocation = setLocation
        }
    }
    
    override func requestLocation() {
        switch locationStatus {
        case .some(.restricted), .some(.denied):
            showDeniedLocationAlert = true
        case .some(.authorizedAlways), .some(.authorizedWhenInUse):
            if let testLocation {
                self.locationManager(locationManager, didUpdateLocations: [testLocation])
            } else {
                //Return unknown location error if no location initialised with mock
                self.locationManager(locationManager, didFailWithError: CLError(CLError.locationUnknown))
            }
        default:
            //Mock should always be initialised with one of the statuses above - do nothing.
            print("")
        }
    }
    
    //Delegate functions
    override func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        if self.isRequestingLocation {
            self.isRequestingLocation = false
        }
    }
    
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
    }

}

