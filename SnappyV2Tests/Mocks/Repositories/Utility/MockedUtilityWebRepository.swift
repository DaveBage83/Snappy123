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
        case mentionMeCallHome(requestType: MentionMeRequest, businessOrderId: Int?)
    }
    
    var actions = MockActions<Action>(expected: [])
    var getServerTimeResponse: Result<TrueTime?, Error> = .failure(MockError.valueNotSet)
    var mentionMeCallHomeResponse: Result<ShimmedMentionMeCallHomeResponse, Error> = .failure(MockError.valueNotSet)
    
    func getServerTime() -> AnyPublisher<TrueTime?, Error> {
        register(.getServerTime)
        return getServerTimeResponse.publish()
    }
    
    func mentionMeCallHome(requestType: MentionMeRequest, businessOrderId: Int?) async throws -> ShimmedMentionMeCallHomeResponse {
        register(.mentionMeCallHome(requestType: requestType, businessOrderId: businessOrderId))
        switch mentionMeCallHomeResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
}
