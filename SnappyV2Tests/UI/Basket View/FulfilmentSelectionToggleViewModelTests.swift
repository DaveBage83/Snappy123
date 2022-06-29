//
//  FulfilmentSelectionToggleViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 29/06/2022.
//

import XCTest
import Combine
import AppsFlyerLib
@testable import SnappyV2

class FulfilmentSelectionToggleViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.fulfilmentMethod, .delivery)
    }
    
    func test_whenTogglePressed_thenAppStateFulfilmentMethodSwitched() {
        let sut = makeSUT()
        sut.container.appState.value.userData.selectedFulfilmentMethod = .delivery
        sut.toggleFulfilmentMethod()
        XCTAssertEqual(sut.container.appState.value.userData.selectedFulfilmentMethod, .collection)
        sut.toggleFulfilmentMethod()
        XCTAssertEqual(sut.container.appState.value.userData.selectedFulfilmentMethod, .delivery)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> FulfilmentTypeSelectionToggleViewModel {
        let sut = FulfilmentTypeSelectionToggleViewModel(container: .preview)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
