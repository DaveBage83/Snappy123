//
//  MockedEventLoggerWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 01/10/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedEventLoggerWebRepository: TestWebRepository, Mock, EventLoggerWebRepositoryProtocol {
    
    enum Action: Equatable {
        case getIterableJWT(email: String?, userId: String?)
    }
    
    var actions = MockActions<Action>(expected: [])
    var getIterableJWTResponse: Result<IterableJWTResult, Error> = .failure(MockError.valueNotSet)

    func getIterableJWT(email: String?, userId: String?) async throws -> IterableJWTResult {
        register(.getIterableJWT(email: email, userId: userId))
        switch getIterableJWTResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
}
