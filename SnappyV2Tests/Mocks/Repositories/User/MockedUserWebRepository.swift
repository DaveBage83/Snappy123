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
        case login(email: String, password: String, basketToken: String?)
        case login(email: String, oneTimePassword: String, basketToken: String?)
        case login(appleSignInToken: String, username: String?, firstname: String?, lastname: String?, basketToken: String?, registeringFromScreen: RegisteringFromScreenType)
        case login(facebookAccessToken: String, basketToken: String?, registeringFromScreen: RegisteringFromScreenType)
        case resetPasswordRequest(email: String)
        case resetPassword(resetToken: String?, logoutFromAll: Bool, password: String, currentPassword: String?)
        case register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?)
        case logout(basketToken: String?)
        case getProfile(storeId: Int?)
        case updateProfile(firstname: String, lastname: String, mobileContactNumber: String)
        case addAddress(address: Address)
        case updateAddress(address: Address)
        case setDefaultAddress(addressId: Int)
        case removeAddress(addressId: Int)
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getPlacedOrderDetails(forBusinessOrderId: Int)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
        case updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?)
        case clearNetworkSession
        case checkRegistrationStatus(email: String, basketToken: String)
        case requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType)
    }
    var actions = MockActions<Action>(expected: [])
    
    var loginByEmailPasswordResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var loginByEmailOneTimePasswordResponse: Result<Void, Error> = .failure(MockError.valueNotSet)
    var loginByAppleSignIn: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var loginByFacebook: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var resetPasswordRequestResponse: Result<Data, Error> = .failure(MockError.valueNotSet)
    var resetPasswordResponse: Result<UserSuccessResult, Error> = .failure(MockError.valueNotSet)
    var registerResponse: Result<Data, Error> = .failure(MockError.valueNotSet)
    var logoutResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var getProfileResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var updateProfileResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var addAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var updateAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var setDefaultAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var removeAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var getPastOrdersResponse: Result<[PlacedOrder]?, Error> = .failure(MockError.valueNotSet)
    var getPlacedOrderDetailsResponse: Result<PlacedOrder, Error> = .failure(MockError.valueNotSet)
    var getMarketingOptionsResponse: Result<UserMarketingOptionsFetch, Error> = .failure(MockError.valueNotSet)
    var updateMarketingOptionsResponse: Result<UserMarketingOptionsUpdateResponse, Error> = .failure(MockError.valueNotSet)
    var checkRegistrationStatusResponse: Result<CheckRegistrationResult, Error> = .failure(MockError.valueNotSet)
    var requestMessageWithOneTimePasswordResponse: Result<OneTimePasswordSendResult, Error> = .failure(MockError.valueNotSet)

    func login(email: String, password: String, basketToken: String?) -> AnyPublisher<Bool, Error> {
        register(.login(email: email, password: password, basketToken: basketToken))
        return loginByEmailPasswordResponse.publish()
    }
    
    func login(email: String, oneTimePassword: String, basketToken: String?) async throws {
        register(.login(email: email, oneTimePassword: oneTimePassword, basketToken: basketToken))
        switch loginByEmailOneTimePasswordResponse {
        case .success:
            break
        case let .failure(error):
            throw error
        }
    }
    
    func login(appleSignInToken: String, username: String?, firstname: String?, lastname: String?, basketToken: String?, registeringFromScreen: RegisteringFromScreenType) -> AnyPublisher<Bool, Error> {
        register(.login(appleSignInToken: appleSignInToken, username: username, firstname: firstname, lastname: lastname, basketToken: basketToken, registeringFromScreen: registeringFromScreen))
        return loginByAppleSignIn.publish()
    }
    
    func login(facebookAccessToken: String, basketToken: String?, registeringFromScreen: RegisteringFromScreenType) -> AnyPublisher<Bool, Error> {
        register(.login(facebookAccessToken: facebookAccessToken, basketToken: basketToken, registeringFromScreen: registeringFromScreen))
        return loginByFacebook.publish()
    }
    
    func resetPasswordRequest(email: String) -> AnyPublisher<Data, Error> {
        register(.resetPasswordRequest(email: email))
        return resetPasswordRequestResponse.publish()
    }
    
    func resetPassword(resetToken: String?, logoutFromAll: Bool, password: String, currentPassword: String?) -> AnyPublisher<UserSuccessResult, Error> {
        register(.resetPassword(resetToken: resetToken, logoutFromAll: logoutFromAll, password: password, currentPassword: currentPassword))
        return resetPasswordResponse.publish()
    }
    
    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) -> AnyPublisher<Data, Error> {
        register(.register(member: member, password: password, referralCode: referralCode, marketingOptions: marketingOptions))
        return registerResponse.publish()
    }
    
    func logout(basketToken: String?) -> AnyPublisher<Bool, Error> {
        register(.logout(basketToken: basketToken))
        return logoutResponse.publish()
    }
    
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        register(.getProfile(storeId: storeId))
        return getProfileResponse.publish()
    }
    
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) -> AnyPublisher<MemberProfile, Error> {
        register(.updateProfile(firstname: firstname, lastname: lastname, mobileContactNumber: mobileContactNumber))
        return updateProfileResponse.publish()
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
    
    func getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) -> AnyPublisher<[PlacedOrder]?, Error> {
        register(.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit))
        return getPastOrdersResponse.publish()
    }
    
    func getPlacedOrderDetails(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrder, Error> {
        register(
            .getPlacedOrderDetails(forBusinessOrderId: businessOrderId)
        )
        return getPlacedOrderDetailsResponse.publish()
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch {
        register(.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken))
        switch getMarketingOptionsResponse {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?) async throws -> UserMarketingOptionsUpdateResponse {
        register(.updateMarketingOptions(options: options, basketToken: basketToken))
        switch updateMarketingOptionsResponse {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func clearNetworkSession() {
        register(.clearNetworkSession)
    }
    
    func checkRegistrationStatus(email: String, basketToken: String) async throws -> CheckRegistrationResult {
        register(.checkRegistrationStatus(email: email, basketToken: basketToken))
        switch checkRegistrationStatusResponse {
        case let .success(result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult {
        register(.requestMessageWithOneTimePassword(email: email, type: type))
        switch requestMessageWithOneTimePasswordResponse {
        case let .success(result):
            return result
        case let .failure(error):
            throw error
        }
    }
}
