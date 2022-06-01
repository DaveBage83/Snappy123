//
//  LoyaltyViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
@testable import SnappyV2

class LoyaltyViewModelTests: XCTestCase {
    
    func test_init() {
        let member = MemberProfile(
            uuid: UUID(),
            firstname: "Alan",
            lastname: "Shearer",
            emailAddress: "alan.shearer@nufc.com",
            type: .customer,
            referFriendCode: "TESTCODE",
            referFriendBalance: 5.0,
            numberOfReferrals: 1,
            mobileContactNumber: "122334444",
            mobileValidated: false,
            acceptedMarketing: false,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)
        
        let sut = makeSUT(profile: member)
        
        XCTAssertEqual(sut.profile, member)
        XCTAssertEqual(sut.referralCode, "TESTCODE")
        XCTAssertEqual(sut.numberOfReferrals, "1")
        // Decimal removed as value is Int
        XCTAssertEqual(sut.referralBalance, "£5.00")
    }
    
    func test_whenReferBalanceHasDecimals_thenShow2DecimalPlaces() {
        let member = MemberProfile(
            uuid: UUID(),
            firstname: "Alan",
            lastname: "Shearer",
            emailAddress: "alan.shearer@nufc.com",
            type: .customer,
            referFriendCode: "TESTCODE",
            referFriendBalance: 5.25,
            numberOfReferrals: 1,
            mobileContactNumber: "122334444",
            mobileValidated: false,
            acceptedMarketing: false,
            defaultBillingDetails: nil,
            savedAddresses: nil,
            fetchTimestamp: nil)
        
        let sut = makeSUT(profile: member)

        XCTAssertEqual(sut.referralBalance, "£5.25")
    }
    
    func test_whenProfileIsNil_thenReferralsAndBalanceAre0AndReferFriendErrorShown() {
        let sut = makeSUT(profile: nil)
        XCTAssertEqual(sut.referralBalance, "0")
        XCTAssertEqual(sut.numberOfReferrals, "0")
        XCTAssertEqual(sut.referralCode, Strings.MemberDashboard.Loyalty.noCode.localized)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), profile: MemberProfile?) -> MemberDashboardLoyaltyViewModel {
        let sut = MemberDashboardLoyaltyViewModel(profile: profile)
        trackForMemoryLeaks(sut)
        return sut
    }
}
