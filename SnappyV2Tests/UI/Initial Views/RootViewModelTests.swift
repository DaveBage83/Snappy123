//
//  RootViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 22/09/2021.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class RootViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.selectedTab, .stores)
    }
    
    func test_givenInit_whenAppStateSelectedTabSetToAccount_thenLocalSelectedTabIsAccount() {
        let sut = makeSUT()
        
        sut.container.appState.value.routing.selectedTab = .account
        
        let expectation = expectation(description: "selectedTab")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedTab
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.selectedTab, .account)
    }
    
    func test_givenInit_whenLocalselectedTabSetToMenu_thenAppStateSelectedTabIsMenu() {
        let sut = makeSUT()
        
        sut.selectedTab = .menu
        
        let expectation = expectation(description: "selectedTab")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedTab
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.container.appState.value.routing.selectedTab, .menu)
    }
    
    func test_setupResetPaswordDeepLinkNavigation_givenPasswordResetCode_thenChangeToAccountTab() {
        
        let sut = makeSUT()
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$selectedTab
            .filter { $0 != .stores }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.passwordResetCode = "p6rGf6KLBD"
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sut.selectedTab, .account)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked() )) -> RootViewModel {
        let sut = RootViewModel(container: container)
        
        return sut
    }
}
