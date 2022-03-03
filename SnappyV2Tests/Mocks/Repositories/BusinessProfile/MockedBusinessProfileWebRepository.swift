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
    }
    var actions = MockActions<Action>(expected: [])
    
    var getProfileResponse: Result<BusinessProfile, Error> = .failure(MockError.valueNotSet)
    
    func getProfile() -> AnyPublisher<BusinessProfile, Error> {
        register(.getProfile)
        return getProfileResponse.publish()
    }

}
