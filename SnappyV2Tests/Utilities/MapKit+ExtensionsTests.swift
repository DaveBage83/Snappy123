//
//  MapKit+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 15/06/2022.
//

import XCTest
import MapKit
@testable import SnappyV2

class MapKit_ExtensionsTests: XCTestCase {
    
    func test_MKCoordinateRegionCordinates_whenCoordinates_returnRegion() {
        // some coordinates around Dundee
        let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 56.410598, longitude: -5.47583),
            CLLocationCoordinate2D(latitude: 56.497526, longitude: -5.47783)
        ]
        // compare to the expected values
        if let result = MKCoordinateRegion(coordinates: coordinates) {
            XCTAssertEqual(result.span.latitudeDelta, 0.17385600000000068)
            XCTAssertEqual(result.span.longitudeDelta, 0.0039999999999995595)
            XCTAssertEqual(result.center, CLLocationCoordinate2D(latitude: 56.454062, longitude: -5.47683))
        } else {
            XCTFail("Expected MKCoordinateRegion instead of nil", file: #file, line: #line)
        }
    }
    
    func test_MKCoordinateRegionCordinates_whenNoCoordinates_returnNil() {
        XCTAssertNil(MKCoordinateRegion(coordinates: []))
    }

}
