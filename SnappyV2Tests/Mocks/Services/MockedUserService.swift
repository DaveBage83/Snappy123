//
//  MockedUserService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 19/12/2021.
//

import XCTest
import Combine
import AuthenticationServices
@testable import SnappyV2

struct MockedUserService: Mock, UserServiceProtocol {
    enum Action: Equatable {
        case login(email: String, password: String)
        case login(email: String, oneTimePassword: String)
        case login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType)
        case loginWithFacebook(registeringFromScreen: RegisteringFromScreenType)
        case loginWithGoogle(registeringFromScreen: RegisteringFromScreenType)
        case resetPasswordRequest(email: String)
        case resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?)
        case register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?)
        case logout
        case getProfile(filterDeliveryAddresses: Bool)
        case updateProfile(firstname: String, lastname: String, mobileContactNumber: String)
        case addAddress(address: Address)
        case updateAddress(address: Address)
        case setDefaultAddress(addressId: Int)
        case removeAddress(addressId: Int)
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getPlacedOrder(businessOrderId: Int)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool)
        case updateMarketingOptions(options: [UserMarketingOptionRequest])
        case checkRegistrationStatus(email: String)
        case requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType)
        case restoreLastUser
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func login(email: String, password: String) async throws {
        register(.login(email: email, password: password))
    }
    
    func login(email: String, oneTimePassword: String) async throws -> Void {
        register(.login(email: email, oneTimePassword: oneTimePassword))
    }
    
    func restoreLastUser() async throws {
        register(.restoreLastUser)
    }
    
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) async throws {
        register(.login(appleSignInAuthorisation: appleSignInAuthorisation, registeringFromScreen: registeringFromScreen))
    }
    
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) async throws {
        register(.loginWithFacebook(registeringFromScreen: registeringFromScreen))
    }
    
    func loginWithGoogle(registeringFromScreen: RegisteringFromScreenType) async throws {
        register(.loginWithGoogle(registeringFromScreen: registeringFromScreen))
    }
    
    func resetPasswordRequest(email: String) async throws {
        register(.resetPasswordRequest(email: email))
    }
    
    func resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?) async throws {
        register(.resetPassword(resetToken: resetToken, logoutFromAll: logoutFromAll, email: email, password: password, currentPassword: currentPassword))
    }
    
    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) async throws {
        register(.register(member: member, password: password, referralCode: referralCode, marketingOptions: marketingOptions))
    }
    
    func logout() async throws {
        register(.logout)
    }
    
    func getProfile(filterDeliveryAddresses: Bool) async throws {
        register(.getProfile(filterDeliveryAddresses: filterDeliveryAddresses))
    }
    
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) -> Future<Void, Error> {
        register(.updateProfile(firstname: firstname, lastname: lastname, mobileContactNumber: mobileContactNumber))
        return Future { $0(.success(())) }
    }
    
    func addAddress(address: Address) -> Future<Void, Error> {
        register(.addAddress(address: address))
        return Future { $0(.success(())) }
    }
    
    func updateAddress(address: Address) -> Future<Void, Error> {
        register(.updateAddress(address: address))
        return Future { $0(.success(())) }
    }
    
    func setDefaultAddress(addressId: Int) -> Future<Void, Error> {
        register(.setDefaultAddress(addressId: addressId))
        return Future { $0(.success(())) }
    }
    
    func removeAddress(addressId: Int) -> Future<Void, Error> {
        register(.removeAddress(addressId: addressId))
        return Future { $0(.success(())) }
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) {
        register(.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit))
    }
    
    func getPlacedOrder(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int) {
        register(.getPlacedOrder(businessOrderId: businessOrderId))
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool) async throws -> UserMarketingOptionsFetch {
        register(.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled))
        return UserMarketingOptionsFetch(marketingPreferencesIntro: nil, marketingPreferencesGuestIntro: nil, marketingOptions: nil, fetchIsCheckout: nil, fetchNotificationsEnabled: nil, fetchBasketToken: nil, fetchTimestamp: nil)
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest]) async throws -> UserMarketingOptionsUpdateResponse {
        register(.updateMarketingOptions(options: options))
        return UserMarketingOptionsUpdateResponse(email: .out, directMail: .out, notification: .out, telephone: .out, sms: .out)
    }
    
    func checkRegistrationStatus(email: String) async throws -> CheckRegistrationResult {
        register(.checkRegistrationStatus(email: email))
        return CheckRegistrationResult.mockedData
    }
    
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult {
        register(.requestMessageWithOneTimePassword(email: email, type: type))
        return OneTimePasswordSendResult.mockedData
    }    
}
