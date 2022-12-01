//
//  UserWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Foundation
import Combine

// General Note:
// (a) Parameter requirement checking (PRC) could be at higher point in the call chain, e.g. in RetailStoresService
// public or helper methods. We could also try an map it to server responses. In the end we (Henrik|Kevin) decided
// to have it at this web repository level because:
// - parent calling methods might easily omit the checks if their implementation is updated
// - the web repository is nearer to the business logic and PRC is based on this logic
// - the server responses vary and don't always adhere to APIErrorResult structure or http codes

protocol UserWebRepositoryProtocol: WebRepository {
    
    func login(
        email: String,
        password: String,
        basketToken: String?,
        notificationDeviceToken: String?
    ) async throws -> LoginResult
    func login(
        email: String,
        oneTimePassword: String,
        basketToken: String?,
        notificationDeviceToken: String?
    ) async throws -> LoginResult
    func login(
        appleSignInToken: String,
        username: String?,
        firstname: String?,
        lastname: String?,
        basketToken: String?,
        notificationDeviceToken: String?,
        registeringFromScreen: RegisteringFromScreenType
    ) async throws -> LoginResult
    func login(
        facebookAccessToken: String,
        basketToken: String?,
        notificationDeviceToken: String?,
        registeringFromScreen: RegisteringFromScreenType
    ) async throws -> LoginResult
    func login(
        googleAccessToken: String,
        basketToken: String?,
        notificationDeviceToken: String?,
        registeringFromScreen: RegisteringFromScreenType
    ) async throws -> LoginResult
    
    func resetPasswordRequest(email: String) -> AnyPublisher<Data, Error>
    func resetPassword(
        logoutFromAll: Bool,
        password: String,
        currentPassword: String
    ) -> AnyPublisher<UserSuccessResult, Error>
    func resetPasswordAndSignIn(
        resetToken: String,
        logoutFromAll: Bool,
        password: String
    ) -> AnyPublisher<Bool, Error>
    func register(
        member: MemberProfileRegisterRequest,
        password: String,
        referralCode: String?,
        marketingOptions: [UserMarketingOptionResponse]?
    ) async throws -> UserRegistrationResult
    func setToken(to: ApiAuthenticationResult)
    func logout(basketToken: String?, notificationDeviceToken: String?) -> AnyPublisher<Bool, Error>
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error>
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) -> AnyPublisher<MemberProfile, Error>
    func addAddress(address: Address) -> AnyPublisher<MemberProfile, Error>
    func updateAddress(address: Address) -> AnyPublisher<MemberProfile, Error>
    func setDefaultAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error>
    func removeAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error>
    
    func getSavedCards() async throws -> [MemberCardDetails]
    func saveNewCard(token: String) async throws -> MemberCardDetails
    func deleteCard(id: String) async throws -> CardDeleteResponse
    
    func getPastOrders(
        dateFrom: String?,
        dateTo: String?,
        status: String?,
        page: Int?,
        limit: Int?
    ) -> AnyPublisher<[PlacedOrderSummary]?, Error>

    func getPlacedOrderDetails(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrder, Error>
    func getDriverSessionSettings(withKnownV1SessionToken: String?) async throws -> DriverSessionSettings
    func requestMobileVerificationCode() async throws -> RequestMobileVerificationCodeResult
    func checkMobileVerificationCode(verificationCode: String) async throws -> CheckMobileVerificationCodeResult
    func checkRetailMembershipId(basketToken: String) async throws -> CheckRetailMembershipIdResult
    func storeRetailMembershipId(storeId: Int, basketToken: String, retailMemberId: String) async throws -> StoreRetailMembershipIdResult
    
    // do not need a member signed in
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?, channel: Int?) async throws -> UserMarketingOptionsUpdateResponse
    func checkRegistrationStatus(email: String, basketToken: String) async throws -> CheckRegistrationResult
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult
    
    func clearNetworkSession()
}

