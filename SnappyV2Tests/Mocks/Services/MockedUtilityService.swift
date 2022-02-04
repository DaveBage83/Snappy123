//
//  MockedUtilityService.swift
//  SnappyV2Tests
//
//  Created by David Bage on 24/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedUtilityService: Mock, UtilityServiceProtocol {
    enum Action: Equatable {
        case setDeviceTimeOffset
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func setDeviceTimeOffset() {
        register(.setDeviceTimeOffset)
    }
}
