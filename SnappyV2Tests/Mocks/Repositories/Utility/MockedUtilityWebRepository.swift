//
//  MockedUtilityWebRepository.swift
//  SnappyV2Tests
//
//  Created by David Bage on 24/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedUtilityWebRepository: TestWebRepository, Mock, UtilityWebRepositoryProtocol {
    
    enum Action: Equatable {
        case getServerTime
    }
    
    var actions = MockActions<Action>(expected: [])
    var getServerTimeResponse: Result<TrueTime?, Error> = .failure(MockError.valueNotSet)
    
    func getServerTime() -> AnyPublisher<TrueTime?, Error> {
        register(.getServerTime)
        return getServerTimeResponse.publish()
    }
}
