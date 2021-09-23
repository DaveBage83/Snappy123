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

    func makeSUT() -> RootViewModel {
        let sut = RootViewModel(container: .preview)
        
        return sut
    }
}
