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
        case addAddress(storeId: Int?, address: Address)
        case updateAddress(storeId: Int?, address: Address)
        case setDefaultAddress(storeId: Int?, addressId: Int)
        case removeAddress(storeId: Int?, addressId: Int)
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
        case updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var loginByEmailPasswordResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var logoutResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var getProfileResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var addAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var updateAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var setDefaultAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var removeAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var getPastOrdersResponse: Result<[PastOrder]?, Error> = .failure(MockError.valueNotSet)
    var getMarketingOptionsResponse: Result<UserMarketingOptionsFetch, Error> = .failure(MockError.valueNotSet)
    var updateMarketingOptionsResponse: Result<UserMarketingOptionsUpdateResponse, Error> = .failure(MockError.valueNotSet)

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
    
    func addAddress(storeId: Int?, address: Address) -> AnyPublisher<MemberProfile, Error> {
        register(.addAddress(storeId: storeId, address: address))
        return addAddressResponse.publish()
    }
    
    func updateAddress(storeId: Int?, address: Address) -> AnyPublisher<MemberProfile, Error> {
        register(.updateAddress(storeId: storeId, address: address))
        return updateAddressResponse.publish()
    }
    
    func setDefaultAddress(storeId: Int?, addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        register(.setDefaultAddress(storeId: storeId, addressId: addressId))
        return setDefaultAddressResponse.publish()
    }
    
    func removeAddress(storeId: Int?, addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        register(.removeAddress(storeId: storeId, addressId: addressId))
        return removeAddressResponse.publish()
    }
    
    func getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) -> AnyPublisher<[PastOrder]?, Error> {
        register(.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit))
        return getPastOrdersResponse.publish()
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) -> AnyPublisher<UserMarketingOptionsFetch, Error> {
        register(.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        return getMarketingOptionsResponse.publish()
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?) -> AnyPublisher<UserMarketingOptionsUpdateResponse, Error> {
        register(.updateMarketingOptions(options: options, basketToken: basketToken))
        return updateMarketingOptionsResponse.publish()
    }
}
