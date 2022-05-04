//
//  NavigationBarViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 02/12/2021.
//

import XCTest
@testable import SnappyV2

class NavigationBarViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertEqual(sut.selectedStore, .notRequested)
        XCTAssertEqual(sut.selectedFulfilmentMethod, .delivery)
    }
    
    func test_whenTappingNavigateToStoreSelection_thenAppStateRoutingIsStores() {
        let sut = makeSUT()
        sut.container.appState.value.routing.selectedTab = .menu
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .menu)
        
        sut.navigateToStoreSelection()
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .stores)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> NavigationBarViewModel {
        let sut = NavigationBarViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
