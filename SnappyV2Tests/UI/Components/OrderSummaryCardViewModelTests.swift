//
//  OrderSummaryCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 05/09/2022.
//

import XCTest
@testable import SnappyV2

class OrderSummaryCardViewModelTests: XCTestCase {
    
    func test_whenPlacedOrderPresent_thenPopulatePropertiesWithTheseValues() {
        let order = PlacedOrder.mockedData
        let sut = makeSUT(order: order, basket: nil)
        
        XCTAssertEqual(sut.fulfilmentType, .delivery)
        XCTAssertEqual(sut.statusType, .standard)
        XCTAssertEqual(sut.orderTotal, "£11.25")
        XCTAssertEqual(sut.status, "Store Accepted / Picking")
        XCTAssertEqual(sut.storeName, "Master Testtt")
        XCTAssertEqual(sut.concatenatedAddress, "Gallanach Rd, Oban, PA34 4PD")
        XCTAssertEqual(sut.storeWithAddress1, "Master Testtt, Gallanach Rd")
        XCTAssertEqual(sut.selectedSlot, "20-Sep | 17:40 - 17:55")
    }
    
    func test_whenBasketOrderPresentAndPlacedOrderNot_thenPopulatePropertiesWithTheseValues() {
        let basket = Basket.mockedData
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container, order: nil, basket: basket)
        container.appState.value.userData.selectedStore = .loaded(.mockedData)
        
        XCTAssertEqual(sut.fulfilmentType, .delivery)
        XCTAssertEqual(sut.orderTotal, "£23.30")
        XCTAssertEqual(sut.status, "Sent to Store")
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), order: PlacedOrder?, basket: Basket?) -> OrderSummaryCardViewModel {
        let sut = OrderSummaryCardViewModel(container: container, order: order, basket: basket)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
