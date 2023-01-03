//
//  CheckoutSuccessViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 05/09/2022.
//

import Foundation

import XCTest
import Combine
@testable import SnappyV2
import SwiftUI

@MainActor
class CheckoutSuccessViewModelTests: XCTestCase {
    
    func test_whenStoreNumberPresentInAppState_thenAssignToStoreNumber() {
        let sut = makeSUT()
        sut.container.appState.value.userData.selectedStore = .loaded(.mockedData)
        XCTAssertEqual(sut.storeNumber, "tel://01382621132")
    }
    
    func test_whenStoreNumberIsNotNilOrEmpty_thenShowCallStoreButtonTrue() {
        let sut = makeSUT()
        sut.container.appState.value.userData.selectedStore = .loaded(.mockedData)
        XCTAssertTrue(sut.showCallStoreButton)
    }
    
    func test_whenClearSuccessCheckoutBasketCalled_thenSuccessCheckoutBasketCleared() {
        let sut = makeSUT()
        sut.container.appState.value.userData.successCheckoutBasket = .mockedData
        sut.clearSuccessCheckoutBasket()
        XCTAssertNil(sut.container.appState.value.userData.successCheckoutBasket)
    }
    
    func test_when_then() {
        
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), checkoutState: @escaping (CheckoutRootViewModel.CheckoutState) -> Void = {_ in }, dateGenerator: @escaping () -> Date = Date.init) -> CheckoutSuccessViewModel {
        let sut = CheckoutSuccessViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
