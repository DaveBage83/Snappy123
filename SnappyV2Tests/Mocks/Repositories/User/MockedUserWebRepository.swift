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
        case login(googleAccessToken: String, basketToken: String?, registeringFromScreen: RegisteringFromScreenType)
        case resetPasswordRequest(email: String)
        case resetPassword(resetToken: String?, logoutFromAll: Bool, password: String, currentPassword: String?)
        case register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?)
        case setToken(to: ApiAuthenticationResult)
        case logout(basketToken: String?)
        case getProfile(storeId: Int?)
        case updateProfile(firstname: String, lastname: String, mobileContactNumber: String)
        case addAddress(address: Address)
        case updateAddress(address: Address)
        case setDefaultAddress(addressId: Int)
        case removeAddress(addressId: Int)
        case getSavedCards
        case saveNewCard(token: String)
        case deleteCard(id: String)
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getPlacedOrderDetails(forBusinessOrderId: Int)
        case getDriverSessionSettings(withKnownV1SessionToken: String?)
        case requestMobileVerificationCode
        case checkMobileVerificationCode(verificationCode: String)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?)
        case updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?, channel: Int?)
        case clearNetworkSession
        case checkRegistrationStatus(email: String, basketToken: String)
        case requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType)
        case checkRetailMembershipId(basketToken: String)
        case storeRetailMembershipId(storeId: Int, basketToken: String, retailMemberId: String)
    }
    var actions = MockActions<Action>(expected: [])
    
    var loginByEmailPasswordResponse: Result<LoginResult, Error> = .failure(MockError.valueNotSet)
    var loginByEmailOneTimePasswordResponse: Result<LoginResult, Error> = .failure(MockError.valueNotSet)
    var loginByAppleSignInResponse: Result<LoginResult, Error> = .failure(MockError.valueNotSet)
    var loginByFacebookResponse: Result<LoginResult, Error> = .failure(MockError.valueNotSet)
    var loginByGoogleSignInResponse: Result<LoginResult, Error> = .failure(MockError.valueNotSet)
    var resetPasswordRequestResponse: Result<Data, Error> = .failure(MockError.valueNotSet)
    var resetPasswordResponse: Result<UserSuccessResult, Error> = .failure(MockError.valueNotSet)
    var registerResponse: Result<UserRegistrationResult, Error> = .failure(MockError.valueNotSet)
    var logoutResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var getProfileResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var updateProfileResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var addAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var updateAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var setDefaultAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var removeAddressResponse: Result<MemberProfile, Error> = .failure(MockError.valueNotSet)
    var getSavedCardsResponse: Result<[MemberCardDetails], Error> = .failure(MockError.valueNotSet)
    var saveNewCardResponse: Result<MemberCardDetails, Error> = .failure(MockError.valueNotSet)
    var deleteCardResponse: Result<CardDeleteResponse, Error> = .failure(MockError.valueNotSet)
    var getPastOrdersResponse: Result<[PlacedOrderSummary]?, Error> = .failure(MockError.valueNotSet)
    var getPlacedOrderDetailsResponse: Result<PlacedOrder, Error> = .failure(MockError.valueNotSet)
    var getDriverSessionSettingsResponse: Result<DriverSessionSettings, Error> = .failure(MockError.valueNotSet)
    var requestMobileVerificationCodeResponse: Result<RequestMobileVerificationCodeResult, Error> = .failure(MockError.valueNotSet)
    var checkMobileVerificationCodeResponse: Result<CheckMobileVerificationCodeResult, Error> = .failure(MockError.valueNotSet)
    var getMarketingOptionsResponse: Result<UserMarketingOptionsFetch, Error> = .failure(MockError.valueNotSet)
    var updateMarketingOptionsResponse: Result<UserMarketingOptionsUpdateResponse, Error> = .failure(MockError.valueNotSet)
    var checkRegistrationStatusResponse: Result<CheckRegistrationResult, Error> = .failure(MockError.valueNotSet)
    var requestMessageWithOneTimePasswordResponse: Result<OneTimePasswordSendResult, Error> = .failure(MockError.valueNotSet)
    var checkRetailMembershipIdResponse: Result<CheckRetailMembershipIdResult, Error> = .failure(MockError.valueNotSet)
    var storeRetailMembershipIdResponse: Result<StoreRetailMembershipIdResult, Error> = .failure(MockError.valueNotSet)

    func login(email: String, password: String, basketToken: String?) async throws -> LoginResult {
        register(.login(email: email, password: password, basketToken: basketToken))
        switch loginByEmailPasswordResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func login(email: String, oneTimePassword: String, basketToken: String?) async throws -> LoginResult {
        register(.login(email: email, oneTimePassword: oneTimePassword, basketToken: basketToken))
        switch loginByEmailOneTimePasswordResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func login(appleSignInToken: String, username: String?, firstname: String?, lastname: String?, basketToken: String?, registeringFromScreen: RegisteringFromScreenType) async throws -> LoginResult {
        register(.login(appleSignInToken: appleSignInToken, username: username, firstname: firstname, lastname: lastname, basketToken: basketToken, registeringFromScreen: registeringFromScreen))
        switch loginByAppleSignInResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func login(facebookAccessToken: String, basketToken: String?, registeringFromScreen: RegisteringFromScreenType) async throws -> LoginResult {
        register(.login(facebookAccessToken: facebookAccessToken, basketToken: basketToken, registeringFromScreen: registeringFromScreen))
        switch loginByAppleSignInResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func login(googleAccessToken: String, basketToken: String?, registeringFromScreen: RegisteringFromScreenType) async throws -> LoginResult {
        register(.login(googleAccessToken: googleAccessToken, basketToken: basketToken, registeringFromScreen: registeringFromScreen))
        switch loginByAppleSignInResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func resetPasswordRequest(email: String) -> AnyPublisher<Data, Error> {
        register(.resetPasswordRequest(email: email))
        return resetPasswordRequestResponse.publish()
    }
    
    func resetPassword(resetToken: String?, logoutFromAll: Bool, password: String, currentPassword: String?) -> AnyPublisher<UserSuccessResult, Error> {
        register(.resetPassword(resetToken: resetToken, logoutFromAll: logoutFromAll, password: password, currentPassword: currentPassword))
        return resetPasswordResponse.publish()
    }
    
    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) async throws -> UserRegistrationResult {
        register(.register(member: member, password: password, referralCode: referralCode, marketingOptions: marketingOptions))
        switch registerResponse {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func setToken(to token: ApiAuthenticationResult) {
        register(.setToken(to: token))
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
    
    func getSavedCards() async throws -> [MemberCardDetails] {
        register(.getSavedCards)
        return try await getSavedCardsResponse.publish().singleOutput()
    }
    
    func saveNewCard(token: String) async throws -> MemberCardDetails {
        register(.saveNewCard(token: token))
        return try await saveNewCardResponse.publish().singleOutput()
    }
    
    func deleteCard(id: String) async throws -> CardDeleteResponse {
        register(.deleteCard(id: id))
        return try await deleteCardResponse.publish().singleOutput()
    }
    
    func getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) -> AnyPublisher<[PlacedOrderSummary]?, Error> {
        register(.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit))
        return getPastOrdersResponse.publish()
    }
    
    func getPlacedOrderDetails(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrder, Error> {
        register(
            .getPlacedOrderDetails(forBusinessOrderId: businessOrderId)
        )
        return getPlacedOrderDetailsResponse.publish()
    }
    
    func getDriverSessionSettings(withKnownV1SessionToken token: String?) async throws -> DriverSessionSettings {
        register(.getDriverSessionSettings(withKnownV1SessionToken: token))
        switch getDriverSessionSettingsResponse {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func requestMobileVerificationCode() async throws -> RequestMobileVerificationCodeResult {
        register(.requestMobileVerificationCode)
        switch requestMobileVerificationCodeResponse {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func checkMobileVerificationCode(verificationCode: String) async throws -> CheckMobileVerificationCodeResult {
        register(.checkMobileVerificationCode(verificationCode: verificationCode))
        switch checkMobileVerificationCodeResponse {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
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
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?, channel: Int?) async throws -> UserMarketingOptionsUpdateResponse {
        register(.updateMarketingOptions(options: options, basketToken: basketToken, channel: channel))
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
    
    func checkRetailMembershipId(basketToken: String) async throws -> CheckRetailMembershipIdResult {
        register(.checkRetailMembershipId(basketToken: basketToken))
        switch checkRetailMembershipIdResponse {
        case let .success(result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
    func storeRetailMembershipId(storeId: Int, basketToken: String, retailMemberId: String) async throws -> StoreRetailMembershipIdResult {
        register(.storeRetailMembershipId(storeId: storeId, basketToken: basketToken, retailMemberId: retailMemberId))
        switch storeRetailMembershipIdResponse {
        case let .success(result):
            return result
        case let .failure(error):
            throw error
        }
    }
}
