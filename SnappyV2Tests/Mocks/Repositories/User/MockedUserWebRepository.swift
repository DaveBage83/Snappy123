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
        case register(member: MemberProfile, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?)
        case logout
        case getProfile(storeId: Int?)
        case addAddress(address: Address)
        case updateAddress(address: Address)
        case setDefaultAddress(addressId: Int)
        case removeAddress(addressId: Int)
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
        case updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var loginByEmailPasswordResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var registerResponse: Result<Data, Error> = .failure(MockError.valueNotSet)
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
    
    func register(member: MemberProfile, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) -> AnyPublisher<Data, Error> {
        register(.register(member: member, password: password, referralCode: referralCode, marketingOptions: marketingOptions))
        return registerResponse.publish()
    }
    
    func logout() -> AnyPublisher<Bool, Error> {
        register(.logout)
        return logoutResponse.publish()
    }
    
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        register(.getProfile(storeId: storeId))
        return getProfileResponse.publish()
    }
    
    func addAddress(address: Address) -> AnyPublisher<MemberProfile, Error> {
        register(.addAddress(address: address))
        return addAddressResponse.publish()
    }
    
    func updateAddress(address: Address) -> AnyPublisher<MemberProfile, Error> {
        register(.updateAddress(address: address))
        return updateAddressResponse.publish()
    }
    
    func setDefaultAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        register(.setDefaultAddress(addressId: addressId))
        return setDefaultAddressResponse.publish()
    }
    
    func removeAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        register(.removeAddress(addressId: addressId))
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
