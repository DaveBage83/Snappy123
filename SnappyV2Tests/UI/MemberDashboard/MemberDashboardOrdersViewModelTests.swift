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
        XCTAssertFalse(sut.ordersAreLoading)
    }
    
    func test_whenPlacedOrdersFetched_givenPastOrdersArePresent_thenPastOrdersPopulated() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrder.mockedData]
    
        // Odd implementation: Need to check for the registering from a thread that has no
        // other properties to test that it has been reached
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            count += 1
            if
                let mockedUserService = sut.container.services.userService as? MockedUserService,
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
        sut.container.services.verify(as: .user)
    }
    
    func test_whenPlacedordersFetched_givenThatOrdersAreComplete_thenPastOrdersPopulatedAndPastOrdersPresentSetToTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrder.mockedDataStatusComplete]
        
        // Odd implementation: Need to check for the registering from a thread that has no
        // other properties to test that it has been reached
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            count += 1
            if
                let mockedUserService = sut.container.services.userService as? MockedUserService,
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
        sut.container.services.verify(as: .user)
    }
    
    func test_whenPlacedordersFetched_givenThatBothPastAndPresentOrdersArepresent_thenOrdersCategorisedCorrectly() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrder.mockedDataStatusComplete, PlacedOrder.mockedData]
        
        // Odd implementation: Need to check for the registering from a thread that has no
        // other properties to test that it has been reached
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            count += 1
            if
                let mockedUserService = sut.container.services.userService as? MockedUserService,
                mockedUserService.actions.factual.contains(.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10))
            {
                expectation.fulfill()
                XCTAssertEqual(sut.pastOrders, [PlacedOrder.mockedDataStatusComplete])
                XCTAssertEqual(sut.currentOrders, [PlacedOrder.mockedData])
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
        sut.container.services.verify(as: .user)
    }
    
    func test_whenGetMoreOrdersTapped_givenThatLessThan10AreDisplayed_thenJustAdd3ToMaxDisplayOrders() {
        let sut = makeSUT()
        
        let placedOrders = [PlacedOrder.mockedDataStatusComplete, PlacedOrder.mockedData,  PlacedOrder.mockedData,  PlacedOrder.mockedData,  PlacedOrder.mockedData,  PlacedOrder.mockedData]
        
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
        
        let placedOrders = [PlacedOrder.mockedDataStatusComplete, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData, PlacedOrder.mockedData]
        
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
    
    func test_whenPlacedOrdersIsLessThanOrEqualToMaxDisplayed_thenAllOrdersFetchedIsTrue() {
        let sut = makeSUT()
        
        let placedOrders = [PlacedOrder.mockedDataStatusComplete, PlacedOrder.mockedData]
        
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
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "past_orders_list"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), categoriseOrders: Bool = false) -> MemberDashboardOrdersViewModel {
        let sut = MemberDashboardOrdersViewModel(container: container, categoriseOrders: categoriseOrders)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
