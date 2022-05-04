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
    
    func test_whenBasketTotalIsGreaterThan0_thenBasketTotalStringPopulated() {
        let sut = makeSut()
        
        sut.container.appState.value.userData.basket = Basket.mockedData
        
        XCTAssertEqual(sut.basketTotal, "£23.30")
    }
    
    func test_whenBasketTotalIs0_thenBasketTotalIsNil() {
        let sut = makeSut()
        
        sut.container.appState.value.userData.basket = Basket.mockedDataOrderTotalIsZero
        
        XCTAssertNil(sut.basketTotal)
    }
    
    func makeSut(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> TabBarViewModel {
        let sut = TabBarViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
