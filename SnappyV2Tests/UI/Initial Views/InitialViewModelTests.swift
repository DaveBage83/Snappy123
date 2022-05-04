//
//  InitialViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 17/11/2021.
//

import XCTest
import Combine
@testable import SnappyV2
import KeychainAccess

@MainActor
class InitialViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertFalse(sut.loginButtonPressed)
        XCTAssertFalse(sut.hasStore)
        XCTAssertEqual(sut.searchResult, .notRequested)
        XCTAssertFalse(sut.isLoading)
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

    func test_whenloadBusinessProfileIsTriggered_thengetProfileIsCalled() async throws {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(businessProfileService: [.getProfile]))
        let sut = makeSUT(container: container)

        try await sut.loadBusinessProfile()
        
        XCTAssertTrue(sut.showFirstView)
        container.services.verify(as: .businessProfile)
    }
    
    func test_whenloadBusinessProfileIsTriggered_thengetMemberProfileIsCalled() async throws {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.restoreLastUser]))
        let sut = makeSUT(container: container)
        
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        keychain["memberSignedIn"] = "email"
        
        try await sut.loadBusinessProfile()
        
        XCTAssertTrue(sut.showFirstView)
        container.services.verify(as: .user)
    }
    
    func test_whenDissmissLocationAlertTappedTriggered_thenLocationIsLoadingIsFalse() {
        let sut = makeSUT()
        sut.locationIsLoading = true
        
        sut.dismissLocationAlertTapped()
        
        XCTAssertFalse(sut.locationIsLoading)
    }
    
    func test_whenTapLoadRetailStoresTriggered_thenServiceCalledAndShowInitialViewIsFalse() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "PA34 4AG")]))
        let sut = makeSUT(container: container)
        
        await sut.tapLoadRetailStores()
        
        XCTAssertFalse(sut.container.appState.value.routing.showInitialView)
        container.services.verify(as: .retailStore)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> InitialViewModel {
        return InitialViewModel(container: container)
    }
}
