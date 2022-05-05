//
//  OrderStoreViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/04/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class OrderStoreViewModelTests: XCTestCase {
    
    func test_init_givenAddressLine2Present() {
        let sut = makeSUT(store: PlacedOrderStore.mockedDataAddressLine2Present)
        let placedOrderStore = PlacedOrderStore.mockedDataAddressLine2Present
        
        XCTAssertEqual(sut.store, placedOrderStore)
        XCTAssertEqual(sut.storeName, placedOrderStore.name)
        XCTAssertEqual(sut.storeLogo, placedOrderStore.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
        XCTAssertEqual(sut.address1, placedOrderStore.address1)
        XCTAssertEqual(sut.address2, placedOrderStore.address2)
        XCTAssertEqual(sut.town, placedOrderStore.town)
        XCTAssertEqual(sut.postcode, placedOrderStore.postcode)
        XCTAssertEqual(sut.telephone, placedOrderStore.telephone)
    }
    
    func test_init_givenAddressLineNotPresent() {
        let sut = makeSUT(store: PlacedOrderStore.mockedData)
        let placedOrderStore = PlacedOrderStore.mockedData
        
        XCTAssertEqual(sut.store, placedOrderStore)
        XCTAssertEqual(sut.storeName, placedOrderStore.name)
        XCTAssertEqual(sut.storeLogo, placedOrderStore.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
        XCTAssertEqual(sut.address1, placedOrderStore.address1)
        XCTAssertNil(sut.address2)
        XCTAssertEqual(sut.town, placedOrderStore.town)
        XCTAssertEqual(sut.postcode, placedOrderStore.postcode)
        XCTAssertEqual(sut.telephone, placedOrderStore.telephone)
    }
    
    func test_init_givenTelephoneNotPresent() {
        let sut = makeSUT(store: PlacedOrderStore.mockedDataNoTelephone)
        let placedOrderStore = PlacedOrderStore.mockedDataNoTelephone
        
        XCTAssertEqual(sut.store, placedOrderStore)
        XCTAssertEqual(sut.storeName, placedOrderStore.name)
        XCTAssertEqual(sut.storeLogo, placedOrderStore.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
        XCTAssertEqual(sut.address1, placedOrderStore.address1)
        XCTAssertNil(sut.address2)
        XCTAssertEqual(sut.town, placedOrderStore.town)
        XCTAssertEqual(sut.postcode, placedOrderStore.postcode)
        XCTAssertEqual(sut.telephone, "Unknown")
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), store: PlacedOrderStore) -> OrderStoreViewModel {
        let sut = OrderStoreViewModel(container: container, store: store)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
