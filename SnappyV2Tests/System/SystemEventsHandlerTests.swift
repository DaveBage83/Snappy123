//
//  SystemEventsHandlerTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/08/2022.
//

import XCTest
import UIKit
@testable import SnappyV2

final class SystemEventsHandlerTests: XCTestCase {
    
    var sut: SystemEventsHandler!
    var deepLinksHandler: MockedDeepLinksHandler!
    var pushNotificationWebRepository: MockedPushNotificationWebRepository!
    var userPermissionsService: MockedUserPermissionsService!
    
    var appState: AppState {
        return sut.container.appState.value
    }
    var services: DIContainer.Services {
        return sut.container.services
    }
    
    func verify(appState: AppState = AppState(), file: StaticString = #file, line: UInt = #line) {
        services.verify(as: .userPermissions, file: file, line: line)
        deepLinksHandler?.verify(file: file, line: line)
        pushNotificationWebRepository?.verify(file: file, line: line)
        // We have had to remove the conformity of AppState to equatable
//        XCTAssertEqual(self.appState, appState, file: file, line: line)
    }

    func setupSut(
        permissions: [MockedUserPermissionsService.Action] = [],
        deepLink: [MockedDeepLinksHandler.Action] = [],
        pushNotification: [MockedPushNotificationWebRepository.Action] = []
    ) {
        
        userPermissionsService = MockedUserPermissionsService(expected: permissions)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: userPermissionsService
        )
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        deepLinksHandler = MockedDeepLinksHandler(expected: deepLink)
        let pushNotificationsHandler = DummyPushNotificationsHandler()
        pushNotificationWebRepository = MockedPushNotificationWebRepository(expected: pushNotification)

