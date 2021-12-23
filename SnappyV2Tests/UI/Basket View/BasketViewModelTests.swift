//
//  BasketViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 23/12/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class BasketViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertNil(sut.basket)
    }
    
    func test_setupBasket() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberSignedIn: false))
        let container = DIContainer(appState: appState, services: .mocked())
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "setupBasket")
        var cancellables = Set<AnyCancellable>()
        
        sut.$basket
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.basket, basket)
    }
    
    func test_givenBasketPopulated_whenSubmittingCouponCode_thenApplyingCouponChangesAndApplyCouponTriggers() {
        let basket = Basket(basketToken: "aaabbb", isNewBasket: false, items: [], fulfilmentMethod: BasketFulfilmentMethod(type: .delivery), selectedSlot: nil, savings: nil, coupon: nil, fees: nil, orderSubtotal: 0, orderTotal: 0)
        let appState = AppState(system: .init(), routing: .init(), userData: .init(selectedStore: .notRequested, selectedFulfilmentMethod: .delivery, searchResult: .notRequested, basket: basket, memberSignedIn: false))
        let container = DIContainer(appState: appState, services: .mocked(basketService: [.applyCoupon(code: "SPRING10")]))
        let sut = makeSUT(container: container)
        sut.couponCode = "SPRING10"
        
        let expectation = expectation(description: "submitCoupon")
        var cancellables = Set<AnyCancellable>()
        
        sut.$applyingCoupon
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.submitCoupon()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.applyingCoupon)
        
        container.services.verify()
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> BasketViewModel {
        let sut = BasketViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
