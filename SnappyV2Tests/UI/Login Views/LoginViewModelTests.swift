//
//  LoginViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
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
        XCTAssertFalse(sut.isInCheckout)
    }
    
    func test_basketTotalHasValue_thenOrderTotalPopulated() async throws {
        let container = DIContainer.preview
        container.appState.value.userData.basket = Basket.mockedData
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.orderTotal, 23.3)
    }
    
    func test_whenLoginTapped_givenEmailAndPasswordAreEmpty_thenEmailHasErrorAndPasswordHasErrorAreTrue() async {
        let sut = makeSUT()
        
        await sut.loginTapped()
        
        XCTAssertTrue(sut.emailHasError)
        XCTAssertTrue(sut.passwordHasError)
    }
    
    func test_whenLoginTapped_givenEmailAndPasswordWereEmptyButNoLongerAre_thenEmailHasErrorAndPasswordHasErrorAreFalse() async {
        let sut = makeSUT()
        
        await sut.loginTapped()
        
        XCTAssertTrue(sut.emailHasError)
        XCTAssertTrue(sut.passwordHasError)
        
        sut.email = "test@test.com"
        sut.password = "Test1"
        
        await sut.loginTapped()
        
        XCTAssertFalse(sut.emailHasError)
        XCTAssertFalse(sut.passwordHasError)
    }
    
    func test_whenLoginTapped_thenIsLoadingSetToTrue() async {
        let sut = makeSUT()
        
        await sut.loginTapped()
        
        sut.isLoading = true
    }
    
    func test_whenCreateAccountTapped_thenShowCreateAccountViewIsTrue() {
        let sut = makeSUT()
        
        sut.createAccountTapped()
        
        XCTAssertTrue(sut.showCreateAccountView)
    }
    
    func test_whenLoginTapped_thenIsLoadingSetToFalseAndLoginSucceeds() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.login(email: "test@test.com", password: "password1", atCheckout: false)]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "isLoadingTrue")
        var cancellables = Set<AnyCancellable>()

        sut.email = "test@test.com"
        sut.password = "password1"
        
        await sut.loginTapped()
        
        sut.$isLoading
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        sut.container.services.verify(as: .member)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "account_sign_in"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenOnCreateAccountAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "register_from_account_sign_in"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onCreateAccountAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenShowInitialViewFalseInAppState_thenIsFromInitialViewIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.routing.showInitialView = false
        let sut = makeSUT(container: container)
        XCTAssertFalse(sut.isFromInitialView)
    }
    
    func test_whenShowInitialViewTrueInAppState_thenIsFromInitialViewIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.routing.showInitialView = true
        let sut = makeSUT(container: container)
        XCTAssertTrue(sut.isFromInitialView)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> LoginViewModel {
        let sut = LoginViewModel(container: container)
        
        return sut
    }
}
