//
//  MockedUserPermissionsUserDefaultsRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 09/09/2022.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

final class MockedUserPermissionsUserDefaultsRepository: Mock, UserPermissionsUserDefaultsRepositoryProtocol {
    
    enum Action: Equatable {
        case userChoseNoNotifications
        case userPushNotificationMarketingSelection
        case userPushNotificationMarketingRegisteredSelection
        case setUserChoseNoNotifications(to: Bool)
        case setUserPushNotificationMarketingSelection(to: PushNotificationDeviceMarketingOptIn)
        case setUserPushNotificationMarketingRegisteredSelection(to: PushNotificationDeviceMarketingOptIn)
    }
    var actions = MockActions<Action>(expected: [])
    
    var userChoseNoNotificationsResponse: Bool = false
    var userPushNotificationMarketingSelectionResponse: PushNotificationDeviceMarketingOptIn = .undecided
    var userPushNotificationMarketingRegisteredSelectionResponse: PushNotificationDeviceMarketingOptIn = .undecided
    
    var userChoseNoNotifications: Bool {
        register(.userChoseNoNotifications)
        return userChoseNoNotificationsResponse
    }
    
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn {
        register(.userPushNotificationMarketingSelection)
        return userPushNotificationMarketingSelectionResponse
    }
    
    var userPushNotificationMarketingRegisteredSelection: PushNotificationDeviceMarketingOptIn {
        register(.userPushNotificationMarketingRegisteredSelection)
        return userPushNotificationMarketingRegisteredSelectionResponse
    }
    
    func setUserChoseNoNotifications(to newValue: Bool) {
        register(.setUserChoseNoNotifications(to: newValue))
    }
    
    func setUserPushNotificationMarketingSelection(to newValue: PushNotificationDeviceMarketingOptIn) {
        register(.setUserPushNotificationMarketingSelection(to: newValue))
    }
    
    func setUserPushNotificationMarketingRegisteredSelection(to newValue: PushNotificationDeviceMarketingOptIn) {
        register(.setUserPushNotificationMarketingRegisteredSelection(to: newValue))
    }

}
