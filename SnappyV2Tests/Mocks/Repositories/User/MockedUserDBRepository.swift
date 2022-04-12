//
//  MockedUserDBRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 09/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedUserDBRepository: Mock, UserDBRepositoryProtocol {

    enum Action: Equatable {
        case clearMemberProfile
        case store(memberProfile: MemberProfile, forStoreId: Int?)
        case memberProfile
        case clearAllFetchedUserMarketingOptions
        case clearFetchedUserMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
        case store(marketingOptionsFetch: UserMarketingOptionsFetch, isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
        case userMarketingOptionsFetch(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var clearMemberProfileResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var storeMemberProfileResult: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var memberProfileResult: Result<MemberProfile?, Error> = .failure(MockError.valueNotSet)
    var clearAllFetchedUserMarketingOptionsResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearFetchedUserMarketingOptionsResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var storeMarketingOptionsFetchResult: Result<UserMarketingOptionsFetch, Error> = .failure(MockError.valueNotSet)
    var userMarketingOptionsFetchResult: Result<UserMarketingOptionsFetch?, Error> = .failure(MockError.valueNotSet)
    
    func clearMemberProfile() -> AnyPublisher<Bool, Error> {
        register(.clearMemberProfile)
        return clearMemberProfileResult.publish()
    }
    
    func store(memberProfile: MemberProfile, forStoreId storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        register(.store(memberProfile: memberProfile, forStoreId: storeId))
        return storeMemberProfileResult.publish()
    }
    
    func memberProfile(storeId: Int?) -> AnyPublisher<MemberProfile?, Error> {
        register(.memberProfile)
        return memberProfileResult.publish()
    }

    func clearAllFetchedUserMarketingOptions() -> AnyPublisher<Bool, Error> {
        register(.clearAllFetchedUserMarketingOptions)
        return clearAllFetchedUserMarketingOptionsResult.publish()
    }
    
    func clearFetchedUserMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> Bool {
        register(.clearFetchedUserMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        switch clearFetchedUserMarketingOptionsResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func store(marketingOptionsFetch: UserMarketingOptionsFetch, isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch {
        register(.store(marketingOptionsFetch: marketingOptionsFetch, isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        switch storeMarketingOptionsFetchResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func userMarketingOptionsFetch(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch? {
        register(.userMarketingOptionsFetch(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        switch userMarketingOptionsFetchResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

}

