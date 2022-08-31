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
        case openURL
        case pushRegistration
    }
    var actions = MockActions<Action>(expected: [])
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        register(.openURL)
    }
    
    func handlePushRegistration(result: Result<Data, Error>) {
        register(.pushRegistration)
    }
}
