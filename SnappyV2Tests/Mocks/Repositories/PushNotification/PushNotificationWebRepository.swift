//
//  PushNotificationWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/08/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedPushNotificationWebRepository: TestWebRepository, Mock, PushNotificationWebRepositoryProtocol {
    
    enum Action: Equatable {
        case registerDevice(request: PushNotificationDeviceRequest)
    }
    
    var actions = MockActions<Action>(expected: [])
    var registerDeviceResponse: Result<RegisterPushNotificationDeviceResult, Error> = .failure(MockError.valueNotSet)
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func registerDevice(request: PushNotificationDeviceRequest) async throws -> RegisterPushNotificationDeviceResult {
        register(.registerDevice(request: request))
        switch registerDeviceResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }

}
