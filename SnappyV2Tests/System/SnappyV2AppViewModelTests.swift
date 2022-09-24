//
//  SnappyV2AppViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class SnappyV2AppViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.showInitialView, true)
        XCTAssertEqual(sut.container.appState.value.routing.showInitialView, true)
    }
    
    func test_givenInit_whenEnvironmentAppStateShowInitialViewSetToFalse_thenShowInitialViewIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "showInitialView")
        var cancellables = Set<AnyCancellable>()
        
        sut.$showInitialView
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                sut.container.appState.value.routing.showInitialView = false
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.showInitialView, false)
    }
    
    func test_givenInit_whenEnvironmentAppStateIsActiveSetToFalse_thenIsActiveIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "showInitialView")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isActive
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.isActive, false)
    }
    
    func test_whenSetAppForegroundStatusIsSetToBackground_thenAppStateUpdatedToFalse() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.container.appState.value.system.isInForeground)
        
        sut.setAppForegroundStatus(phase: .active)
        
        XCTAssertTrue(sut.container.appState.value.system.isInForeground)
        
        sut.setAppForegroundStatus(phase: .background)
        
        XCTAssertFalse(sut.container.appState.value.system.isInForeground)
    }
    
    func test_dismissMobileVerifyNumberView() {
        let sut = makeSUT()
        
        sut.dismissMobileVerifyNumberView(error: nil, toast: nil)

        XCTAssertNil(sut.error)
        XCTAssertNil(sut.successMessage)

        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        sut.dismissMobileVerifyNumberView(error: networkError, toast: nil)

        XCTAssertEqual(sut.error as? NSError, networkError)
        XCTAssertNil(sut.successMessage)
        
        sut.dismissMobileVerifyNumberView(error: nil, toast: "test message")

        XCTAssertEqual(sut.successMessage, "test message")
    }

    func makeSUT() -> SnappyV2AppViewModel {
        let appState = AppState()
        let container = DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked())
        let sut = SnappyV2AppViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
