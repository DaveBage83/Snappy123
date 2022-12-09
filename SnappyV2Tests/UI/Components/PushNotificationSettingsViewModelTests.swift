//
//  PushNotificationSettingsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 04/09/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
final class PushNotificationSettingsViewModelTests: XCTestCase {

    func test_init_whenViewContextSettings_useLargeTitleTrue() {
        let sut = makeSUT(
            userPermissionsService: [.resolveStatus(permission: SnappyV2.Permission.marketingPushNotifications, reconfirmIfKnown: false)],
            viewContext: .settings
        )
        XCTAssertTrue(sut.useLargeTitles, file: #file, line: #line)
        sut.container.services.verify(as: .userPermissions)
    }
    
    func test_init_whenViewContextSettings_useLargeTitleFalse() {
        let sut = makeSUT(
            userPermissionsService: [.resolveStatus(permission: SnappyV2.Permission.marketingPushNotifications, reconfirmIfKnown: false)],
            viewContext: .checkout
        )
        XCTAssertFalse(sut.useLargeTitles, file: #file, line: #line)
        sut.container.services.verify(as: .userPermissions)
    }
    
    func test_init_whenInitialAppStatePushNotificationPermissionNotGrantedAndPushNotificationMarketingNotGranted_pushNotificationsDisabledMArketingFalse() {
        
        var appState = AppState()
        
        appState[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] = .denied
        appState.permissions.marketingPushNotifications = .unknown
        
        let sut = makeSUT(
            appState: appState,
            userPermissionsService: [.resolveStatus(permission: SnappyV2.Permission.marketingPushNotifications, reconfirmIfKnown: false)]
        )
        XCTAssertTrue(sut.pushNotificationsDisabled, file: #file, line: #line)
        XCTAssertFalse(sut.allowPushNotificationMarketing, file: #file, line: #line)
        sut.container.services.verify(as: .userPermissions)
    }
    
    func test_init_whenInitialAppStatePushNotificationPermissionGrantedAndPushNotificationMarketingGranted_pushNotificationsEnabledMArketingTrue() {
        
        var appState = AppState()
        
        appState[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] = .granted
        appState.permissions.marketingPushNotifications = .granted
        
        let sut = makeSUT(
            appState: appState,
            userPermissionsService: [.resolveStatus(permission: SnappyV2.Permission.marketingPushNotifications, reconfirmIfKnown: false)]
        )
        XCTAssertFalse(sut.pushNotificationsDisabled, file: #file, line: #line)
        XCTAssertTrue(sut.allowPushNotificationMarketing, file: #file, line: #line)
        sut.container.services.verify(as: .userPermissions)
    }
    
    func test_setupPushNotificationBinding_whenInitialAppStatePushNotificationPermissionGrantedChangedToDenied_thenPushNotificationsDisabled() {
        
        var appState = AppState()
        appState[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] = .granted
        
        let sut = makeSUT(appState: appState)
        
        // before with initial app state value
        XCTAssertFalse(sut.pushNotificationsDisabled, file: #file, line: #line)
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$pushNotificationsDisabled
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] = .denied
        
        wait(for: [expectation], timeout: 2.0)
        
        // after app state change
        XCTAssertTrue(sut.pushNotificationsDisabled, file: #file, line: #line)
    }
    
    func test_setupMarketingPreferenceBinding_whenInitialAppStatePushNotificationPermissionGrantedChangedToDenied_thenAllowPushNotificationMarketingDisabled() {
        
        var appState = AppState()
        appState[keyPath: AppState.permissionKeyPath(for: .marketingPushNotifications)] = .granted
        
        let sut = makeSUT(appState: appState)
        
        // before with initial app state value
        XCTAssertTrue(sut.allowPushNotificationMarketing, file: #file, line: #line)
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$allowPushNotificationMarketing
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value[keyPath: AppState.permissionKeyPath(for: .marketingPushNotifications)] = .denied
        
        wait(for: [expectation], timeout: 2.0)
        
        // after app state change
        XCTAssertFalse(sut.allowPushNotificationMarketing, file: #file, line: #line)
    }
    
    func test_setupMarketingPreferenceBinding_whenAllowPushNotificationMarketingUpdated_thenSetPushNotificationMarketingSelection() {
        
        var appState = AppState()
        appState[keyPath: AppState.permissionKeyPath(for: .marketingPushNotifications)] = .denied
        
        let sut = makeSUT(
            appState: appState,
            userPermissionsService: [
                .resolveStatus(permission: SnappyV2.Permission.marketingPushNotifications, reconfirmIfKnown: false),
                .setPushNotificationMarketingSelection(marketingOptIn: .optIn)
            ]
        )
        
        // before with initial app state value
        XCTAssertFalse(sut.allowPushNotificationMarketing, file: #file, line: #line)

        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()

        sut.$allowPushNotificationMarketing
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.allowPushNotificationMarketing = true

        wait(for: [expectation], timeout: 2.0)

        sut.container.services.verify(as: .userPermissions)
    }
    
    func test_enableNotificationsTappedWhenDenied_setAppStateRoutingToOpenSettingsURL() {
        let sut = makeSUT(
            userPermissionsService: [
                .resolveStatus(permission: SnappyV2.Permission.marketingPushNotifications, reconfirmIfKnown: false)
            ]
        )
        sut.container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] = .denied
        sut.container.appState.value.routing.urlToOpen = nil
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)
        
        sut.container.appState
            .map(\.routing.urlToOpen)
            .first(where: { $0 != nil })
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.enableNotificationsTapped()
        
        wait(for: [expectation], timeout: 2.0)
        
        sut.container.services.verify(as: .userPermissions)
        XCTAssertEqual(sut.container.appState.value.routing.urlToOpen, URL(string: UIApplication.openSettingsURLString))
    }
    
    func test_enableNotificationsTappedNotDenied_setAppStateToShowPushNotificationsEnablePromptView() {
        let sut = makeSUT(
            userPermissionsService: [
                .resolveStatus(permission: SnappyV2.Permission.marketingPushNotifications, reconfirmIfKnown: false)
            ]
        )
        sut.container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] = .granted
        sut.container.appState.value.pushNotifications.showPushNotificationsEnablePromptView = false
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)
        
        sut.container.appState
            .map(\.pushNotifications.showPushNotificationsEnablePromptView)
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.enableNotificationsTapped()
        
        wait(for: [expectation], timeout: 2.0)
        
        sut.container.services.verify(as: .userPermissions)
        XCTAssertTrue(sut.container.appState.value.pushNotifications.showPushNotificationsEnablePromptView)
    }

    func makeSUT(
        appState: AppState = AppState(),
        userPermissionsService: [MockedUserPermissionsService.Action] = [],
        viewContext: PushNotificationSettingsViewModel.ViewContext = .settings,
        hideAcceptedMarketingOptions: Bool = false
    ) -> PushNotificationSettingsViewModel {
        
        let sut = PushNotificationSettingsViewModel(
            container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: .mocked(userPermissionsService: userPermissionsService)),
            viewContext: viewContext
        )
        trackForMemoryLeaks(sut)
        return sut
    }

}