        sut = SystemEventsHandler(
            container: container,
            deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler,
            pushNotificationsWebRepository: pushNotificationWebRepository
        )
    }
    
    func test_noSideEffectOnInit() {
        setupSut()
        sut.container.appState[\.permissions.push] = .denied
        let reference = sut.container.appState.value
        verify(appState: reference)
    }
    
    func test_subscribesOnPushIfGranted() {
        setupSut(permissions: [
            .request(permission: .pushNotifications)
        ])
        sut.container.appState[\.permissions.push] = .granted
        let reference = sut.container.appState.value
        verify(appState: reference)
    }
    
    func test_init_whenPreviousToken_pushNotificationSetInAppState() {
        let previousDeviceToken: String = "888888887307661deceeef3804a411a789417793189f929198e714686634f659"
        UserDefaults.standard.set(previousDeviceToken, forKey: SystemEventsHandler.keyToken)
        var expectedAppState = AppState()
        expectedAppState.system.notificationDeviceToken = previousDeviceToken
        setupSut()
        self.verify(appState: expectedAppState)
    }
    
    func test_handlePushRegistration_whenNoPreviousToken_registerDevice() {
        
        let rawAppleExampleData: [UInt8] = [124,81,213,184,115,7,102,29,236,238,239,56,4,164,17,167,137,65,119,147,24,159,146,145,152,231,20,104,102,52,246,89]
        let decodedDeviceToken: String = "7c51d5b87307661deceeef3804a411a789417793189f929198e714686634f659"

        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: SystemEventsHandler.keyToken)
        userDefaults.set(nil, forKey: SystemEventsHandler.keyTokenRegistered)
        
        var expectedAppState = AppState()
        expectedAppState.system.notificationDeviceToken = decodedDeviceToken
        
        let expectedRequest = PushNotificationDeviceRequest(
            deviceMessageToken: decodedDeviceToken,
            firebaseCloudMessageToken: nil,
            oldDeviceMessageToken: nil,
            optOut: .optIn
        )
        setupSut(
            permissions: [
                .userPushNotificationMarketingSelection,
                .setSavedPushNotificationMarketingSelection
            ],
            pushNotification: [
                .registerDevice(
                    request: expectedRequest
                )
            ]
        )
        
        (sut.container.services.userPermissionsService as? MockedUserPermissionsService)?.userPushNotificationMarketingSelectionResponse = .optIn
        pushNotificationWebRepository.registerDeviceResponse = .success(RegisterPushNotificationDeviceResult.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut.handlePushRegistration(result: .success(Data(rawAppleExampleData))) { [weak self] in
            guard let self = self else { return }
            self.verify(appState: expectedAppState)
            XCTAssertEqual(userDefaults.string(forKey: SystemEventsHandler.keyToken), decodedDeviceToken)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_handlePushRegistration_whenPreviousSavedTokenIsDifferent_registerDevice() {
        
        let rawAppleExampleData: [UInt8] = [124,81,213,184,115,7,102,29,236,238,239,56,4,164,17,167,137,65,119,147,24,159,146,145,152,231,20,104,102,52,246,89]
        let decodedDeviceToken: String = "7c51d5b87307661deceeef3804a411a789417793189f929198e714686634f659"
        let previousDeviceToken: String = "888888887307661deceeef3804a411a789417793189f929198e714686634f659"
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(previousDeviceToken, forKey: SystemEventsHandler.keyToken)
        userDefaults.set(true, forKey: SystemEventsHandler.keyTokenRegistered)
        
        var expectedAppState = AppState()
        expectedAppState.system.notificationDeviceToken = decodedDeviceToken

        let expectedRequest = PushNotificationDeviceRequest(
            deviceMessageToken: decodedDeviceToken,
            firebaseCloudMessageToken: nil,
            oldDeviceMessageToken: previousDeviceToken,
            optOut: .optIn
        )
        
        setupSut(
            permissions: [
                .userPushNotificationMarketingSelection,
                .setSavedPushNotificationMarketingSelection
            ],
            pushNotification: [
                .registerDevice(
                    request: expectedRequest
                )
            ]
        )
        (sut.container.services.userPermissionsService as? MockedUserPermissionsService)?.userPushNotificationMarketingSelectionResponse = .optIn
        pushNotificationWebRepository.registerDeviceResponse = .success(RegisterPushNotificationDeviceResult.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut.handlePushRegistration(result: .success(Data(rawAppleExampleData))) { [weak self] in
            guard let self = self else { return }
            self.verify(appState: expectedAppState)
            XCTAssertEqual(userDefaults.string(forKey: SystemEventsHandler.keyToken), decodedDeviceToken)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_handlePushRegistration_whenPreviousSavedTokenIsSame_doNotRegisterDevice() {
        
        let rawAppleExampleData: [UInt8] = [124,81,213,184,115,7,102,29,236,238,239,56,4,164,17,167,137,65,119,147,24,159,146,145,152,231,20,104,102,52,246,89]
        let decodedDeviceToken: String = "7c51d5b87307661deceeef3804a411a789417793189f929198e714686634f659"
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(decodedDeviceToken, forKey: SystemEventsHandler.keyToken)
        userDefaults.set(true, forKey: SystemEventsHandler.keyTokenRegistered)
        
        var expectedAppState = AppState()
        expectedAppState.system.notificationDeviceToken = decodedDeviceToken
        
        setupSut(
            permissions: [.unsavedPushNotificationPreferences]
        )
        
        let exp = XCTestExpectation(description: #function)
        sut.handlePushRegistration(result: .success(Data(rawAppleExampleData))) { [weak self] in
            guard let self = self else { return }
            self.verify(appState: expectedAppState)
            XCTAssertEqual(userDefaults.string(forKey: SystemEventsHandler.keyToken), decodedDeviceToken)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_handlePushRegistration_whenPreviousSavedTokenIsNotDifferentButUnsavedPreference_registerDevice() {
        
        let rawAppleExampleData: [UInt8] = [124,81,213,184,115,7,102,29,236,238,239,56,4,164,17,167,137,65,119,147,24,159,146,145,152,231,20,104,102,52,246,89]
        let decodedDeviceToken: String = "7c51d5b87307661deceeef3804a411a789417793189f929198e714686634f659"
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(decodedDeviceToken, forKey: SystemEventsHandler.keyToken)
        userDefaults.set(true, forKey: SystemEventsHandler.keyTokenRegistered)
        
        var expectedAppState = AppState()
        expectedAppState.system.notificationDeviceToken = decodedDeviceToken

        let expectedRequest = PushNotificationDeviceRequest(
            deviceMessageToken: decodedDeviceToken,
            firebaseCloudMessageToken: nil,
            oldDeviceMessageToken: nil,
            optOut: .optIn
        )
        
        setupSut(
            permissions: [
                .unsavedPushNotificationPreferences,
                .userPushNotificationMarketingSelection,
                .setSavedPushNotificationMarketingSelection
            ],
            pushNotification: [
                .registerDevice(
                    request: expectedRequest
                )
            ]
        )
        (sut.container.services.userPermissionsService as? MockedUserPermissionsService)?.userPushNotificationMarketingSelectionResponse = .optIn
        pushNotificationWebRepository.registerDeviceResponse = .success(RegisterPushNotificationDeviceResult.mockedData)
        userPermissionsService.unsavedPushNotificationPreferencesResponse = true
        
        let exp = XCTestExpectation(description: #function)
        sut.handlePushRegistration(result: .success(Data(rawAppleExampleData))) { [weak self] in
            guard let self = self else { return }
            self.verify(appState: expectedAppState)
            XCTAssertEqual(userDefaults.string(forKey: SystemEventsHandler.keyToken), decodedDeviceToken)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
}
