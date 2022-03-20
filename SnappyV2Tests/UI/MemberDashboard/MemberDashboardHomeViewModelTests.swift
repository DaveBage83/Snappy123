//
//  MemberDashboardHomeViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

#warning("Past orders functionality not working yet due to backend issues so tests will be added later for this")
class MemberDashboardHomeViewModelTests: XCTestCase {
    
    func test_init() {
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
        
        let sut = makeSUT(profile: member)
        
        XCTAssertEqual(sut.profile, member)
        XCTAssertEqual(sut.referralCode, "TESTCODE")
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), profile: MemberProfile?) -> MemberDashboardHomeViewModel {
        let sut = MemberDashboardHomeViewModel(container: container, profile: profile)
        
        return sut
    }
}
