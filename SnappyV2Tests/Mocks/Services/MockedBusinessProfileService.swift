//
//  MockedBusinessProfileService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedBusinessProfileService: Mock, BusinessProfileServiceProtocol {
    
    enum Action: Equatable {
        case getProfile
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func getProfile() -> Future<Void, Error> {
        register(.getProfile)
        return Future { $0(.success(())) }
    }
    
}
