//
//  UserPermissionsUserDefaultsRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 09/09/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class UserPermissionsUserDefaultsRepositoryTests: XCTestCase {
    
    var mockedUserDefaults: UserDefaults!
    var sut: UserPermissionsUserDefaultsRepository!
    
    override func setUp() {
        // based on: https://www.swiftbysundell.com/tips/avoiding-mocking-userdefaults/
        mockedUserDefaults = UserDefaults(suiteName: #file)
        mockedUserDefaults.removePersistentDomain(forName: #file)
        sut = UserPermissionsUserDefaultsRepository(userDefaults: mockedUserDefaults)
    }
    
    override func tearDown() {
        mockedUserDefaults = nil
        sut = nil
    }
    
}

// MARK: - Vars/Methods in UserPermissionsUserDefaultsRepository

final class UserPermissionsUserDefaultsRepositoryProtocolTests: UserPermissionsUserDefaultsRepositoryTests {
        
    // MARK: - userChoseNoNotifications: Bool
    
    func test_userChoseNoNotifications() {
        mockedUserDefaults.set(true, forKey: "no_notifications")
        XCTAssertEqual(sut.userChoseNoNotifications, true, file: #file, line: #line)
    }
    
    // MARK: - userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn
    
    func test_userPushNotificationMarketingSelection() {
        let setting = PushNotificationDeviceMarketingOptIn.optIn
        mockedUserDefaults.set(setting.rawValue, forKey: "marketing_notification")
        XCTAssertEqual(sut.userPushNotificationMarketingSelection, setting, file: #file, line: #line)
    }
    
    // MARK: - userPushNotificationMarketingRegisteredSelection: PushNotificationDeviceMarketingOptIn
    
    func test_userPushNotificationMarketingRegisteredSelection() {
        let setting = PushNotificationDeviceMarketingOptIn.optIn
        mockedUserDefaults.set(setting.rawValue, forKey: "saved_marketing_notification")
        XCTAssertEqual(sut.userPushNotificationMarketingRegisteredSelection, setting, file: #file, line: #line)
    }
    
    // MARK: - setUserChoseNoNotifications(to:)
    
    func test_setUserChoseNoNotifications() {
        sut.setUserChoseNoNotifications(to: true)
        XCTAssertTrue(mockedUserDefaults.bool(forKey: "no_notifications"), file: #file, line: #line)
    }
    
    // MARK: - setUserPushNotificationMarketingSelection(to:)
    
    func test_setUserPushNotificationMarketingSelection() {
        let setting = PushNotificationDeviceMarketingOptIn.optIn
        sut.setUserPushNotificationMarketingSelection(to: setting)
        XCTAssertEqual(mockedUserDefaults.integer(forKey: "marketing_notification"), setting.rawValue, file: #file, line: #line)
    }
    
    // MARK: - setUserPushNotificationMarketingRegisteredSelection(to:)
    
    func test_setUserPushNotificationMarketingRegisteredSelection() {
        let setting = PushNotificationDeviceMarketingOptIn.optIn
        sut.setUserPushNotificationMarketingRegisteredSelection(to: setting)
        XCTAssertEqual(mockedUserDefaults.integer(forKey: "saved_marketing_notification"), setting.rawValue, file: #file, line: #line)
    }
    
}
