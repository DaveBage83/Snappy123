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
        case login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType)
        case loginWithFacebook(registeringFromScreen: RegisteringFromScreenType)
        case resetPasswordRequest(email: String)
        case register(member: MemberProfile, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?)
        case logout
        case getProfile(filterDeliveryAddresses: Bool)
        case updateProfile(firstname: String, lastname: String, mobileContactNumber: String)
        case addAddress(address: Address)
        case updateAddress(address: Address)
        case setDefaultAddress(addressId: Int)
        case removeAddress(addressId: Int)
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool)
        case updateMarketingOptions(options: [UserMarketingOptionRequest])
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func login(email: String, password: String) -> Future<Void, Error> {
        register(.login(email: email, password: password))
        return Future { $0(.success(())) }
    }
    
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error> {
        register(.login(appleSignInAuthorisation: appleSignInAuthorisation, registeringFromScreen: registeringFromScreen))
        return Future { $0(.success(())) }
    }
    
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error> {
        register(.loginWithFacebook(registeringFromScreen: registeringFromScreen))
        return Future { $0(.success(())) }
    }
    
    func resetPasswordRequest(email: String) -> Future<Void, Error> {
        register(.resetPasswordRequest(email: email))
        return Future { $0(.success(())) }
    }
    
    func register(member: MemberProfile, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) -> Future<Void, Error> {
        register(.register(member: member, password: password, referralCode: referralCode, marketingOptions: marketingOptions))
        return Future { $0(.success(())) }
    }
    
    func logout() -> Future<Void, Error> {
        register(.logout)
        return Future { $0(.success(())) }
    }
    
    func getProfile(profile: LoadableSubject<MemberProfile>, filterDeliveryAddresses: Bool) {
        register(.getProfile(filterDeliveryAddresses: filterDeliveryAddresses))
    }
    
    func updateProfile(profile: LoadableSubject<MemberProfile>, firstname: String, lastname: String, mobileContactNumber: String) {
        register(.updateProfile(firstname: firstname, lastname: lastname, mobileContactNumber: mobileContactNumber))
    }
    
    func addAddress(profile: LoadableSubject<MemberProfile>, address: Address) {
        register(.addAddress(address: address))
    }
    
    func updateAddress(profile: LoadableSubject<MemberProfile>, address: Address) {
        register(.updateAddress(address: address))
    }
    
    func setDefaultAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) {
        register(.setDefaultAddress(addressId: addressId))
    }
    
    func removeAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) {
        register(.removeAddress(addressId: addressId))
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) {
        register(.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit))
    }
    
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool) {
        register(.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled))
    }
    
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest]) {
        register(.updateMarketingOptions(options: options))
    }
    
}
