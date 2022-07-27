//
//  MemberDashboardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
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
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertFalse(sut.isOrdersSelected)
        XCTAssertFalse(sut.isAddressesSelected)
        XCTAssertFalse(sut.isProfileSelected)
        XCTAssertFalse(sut.isLoyaltySelected)
        XCTAssertFalse(sut.isLogOutSelected)
    }

    func test_whenAddAddressTapped_thenAddressAdded() async {
        let address = Address(id: 123, isDefault: false, addressName: "", firstName: "", lastName: "", addressLine1: "", addressLine2: "", town: "", postcode: "", county: "", countryCode: "", type: .delivery, location: nil, email: nil, telephone: nil)

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.addAddress(address: address)]))
        
        let sut = makeSUT(container: container)
        await sut.addAddress(address: address)

        sut.container.services.verify(as: .user)
    }
    
    func test_whenUpdateAddressTapped_thenAddressUpdated() async {
        let address = Address(id: 123, isDefault: false, addressName: "", firstName: "", lastName: "", addressLine1: "", addressLine2: "", town: "", postcode: "", county: "", countryCode: "", type: .delivery, location: nil, email: nil, telephone: nil)

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.updateAddress(address: address)]))
        
        let sut = makeSUT(container: container)
        await sut.updateAddress(address: address)

        sut.container.services.verify(as: .user)
    }

    func test_init_whenMemberProfilePresent_thenMemberDetailsPopulated() {
        let cancelbag = CancelBag()
        let sut = makeSUT(profile: MemberProfile.mockedData)
        let expectation = expectation(description: "userProfileDetailsPopulated")
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { profile in
                XCTAssertTrue(sut.firstNamePresent)
                XCTAssertEqual(sut.profile, MemberProfile.mockedData)
                expectation.fulfill()
            }
            .store(in: cancelbag)
        wait(for: [expectation], timeout: 0.2)
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

        sut.myDetailsTapped()
        XCTAssertTrue(sut.isAddressesSelected)
        XCTAssertEqual(sut.viewState, .myDetails)
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
    
    func test_whenMemberLogsOut_thenLogoutIsSuccessful() async {
        let sut = makeSUT()
        
        await sut.logOut()
        
        XCTAssertNil(sut.container.appState.value.userData.memberProfile)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "root_account"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenOnAppearAddressViewSendEvenTriggered_thenCorrectAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "delivery_address_list"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearAddressViewSendEvent()
        
        eventLogger.verify()
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), profile: MemberProfile? = nil) -> MemberDashboardViewModel {
        
        if let profile = profile {
            container.appState.value.userData.memberProfile = profile
        }
        
        let sut = MemberDashboardViewModel(container: container)

        trackForMemoryLeaks(sut)
        return sut
    }
}