struct UserWebRepository: UserWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func login(
        email: String,
        password: String,
        basketToken: String?,
        notificationDeviceToken: String?
    ) async throws -> LoginResult {
        // required parameters
        var parameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "scope": "*",
            "username": email,
            "password": password,
            "grant_type": "password"
        ]
        
        // optional paramters
        if let basketToken {
            parameters["basketToken"] = basketToken
        }
        if let notificationDeviceToken {
            parameters["platform"] = AppV2Constants.Client.platform
            parameters["messagingDeviceId"] = notificationDeviceToken
        }
        
        return try await call(endpoint: API.login(parameters)).singleOutput()
    }
    
    func login(
        appleSignInToken: String,
        username: String?,
        firstname: String?,
        lastname: String?,
        basketToken: String?,
        notificationDeviceToken: String?,
        registeringFromScreen: RegisteringFromScreenType
    ) async throws -> LoginResult {
        // required parameters
        var parameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "scope": "*",
            "access_token": appleSignInToken,
            "registeringFromScreen": registeringFromScreen.rawValue,
            "platform": AppV2Constants.Client.platform,
            "provider": "apple",
            "grant_type": "custom_request"
        ]
        
        // optional paramters
        if let username {
            parameters["username"] = username
        }
        if let firstname {
            parameters["firstname"] = firstname
        }
        if let lastname {
            parameters["lastname"] = lastname
        }
        if let basketToken {
            parameters["basketToken"] = basketToken
        }
        if let notificationDeviceToken {
            parameters["platform"] = AppV2Constants.Client.platform
            parameters["messagingDeviceId"] = notificationDeviceToken
        }
        
        return try await call(endpoint: API.login(parameters)).singleOutput()
    }
    
    func login(
        facebookAccessToken: String,
        basketToken: String?,
        notificationDeviceToken: String?,
        registeringFromScreen: RegisteringFromScreenType
    ) async throws -> LoginResult {
        // required parameters
        var parameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "scope": "*",
            "access_token": facebookAccessToken,
            "registeringFromScreen": registeringFromScreen.rawValue,
            "platform": AppV2Constants.Client.platform,
            "provider": "facebook",
            "grant_type": "custom_request"
        ]
        
        // optional paramters
        if let basketToken {
            parameters["basketToken"] = basketToken
        }
        if let notificationDeviceToken {
            parameters["platform"] = AppV2Constants.Client.platform
            parameters["messagingDeviceId"] = notificationDeviceToken
        }
        
        return try await call(endpoint: API.login(parameters)).singleOutput()
    }
    
    func login(
        googleAccessToken: String,
        basketToken: String?,
        notificationDeviceToken: String?,
        registeringFromScreen: RegisteringFromScreenType
    ) async throws -> LoginResult {
        // required parameters
        var parameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "scope": "*",
            "id_token": googleAccessToken,
            "registeringFromScreen": registeringFromScreen.rawValue,
            "platform": AppV2Constants.Client.platform,
            "provider": "google",
            "grant_type": "custom_request"
        ]
        
        // optional paramters
        if let basketToken {
            parameters["basketToken"] = basketToken
        }
        if let notificationDeviceToken {
            parameters["platform"] = AppV2Constants.Client.platform
            parameters["messagingDeviceId"] = notificationDeviceToken
        }
        
        return try await call(endpoint: API.login(parameters)).singleOutput()
    }
    
    func login(
        email: String,
        oneTimePassword: String,
        basketToken: String?,
        notificationDeviceToken: String?
    ) async throws -> LoginResult {
        // required parameters
        var parameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "scope": "*",
            "username": email,
            "platform": AppV2Constants.Client.platform,
            "password": oneTimePassword,
            "provider": "otp",
            "grant_type": "custom_request"
        ]
        
        // optional paramters
        if let basketToken {
            parameters["basketToken"] = basketToken
        }
        if let notificationDeviceToken {
            parameters["platform"] = AppV2Constants.Client.platform
            parameters["messagingDeviceId"] = notificationDeviceToken
        }

        return try await call(endpoint: API.login(parameters)).singleOutput()
    }
    
    func resetPasswordRequest(email: String) -> AnyPublisher<Data, Error> {
        // required parameters
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "email": email,
            "platform": AppV2Constants.Client.platform
        ]
        
        return call(endpoint: API.resetPasswordRequest(parameters))
    }
    
    func resetPassword(email: String) -> AnyPublisher<UserSuccessResult, Error> {
        // required parameters
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "email": email,
            "platform": AppV2Constants.Client.platform
        ]
        
        return call(endpoint: API.resetPasswordRequest(parameters))
    }
    
    func resetPasswordAndSignIn(
        resetToken: String,
        logoutFromAll: Bool,
        password: String
    ) -> AnyPublisher<Bool, Error> {
        
        let parameters: [String: Any] = [
            "logoutFromAll": logoutFromAll,
            "resetToken": resetToken,
            "password": password
        ]
        
        return networkHandler.resetPasswordAndSignIn(
            connectionTimeout: AppV2Constants.API.connectionTimeout,
            parameters: parameters
        )
    }
    
    func resetPassword(
        logoutFromAll: Bool,
        password: String,
        currentPassword: String
    ) -> AnyPublisher<UserSuccessResult, Error> {

        let parameters: [String: Any] = [
            "logoutFromAll": logoutFromAll,
            "password": password,
            "currentPassword": currentPassword
        ]
        
        return call(endpoint: API.resetPassword(parameters))
    }
    
    func register(
        member: MemberProfileRegisterRequest,
        password: String,
        referralCode: String?,
        marketingOptions: [UserMarketingOptionResponse]?
    ) async throws -> UserRegistrationResult {
        // required parameters
        var parameters: [String: Any] = [
            "email": member.emailAddress,
            "password": password,
            "firstname": member.firstname,
            "lastname": member.lastname,
            "mobileContactNumber": member.mobileContactNumber ?? "",
            "platform": AppV2Constants.Client.platform,
            // required so that an access token can be generated
            // rather than needing to login as a separate call
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret
        ]
        
        // optional paramters
        if let defaultBillingDetails = member.defaultBillingDetails {
            var defaultBillingAddress: [String: Any] = [
                "addressline1": defaultBillingDetails.addressLine1,
                "town": defaultBillingDetails.town,
                "postcode": defaultBillingDetails.postcode,
                "countryCode": defaultBillingDetails.countryCode ?? ""
            ]
            if let addressName = defaultBillingDetails.addressName {
                defaultBillingAddress["addressName"] = addressName
            }
            if
                let firstName = defaultBillingDetails.firstName,
                firstName.isEmpty == false
            {
                defaultBillingAddress["firstname"] = firstName
            } else {
                defaultBillingAddress["firstname"] = member.firstname
            }
            if
                let lastName = defaultBillingDetails.lastName,
                lastName.isEmpty == false
            {
                defaultBillingAddress["lastname"] = lastName
            } else {
                defaultBillingAddress["lastname"] = member.lastname
            }
            if let addressLine2 = defaultBillingDetails.addressLine2 {
                defaultBillingAddress["addressline2"] = addressLine2
            }
            if let county = defaultBillingDetails.county {
                defaultBillingAddress["county"] = county
            }
            parameters["defaultBillingAddress"] = defaultBillingAddress
        }
        
        if let referralCode = referralCode {
            parameters["referralCode"] = referralCode
        }
        
        if
            let savedAddresses = member.savedAddresses,
            savedAddresses.count != 0
        {
            // use the first delivery address
            for savedAddress in savedAddresses where savedAddress.type == .delivery {
                var defaultDeliveryAddress: [String: Any] = [
                    "addressline1": savedAddress.addressLine1,
                    "town": savedAddress.town,
                    "postcode": savedAddress.postcode,
                    "countryCode": savedAddress.countryCode ?? ""
                ]
                if let addressName = savedAddress.addressName {
                    defaultDeliveryAddress["addressName"] = addressName
                }
                if
                    let firstName = savedAddress.firstName,
                    firstName.isEmpty == false
                {
                    defaultDeliveryAddress["firstname"] = firstName
                }
                if
                    let lastName = savedAddress.lastName,
                    lastName.isEmpty == false
                {
                    defaultDeliveryAddress["lastname"] = lastName
                }
                if let addressLine2 = savedAddress.addressLine2 {
                    defaultDeliveryAddress["addressline2"] = addressLine2
                }
                if let county = savedAddress.county {
                    defaultDeliveryAddress["county"] = county
                }
                parameters["defaultDeliveryAddress"] = defaultDeliveryAddress
                break
            }
        }

        if
            let marketingOptions = marketingOptions,
            marketingOptions.count != 0
        {
            let marketingPreferences: [String: UserMarketingOptionState] = marketingOptions.reduce([:], { (dict, preference) -> [String: UserMarketingOptionState] in
                var dict = dict
                dict[preference.type] = preference.opted
                return dict
            })
            parameters["marketingPreferences"] = marketingPreferences
        }
        
        return try await call(endpoint: API.register(parameters)).singleOutput()
    }
    
    func setToken(to token: ApiAuthenticationResult) {
        return networkHandler.setAccessToken(to: token)
    }
    
    func logout(basketToken: String?, notificationDeviceToken: String?) -> AnyPublisher<Bool, Error> {

        var parameters: [String: Any] = [:]
        // optional paramters
        if let basketToken {
            parameters["basketToken"] = basketToken
        }
        if let notificationDeviceToken {
            parameters["platform"] = AppV2Constants.Client.platform
            parameters["messagingDeviceId"] = notificationDeviceToken
        }
        
        return networkHandler.signOut(
            connectionTimeout: AppV2Constants.API.connectionTimeout,
            parameters: parameters
        )
    }
    
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        var parameters: [String: Any] = [:]
        
        // optional paramters
        if let storeId = storeId {
            parameters["storeId"] = storeId
        }
        return call(endpoint: API.getProfile(parameters))
    }
    
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "firstname": firstname,
            "lastname": lastname,
            "mobileContactNumber": mobileContactNumber
        ]

        return call(endpoint: API.updateProfile(parameters))
    }
    
    func addAddress(address: Address) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "isDefault": address.isDefault ?? false,
            "addressline1": address.addressLine1,
            "town": address.town,
            "postcode": address.postcode,
            "countryCode": address.countryCode ?? "",
            "type": address.type.rawValue
        ]
        
        // optional paramters
        if let addressName = address.addressName {
            parameters["addressName"] = addressName
        }
        if
            let firstName = address.firstName,
            firstName.isEmpty == false
        {
            parameters["firstName"] = firstName
        }
        if
            let lastName = address.lastName,
            lastName.isEmpty == false
        {
            parameters["lastName"] = lastName
        }
        if let addressLine2 = address.addressLine2 {
            parameters["addressline2"] = addressLine2
        }
        if let county = address.county {
            parameters["county"] = county
        }
        if let location = address.location {
            parameters["location"] = location
        }
        
        return call(endpoint: API.addAddress(parameters))
    }
    
    func updateAddress(address: Address) -> AnyPublisher<MemberProfile, Error> {
        
        // See general note (a)
        if let id = address.id {
            
            // required parameters
            var parameters: [String: Any] = [
                "id": id,
                "businessId": AppV2Constants.Business.id,
                "isDefault": address.isDefault ?? false,
                "addressline1": address.addressLine1,
                "town": address.town,
                "postcode": address.postcode,
                "countryCode": address.countryCode ?? "",
                "type": address.type.rawValue
            ]
            
            // optional paramters
            if let addressName = address.addressName {
                parameters["addressName"] = addressName
            }
            
            if
                let firstName = address.firstName,
                firstName.isEmpty == false
            {
                parameters["firstName"] = firstName
            }
            
            if
                let lastName = address.firstName,
                lastName.isEmpty == false
            {
                parameters["lastName"] = lastName
            }
            
            if let addressLine2 = address.addressLine2 {
                parameters["addressline2"] = addressLine2
            }
            
            if let county = address.county {
                parameters["county"] = county
            }
            
            if let location = address.location {
                parameters["location"] = location
            }
            
            return call(endpoint: API.updateAddress(parameters))
        } else {
            return Fail(outputType: MemberProfile.self, failure: UserServiceError.invalidParameters(["address id not set"]))
                .eraseToAnyPublisher()
        }
    }
    
    func setDefaultAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "addressId": addressId
        ]
        
        return call(endpoint: API.setDefaultAddress(parameters))
    }
    
    func removeAddress(addressId: Int) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "addressId": addressId
        ]
        
        return call(endpoint: API.removeAddress(parameters))
    }
    
    func getSavedCards() async throws -> [MemberCardDetails] {
        return try await call(endpoint: API.getSavedCards).singleOutput()
    }
    
    func saveNewCard(token: String) async throws -> MemberCardDetails {
        // required parameters
        let parameters: [String: Any] = [
            "token": token
        ]
        return try await call(endpoint: API.saveNewCard(parameters)).singleOutput()
    }
    
    func deleteCard(id: String) async throws -> CardDeleteResponse {
        // required parameters
        let parameters: [String: Any] = [
            "cardId": id
        ]
        return try await call(endpoint: API.deleteCard(parameters)).singleOutput()
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch {
        // required parameters
        var parameters: [String: Any] = [
            "isCheckout": isCheckout,
            "notificationsEnabled": notificationsEnabled
        ]
        
        // optional paramters
        if let basketToken = basketToken {
            parameters["basketToken"] = basketToken
        }
        return try await call(endpoint: API.getMarketingOptions(parameters)).singleOutput()
    }
    
    func checkRetailMembershipId(basketToken: String) async throws -> CheckRetailMembershipIdResult {
        // required parameters
        let parameters: [String: Any] = [
            "basketToken": basketToken
        ]
        return try await call(endpoint: API.checkRetailMembershipId(parameters)).singleOutput()
    }
    
    func storeRetailMembershipId(storeId: Int, basketToken: String, retailMemberId: String) async throws -> StoreRetailMembershipIdResult {
        // required parameters
        let parameters: [String: Any] = [
            "storeId": storeId,
            "basketToken": basketToken,
            "retailMemberId": retailMemberId
        ]
        return try await call(endpoint: API.storeRetailMembershipId(parameters)).singleOutput()
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], basketToken: String?, channel: Int? = nil) async throws -> UserMarketingOptionsUpdateResponse {
        // required parameters
        var parameters: [String: Any?] = [
            "marketingOptions": options,
            "marketingChannelId": channel
        ]
        
        // optional paramters
        if let basketToken {
            parameters["basketToken"] = basketToken
        }
        return try await call(endpoint: API.updateMarketingOptions(parameters as [String : Any])).singleOutput()
    }
    
    func getPastOrders(
        dateFrom: String?,
        dateTo: String?,
        status: String?,
        page: Int?,
        limit: Int?
    ) -> AnyPublisher<[PlacedOrderSummary]?, Error> {

        // required parameters
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id
        ]
        
        // optional paramters
        if let dateFrom = dateFrom {
            parameters["dateFrom"] = dateFrom
        }
        if let dateTo = dateTo {
            parameters["dateTo"] = dateTo
        }
        if let status = status {
            parameters["status"] = status
        }
        if let page = page {
            parameters["page"] = page
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        return call(endpoint: API.getPastOrders(parameters))
    }
    
    func getPlacedOrderDetails(forBusinessOrderId businessOrderId: Int) -> AnyPublisher<PlacedOrder, Error> {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "businessOrderId": businessOrderId
        ]
        
        return call(endpoint: API.getPlacedOrderDetails(parameters))
    }
    
    func getDriverSessionSettings(withKnownV1SessionToken token: String?) async throws -> DriverSessionSettings {
        
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id
        ]
        
        // optional paramter
        if let token {
            parameters["sessionToken"] = token
        }
        
        return try await call(endpoint: API.getDriverSessionSettings(parameters)).singleOutput()
        
    }
    
    func requestMobileVerificationCode() async throws -> RequestMobileVerificationCodeResult {
        return try await call(endpoint: API.requestMobileVerificationCode).singleOutput()
    }
    
    func checkMobileVerificationCode(verificationCode: String) async throws -> CheckMobileVerificationCodeResult {
        let parameters: [String: Any] = [
            "verificationCode": verificationCode
        ]
        return try await call(endpoint: API.checkMobileVerificationCode(parameters)).singleOutput()
    }
    
    func checkRegistrationStatus(email: String, basketToken: String) async throws -> CheckRegistrationResult {
        
        let parameters: [String: Any] = [
            "email": email,
            "basketToken": basketToken
        ]
        
        return try await call(endpoint: API.checkRegistrationStatus(parameters)).singleOutput()
    }
    
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "email": email,
            "type": type.rawValue
        ]
        
        return try await call(endpoint: API.requestMessageWithOneTimePassword(parameters)).singleOutput()
    }
    
    func clearNetworkSession() {
        networkHandler.flushAccessTokens()
    }
    
}

