//
//  MemberDashboardOrdersViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/04/2022.
//

import XCTest
import Combine
@testable import SnappyV2

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
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let cancelbag = CancelBag()
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrder.mockedData]
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
                XCTAssertEqual(sut.allOrders, placedOrders)
                XCTAssertEqual(sut.currentOrders, placedOrders)
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 0.2)
        sut.container.services.verify()
    }
    
    func test_whenPlacedordersFetched_givenThatOrdersAreComplete_thenPastOrdersPopulatedAndPastOrdersPresentSetToTrue() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let cancelbag = CancelBag()
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrder.mockedDataStatusComplete]
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
                XCTAssertEqual(sut.pastOrders, placedOrders)
                XCTAssertTrue(sut.pastOrdersPresent)
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 0.2)
        sut.container.services.verify()
    }
    
    func test_whenPlacedordersFetched_givenThatBothPastAndPresentOrdersArepresent_thenOrdersCategorisedCorrectly() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)]))
        
        let sut = makeSUT(container: container, categoriseOrders: false)
        let cancelbag = CancelBag()
        let expectation = expectation(description: "pastOrdersPresent")
        
        let placedOrders = [PlacedOrder.mockedDataStatusComplete, PlacedOrder.mockedData]
        
        sut.placedOrdersFetch = .loaded(placedOrders)
        
        sut.$placedOrdersFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { order in
                expectation.fulfill()
                XCTAssertEqual(sut.pastOrders, [PlacedOrder.mockedDataStatusComplete])
                XCTAssertEqual(sut.currentOrders, [PlacedOrder.mockedData])
                XCTAssertEqual(sut.allOrders, placedOrders)
                XCTAssertTrue(sut.pastOrdersPresent)
                XCTAssertTrue(sut.currentOrdersPresent)
            }
            .store(in: cancelbag)

        wait(for: [expectation], timeout: 0.2)
        sut.container.services.verify()
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

        wait(for: [expectation], timeout: 0.2)
        
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

        wait(for: [expectation], timeout: 0.2)
        
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

        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertTrue(sut.allOrdersFetched)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), categoriseOrders: Bool = false) -> MemberDashboardOrdersViewModel {
        let sut = MemberDashboardOrdersViewModel(container: container, categoriseOrders: categoriseOrders)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
