//
//  MemberDashboardSettingsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 28/07/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class MemberDashboardSettingsViewModelTests: XCTestCase {
    
    // Test when member signed out then showMarketingPreferencesIsFalse
    func test_whenMemberSignedOut_thenShowMarketingPreferencesIsFalse() {
        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = nil
        
        XCTAssertFalse(sut.showMarketingPreferences)
    }
    
    // Test when member signed out then showMarketingPreferencesIsFalse
    func test_whenMemberSignedIn_thenShowMarketingPreferencesIsTrue() {
        let sut = makeSUT()
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        XCTAssertTrue(sut.showMarketingPreferences)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), profile: MemberProfile? = nil) -> MemberDashboardSettingsViewModel {
        
        let sut = MemberDashboardSettingsViewModel(container: container)

        trackForMemoryLeaks(sut)
        return sut
    }
}
