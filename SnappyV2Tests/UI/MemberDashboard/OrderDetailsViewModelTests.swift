//
//  OrderDetailsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/04/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
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
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "PA34 4PD"), .getStoreDetails(storeId: 910, postcode: "PA34 4PD")]))
        
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
    
    func test_whenRepeatOrderTapped_givenDeliveryDetailsIncomplete_thenSetDeliveryAddressNotCompleted() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.populateRepeatOrder(businessOrderId: 2106)]))
        
        let order = PlacedOrder.mockedDataIncompleteAddress
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .loaded(RetailStoresSearch.mockedData)
        
        do {
            try await sut.repeatOrderTapped()
        } catch {
            XCTFail("Error thrown when setDeliveryAddress should silently fail")
        }
        
        container.services.verify(as: .basket)
    }

    func test_whenRepeatOrderTapped_givenDeliveryDetailsIncomplete_thenFailedToSetDeliveryAddressErrorThrown() async {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedDataIncompleteAddress)
        
        do {
          try await sut.exposeSetDeliveryAddress()
            XCTFail("Expected error not hit")
        } catch {
            if let error = error as? OrderDetailsViewModel.OrderDetailsError {
                XCTAssertEqual(error, OrderDetailsViewModel.OrderDetailsError.failedToSetDeliveryAddress)
            } else {
                XCTFail("Expected error not hit")
            }
        }
    }
    
    // BasketService check
    func test_whenRepeatOrderTapped_thenRepeatOrderPopulatedAndSetDeliveryAddressProcessed() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.populateRepeatOrder(businessOrderId: 2106), .setDeliveryAddress(address: SnappyV2.BasketAddressRequest(firstName: "Harold", lastName: "Brown", addressLine1: "Gallanach Rd", addressLine2: "", town: "Oban", postcode: "PA34 4PD", countryCode: "GB", type: "delivery", email: "testemail@email.com", telephone: "09998278888", state: nil, county: nil, location: nil))]))
        
        let order = PlacedOrder.mockedDataRepeatOrder
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .loaded(RetailStoresSearch.mockedData)
        
        await sut.repeatOrderTapped()
        
        XCTAssertNil(sut.error)
        container.services.verify(as: .basket)
    }
    
    func test_whenRepeatOrderTapped_givenNoStoresFound_thenNoStoreFoundErrorThrown() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let order = PlacedOrder.mockedDataRepeatOrder
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .notRequested
        
        await sut.repeatOrderTapped()
        
        if let error = sut.error as? OrderDetailsViewModel.OrderDetailsError {
            XCTAssertEqual(error, OrderDetailsViewModel.OrderDetailsError.noStoreFound)
        } else {
            XCTFail("Expected error not hit")
        }
    }
    
    func test_whenRepeatOrderTapped_givenStoreDoesNotMatchOrderStoreID_thenNoMatchingStoreFoundErrorThrown() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let order = PlacedOrder.mockedData
        let sut = makeSUT(container: container, placedOrder: order)
        
        let stores = [RetailStore.mockedData[2]]
        
        let retailStoreSearch = RetailStoresSearch(
            storeProductTypes: RetailStoreProductType.mockedData,
            stores: stores,
            fulfilmentLocation: FulfilmentLocation.mockedData
        )
        
        container.appState.value.userData.searchResult = .loaded(retailStoreSearch)
        
        await sut.repeatOrderTapped()
        
        if let error = sut.error as? OrderDetailsViewModel.OrderDetailsError {
            XCTAssertEqual(error, OrderDetailsViewModel.OrderDetailsError.noMatchingStoreFound)
        } else {
            XCTFail("Unexpected error type")
        }
    }
    
    func test_whenRepeatOrderTapped_givenNoDeliveryAddressSetOnOrder_thenDeliveryAddressOnOrderErrorThrown() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let order = PlacedOrder.mockedDataNoDeliveryAddress
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .notRequested
        
        await sut.repeatOrderTapped()
        
        if let error = sut.error as? OrderDetailsViewModel.OrderDetailsError {
            XCTAssertEqual(error, OrderDetailsViewModel.OrderDetailsError.noDeliveryAddressOnOrder)
        } else {
            XCTFail("Expected error not hit")
        }
    }
    
    func test_whenShowTrackOrderButtonOverrideIsFalse_thenShowTrackOrderButtonIsFalse() {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedData)
        sut.driverLocation = DriverLocation(orderId: 123, pusher: nil, store: nil, delivery: OrderDeliveryLocationAndStatus(latitude: 1, longitude: 1, status: 5), driver: nil)
        sut.showTrackOrderButtonOverride = false
        XCTAssertFalse(sut.showTrackOrderButton)
    }
    
    func test_whenDriverStatusIs5AndShowTrackOrderButtonOverrideIsFalse_thenShowTrackOrderButtonIsTrue() {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedData)
        sut.driverLocation = DriverLocation(orderId: 123, pusher: nil, store: nil, delivery: OrderDeliveryLocationAndStatus(latitude: 1, longitude: 1, status: 5), driver: nil)
        
        XCTAssertTrue(sut.showTrackOrderButton)
    }
    
    func test_whenSetDriverLocationTriggered_thenDriverLocationCalled() async {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedData)
        let expectedDriverLocation = DriverLocation.mockedDataEnRoute
        do {
            try await sut.setDriverLocation()
            XCTAssertEqual(sut.driverLocation, expectedDriverLocation)
            
        } catch {
            XCTFail("Failed to set driver location: \(error)")
        }
    }
    
    func test_whenOrderProgressIs1AndGetDriverLocationIfOrderCompleteCalled_thenShowDetailsViewIsTrue() async {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedDataStatusComplete)
        
        await sut.getDriverLocationIfOrderIncomplete(orderProgress: 1)
        XCTAssertTrue(sut.showDetailsView)
        XCTAssertNil(sut.driverLocation)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), placedOrder: PlacedOrder) -> OrderDetailsViewModel {
        let sut = OrderDetailsViewModel(container: container, order: placedOrder)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
