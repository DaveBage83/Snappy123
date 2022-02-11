//
//  MockedUserWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 09/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedUserWebRepository: TestWebRepository, Mock, UserWebRepositoryProtocol {

    enum Action: Equatable {
        case login(email: String, password: String)
        case logout
        case getProfile(storeId: Int?)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
        case updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var loginByEmailPasswordResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var logoutResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var getProfileResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var getMarketingOptions: Result<UserMarketingOptionsFetch, Error> = .failure(MockError.valueNotSet)
    var updateMarketingOptions: Result<UserMarketingOptionsUpdateResponse, Error> = .failure(MockError.valueNotSet)

    func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        register(.login(email: email, password: password))
        return loginByEmailPasswordResponse.publish()
    }
    
    func logout() -> AnyPublisher<Bool, Error> {
        register(.logout)
        return logoutResponse.publish()
    }
    
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        register(.getProfile(storeId: storeId))
        return getProfileResponse.publish()
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) -> AnyPublisher<UserMarketingOptionsFetch, Error> {
        register(.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        return getMarketingOptions.publish()
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?) -> AnyPublisher<UserMarketingOptionsUpdateResponse, Error> {
        register(.updateMarketingOptions(options: options, basketToken: basketToken))
        return updateMarketingOptions.publish()
    }
}
