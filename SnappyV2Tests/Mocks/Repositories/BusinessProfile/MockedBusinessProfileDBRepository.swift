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
    
    func businessProfile(forLocaleCode localeCode: String) async throws -> BusinessProfile? {
        register(.businessProfile(forLocaleCode: localeCode))
        switch businessProfileResult {
        case let .success(profile):
            return profile
        case let .failure(error):
            throw error
        }
    }
    
    func clearBusinessProfile(forLocaleCode localeCode: String) async throws {
        register(.clearBusinessProfile(forLocaleCode: localeCode))
        switch clearBusinessProfileResult {
        case let .failure(error):
            throw error
        default:
            break
        }
    }
    
    func store(businessProfile: BusinessProfile, forLocaleCode localeCode: String) async throws {
        register(.store(businessProfile: businessProfile, forLocaleCode: localeCode))
        switch storeBusinessProfileResult {
        case let .failure(error):
            throw error
        default:
            break
        }
    }

}
