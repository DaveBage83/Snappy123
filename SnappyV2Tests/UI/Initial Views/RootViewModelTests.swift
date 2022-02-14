//
//  RootViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 22/09/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class RootViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.selectedTab, 1)
        XCTAssertNil(sut.basketTotal)
    }
    
    func test_givenInit_whenAppStateSelectedTabSetTo3_thenLocalSelectedTabIs3() {
        let sut = makeSUT()
        
        sut.container.appState.value.routing.selectedTab = 3
        
        let expectation = expectation(description: "selectedTab")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedTab
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.selectedTab, 3)
    }
    
    func test_givenInit_whenLocalselectedTabSetTo2_thenAppStateSelectedTabIs2() {
        let sut = makeSUT()
        
        sut.selectedTab = 2
        
        let expectation = expectation(description: "selectedTab")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedTab
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, 2)
    }
    
    func test_setupBasketTotal() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, addresses: nil, orderSubtotal: 0, orderTotal: 12.34)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberSignedIn: false))
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setupBasket")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basketTotal
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.basketTotal, "£12.34")
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked() )) -> RootViewModel {
        let sut = RootViewModel(container: container)
        
        return sut
    }
}
