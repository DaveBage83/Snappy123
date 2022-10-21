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
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "PA34 4PD"), .getStoreDetails(storeId: 910, postcode: "PA34 4PD")]))
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let sut = makeSUT(container: container, placedOrder: order)
        
        XCTAssertEqual(sut.order, order)
        XCTAssertEqual(sut.orderNumber, String(order.id))
        XCTAssertEqual(sut.totalToPay, "£13.09")
        XCTAssertEqual(sut.deliveryCostPriceString, "£1.00")
        XCTAssertEqual(sut.driverTipPriceString, "£1.50")
        XCTAssertEqual(sut.numberOfItems, "1 item")
        XCTAssertEqual(sut.fulfilmentMethod, "Delivery")

        XCTAssertEqual(sut.displayableSurcharges.first?.amount, "£0.09")
    }
    
    func test_init_whenFulfilmentIsCollection() {
        let order = PlacedOrder.mockedDataCollection
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "PA34 4PD"), .getStoreDetails(storeId: 910, postcode: "PA34 4PD")]))
        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let sut = makeSUT(container: container, placedOrder: order)
        
        XCTAssertEqual(sut.order, order)
        XCTAssertEqual(sut.orderNumber, String(order.id))
        XCTAssertEqual(sut.totalToPay, "£13.09")
        XCTAssertEqual(sut.deliveryCostPriceString, "£1.00")
        XCTAssertEqual(sut.driverTipPriceString, "£1.50")
        XCTAssertEqual(sut.numberOfItems, "1 item")
        XCTAssertEqual(sut.fulfilmentMethod, "Collection")
        
        XCTAssertEqual(sut.displayableSurcharges.first?.amount, "£0.09")
    }
    
    // RetailStoresService check
    func test_whenRepeatOrderTapped_thenStoreDetailsFetchedAndStoreSearchCarriedOut() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "PA34 4PD"), .getStoreDetails(storeId: 910, postcode: "PA34 4PD")]))
        
        let order = PlacedOrder.mockedDataRepeatOrder
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .loaded(RetailStoresSearch.mockedData)
        
        await sut.repeatOrderTapped()
        
        container.services.verify(as: .retailStore)
    }
    
    func test_whenRepeatOrderTapped_givenDeliveryDetailsIncomplete_thenSetDeliveryAddressNotCompleted() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(basketService: [.populateRepeatOrder(businessOrderId: 2106)]))
        
        let order = PlacedOrder.mockedDataIncompleteAddress
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .loaded(RetailStoresSearch.mockedData)
        
        await sut.repeatOrderTapped()
        
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
        
        XCTAssertNil(sut.container.appState.value.latestError)
        container.services.verify(as: .basket)
    }
    
    func test_whenRepeatOrderTapped_givenNoStoresFound_thenNoStoreFoundErrorThrown() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        let order = PlacedOrder.mockedDataRepeatOrder
        let sut = makeSUT(container: container, placedOrder: order)
        
        container.appState.value.userData.searchResult = .notRequested
        
        await sut.repeatOrderTapped()
        
        if let error = sut.container.appState.value.latestError as? OrderDetailsViewModel.OrderDetailsError {
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
        
        if let error = sut.container.appState.value.latestError as? OrderDetailsViewModel.OrderDetailsError {
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
        
        if let error = sut.container.appState.value.latestError as? OrderDetailsViewModel.OrderDetailsError {
            XCTAssertEqual(error, OrderDetailsViewModel.OrderDetailsError.noDeliveryAddressOnOrder)
        } else {
            XCTFail("Expected error not hit")
        }
    }
    
    func test_whenShowTrackOrderButtonOverrideIsFalse_thenShowTrackOrderButtonIsFalse() {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedData)
        sut.driverLocation = DriverLocation(orderId: 123, pusher: nil, store: nil, delivery: OrderDeliveryLocationAndStatus(latitude: 1, longitude: 1, status: 5), driver: nil)
        sut.showTrackOrderButtonOverride = false
        XCTAssertFalse(sut.displayTrackOrderButton)
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
    
    func test_whenDisplayDriverMapTriggered_thenDriverMapDisplayed() async {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedData, showTrackOrderButton: true)
        sut.driverLocation = DriverLocation.mockedDataEnRoute
        await sut.displayDriverMap()
        XCTAssertTrue(sut.showDriverMap)
    }
    
    func test_whenDriverMapDismissHandlerCalled_thenShowTrackOrderButtonOverrideAndShowDriverMapIsFalse() {
        let sut = makeSUT(placedOrder: PlacedOrder.mockedData)
        sut.driverMapDismissAction()
        
        XCTAssertFalse(sut.showDriverMap)
        XCTAssertFalse(sut.showTrackOrderButtonOverride)
        XCTAssertFalse(sut.displayTrackOrderButton)
	}

    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "past_order_detail"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let placedOrder = PlacedOrder.mockedData
        let sut = makeSUT(container: container, placedOrder: placedOrder)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenInit_thenTotalRefundedPopulated() {
        let sut = makeSUT(placedOrder: .mockedData)
        XCTAssertEqual(sut.totalRefunded, "£0.00")
    }
    
    func test_whenInit_thenAdjustedTotalPopulated() {
        let sut = makeSUT(placedOrder: .mockedData)
        XCTAssertEqual(sut.adjustedTotal, "£20.00")
    }
    
    func test_whenTotalCostAdjustmentGreaterThan0_thenShowTotalCostAdjustmentIsTrue() {
        let sut = makeSUT(placedOrder: .mockedDataWithRefundedTotal)
        XCTAssertTrue(sut.showTotalCostAdjustment)
    }
    
    func test_whenTotalCostAdjustment0_thenShowTotalCostAdjustmentIsFalse() {
        let sut = makeSUT(placedOrder: .mockedData)
        XCTAssertFalse(sut.showTotalCostAdjustment)
    }
    
    func test_whenDriverTipRefundsPresent_thenPopulateDriverTipRefund() {
        let sut = makeSUT(placedOrder: .mockedDataWithDriverTipRefunds)
        let refunds = [PlacedOrderDriverTip(value: 0.5, message: "test reason"), PlacedOrderDriverTip(value: 0.2, message: "test reason")]
        XCTAssertEqual(sut.driverTipRefund, refunds)
        XCTAssertEqual(sut.totalDriverTipRefundValue, 0.7)
        XCTAssertEqual(sut.finalDriverTip, "£0.80")
    }

    func test_whenDriverTipRefundsNotPresent_thenSetDriverTipRefundToNil() {
        let sut = makeSUT(placedOrder: .mockedData)
        XCTAssertNil(sut.driverTipRefund)
        XCTAssertNil(sut.totalDriverTipRefundValue)
        XCTAssertNil(sut.finalDriverTip)
    }
    
//    func test_whenSlotSelected_thenSelectedSlotCorrectlyFormatted() {
//        let sut = makeSUT(placedOrder: .mockedData)
//        XCTAssertEqual(sut.selectedSlot, "20-Sep | 3:00 pm")
//    }
    
    func test_whenNoSlotSelected_thenSelectedSlotReturnsCorrectString() {
        let sut = makeSUT(placedOrder: .mockedDataNoSlot)
        XCTAssertEqual(sut.selectedSlot, Strings.PlacedOrders.OrderSummaryCard.noSlotSelected.localized)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), placedOrder: PlacedOrder, showTrackOrderButton: Bool = false) -> OrderDetailsViewModel {
        let sut = OrderDetailsViewModel(container: container, order: placedOrder, showTrackOrderButton: showTrackOrderButton)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
