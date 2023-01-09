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

struct MockedUserService: Mock, MemberServiceProtocol {
    var getPlacedOrderResult = PlacedOrder.mockedData
    
    enum Action: Equatable {
        case login(email: String, password: String, atCheckout: Bool)
        case login(email: String, oneTimePassword: String, atCheckout: Bool)
        case login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType)
        case loginWithFacebook(registeringFromScreen: RegisteringFromScreenType)
        case loginWithGoogle(registeringFromScreen: RegisteringFromScreenType)
        case resetPasswordRequest(email: String)
        case resetPasswordAndSignIn(resetToken: String, logoutFromAll: Bool, password: String, atCheckout: Bool)
        case register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?, atCheckout: Bool)
        case changePassword(logoutFromAll: Bool, password: String, currentPassword: String)
        case logout
        case getProfile(filterDeliveryAddresses: Bool, loginContext: LoginContext?)
        case updateProfile(firstname: String, lastname: String, mobileContactNumber: String)
        case addAddress(address: Address)
        case updateAddress(address: Address)
        case setDefaultAddress(addressId: Int)
        case removeAddress(addressId: Int)
        case getSavedCards
        case saveNewCard(token: String)
        case deleteCard(id: String)
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getPlacedOrder(businessOrderId: Int)
        case getDriverSessionSettings
        case requestMobileVerificationCode
        case checkMobileVerificationCode(verificationCode: String)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool)
        case updateMarketingOptions(options: [UserMarketingOptionRequest], channel: Int?)
        case checkRegistrationStatus(email: String)
        case requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType)
        case restoreLastUser
        case checkRetailMembershipId
        case storeRetailMembershipId(retailMemberId: String)
        case sendForgetMemberCode
        case forgetMember(code: String)
    }
    
    let actions: MockActions<Action>
    
    var requestMobileVerificationCodeResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var checkMobileVerificationCodeResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var checkRetailMembershipIdResponse: Result<CheckRetailMembershipIdResult, Error> = .failure(MockError.valueNotSet)
    var storeRetailMembershipIdResponse: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var sendForgetCode: Result<ForgetMemberCodeRequestResult, Error> = .failure(MockError.valueNotSet)
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func login(email: String, password: String, atCheckout: Bool) async throws {
        register(.login(email: email, password: password, atCheckout: atCheckout))
    }
    
    func login(email: String, oneTimePassword: String, atCheckout: Bool) async throws -> Void {
        register(.login(email: email, oneTimePassword: oneTimePassword, atCheckout: atCheckout))
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
    
    func resetPasswordAndSignIn(resetToken: String, logoutFromAll: Bool, password: String, atCheckout: Bool) async throws {
        register(.resetPasswordAndSignIn(resetToken: resetToken, logoutFromAll: logoutFromAll, password: password, atCheckout: atCheckout))
    }
    
    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?, atCheckout: Bool) async throws -> Bool {
        register(.register(member: member, password: password, referralCode: referralCode, marketingOptions: marketingOptions, atCheckout: atCheckout))
        return false
    }
    
    func changePassword(logoutFromAll: Bool, password: String, currentPassword: String) async throws {
        register(.changePassword(logoutFromAll: logoutFromAll, password: password, currentPassword: currentPassword))
    }
    
    func logout() async throws {
        register(.logout)
    }
    
    func getProfile(filterDeliveryAddresses: Bool, loginContext: LoginContext?) async throws {
        register(.getProfile(filterDeliveryAddresses: filterDeliveryAddresses, loginContext: loginContext))
    }
    
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) async throws {
        register(.updateProfile(firstname: firstname, lastname: lastname, mobileContactNumber: mobileContactNumber))
    }
    
    func addAddress(address: Address) async throws {
        register(.addAddress(address: address))
    }
    
    func updateAddress(address: Address) async throws {
        register(.updateAddress(address: address))
    }
    
    func setDefaultAddress(addressId: Int) async throws {
        register(.setDefaultAddress(addressId: addressId))
    }
    
    func removeAddress(addressId: Int) async throws {
        register(.removeAddress(addressId: addressId))
    }
    
    func getSavedCards() async throws -> [MemberCardDetails] {
        register(.getSavedCards)
        return []
    }
    
    func saveNewCard(token: String) async throws {
        register(.saveNewCard(token: token))
    }
    
    func deleteCard(id: String) async throws {
        register(.deleteCard(id: id))
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrderSummary]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) async {
        register(.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit))
    }
    
    func getPlacedOrder(businessOrderId: Int) async -> PlacedOrder {
        register(.getPlacedOrder(businessOrderId: businessOrderId))
        return getPlacedOrderResult
    }

    func getDriverSessionSettings() async throws -> DriverSessionSettings {
        register(.getDriverSessionSettings)
        return DriverSessionSettings.mockedData
    }
    
    func requestMobileVerificationCode() async throws -> Bool {
        register(.requestMobileVerificationCode)
        switch requestMobileVerificationCodeResponse {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func checkMobileVerificationCode(verificationCode: String) async throws {
        register(.checkMobileVerificationCode(verificationCode: verificationCode))
        switch checkMobileVerificationCodeResponse {
        case .failure(let error):
            throw error
        default:
            break
        }
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool) async throws -> UserMarketingOptionsFetch {
        register(.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled))
        return UserMarketingOptionsFetch(marketingPreferencesIntro: nil, marketingPreferencesGuestIntro: nil, marketingOptions: nil, fetchIsCheckout: nil, fetchNotificationsEnabled: nil, fetchBasketToken: nil, fetchTimestamp: nil)
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], channel: Int?) async throws -> UserMarketingOptionsUpdateResponse {
        register(.updateMarketingOptions(options: options, channel: channel))
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
    
    func checkRetailMembershipId() async throws -> CheckRetailMembershipIdResult {
        register(.checkRetailMembershipId)
        switch checkRetailMembershipIdResponse {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func storeRetailMembershipId(retailMemberId: String) async throws {
        register(.storeRetailMembershipId(retailMemberId: retailMemberId))
        switch storeRetailMembershipIdResponse {
        case .failure(let error):
            throw error
        default:
            break
        }
    }
    
    func sendForgetCode() async throws -> SnappyV2.ForgetMemberCodeRequestResult {
        register(.sendForgetMemberCode)
        return .init(success: true, message_title: nil, message: nil)
    }
    
    func forgetMember(confirmationCode: String) async throws -> ForgetMemberRequestResult {
        register(.forgetMember(code: confirmationCode
                              ))
        return ForgetMemberRequestResult(success: true, errors: nil)
    }
}
