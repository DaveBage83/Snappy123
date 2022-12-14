//
//  TabBarViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 03/05/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class TabBarViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSut()
        XCTAssertEqual(sut.selectedTab, .stores)
        XCTAssertNil(sut.basketTotal)
    }
    
    func test_whenSelectTab_correctTabSelected() {
        let sut = makeSut()
        
        sut.selectTab(.account)
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .account)
    }

    func test_whenBasketTotalIs0_thenBasketTotalIsNil() {
        let sut = makeSut()
        
        sut.container.appState.value.userData.basket = Basket.mockedDataOrderTotalIsZero
        
        XCTAssertNil(sut.basketTotal)
    }
    
    func test_whenBasketOrderTotalSet_givenItIsNotNilAndItIsGreaterThan0_thenSetBasketTotal() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = .mockedData
        container.appState.value.userData.selectedStore = .loaded(.mockedData)
        let sut = makeSut(container: container)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "setBasketTotal")
        
        
        sut.$basketTotal
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.basketTotal, "£23.30")
    }
    
    func test_whenBasketOrderTotalSet_givenItIsNotNilAndItIsGreaterThan0AndCurrencyIsNil_thenSetBasketTotalToNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = .mockedData
        let sut = makeSut(container: container)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "setBasketTotal")
        
        
        sut.$basketTotal
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertNil(sut.basketTotal)
    }
    
    func test_whenBasketOrderTotalSet_givenItIsNil_thenSetBasketTotalToNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedStore = .loaded(.mockedData)

        let sut = makeSut(container: container)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "setBasketTotal")
        
        sut.$basketTotal
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertNil(sut.basketTotal)
    }
    
    func test_whenBasketOrderTotalSet_givenItIsZero_thenSetBasketTotalToNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.selectedStore = .loaded(.mockedData)
        container.appState.value.userData.basket = .mockedDataOrderTotalIsZero

        let sut = makeSut(container: container)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "setBasketTotal")
        
        sut.$basketTotal
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertNil(sut.basketTotal)
    }
    
    func makeSut(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> TabBarViewModel {
        let sut = TabBarViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
