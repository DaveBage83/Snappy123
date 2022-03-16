//
//  InitialViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 17/11/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class InitialViewModelTests: XCTestCase {
    
    let container = DIContainer(appState: AppState(), services: .mocked())
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertFalse(sut.loginButtonPressed)
        XCTAssertFalse(sut.hasStore)
        XCTAssertEqual(sut.search, .notRequested)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_givenStoreSearchResult_whenIsLoadingStatus_thenReturnsTrue() {
        let sut = makeSUT()
        sut.search = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_givenStoreSearchResult_whenLoadedStatus_thenReturnsFalse() {
        let sut = makeSUT()
        sut.search = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentLocation(country: "", latitude: 0, longitude: 0, postcode: "")))
        
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_whenMemberSignedIn_thenShowLoginScreenAndShowRegScreenAreFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "memberSignedInChanged")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isUserSignedIn
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.userData.memberSignedIn = true
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.showLoginScreen)
        XCTAssertFalse(sut.showRegisterScreen)
    }
    
//    func test_whenAllFieldsValid_thenUserLoggedIn() {
//        
//        let sut = makeSUT()
//        let createAccountVM = makeCreateAccountViewModel()
//        
//        createAccountVM.firstName = "Test"
//        createAccountVM.lastName = "Test last"
//        createAccountVM.email = "test@test.com"
//        createAccountVM.phone = "07795565655"
//        createAccountVM.password = "password1"
//        createAccountVM.emailMarketingEnabled = true
//        createAccountVM.directMailMarketingEnabled = true
//
//        let expectation = expectation(description: "memberCreated")
//        var cancellables = Set<AnyCancellable>()
//
//        createAccountVM.createAccountTapped()
//        
//        sut.$isUserSignedIn
//            .first()
//            .receive(on: RunLoop.main)
//            .sink { _ in
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 5)
//        
//        XCTAssertTrue(sut.isUserSignedIn)
//    }
    
    func test_whenLoginTapped_thenShowLoginScreenSetToTrue() {
        let sut = makeSUT()
        
        sut.loginTapped()
        XCTAssertTrue(sut.showLoginScreen)
    }
    
    func test_whenSignupTapped_thenShowRegistrationScreenSetToTrue() {
        let sut = makeSUT()
        
        sut.signUpTapped()
        
        XCTAssertTrue(sut.showRegisterScreen)
    }

    func makeSUT() -> InitialViewModel {
        return InitialViewModel(container: container)
    }
    
    func makeCreateAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(container: container)
    }
}
