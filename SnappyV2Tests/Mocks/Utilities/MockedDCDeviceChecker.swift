//
//  MockedDCDeviceChecker.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/01/2023.
//

import Foundation
import XCTest

@testable import SnappyV2

final class MockedDCDeviceChecker: Mock, DCDeviceCheckerProtocol {
    
    enum Action: Equatable {
        case getAppleDeviceToken
    }
    
    // deliberately public to allow it to be set using different initialisation patterns
    var actions: MockActions<Action>
    
    var appleDeviceTokenResult: String?
    
    init(expected: [Action] = []) {
        self.actions = .init(expected: expected)
    }
    
    func getAppleDeviceToken() async -> String? {
        register(.getAppleDeviceToken)
        return appleDeviceTokenResult
    }
    
}
