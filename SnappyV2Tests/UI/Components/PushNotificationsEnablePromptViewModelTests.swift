//
//  PushNotificationsEnablePromptViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 04/09/2022.
//

import XCTest
@testable import SnappyV2

@MainActor
class PushNotificationsEnablePromptViewModelTests: XCTestCase {

    func test_noNotificationsButtonRequired_onlyTrueWhenNotGranted() {
        let sut = makeSUT()
        sut.container.appState.value.permissions.push = .unknown
        XCTAssertTrue(sut.noNotificationsButtonRequired, file: #file, line: #line)
        sut.container.appState.value.permissions.push = .denied
        XCTAssertTrue(sut.noNotificationsButtonRequired, file: #file, line: #line)
        sut.container.appState.value.permissions.push = .notRequested
        XCTAssertTrue(sut.noNotificationsButtonRequired, file: #file, line: #line)
        sut.container.appState.value.permissions.push = .granted
        XCTAssertFalse(sut.noNotificationsButtonRequired, file: #file, line: #line)
    }
    
    func test_stringsWhenBusinessProfileMarketingTextsNotSet_useDefaults() {
        let sut = makeSUT()
        sut.container.appState.value.businessData.businessProfile = nil
        XCTAssertEqual(sut.introductionText, Strings.PushNotifications.defaultEnabledMessage.localized, file: #file, line: #line)
        XCTAssertEqual(sut.ordersOnlyButtonTitle, Strings.PushNotifications.defaultEnabledOrdersOnly.localized, file: #file, line: #line)
        XCTAssertEqual(sut.includingMarketingButtonTitle, Strings.PushNotifications.defaultEnabledIncludeMarketing.localized, file: #file, line: #line)
        XCTAssertEqual(sut.nonNotificationsButtonTitle, Strings.PushNotifications.defaultEnabledNone.localized, file: #file, line: #line)
    }
    
    func test_stringsWhenBusinessProfileMarketingTextsNotSet_useBusinessProfileMarketingTexts() {
        let sut = makeSUT()
        sut.container.appState.value.businessData.businessProfile = BusinessProfile.mockedDataFromAPI
        let marketingTexts = sut.container.appState.value.businessData.businessProfile?.marketingText
        XCTAssertEqual(sut.introductionText, marketingTexts?.iosRemoteNotificationIntro, file: #file, line: #line)
        XCTAssertEqual(sut.ordersOnlyButtonTitle, marketingTexts?.remoteNotificationOrdersOnlyButton, file: #file, line: #line)
        XCTAssertEqual(sut.includingMarketingButtonTitle, marketingTexts?.remoteNotificationIncludingMarketingButton, file: #file, line: #line)
        XCTAssertEqual(sut.nonNotificationsButtonTitle, marketingTexts?.remoteNotificationNoneButton, file: #file, line: #line)
    }
    
    func test_ordersOnlyTapped() {
        var handlerCalled = false
        let sut = makeSUT(userPermissionsService: [.setPushNotificationMarketingSelection(marketingOptIn: .optOut)]) {
            handlerCalled = true
        }
        sut.ordersOnlyTapped()
        sut.container.services.verify(as: .userPermissions)
        XCTAssertTrue(handlerCalled, file: #file, line: #line)
    }
    
    func test_includeMarketingTapped() {
        var handlerCalled = false
        let sut = makeSUT(userPermissionsService: [.setPushNotificationMarketingSelection(marketingOptIn: .optIn)]) {
            handlerCalled = true
        }
        sut.includeMarketingTapped()
        sut.container.services.verify(as: .userPermissions)
        XCTAssertTrue(handlerCalled, file: #file, line: #line)
    }
    
    func test_noNotificationsTapped() {
        var handlerCalled = false
        let sut = makeSUT(userPermissionsService: [.setUserDoesNotWantPushNotifications]) {
            handlerCalled = true
        }
        sut.noNotificationsTapped()
        sut.container.services.verify(as: .userPermissions)
        XCTAssertTrue(handlerCalled, file: #file, line: #line)
    }

    func makeSUT(
        userPermissionsService: [MockedUserPermissionsService.Action] = [],
        dismissPushNotificationViewHandler: @escaping ()->() = {}
    ) -> PushNotificationsEnablePromptViewModel {
        let sut = PushNotificationsEnablePromptViewModel(
            container: DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(userPermissionsService: userPermissionsService)),
            dismissPushNotificationViewHandler: dismissPushNotificationViewHandler
        )
        trackForMemoryLeaks(sut)
        return sut
    }

}
