//
//  MockedSystemEventsHandler.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 29/08/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedSystemEventsHandler: Mock, SystemEventsHandlerProtocol {
    
    enum Action: Equatable {
        case handle(url: URL)
        case pushRegistration
    }
    var actions = MockActions<Action>(expected: [])
    
    var handleURLResult = false
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func handle(url: URL) -> Bool {
        register(.handle(url: url))
        return handleURLResult
    }
    
    func handlePushRegistration(result: Result<Data, Error>, completed: (()->Void)?) {
        register(.pushRegistration)
    }
}

final class DummyPushNotificationsHandler: PushNotificationsHandlerProtocol { }
