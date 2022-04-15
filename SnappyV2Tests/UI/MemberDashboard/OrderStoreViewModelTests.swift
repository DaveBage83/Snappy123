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
        XCTAssertEqual(sut.store, PlacedOrderStore.mockedDataAddressLine2Present)
        XCTAssertEqual(sut.storeName, "Master Testtt")
        XCTAssertEqual(sut.storeLogo, "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")
        XCTAssertEqual(sut.address1, "Gallanach Rd")
        XCTAssertEqual(sut.address2, "Line 2 test")
        XCTAssertEqual(sut.town, "Oban")
        XCTAssertEqual(sut.postcode, "PA34 4PD")
        XCTAssertEqual(sut.telephone, "07986238097")
    }
    
    func test_init_givenAddressLineNotPresent() {
        let sut = makeSUT(store: PlacedOrderStore.mockedData)
        XCTAssertEqual(sut.store, PlacedOrderStore.mockedData)
        XCTAssertEqual(sut.storeName, "Master Testtt")
        XCTAssertEqual(sut.storeLogo, "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")
        XCTAssertEqual(sut.address1, "Gallanach Rd")
        XCTAssertNil(sut.address2)
        XCTAssertEqual(sut.town, "Oban")
        XCTAssertEqual(sut.postcode, "PA34 4PD")
        XCTAssertEqual(sut.telephone, "07986238097")
    }
    
    func test_init_givenTelephoneNotPresent() {
        let sut = makeSUT(store: PlacedOrderStore.mockedDataNoTelephone)
        XCTAssertEqual(sut.store, PlacedOrderStore.mockedDataNoTelephone)
        XCTAssertEqual(sut.storeName, "Master Testtt")
        XCTAssertEqual(sut.storeLogo, "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1589564824552274_13470292_2505971_9c972622_image.png")
        XCTAssertEqual(sut.address1, "Gallanach Rd")
        XCTAssertNil(sut.address2)
        XCTAssertEqual(sut.town, "Oban")
        XCTAssertEqual(sut.postcode, "PA34 4PD")
        XCTAssertEqual(sut.telephone, "Unknown")
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), store: PlacedOrderStore) -> OrderStoreViewModel {
        let sut = OrderStoreViewModel(container: container, store: store)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
