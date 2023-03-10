//
//  MockedEventLogger.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 14/04/2022.
//

import Foundation
import XCTest

// 3rd party libraries
import AppsFlyerLib

@testable import SnappyV2

final class MockedEventLogger: Mock, EventLoggerProtocol {

    enum Action: Equatable {
        case initialiseSentry
        case initialiseAppsFlyer
        case initialiseIterable(apiKey: String)
        case initialiseLoggers
        case sendEvent(for: AppEvent, with: EventLoggerType, params: [String : Any])
        case sendMentionMeConsumerOrderEvent(businessOrderId: Int)
        case setCustomerID(profileUUID: String)
        case clearCustomerID
        case pushNotificationDeviceRegistered(deviceToken: Data)
        case getFirebaseItemsArray(from: [BasketItem])
        
        // required because sendEvent(for eventName: String, with type: EventLoggerType, params: [String : Any]) is not Equatable
        static func == (lhs: MockedEventLogger.Action, rhs: MockedEventLogger.Action) -> Bool {
            switch (lhs, rhs) {
            
            case (.initialiseSentry, .initialiseSentry):
                return true
                
            case (.initialiseAppsFlyer, .initialiseAppsFlyer):
                return true
                
            case (let .sendEvent(lhsEvent, lhsType, lhsParams), let .sendEvent(rhsEvent, rhsType, rhsParams)):
                return lhsEvent == rhsEvent && lhsType == rhsType && lhsParams.isEqual(to: rhsParams)
                
            case (let .sendMentionMeConsumerOrderEvent(lhsBusinessOrderId), let .sendMentionMeConsumerOrderEvent(rhsBusinessOrderId)):
                return lhsBusinessOrderId == rhsBusinessOrderId
                
            case (.setCustomerID(profileUUID: let lhsString), .setCustomerID(profileUUID: let rhsString)):
                return lhsString == rhsString
                
            case (.clearCustomerID, .clearCustomerID):
                return true
                
            case (let .pushNotificationDeviceRegistered(deviceToken: lhsDeviceTokenData), let .pushNotificationDeviceRegistered(deviceToken: rhsDeviceTokenData)):
                return lhsDeviceTokenData == rhsDeviceTokenData
                
            case (let .getFirebaseItemsArray(from: lhsBasketItems), let .getFirebaseItemsArray(from: rhsBasketItems)):
                return lhsBasketItems == rhsBasketItems

            default:
                return false
            }
        }
    }
    
    // deliberately public to allow it to be set using different initialisation patterns
    var actions: MockActions<Action>
    
    init(expected: [Action] = []) {
        self.actions = .init(expected: expected)
    }
    
    func initialiseSentry() {
        register(.initialiseSentry)
    }
    
    static func initialiseAppsFlyer(delegate: AppsFlyerLibDelegate) {
        // unfortunately a static func will not be able to use the Mock register(Action)
        //register(.initialiseAppsFlyer)
    }
    
    func initialiseIterable(apiKey: String) {
        register(.initialiseIterable(apiKey: apiKey))
    }
    
    func initialiseLoggers(container: DIContainer) {
        register(.initialiseLoggers)
    }
    
    func sendEvent(for event: AppEvent, with type: EventLoggerType, params: [String : Any]) {
        register(.sendEvent(for: event, with: type, params: params))
    }
    
    func sendMentionMeConsumerOrderEvent(businessOrderId: Int) async {
        register(.sendMentionMeConsumerOrderEvent(businessOrderId: businessOrderId))
    }
    
    func setCustomerID(profileUUID: String) {
        register(.setCustomerID(profileUUID: profileUUID))
    }
    
    func clearCustomerID() {
        register(.clearCustomerID)
    }
    
    func pushNotificationDeviceRegistered(deviceToken: Data) {
        register(.pushNotificationDeviceRegistered(deviceToken: deviceToken))
    }
    
    static func getFirebaseItemsArray(from items: [BasketItem]) -> [[String: Any]] {
        // unfortunately a static func will not be able to use the Mock register(Action)
        //register(.getFirebaseItemsArray(from: items))
        return []
    }
}
