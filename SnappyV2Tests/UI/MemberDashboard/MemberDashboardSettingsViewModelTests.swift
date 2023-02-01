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
    
    func test_whenUserTapsOnVersionLabel_givenVersionTapsForDebugInformationReached_thenCopyDebugInfoToClipboard() async {
        
        let mockedDCDeviceChecker = MockedDCDeviceChecker()
        let sut = makeSUT(deviceChecker: mockedDCDeviceChecker)
        
        mockedDCDeviceChecker.actions = .init(expected: [
            .getAppleDeviceToken
        ])
        
        UIPasteboard.general.string = nil
        
        var count = 0
        repeat {
            count += 1
            await sut.versionTapped(debugInformationCopied: {
                if count == sut.versionTapsForDebugInformation {
                    // Simple test that the clipboard contains the start and end of the debug block.
                    XCTAssertTrue(
                        (UIPasteboard.general.string?.contains("- BEGIN -") ?? false) &&
                        (UIPasteboard.general.string?.contains("- END -") ?? false)
                    )
                    return
                }
                XCTFail("Unexpected call to debugInformationCopied handler")
            })
        } while count < sut.versionTapsForDebugInformation + 1
        mockedDCDeviceChecker.verify()
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), deviceChecker: MockedDCDeviceChecker = MockedDCDeviceChecker(), profile: MemberProfile? = nil) -> MemberDashboardSettingsViewModel {
        let sut = MemberDashboardSettingsViewModel(container: container, deviceChecker: deviceChecker)

        trackForMemoryLeaks(sut)
        return sut
    }
}
