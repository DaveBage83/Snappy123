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
    func test_init_whenNoProfilePresent_thenProfileDetailsNotPresent() {
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
        XCTAssertTrue(sut.noMemberFound)
    }
    
    func test_init_whenProfileIsPresent_thenProfileDetailsArePopulated() {
        let sut = makeSUT(profile: MemberProfile.mockedData)
        XCTAssertEqual(sut.viewState, .dashboard)
        XCTAssertTrue(sut.firstNamePresent)
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertFalse(sut.isOrdersSelected)
        XCTAssertFalse(sut.isAddressesSelected)
        XCTAssertFalse(sut.isProfileSelected)
        XCTAssertFalse(sut.isLoyaltySelected)
        XCTAssertFalse(sut.isLogOutSelected)
        XCTAssertEqual(sut.profile, MemberProfile.mockedData)
        XCTAssertFalse(sut.noMemberFound)
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
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), profile: MemberProfile? = nil) -> MemberDashboardViewModel {
        let sut = MemberDashboardViewModel(container: container)
        
        if let profile = profile {
            sut.container.appState.value.userData.memberProfile = profile
        }
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
