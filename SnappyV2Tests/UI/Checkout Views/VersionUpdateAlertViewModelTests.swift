//
//  VersionUpdateAlertViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 02/01/2023.
//

import Foundation

import XCTest
import Combine
@testable import SnappyV2
import SwiftUI

@MainActor
class VersionUpdateAlertViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        XCTAssertEqual(sut.prompt, "Test")
        XCTAssertEqual(sut.appstoreLink, URL(string: "www.test.com")!)
    }
    
    func test_whenNavigateToAppStoreCalled_thenVersionUpdateCheckedInAppStateSetToTrue() {
        let sut = makeSUT()
        XCTAssertFalse(sut.container.appState.value.userData.versionUpdateChecked)
        sut.navigateToAppStore()
        XCTAssertTrue(sut.container.appState.value.userData.versionUpdateChecked)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> VersionUpdateAlertViewModel {
        let sut = VersionUpdateAlertViewModel(container: container, prompt: "Test", appstoreLink: URL(string: "www.test.com")!)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
