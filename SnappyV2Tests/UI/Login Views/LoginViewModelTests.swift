//
//  LoginViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
import AuthenticationServices
@testable import SnappyV2

class LoginViewModelTests: XCTestCase {
    func test_init() {
       let sut = makeSUT()
        
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.password, "")
        XCTAssertFalse(sut.passwordRevealed)
        XCTAssertFalse(sut.showCreateAccountView)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.emailHasError)
        XCTAssertFalse(sut.passwordHasError)
    }
    
    func test_whenLoginTapped_givenEmailAndPasswordAreEmpty_thenEmailHasErrorAndPasswordHasErrorAreTrue() {
        let sut = makeSUT()
        
        sut.loginTapped()
        
        XCTAssertTrue(sut.emailHasError)
        XCTAssertTrue(sut.passwordHasError)
    }
    
    func test_whenLoginTapped_givenEmailAndPasswordWereEmptyButNoLongerAre_thenEmailHasErrorAndPasswordHasErrorAreFalse() {
        let sut = makeSUT()
        
        sut.loginTapped()
        
        XCTAssertTrue(sut.emailHasError)
        XCTAssertTrue(sut.passwordHasError)
        
        sut.email = "test@test.com"
        sut.password = "Test1"
        
        XCTAssertFalse(sut.emailHasError)
        XCTAssertFalse(sut.passwordHasError)
    }
    
    func test_whenLoginTapped_thenIsLoadingSetToTrue() {
        let sut = makeSUT()
        
        sut.loginTapped()
        
        sut.isLoading = true
    }
    
    func test_whenCreateAccountTapped_thenShowCreateAccountViewIsTrue() {
        let sut = makeSUT()
        
        sut.createAccountTapped()
        
        XCTAssertTrue(sut.showCreateAccountView)
    }
    
    func test_whenLoginTapped_thenIsLoadingSetToFalseAndLoginSucceeds() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.login(email: "test@test.com", password: "password1")]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "logUserIn")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isLoading
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.email = "test@test.com"
        sut.password = "password1"
        
        sut.loginTapped()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isLoading)
        sut.container.services.verify(as: .user)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> LoginViewModel {
        let sut = LoginViewModel(container: container)
        
        return sut
    }
}
