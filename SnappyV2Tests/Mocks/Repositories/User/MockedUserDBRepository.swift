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
        case store(memberProfile: MemberProfile)
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
    
    func store(memberProfile: MemberProfile) -> AnyPublisher<MemberProfile, Error> {
        register(.store(memberProfile: memberProfile))
        return storeMemberProfileResult.publish()
    }
    
    func memberProfile() -> AnyPublisher<MemberProfile?, Error> {
        register(.memberProfile)
        return memberProfileResult.publish()
    }

    func clearAllFetchedUserMarketingOptions() -> AnyPublisher<Bool, Error> {
        register(.clearAllFetchedUserMarketingOptions)
        return clearAllFetchedUserMarketingOptionsResult.publish()
    }
    
    func clearFetchedUserMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) -> AnyPublisher<Bool, Error> {
        register(.clearFetchedUserMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        return clearFetchedUserMarketingOptionsResult.publish()
    }
    
    func store(marketingOptionsFetch: UserMarketingOptionsFetch, isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) -> AnyPublisher<UserMarketingOptionsFetch, Error> {
        register(.store(marketingOptionsFetch: marketingOptionsFetch, isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        return storeMarketingOptionsFetchResult.publish()
    }
    
    func userMarketingOptionsFetch(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) -> AnyPublisher<UserMarketingOptionsFetch?, Error> {
        register(.userMarketingOptionsFetch(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        return userMarketingOptionsFetchResult.publish()
    }

}

