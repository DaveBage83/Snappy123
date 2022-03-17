//
//  LoginWithFacebookViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class LoginWithFacebookViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_whenLoginWithFacebookTapped_thenIsLoadingIsTrue() {
        let sut = makeSUT()
        
        sut.loginWithFacebookTapped()
        
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_whenLoginWithFacebookTapped_thenUserLoggedIn() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.loginWithFacebook(registeringFromScreen: .startScreen)]))
        
        let sut = makeSUT(container: container)
        let expectation = expectation(description: "loginWithFacebook")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isLoading
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.loginWithFacebookTapped()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isLoading)
        sut.container.services.verify()
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> LoginWithFacebookViewModel {
        let sut = LoginWithFacebookViewModel(container: container)
        
        return sut
    }
}
