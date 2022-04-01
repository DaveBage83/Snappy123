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
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertFalse(sut.loginButtonPressed)
        XCTAssertFalse(sut.hasStore)
        XCTAssertEqual(sut.searchResult, .notRequested)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showFirstView)
        XCTAssertFalse(sut.showFailedBusinessProfileLoading)
    }
    
    func test_givenStoreSearchResult_whenIsLoadingStatus_thenReturnsTrue() {
        let sut = makeSUT()
        sut.searchResult = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_givenStoreSearchResult_whenLoadedStatus_thenReturnsFalse() {
        let sut = makeSUT()
        sut.searchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentLocation(country: "", latitude: 0, longitude: 0, postcode: "")))
        
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_whenMemberSignedIn_thenShowLoginScreenAndShowRegScreenAreFalse() {
        let sut = makeSUT()
        
//        let expectation = expectation(description: "memberSignedInChanged")
//        var cancellables = Set<AnyCancellable>()
//
//        sut.$isUserSignedIn
//            .first()
//            .receive(on: RunLoop.main)
//            .sink { _ in
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//
//        sut.container.appState.value.userData.memberSignedIn = true
//
//        wait(for: [expectation], timeout: 5)
        
        let profile = MemberProfile(firstname: "Test", lastname: "Test", emailAddress: "test@test.com", type: .customer, referFriendCode: nil, referFriendBalance: 5, numberOfReferrals: 0, mobileContactNumber: nil, mobileValidated: false, acceptedMarketing: true, defaultBillingDetails: nil, savedAddresses: nil, fetchTimestamp: nil)
        
        sut.container.appState.value.userData.memberProfile = profile
        
        XCTAssertNil(sut.viewState)
    }
    
    func test_whenLoginTapped_thenShowLoginScreenSetToTrue() {
        let sut = makeSUT()
        
        sut.loginTapped()
        XCTAssertEqual(sut.viewState, .login)
    }
    
    func test_whenSignupTapped_thenShowRegistrationScreenSetToTrue() {
        let sut = makeSUT()
        
        sut.signUpTapped()
        
        XCTAssertEqual(sut.viewState, .create)
    }

    func test_whenloadBusinessProfileIsTriggered_thengetProfileIsCalled() {
        let container = DIContainer(appState: AppState(), services: .mocked(businessProfileService: [.getProfile]))
        let sut = makeSUT(container: container)

        let exp = expectation(description: "showFirstView")
        var cancellables = Set<AnyCancellable>()

        sut.$showFirstView
            .removeDuplicates()
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)

        XCTAssertTrue(sut.showFirstView)
        container.services.verifyBusinessProfileService()
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> InitialViewModel {
        return InitialViewModel(container: container)
    }
}
