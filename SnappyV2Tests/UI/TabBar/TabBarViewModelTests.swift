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
    }
    
    func makeSut(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> TabBarViewModel {
        let sut = TabBarViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
