//
//  ForgotPasswordViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class ForgotPasswordViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.emailHasError)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.emailSent)
        XCTAssertEqual(sut.email, "")
    }
    
    func test_whenSubmitTapped_givenEmailIsEmpty_thenEmailHasError() {
        let sut = makeSUT()
        
        sut.submitTapped()
        XCTAssertTrue(sut.emailHasError)
    }
    
    func test_whenSubmitTapped_thenIsLoadingIsTrue() {
        let sut = makeSUT()
        
        sut.submitTapped()
        
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_whenSubmitTapped_givenThatEmailIsPresent_thenResetPasswordEmailSent() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.resetPasswordRequest(email: "test@test.com")]))
        
        var cancellables = Set<AnyCancellable>()
        let sut = makeSUT(container: container)
        
        sut.email = "test@test.com"
        
        let expectation = expectation(description: "resetPassword")
        
        sut.$emailSent
            .receive(on: RunLoop.main)
            .sink { _ in
                if sut.emailSent {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.submitTapped()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.emailSent)
        container.services.verify(as: .user)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> ForgotPasswordViewModel {
        let sut = ForgotPasswordViewModel(container: container)
        
        return sut
    }
}
