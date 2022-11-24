//
//  MemberDashboardOrdersViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/04/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class MemberDashboardOrdersViewModelTests: XCTestCase {
    
    func test_init_whenCategoriseOrdersIsFalse() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.categoriseOrders)
        XCTAssertFalse(sut.allOrdersFetched)
        XCTAssertEqual(sut.maxDisplayedOrders, 3)
        XCTAssertEqual(sut.placedOrdersFetch, .notRequested)
        XCTAssertFalse(sut.currentOrdersPresent)
        XCTAssertFalse(sut.pastOrdersPresent)
        XCTAssertEqual(sut.allOrders, [])
        XCTAssertEqual(sut.currentOrders, [])
        XCTAssertEqual(sut.pastOrders, [])
    }
    
    func test_whenPlacedOrdersFetched_givenPastOrdersArePresent_thenPastOrdersPopulated() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrderSummary.mockedData]
    
        // Odd implementation: Need to check for the registering from a thread that has no
        // other properties to test that it has been reached
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            count += 1
            if
                let mockedUserService = sut.container.services.memberService as? MockedUserService,
                mockedUserService.actions.factual.contains(.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10))
            {
                expectation.fulfill()
                XCTAssertEqual(sut.allOrders, placedOrders)
                XCTAssertEqual(sut.currentOrders, placedOrders)
                timer.invalidate()
                return
            }
            if count >= 5 {
                timer.invalidate()
            }
        }
        
        sut.placedOrdersFetch = .loaded(placedOrders)

        wait(for: [expectation], timeout: 2)
        sut.container.services.verify(as: .member)
    }
    
    func test_whenPlacedordersFetched_givenThatOrdersAreComplete_thenPastOrdersPopulatedAndPastOrdersPresentSetToTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrderSummary.mockedDataStatusComplete]
        
        // Odd implementation: Need to check for the registering from a thread that has no
        // other properties to test that it has been reached
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            count += 1
            if
                let mockedUserService = sut.container.services.memberService as? MockedUserService,
                mockedUserService.actions.factual.contains(.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10))
            {
                expectation.fulfill()
                XCTAssertEqual(sut.pastOrders, placedOrders)
                XCTAssertTrue(sut.pastOrdersPresent)
                timer.invalidate()
                return
            }
            if count >= 5 {
                timer.invalidate()
            }
        }
        
        sut.placedOrdersFetch = .loaded(placedOrders)

        wait(for: [expectation], timeout: 2)
        sut.container.services.verify(as: .member)
    }
    
    func test_whenPlacedordersFetched_givenThatBothPastAndPresentOrdersArepresent_thenOrdersCategorisedCorrectly() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrderSummary.mockedDataStatusComplete, PlacedOrderSummary.mockedData]
        
        // Odd implementation: Need to check for the registering from a thread that has no
        // other properties to test that it has been reached
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            count += 1
            if
                let mockedUserService = sut.container.services.memberService as? MockedUserService,
                mockedUserService.actions.factual.contains(.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10))
            {
                expectation.fulfill()
                XCTAssertEqual(sut.pastOrders, [PlacedOrderSummary.mockedDataStatusComplete])
                XCTAssertEqual(sut.currentOrders, [PlacedOrderSummary.mockedData])
                XCTAssertEqual(sut.allOrders, placedOrders)
                XCTAssertTrue(sut.pastOrdersPresent)
                XCTAssertTrue(sut.currentOrdersPresent)
                timer.invalidate()
                return
            }
            if count >= 5 {
                timer.invalidate()
            }
        }
        
        sut.placedOrdersFetch = .loaded(placedOrders)

        wait(for: [expectation], timeout: 2)
        sut.container.services.verify(as: .member)
    }
    
    func test_whenGetMoreOrdersTapped_givenThatLessThan10AreDisplayed_thenJustAdd3ToMaxDisplayOrders() {
        let sut = makeSUT()
        
        let placedOrders = [PlacedOrderSummary.mockedDataStatusComplete, PlacedOrderSummary.mockedData,  PlacedOrderSummary.mockedData,  PlacedOrderSummary.mockedData,  PlacedOrderSummary.mockedData,  PlacedOrderSummary.mockedData]
        
        let cancelbag = CancelBag()
        let expectation = expectation(description: "getMoreOrdersTapped")
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
                sut.getMoreOrdersTapped()
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.maxDisplayedOrders, 6)
    }
    
    func test_whenMaxDisplayedOrdersIsGreaterThanPlacedOrdersCount_thenIncreaseFetchLimitBy10() {
        let sut = makeSUT()
        
        let placedOrders = [PlacedOrderSummary.mockedDataStatusComplete, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData, PlacedOrderSummary.mockedData]
        
        let cancelbag = CancelBag()
        let expectation = expectation(description: "getMoreOrdersTapped")
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
                sut.getMoreOrdersTapped()
                sut.getMoreOrdersTapped()
                sut.getMoreOrdersTapped()
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.orderFetchLimit, 20)
    }
    
    func test_whenInitialOrdersLoading_thenShowMoreOrdersViewIsFalse() {
        let sut = makeSUT()
        sut.initialOrdersLoading = true
        XCTAssertFalse(sut.showViewMoreOrdersView)
    }
    
    func test_whenInitialOrdersLoadingIsFalse_thenShowMoreOrdersViewIsTrue() {
        let sut = makeSUT()
        sut.initialOrdersLoading = false
        XCTAssertTrue(sut.showViewMoreOrdersView)
    }
    
    func test_whenPlacedOrdersIsLessThanOrEqualToMaxDisplayed_thenAllOrdersFetchedIsTrue() {
        let sut = makeSUT()
        
        let placedOrders = [PlacedOrderSummary.mockedDataStatusComplete, PlacedOrderSummary.mockedData]
        
        let cancelbag = CancelBag()
        let expectation = expectation(description: "getMoreOrdersTapped")
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.allOrdersFetched)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen(.outside, .pastOrdersList), with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenGetPlacedOrderCalled_givenOrderProgressIs1_thenOrderRetrievedButDriverLocationNotSet() async {
                
        var userService = MockedUserService(expected: [.getPlacedOrder(businessOrderId: 123), .getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: Optional(10))])
        let returnedOrder = PlacedOrder.mockedDataStatusComplete
        userService.getPlacedOrderResult = returnedOrder
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: userService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(container: container, disableMemoryTest: true)
        
        await sut.getPlacedOrder(businessOrderId: 123)
        
        XCTAssertEqual(sut.selectedOrder, returnedOrder)
        services.verify(as: .member)
    }
    
    func test_whenGetPlacedOrderCalled_givenOrderProgressIsNot1AndDriverEnRoute_thenOrderRetrievedButDriverLocationSetAndTrackOrderButtonShown() async {
                
        let userService = MockedUserService(expected: [.getPlacedOrder(businessOrderId: 123), .getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: Optional(10))])
        let checkoutService = MockedCheckoutService(expected: [.getDriverLocation(businessOrderId: 123)])
        checkoutService.driverLocationResult = .success(.mockedDataEnRoute)
        let returnedOrder = PlacedOrder.mockedData
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: userService,
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(container: container, disableMemoryTest: true)
        
        await sut.getPlacedOrder(businessOrderId: 123)
        
        XCTAssertEqual(sut.selectedOrder, returnedOrder)
        services.verify(as: .member)
        services.verify(as: .checkout)
        XCTAssertTrue(sut.showTrackOrderButton)
    }
    
    func test_whenGetPlacedOrderCalled_givenOrderProgressIsNot1AndDriverNotEnRoute_thenOrderRetrievedButDriverLocationSetAndTrackOrderButtonShown() async {
                
        let userService = MockedUserService(expected: [.getPlacedOrder(businessOrderId: 123), .getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: Optional(10))])
        let checkoutService = MockedCheckoutService(expected: [.getDriverLocation(businessOrderId: 123)])
        checkoutService.driverLocationResult = .success(.mockedDataDelivered)
        let returnedOrder = PlacedOrder.mockedData
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: userService,
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(container: container, disableMemoryTest: true)
        
        await sut.getPlacedOrder(businessOrderId: 123)
        
        XCTAssertEqual(sut.selectedOrder, returnedOrder)
        services.verify(as: .member)
        services.verify(as: .checkout)
        XCTAssertFalse(sut.showTrackOrderButton)
    }
    
    func test_whenNoOrdersToFetch_thenShowPlaceFirstOrderViewIsTrue() {
        let sut = makeSUT()
        
        let placedOrders: [PlacedOrderSummary] = []
        
        let cancelbag = CancelBag()
        let expectation = expectation(description: "getMoreOrdersTapped")
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.showPlaceFirstOrderView)
    }
    
    func test_whenPlaceFirstOrderPressed_thenTabInAppStateSetToStore() {
        let sut = makeSUT()
        
        let placedOrders: [PlacedOrderSummary] = []
        
        let cancelbag = CancelBag()
        let expectation = expectation(description: "getMoreOrdersTapped")
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 2)
        
        sut.placeFirstOrderButtonTapped()
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .stores)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), categoriseOrders: Bool = false, disableMemoryTest: Bool = false) -> MemberDashboardOrdersViewModel {
        let sut = MemberDashboardOrdersViewModel(container: container, categoriseOrders: categoriseOrders)
        
        #warning("Check again when upgrading xcode - may not be necessary")
        if disableMemoryTest == false {
            trackForMemoryLeaks(sut)
        }
        
        return sut
    }
}
