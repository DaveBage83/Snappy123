//
//  OrderDetailsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/04/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class OrderDetailsViewModelTests: XCTestCase {
    func test_init() {
        let order = PlacedOrder.mockedData
        let sut = makeSUT(placedOrder: order)
        
        XCTAssertEqual(sut.order, order)
        XCTAssertEqual(sut.orderNumber, String(order.id))
        XCTAssertEqual(sut.subTotal, order.totalPrice.toCurrencyString())
        XCTAssertEqual(sut.totalToPay, order.totalToPay?.toCurrencyString())
        XCTAssertEqual(sut.surCharges, order.surcharges)
        XCTAssertTrue(sut.deliveryCostApplicable)
        XCTAssertTrue(sut.driverTipPresent)
        XCTAssertEqual(sut.numberOfItems, "1 item")
        XCTAssertEqual(sut.fulfilmentMethod, "Delivery")
    }
    
    func test_init_whenFulfilmentIsCollection() {
        let order = PlacedOrder.mockedDataCollection
        let sut = makeSUT(placedOrder: order)
        
        XCTAssertEqual(sut.order, order)
        XCTAssertEqual(sut.orderNumber, String(order.id))
        XCTAssertEqual(sut.subTotal, order.totalPrice.toCurrencyString())
        XCTAssertEqual(sut.totalToPay, order.totalToPay?.toCurrencyString())
        XCTAssertEqual(sut.surCharges, order.surcharges)
        XCTAssertTrue(sut.deliveryCostApplicable)
        XCTAssertTrue(sut.driverTipPresent)
        XCTAssertEqual(sut.numberOfItems, "1 item")
        XCTAssertEqual(sut.fulfilmentMethod, "Collection")
    }
    
    // RetailStoresService check
    func test_whenRepeatOrderTapped_thenStoreDetailsFetchedAndStoreSearchCarriedOut() async {
        let container = DIContainer(appState: AppState(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "PA34 4PD"), .getStoreDetails(storeId: 910, postcode: "PA34 4PD")]))
        
        let order = PlacedOrder.mockedDataRepeatOrder
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .loaded(RetailStoresSearch.mockedData)
        
        do {
            try await sut.repeatOrderTapped()
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        container.services.verify(as: .retailStore)
    }
    
    
    
    // BasketService check
    func test_whenRepeatOrderTapped_thenRepeatOrderPopulated() async {
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.populateRepeatOrder(businessOrderId: 2106)]))
        
        let order = PlacedOrder.mockedDataRepeatOrder
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .loaded(RetailStoresSearch.mockedData)
        
        do {
            try await sut.repeatOrderTapped()
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        container.services.verify(as: .basket)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), placedOrder: PlacedOrder) -> OrderDetailsViewModel {
        let sut = OrderDetailsViewModel(container: container, order: placedOrder)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
