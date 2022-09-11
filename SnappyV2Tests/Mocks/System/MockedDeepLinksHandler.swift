//
//  MockedDeepLinksHandler.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 29/08/2022.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedDeepLinksHandler: Mock, DeepLinksHandlerProtocol {
    enum Action: Equatable {
        case open(DeepLink)
    }
    var actions = MockActions<Action>(expected: [])
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func open(deepLink: DeepLink) {
        register(.open(deepLink))
    }
}
