//
//  MockedUserPermissionsService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 29/08/2022.
//

import Foundation
@testable import SnappyV2

class MockedUserPermissionsService: Mock, UserPermissionsServiceProtocol {
    enum Action: Equatable {
        case resolveStatus(permission: Permission, reconfirmIfKnown: Bool)
        case request(permission: Permission)
        case pushNotificationPreferencesRequired
        case unsavedPushNotificationPreferences
        case userDoesNotWantPushNotifications
        case userPushNotificationMarketingSelection
        case setUserDoesNotWantPushNotifications
        case setSavedPushNotificationMarketingSelection
        case setPushNotificationMarketingSelection(marketingOptIn: PushNotificationDeviceMarketingOptIn)
    }
    
    let actions: MockActions<Action>
    
    var unsavedPushNotificationPreferencesResponse = false
    var userPushNotificationMarketingSelectionResponse: PushNotificationDeviceMarketingOptIn = .undecided
    var requestOutcome: (()->())?
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func resolveStatus(for permission: Permission, reconfirmIfKnown: Bool) {
        register(.resolveStatus(permission: permission, reconfirmIfKnown: reconfirmIfKnown))
    }
    
    func request(permission: Permission) {
        register(.request(permission: permission))
        requestOutcome?()
    }
    
    var pushNotificationPreferencesRequired: Bool {
        register(.pushNotificationPreferencesRequired)
        return false
    }
    
    var unsavedPushNotificationPreferences: Bool {
        register(.unsavedPushNotificationPreferences)
        return unsavedPushNotificationPreferencesResponse
    }
    
    var userDoesNotWantPushNotifications: Bool {
        register(.userDoesNotWantPushNotifications)
        return false
    }
    
    var userPushNotificationMarketingSelection: PushNotificationDeviceMarketingOptIn {
        register(.userPushNotificationMarketingSelection)
        return userPushNotificationMarketingSelectionResponse
    }
    
    func setUserDoesNotWantPushNotifications() {
        register(.setUserDoesNotWantPushNotifications)
    }
    
    func setSavedPushNotificationMarketingSelection() {
        register(.setSavedPushNotificationMarketingSelection)
    }
    
    func setPushNotificationMarketingSelection(to marketingOptIn: PushNotificationDeviceMarketingOptIn) {
        register(.setPushNotificationMarketingSelection(marketingOptIn: marketingOptIn))
    }
}
