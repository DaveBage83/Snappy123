//
//  MockedBusinessProfileWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedBusinessProfileWebRepository: TestWebRepository, Mock, BusinessProfileWebRepositoryProtocol {

    enum Action: Equatable {
        case getProfile
        case checkPreviousOrderedDeviceState(deviceCheckToken: String)
    }
    var actions = MockActions<Action>(expected: [])
    
    var getProfileResponse: Result<BusinessProfile, Error> = .failure(MockError.valueNotSet)
    var checkPreviousOrderedDeviceStateResponse: Result<CheckPreviousOrderedDeviceStateResult, Error> = .failure(MockError.valueNotSet)
    
    func getProfile() async throws -> BusinessProfile {
        register(.getProfile)
        switch getProfileResponse {
        case let .success(businessProfile):
            return businessProfile
        case let .failure(error):
            throw error
        }
    }
    
    func checkPreviousOrderedDeviceState(deviceCheckToken: String) async throws -> CheckPreviousOrderedDeviceStateResult {
        register(.checkPreviousOrderedDeviceState(deviceCheckToken: deviceCheckToken))
        switch checkPreviousOrderedDeviceStateResponse {
        case let .success(checkPreviousOrderedDeviceStateResult):
            return checkPreviousOrderedDeviceStateResult
        case let .failure(error):
            throw error
        }
    }

}