// MARK: - Endpoints

extension UserWebRepository {
    enum API {
        case login([String: Any]?)
        case getProfile([String: Any]?)
        case updateProfile([String: Any]?)
        case addAddress([String: Any]?)
        case updateAddress([String: Any]?)
        case setDefaultAddress([String: Any]?)
        case removeAddress([String: Any]?)
        case getSavedCards
        case saveNewCard([String: Any]?)
        case deleteCard([String: Any]?)
        case getMarketingOptions([String: Any]?)
        case updateMarketingOptions([String: Any]?)
        case getPastOrders([String: Any]?)
        case getPlacedOrderDetails([String: Any]?)
        case register([String: Any]?)
        case resetPasswordRequest([String: Any]?)
        case resetPassword([String: Any]?)
        case checkRegistrationStatus([String: Any]?)
        case requestMessageWithOneTimePassword([String: Any]?)
        case getDriverSessionSettings([String: Any]?)
        case requestMobileVerificationCode
        case checkMobileVerificationCode([String: Any]?)
        case checkRetailMembershipId([String: Any]?)
        case storeRetailMembershipId([String: Any]?)
    }
}

extension UserWebRepository.API: APICall {
    var path: String {
        switch self {
        case .login:
            return AppV2Constants.Client.languageCode + "/auth/login.json"
        case .getProfile:
            return AppV2Constants.Client.languageCode + "/member/profile.json"
        case .updateProfile:
            return AppV2Constants.Client.languageCode + "/member/update.json"
        case .addAddress:
            return AppV2Constants.Client.languageCode + "/member/address/add.json"
        case .updateAddress:
            return AppV2Constants.Client.languageCode + "/member/address/update.json"
        case .setDefaultAddress:
            return AppV2Constants.Client.languageCode + "/member/address/setDefault.json"
        case .removeAddress:
            return AppV2Constants.Client.languageCode + "/member/address/remove.json"
        case .getSavedCards:
            return AppV2Constants.Client.languageCode + "/member/cards/getAll.json"
        case .saveNewCard:
            return AppV2Constants.Client.languageCode + "/member/cards/add.json"
        case .deleteCard:
            return AppV2Constants.Client.languageCode + "/member/cards/delete.json"
        case .getMarketingOptions:
            return AppV2Constants.Client.languageCode + "/member/marketing/get.json"
        case .updateMarketingOptions:
            return AppV2Constants.Client.languageCode + "/member/marketing/update.json"
        case .getPastOrders:
            return AppV2Constants.Client.languageCode + "/member/orders.json"
        case .getPlacedOrderDetails:
            return AppV2Constants.Client.languageCode + "/member/orders/get.json"
        case .register:
            return AppV2Constants.Client.languageCode + "/auth/register.json"
        case .resetPasswordRequest:
            return AppV2Constants.Client.languageCode + "/auth/resetPasswordRequest.json"
        case .resetPassword:
            return AppV2Constants.Client.languageCode + "/auth/resetPassword.json"
        case .checkRegistrationStatus:
            return AppV2Constants.Client.languageCode + "/member/checkRegistrationStatus.json"
        case .requestMessageWithOneTimePassword:
            return AppV2Constants.Client.languageCode + "/auth/sendOTPMessage.json"
        case .getDriverSessionSettings:
            return AppV2Constants.Client.languageCode + "/driver/sessionSettings.json"
        case .requestMobileVerificationCode:
            return AppV2Constants.Client.languageCode + "/member/requestVerificationCode.json"
        case .checkMobileVerificationCode:
            return AppV2Constants.Client.languageCode + "/member/checkMobileVerificationCode.json"
        case .checkRetailMembershipId:
            return AppV2Constants.Client.languageCode + "/checkout/checkRetailMembershipId.json"
        case .storeRetailMembershipId:
            return AppV2Constants.Client.languageCode + "/checkout/storeRetailMembershipId.json"
        }
    }
    var method: String {
        switch self {
        case .login, .getProfile, .addAddress, .getMarketingOptions, .getPastOrders, .getPlacedOrderDetails, .setDefaultAddress, .getSavedCards, .saveNewCard, .deleteCard, .register, .resetPasswordRequest, .resetPassword, .checkRegistrationStatus, .requestMessageWithOneTimePassword, .getDriverSessionSettings, .requestMobileVerificationCode, .checkMobileVerificationCode, .checkRetailMembershipId, .storeRetailMembershipId:
            return "POST"
        case .updateProfile, .updateMarketingOptions, .updateAddress:
            return "PUT"
        case .removeAddress:
            return "DELETE"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .login(parameters):
            return parameters
        case let .register(parameters):
            return parameters
        case let .getProfile(parameters):
            return parameters
        case let .updateProfile(parameters):
            return parameters
        case let .addAddress(parameters):
            return parameters
        case let .updateAddress(parameters):
            return parameters
        case let .setDefaultAddress(parameters):
            return parameters
        case let .removeAddress(parameters):
            return parameters
        case .getSavedCards:
            return nil
        case let .saveNewCard(parameters):
            return parameters
        case let .deleteCard(parameters):
            return parameters
        case let .getMarketingOptions(parameters):
            return parameters
        case let .updateMarketingOptions(parameters):
            return parameters
        case let .getPastOrders(parameters):
            return parameters
        case let .getPlacedOrderDetails(parameters):
            return parameters
        case let .resetPasswordRequest(parameters):
            return parameters
        case let .resetPassword(parameters):
            return parameters
        case let .checkRegistrationStatus(parameters):
            return parameters
        case let .requestMessageWithOneTimePassword(parameters):
            return parameters
        case let .getDriverSessionSettings(parameters):
            return parameters
        case .requestMobileVerificationCode:
            return nil
        case let .checkMobileVerificationCode(parameters):
            return parameters
        case let .checkRetailMembershipId(parameters):
            return parameters
        case let .storeRetailMembershipId(parameters):
            return parameters
        }
    }
}



