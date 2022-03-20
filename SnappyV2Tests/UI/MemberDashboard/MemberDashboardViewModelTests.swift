//
//  MemberDashboardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class MemberDashboardViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        XCTAssertEqual(sut.viewState, .dashboard)
        XCTAssertFalse(sut.firstNamePresent)
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertFalse(sut.isOrdersSelected)
        XCTAssertFalse(sut.isAddressesSelected)
        XCTAssertFalse(sut.isProfileSelected)
        XCTAssertFalse(sut.isLoyaltySelected)
        XCTAssertFalse(sut.isLogOutSelected)
        XCTAssertNil(sut.profile)
        XCTAssertEqual(sut.profileFetch, .notRequested)
        XCTAssertFalse(sut.searchingForMember)
    }
    
    func test_whenProfileFetched_thenProfileMappedToProfilePublisher() {
        let container = DIContainer(appState: AppState(), services: .mocked(memberService: [.getProfile(filterDeliveryAddresses: false)]))
                                    
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "getProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profileFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let member = MemberProfile(
            firstname: "Alan",
            lastname: "Shearer",
            emailAddress: "alan.shearer@nufc.com",
            type: .customer,
            referFriendCode: "TESTCODE",
            referFriendBalance: 5.0,
            numberOfReferrals: 0,
            mobileContactNumber: "122334444",
            mobileValidated: false,
            acceptedMarketing: false,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)
        
        sut.profileFetch = .loaded(member)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.profile, member)
        sut.container.services.verify()
    }
    
    func test_whenProfileFetched_FirstNameIsPresent() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "getProfile")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profileFetch
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let member = MemberProfile(
            firstname: "Alan",
            lastname: "Shearer",
            emailAddress: "alan.shearer@nufc.com",
            type: .customer,
            referFriendCode: "TESTCODE",
            referFriendBalance: 5.0,
            numberOfReferrals: 0,
            mobileContactNumber: "122334444",
            mobileValidated: false,
            acceptedMarketing: false,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)
        
        sut.profileFetch = .loaded(member)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.firstNamePresent)
    }
    
    func test_whenDashboardTapped_thenViewStateIsDashboardAndIsDashboardSelectedIsTrue() {
        let sut = makeSUT()
        
        // As the default init viewState is .dashboard, for this test first
        // we set viewState to .orders and then we reset to .dashboard

        sut.ordersTapped()
        XCTAssertFalse(sut.isDashboardSelected)
        XCTAssertNotEqual(sut.viewState, .dashboard)
        sut.dashboardTapped()
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertEqual(sut.viewState, .dashboard)
    }
    
    func test_whenOrdersTapped_thenViewStateIsOrdersAndIsOrdersSelectedIsTrue() {
        let sut = makeSUT()

        sut.ordersTapped()
        XCTAssertTrue(sut.isOrdersSelected)
        XCTAssertEqual(sut.viewState, .orders)
    }
    
    func test_whenAddressesTapped_thenViewStateIsAddressesAndIsAddressesSelectedIsTrue() {
        let sut = makeSUT()

        sut.addressesTapped()
        XCTAssertTrue(sut.isAddressesSelected)
        XCTAssertEqual(sut.viewState, .addresses)
    }
    
    func test_whenProfileTapped_thenViewStateIsProfileAndIsProfileSelectedIsTrue() {
        let sut = makeSUT()

        sut.profileTapped()
        XCTAssertTrue(sut.isProfileSelected)
        XCTAssertEqual(sut.viewState, .profile)
    }
    
    func test_whenLoyaltyTapped_thenViewStateIsLoyaltyAndIsLoyaltySelectedIsTrue() {
        let sut = makeSUT()

        sut.loyaltyTapped()
        XCTAssertTrue(sut.isLoyaltySelected)
        XCTAssertEqual(sut.viewState, .loyalty)
    }
    
    func test_whenLogoutTapped_thenViewStateIsLogoutAndIsLogoutSelectedIsTrue() {
        let sut = makeSUT()

        sut.logOutTapped()
        XCTAssertTrue(sut.isLogOutSelected)
        XCTAssertEqual(sut.viewState, .logOut)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked())) -> MemberDashboardViewModel {
        let sut = MemberDashboardViewModel(container: container)
        
        return sut
    }
}
