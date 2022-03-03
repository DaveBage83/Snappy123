//
//  MockedBusinessProfileDBRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedBusinessProfileDBRepository: Mock, BusinessProfileDBRepositoryProtocol {

    enum Action: Equatable {
        case businessProfile(forLocaleCode: String)
        case clearBusinessProfile(forLocaleCode: String)
        case store(businessProfile: BusinessProfile, forLocaleCode: String)
    }
    var actions = MockActions<Action>(expected: [])
    
    var businessProfileResult: Result<BusinessProfile?, Error> = .failure(MockError.valueNotSet)
    var clearBusinessProfileResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var storeBusinessProfileResult: Result<BusinessProfile, Error> = .failure(MockError.valueNotSet)
    
    func businessProfile(forLocaleCode localeCode: String) -> AnyPublisher<BusinessProfile?, Error> {
        register(.businessProfile(forLocaleCode: localeCode))
        return businessProfileResult.publish()
    }
    
    func clearBusinessProfile(forLocaleCode localeCode: String) -> AnyPublisher<Bool, Error> {
        register(.clearBusinessProfile(forLocaleCode: localeCode))
        return clearBusinessProfileResult.publish()
    }
    
    func store(businessProfile: BusinessProfile, forLocaleCode localeCode: String) -> AnyPublisher<BusinessProfile, Error> {
        register(.store(businessProfile: businessProfile, forLocaleCode: localeCode))
        return storeBusinessProfileResult.publish()
    }

}
