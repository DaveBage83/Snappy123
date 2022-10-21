//
//  DriverMapViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 17/06/2022.
//

import XCTest
import Combine
@testable import SnappyV2
import CoreLocation
import MapKit

@MainActor
class DriverMapViewModelTests: XCTestCase {

    func test_when2CoordinatesProvided_calculateIntermediatePointAndBearingReturnsMidpointAndBearing() {
        let sut = makeSUT(mapParams: DriverLocationMapParameters.mockedWithPlacedOrderData, dismissMapAction: {})
        
        let point1 = CLLocationCoordinate2D(latitude: 51.230780, longitude: -0.781580)
        let point2 = CLLocationCoordinate2D(latitude: 50.697130, longitude: -3.235880)
        
        let intermediatePoint = sut.calculateIntermediatePointAndBearing(point1: point1, point2: point2, percentage: 0.5)
        let expectedIntermediatePoint = CLLocationCoordinate2D(latitude: 50.970384, longitude: -2.015779)
        
        // Round values to 4 dp for testing
        XCTAssertEqual(ceil(intermediatePoint.0.latitude * 1000000) / 1000000, expectedIntermediatePoint.latitude)
        XCTAssertEqual(ceil(intermediatePoint.0.longitude * 1000000) / 1000000, expectedIntermediatePoint.longitude)
        XCTAssertEqual(intermediatePoint.1, -108.0906487502268)
    }
    
    func test_whenOrderCardVerticalUsageSet_thenMapRegionAdjusted() {
        let sut = makeSUT(mapParams: DriverLocationMapParameters.mockedWithPlacedOrderData, dismissMapAction: {})
        sut.setOrderCardVerticalUsage(to: 0.2)
        
        XCTAssertEqual(sut.mapRegion.center.latitude, 37.330440693)
        XCTAssertEqual(sut.mapRegion.center.longitude, -122.02698811)
    }
    
    func test_whenDismissMapTriggered_thenDismissDriverMapHandlerTriggered() {
        
        var test = 0
        let sut = makeSUT(mapParams: DriverLocationMapParameters.mockedWithPlacedOrderData) {
            test = 1
        }
        
        sut.dismissMap()
        XCTAssertEqual(test, 1)
    }
    
    func test_whenCallStoreAndDismissMapCalled_thenDismissHandlerTriggered() {
        var test = 0
        let sut = makeSUT(mapParams: DriverLocationMapParameters.mockedWithPlacedOrderData, dismissMapAction: {
            test = 1
        })
        sut.callStoreAndDismissMap()
        XCTAssertEqual(test, 1)
    }
    
    func test_whenMapToPlacedOrderSummaryCalledOnPlacedOrder_thenPlacedOrderMappedCorrectly() {
        let sut = makeSUT(mapParams: DriverLocationMapParameters.mockedWithPlacedOrderData, dismissMapAction: {})
        
        let expectedPlacedOrderSummary = PlacedOrderSummary(
            id: 1963404,
            businessOrderId: 2106,
            store: PlacedOrderStore.mockedData,
            status: "Store Accepted / Picking",
            statusText: "store_accepted_picking",
            fulfilmentMethod: PlacedOrderFulfilmentMethod.mockedData,
            totalPrice: 11.25)
        XCTAssertEqual(sut.placedOrderSummary, expectedPlacedOrderSummary)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), mapParams: DriverLocationMapParameters, dismissMapAction: @escaping () -> Void) -> DriverMapViewModel {
        DriverMapViewModel(
            container: container,
            mapParameters: mapParams) {
                dismissMapAction()
            }
    }
}
