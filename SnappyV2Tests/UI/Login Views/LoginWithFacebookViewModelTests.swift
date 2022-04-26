//
//  LoginWithFacebookViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class LoginWithFacebookViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isLoading)
    }

    func test_whenLoginWithFacebookTapped_thenUserLoggedIn() async throws {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.loginWithFacebook(registeringFromScreen: .startScreen)]))
        
        let sut = makeSUT(container: container)

        try await sut.loginWithFacebook()
        
        XCTAssertFalse(sut.isLoading)
        sut.container.services.verify(as: .user)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> LoginWithFacebookViewModel {
        let sut = LoginWithFacebookViewModel(container: container)
        
        return sut
    }
}
