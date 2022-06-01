//
//  MemberDashboardHomeViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class MemberDashboardHomeViewModelTests: XCTestCase {
    func test_init() {
        let member = MemberProfile(
            uuid: UUID(),
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
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = member
        
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.profile, member)
        XCTAssertEqual(sut.referralCode, "TESTCODE")
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> MemberDashboardHomeViewModel {
        let sut = MemberDashboardHomeViewModel(container: container)
        trackForMemoryLeaks(sut)
        return sut
    }
}
