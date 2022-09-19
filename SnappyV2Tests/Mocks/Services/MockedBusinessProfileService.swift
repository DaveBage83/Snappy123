//
//  MockedBusinessProfileService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedBusinessProfileService: Mock, BusinessProfileServiceProtocol {

    enum Action: Equatable {
        case getProfile
    }
    
    let actions: MockActions<Action>
    
    var getProfileResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func getProfile() async throws {
        register(.getProfile)
        switch getProfileResponse {
        case let .failure(error):
            throw error
        default:
            break
        }
    }
    
}
