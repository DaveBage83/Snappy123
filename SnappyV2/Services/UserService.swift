//
//  UserService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Combine
import Foundation
import AuthenticationServices

// 3rd Party
import KeychainAccess
import FacebookLogin

// internal errors for the developers - needs to be Equatable for unit tests
// but extension to Equatble outside of this file causes a syntax error
enum UserServiceError: Swift.Error, Equatable {
    case unableToEstablishAppleIdentityToken
    case unknownFacebookLoginProblem
    case missingFacebookLoginPrivileges
    case mssingFacebookLoginAccessToken
    case memberRequiredToBeSignedIn
    case unableToRegisterWhileMemberSignIn
    case unableToRegister([String: [String]])
    case unableToResetPasswordRequest([String: [String]])
    case unableToDecodeResponse(String)
    case unableToPersistResult
    case unableToProceedWithoutBasket
    case invalidParameters([String])
}

enum RegisteringFromScreenType: String {
    case unknown
    case startScreen = "start_screen"
    case accountTab = "account_tab"
    case billingCheckout = "billing_checkout"
    case webReferAFriend = "web_refer_friend"
    case freeDelivery = "free_delivery"
}

extension UserServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToEstablishAppleIdentityToken:
            return "Authentication services did not return an identity token"
        case .unknownFacebookLoginProblem:
            return "Missing in information in Facebook Login response"
        case .missingFacebookLoginPrivileges:
            return "Unable to login because both Facebook public profile and email address read privileges are required"
        case .mssingFacebookLoginAccessToken:
            return "Facebook Login process did not return an access token"
        case .memberRequiredToBeSignedIn:
            return "function requires member to be signed in"
        case .unableToRegisterWhileMemberSignIn:
            return "function requires member to be signed out"
        case let .unableToRegister(fieldErrors):
            var fieldStrings: [String] = []
            for (key, values) in fieldErrors {
                fieldStrings.append( key + " (" + values.joined(separator: ", ") + ")")
            }
            return "Field Errors: \(fieldStrings.joined(separator: ", "))"
        case let .unableToResetPasswordRequest(fieldErrors):
            var fieldStrings: [String] = []
            for (key, values) in fieldErrors {
                fieldStrings.append( key + " (" + values.joined(separator: ", ") + ")")
            }
            return "Field Errors: \(fieldStrings.joined(separator: ", "))"
        case let .unableToDecodeResponse(rawResponse):
            return "Unable to decode response: " + rawResponse
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        }
    }
}

protocol UserServiceProtocol {
    func login(email: String, password: String) -> Future<Void, Error>
    
    // Apple Sign In and Facebook Login automatically create a new member if there
    // was no corresponding account. The registeringFromScreen is set to help
    // record the route that the customer was captured.
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error>
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error>
    
    // Sends a password reset code to the member email. The recieved code along with the
    // new password is sent using the resetPassword method below.
    func resetPasswordRequest(email: String) -> Future<Void, Error>
    
    // Automatically signs in succesfully registering members
    // Notes:
    // - default billing address can be set via member.defaultBillingAddress
    // - default delivery address can be set via the first delivery address in member.savedAddresses
    func register(
        member: MemberProfile,
        password: String,
        referralCode: String?,
        marketingOptions: [UserMarketingOptionResponse]?
    ) -> Future<Void, Error>
    
    //* methods that require a member to be signed in *//
    func logout() -> Future<Void, Error>
    
    // When filterDeliveryAddresses is true the delivery addresses will be filtered for
    // the selected store. Use the parameter when a result is required during the
    // checkout flow.
    func getProfile(profile: LoadableSubject<MemberProfile>, filterDeliveryAddresses: Bool)
    
    // These address functions are designed to be used from the member account UI area
    // because they return the unfiltered delivery addresses
    func updateProfile(profile: LoadableSubject<MemberProfile>, firstname: String, lastname: String, mobileContactNumber: String)
    func addAddress(profile: LoadableSubject<MemberProfile>, address: Address)
    func updateAddress(profile: LoadableSubject<MemberProfile>, address: Address)
    func setDefaultAddress(profile: LoadableSubject<MemberProfile>, addressId: Int)
    func removeAddress(profile: LoadableSubject<MemberProfile>, addressId: Int)
    
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
    
    //* methods where a signed in user is optional *//
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool)
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest])
}

struct UserService: UserServiceProtocol {

    let webRepository: UserWebRepositoryProtocol
    let dbRepository: UserDBRepositoryProtocol
    let appState: Store<AppState>
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    private var cancelBag = CancelBag()
    
    init(webRepository: UserWebRepositoryProtocol, dbRepository: UserDBRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        
        appState.value.userData.memberSignedIn = keychain["memberSignedIn"] != nil
    }
    
    func login(email: String, password: String) -> Future<Void, Error> {
        return Future() { promise in

            webRepository
                .login(email: email, password: password)
                .flatMap({ success -> AnyPublisher<Bool, Error> in
                    if success {
                        return clearAllMarketingOptions(passThrough: success)
                    } else {
                        return Just<Bool>.withErrorType(success, Error.self)
                    }
                })
                .sink(
                    receiveCompletion: { completion in

                        // Only seems to get here if there is an error

                        switch completion {

                        case .failure(let error):
                            // report the error back to the original future
                            promise(.failure(error))

                        case .finished:
                            // should no finish before receiveValue
                            promise(.success(()))

                        }

                    }, receiveValue: { _ in
                        
                        // The following is required because it does not
                        // reach the above on a finished state
                        appState.value.userData.memberSignedIn = true
                        keychain["memberSignedIn"] = "email"
                        
                        promise(.success(()))
                    }
                )
                .store(in: cancelBag)
        }
    }
    
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error> {
        return Future() { promise in
            
            guard
                let appleIDCredential = appleSignInAuthorisation.credential as? ASAuthorizationAppleIDCredential,
                let identityToken = appleIDCredential.identityToken
            else {
                promise(.failure(UserServiceError.unableToEstablishAppleIdentityToken))
                return
            }
            
            webRepository
                .login(
                    appleSignInToken: String(decoding: identityToken, as: UTF8.self),
                    // The following three values are only provided once by Apple and the
                    // names may never be supplied. They are passed to the API if a new
                    // member is being created as a result of the sign in to populate
                    // critical record fields
                    username: appleIDCredential.email,
                    firstname: appleIDCredential.fullName?.givenName,
                    lastname: appleIDCredential.fullName?.familyName,
                    registeringFromScreen: registeringFromScreen
                )
                .flatMap({ success -> AnyPublisher<Bool, Error> in
                    if success {
                        return clearAllMarketingOptions(passThrough: success)
                    } else {
                        return Just<Bool>.withErrorType(success, Error.self)
                    }
                })
                .sinkToResult({ result in
                    switch result {
                    case .success:
                        appState.value.userData.memberSignedIn = true
                        keychain["memberSignedIn"] = "apple_sign_in"
                        promise(.success(()))
                    case let .failure(error):
                        promise(.failure(error))
                    }
                })
                .store(in: cancelBag)
        }
    }
    
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error> {
        return Future() { promise in
            let loginManager = LoginManager()
            // calling the logout function first resolves potential problems when in
            // a confused state
            loginManager.logOut()
            loginManager.logIn(
                permissions: ["public_profile", "email"],
                from: nil
            ) { (loginResult, error) in
                
                if let error = error {
                    promise(.failure(error))
                } else if let loginResult = loginResult {
                    
                    if loginResult.isCancelled {
                        // The customer decided to abandon login so this will not
                        // recoreded as an error and the App State will remain
                        // unchanged.
                        promise(.success(()))
                    } else  {
                        if loginResult.grantedPermissions.contains("email") && loginResult.grantedPermissions.contains("public_profile") {
                            if let facebookAccessToken = loginResult.token?.tokenString {
                                webRepository
                                    .login(
                                        facebookAccessToken: facebookAccessToken,
                                        registeringFromScreen: registeringFromScreen
                                    )
                                    .sinkToResult({ result in
                                        switch result {
                                        case .success:
                                            appState.value.userData.memberSignedIn = true
                                            keychain["memberSignedIn"] = "facebook_login"
                                            promise(.success(()))
                                        case let .failure(error):
                                            promise(.failure(error))
                                        }
                                    })
                                    .store(in: cancelBag)
                            } else {
                                promise(.failure(UserServiceError.mssingFacebookLoginAccessToken))
                            }
                        } else {
                            promise(.failure(UserServiceError.missingFacebookLoginPrivileges))
                        }
                    }
                    
                } else {
                    // Should never get here as either loginResult or error should be set
                    promise(.failure(UserServiceError.unknownFacebookLoginProblem))
                }
            }
                    
        }
    }
    
    func resetPasswordRequest(email: String) -> Future<Void, Error> {
        return Future() { promise in
            webRepository
                .resetPasswordRequest(email: email)
                .sinkToResult { result in
                    switch result {
                    case let .success(webResult):
                        do {
                            // since [String: Any] is not decodable the type Data needs to
                            // be returned by the web repository and the JSON decoded here
                            guard let dictionayResult = try JSONSerialization.jsonObject(with: webResult, options: []) as? [String: Any] else {
                                promise(.failure(UserServiceError.unableToDecodeResponse(String(decoding: webResult, as: UTF8.self))))
                                return
                            }
                            if
                                let success = dictionayResult["success"] as? Bool,
                                success
                            {
                                // registration endpoint call succeded so try to
                                // sign in the customer using the new
                                promise(.success(()))
                            } else {
                                promise(.failure(UserServiceError.unableToResetPasswordRequest(stripToFieldErrors(from: dictionayResult))))
                            }
                        } catch {
                            promise(.failure(UserServiceError.unableToDecodeResponse(String(decoding: webResult, as: UTF8.self))))
                        }
                        
                    case let .failure(webError):
                        promise(.failure(webError))
                    }
                }
                .store(in: cancelBag)
        }
    }
    
    func register(member: MemberProfile, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) -> Future<Void, Error> {
        return Future() { promise in
            
            if appState.value.userData.memberSignedIn {
                promise(.failure(UserServiceError.unableToRegisterWhileMemberSignIn))
                return
            }
            
            webRepository
                .register(
                    member: member,
                    password: password,
                    referralCode: referralCode,
                    marketingOptions: marketingOptions
                )
                .sinkToResult({ result in
                    switch result {
                    case let .success(registeringWebResult):
                        do {
                            // since [String: Any] is not decodable the type Data needs to
                            // be returned by the web repository and the JSON decoded here
                            if let dictionayResult = try JSONSerialization.jsonObject(with: registeringWebResult, options: []) as? [String: Any] {
                                if
                                    let success = dictionayResult["success"] as? Bool,
                                    success
                                {
                                    // registration endpoint call succeded so try to
                                    // sign in the customer using the new
                                    login(email: member.emailAddress, password: password)
                                        .sinkToResult({ loginResult in
                                            switch loginResult {
                                            case .success:
                                                promise(.success(()))
                                            case let .failure(error):
                                                promise(.failure(error))
                                            }
                                        })
                                        .store(in: cancelBag)
                                } else if dictionayResult["email"] as? [String] != nil {
                                    // problem with the email - probably already used so try
                                    // to login as the customer
                                    login(email: member.emailAddress, password: password)
                                        .sinkToResult({ loginResult in
                                            switch loginResult {
                                            case .success:
                                                promise(.success(()))
                                            case .failure:
                                                promise(.failure(UserServiceError.unableToRegister(stripToFieldErrors(from: dictionayResult))))
                                            }
                                        })
                                        .store(in: cancelBag)
                                } else {
                                    promise(.failure(UserServiceError.unableToRegister(stripToFieldErrors(from: dictionayResult))))
                                }
                            }
                        } catch {
                            promise(.failure(UserServiceError.unableToDecodeResponse(String(decoding: registeringWebResult, as: UTF8.self))))
                        }
                        
                    case let .failure(registeringWebError):
                        promise(.failure(registeringWebError))
                    }
                })
                .store(in: cancelBag)
        }
    }
    
    func logout() -> Future<Void, Error> {
        return Future() { promise in
            
            if appState.value.userData.memberSignedIn == false {
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository
                .logout()
                .catch({ error -> AnyPublisher<Bool, Error> in
                    return checkMemberAuthenticationFailure(for: error)
                })
                .flatMap({ success -> AnyPublisher<Bool, Error> in
                    if success {
                        //return clearAllMarketingOptions(passThrough: success)
                        return clearMemberProfile(passThrough: success)
                            .flatMap { _ -> AnyPublisher<Bool, Error> in
                                return clearAllMarketingOptions(passThrough: success)
                            }
                            .eraseToAnyPublisher()
                        
                    } else {
                        return Just<Bool>.withErrorType(success, Error.self)
                    }
                })
                .sink { completion in
                    
                    // Only seems to get here if there is an error

                    switch completion {

                    case .failure(let error):
                        // report the error back to the original future
                        promise(.failure(error))

                    case .finished:
                        // should no finish before receiveValue
                        promise(.success(()))

                    }
                    
                } receiveValue: { success in
                    if success {
                        markUserSignedOut()
                        promise(.success(()))
                    }
                }
                .store(in: cancelBag)
            
        }
    }
    
    func getProfile(profile: LoadableSubject<MemberProfile>, filterDeliveryAddresses: Bool) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        let storeId = filterDeliveryAddresses ? appState.value.userData.selectedStore.value?.id : nil
        
        webRepository
            .getProfile(storeId: storeId)
            .catch({ error -> AnyPublisher<MemberProfile, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
            .flatMap({ memberResult -> AnyPublisher<(Bool, MemberProfile), Error> in
                return Just<(Bool, MemberProfile)>.withErrorType((true, memberResult), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a
                // result from the persistent store
                return dbRepository
                    .memberProfile(storeId: storeId)
                    .flatMap { memberResult -> AnyPublisher<(Bool, MemberProfile), Error> in
                        if
                            let memberResult = memberResult,
                            // check that the data is not too old
                            let fetchTimestamp = memberResult.fetchTimestamp,
                            fetchTimestamp > AppV2Constants.Business.userCachedExpiry
                        {
                            return Just<(Bool, MemberProfile)>.withErrorType((false, memberResult), Error.self)
                        } else {
                            return Fail(outputType: (Bool, MemberProfile).self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
            })
            .flatMap({ (fromWeb, profile) -> AnyPublisher<MemberProfile, Error> in
                if fromWeb {
                    // need to remove the previous result in the
                    // database and store a new value
                    return dbRepository
                        .clearMemberProfile()
                        .flatMap { _ -> AnyPublisher<MemberProfile, Error> in
                            dbRepository
                                .store(memberProfile: profile, forStoreId: storeId)
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just<MemberProfile>.withErrorType(profile, Error.self)
                }
            })
            .eraseToAnyPublisher()
            .sinkToLoadable { profile.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    private func processMemberProfilePublisher(publisher: AnyPublisher<MemberProfile, Error>, profile: LoadableSubject<MemberProfile>) {
        publisher
            .catch({ error -> AnyPublisher<MemberProfile, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
            .flatMap({ profile -> AnyPublisher<MemberProfile, Error> in
                // need to remove the previous result in the
                // database and store a new value
                return dbRepository
                    .clearMemberProfile()
                    .flatMap { _ -> AnyPublisher<MemberProfile, Error> in
                        dbRepository
                            .store(memberProfile: profile, forStoreId: nil)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
            .sinkToLoadable { profile.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func updateProfile(profile: LoadableSubject<MemberProfile>, firstname: String, lastname: String, mobileContactNumber: String) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        processMemberProfilePublisher(
            publisher: webRepository.updateProfile(
                firstname: firstname,
                lastname: lastname,
                mobileContactNumber: mobileContactNumber
            ),
            profile: profile
        )
    }
    
    func addAddress(profile: LoadableSubject<MemberProfile>, address: Address) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        processMemberProfilePublisher(
            publisher: webRepository.addAddress(address: address),
            profile: profile
        )
    }
    
    func updateAddress(profile: LoadableSubject<MemberProfile>, address: Address) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        processMemberProfilePublisher(
            publisher: webRepository.updateAddress(address: address),
            profile: profile
        )
    }
    
    func setDefaultAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        processMemberProfilePublisher(
            publisher: webRepository.setDefaultAddress(addressId: addressId),
            profile: profile
        )
    }
    
    func removeAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        processMemberProfilePublisher(
            publisher: webRepository.removeAddress(addressId: addressId),
            profile: profile
        )
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) {
        
        let cancelBag = CancelBag()
        pastOrders.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: [PastOrder]?.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { pastOrders.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit)
            .catch({ error -> AnyPublisher<[PastOrder]?, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
//            .flatMap({ pastOrdersResult -> AnyPublisher<(Bool, [PastOrder]?), Error> in
//                return Just<(Bool, [PastOrder]?)>.withErrorType((true, pastOrdersResult), Error.self)
//            })
//            .catch({ error in
//                // failed to fetch from the API so try to get a
//                // result from the persistent store
//                return dbRepository
//                    .memberProfile()
//                    .flatMap { memberResult -> AnyPublisher<(Bool, MemberProfile), Error> in
//                        if
//                            let memberResult = memberResult,
//                            // check that the data is not too old
//                            let fetchTimestamp = memberResult.fetchTimestamp,
//                            fetchTimestamp > AppV2Constants.Business.userCachedExpiry
//                        {
//                            return Just<(Bool, MemberProfile)>.withErrorType((false, memberResult), Error.self)
//                        } else {
//                            return Fail(outputType: (Bool, MemberProfile).self, failure: error)
//                                .eraseToAnyPublisher()
//                        }
//                    }
//            })
//            .flatMap({ (fromWeb, profile) -> AnyPublisher<MemberProfile, Error> in
//                if fromWeb {
//                    // need to remove the previous result in the
//                    // database and store a new value
//                    return dbRepository
//                        .clearMemberProfile()
//                        .flatMap { _ -> AnyPublisher<MemberProfile, Error> in
//                            dbRepository
//                                .store(memberProfile: profile)
//                                .eraseToAnyPublisher()
//                        }
//                        .eraseToAnyPublisher()
//                } else {
//                    return Just<MemberProfile>.withErrorType(profile, Error.self)
//                }
//            })
            .eraseToAnyPublisher()
            .sinkToLoadable { pastOrders.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool) {
        
        let cancelBag = CancelBag()
        options.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        var basketToken: String?
        if isCheckout {
            // Basket token is required if the member is not signed in because the
            // server is recording marketing options for that specific order.
            // Otherwise it should not be passed because it is against their member
            // preferences.
            if appState.value.userData.memberSignedIn == false {
                if let currentBasketToken = appState.value.userData.basket?.basketToken {
                    basketToken = currentBasketToken
                }
            }
            // for isCheckout a basket should always exist even if not passed
            // as a request value
            if appState.value.userData.basket?.basketToken == nil {
                Fail(outputType: UserMarketingOptionsFetch.self, failure: UserServiceError.unableToProceedWithoutBasket)
                    .eraseToAnyPublisher()
                    .sinkToLoadable { options.wrappedValue = $0 }
                    .store(in: cancelBag)
                return
            }
        } else if appState.value.userData.memberSignedIn == false {
            // the user should be signed in when not fetching options for checkout
            Fail(outputType: UserMarketingOptionsFetch.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { options.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
            .flatMap({ optionsResult -> AnyPublisher<(Bool, UserMarketingOptionsFetch), Error> in
                return Just<(Bool, UserMarketingOptionsFetch)>.withErrorType((true, optionsResult), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a
                // result from the persistent store
                return dbRepository
                    .userMarketingOptionsFetch(
                        isCheckout: isCheckout,
                        notificationsEnabled: notificationsEnabled,
                        basketToken: basketToken
                    )
                    .flatMap { optionsResult -> AnyPublisher<(Bool, UserMarketingOptionsFetch), Error> in
                        if
                            let optionsResult = optionsResult,
                            // check that the data is not too old
                            let fetchTimestamp = optionsResult.fetchTimestamp,
                            fetchTimestamp > AppV2Constants.Business.userCachedExpiry
                        {
                            return Just<(Bool, UserMarketingOptionsFetch)>.withErrorType((false, optionsResult), Error.self)
                        } else {
                            return Fail(outputType: (Bool, UserMarketingOptionsFetch).self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
            })
            .flatMap({ (fromWeb, fetch) -> AnyPublisher<UserMarketingOptionsFetch, Error> in
                if fromWeb {
                    // need to remove the previous result in the
                    // database and store a new value
                    return dbRepository
                        .clearFetchedUserMarketingOptions(
                            isCheckout: isCheckout,
                            notificationsEnabled: notificationsEnabled,
                            basketToken: basketToken
                        )
                        .flatMap { _ -> AnyPublisher<UserMarketingOptionsFetch, Error> in
                            dbRepository
                                .store(
                                    marketingOptionsFetch: fetch,
                                    isCheckout: isCheckout,
                                    notificationsEnabled: notificationsEnabled,
                                    basketToken: basketToken
                                )
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just<UserMarketingOptionsFetch>.withErrorType(fetch, Error.self)
                }
            })
            .eraseToAnyPublisher()
            //.receive(on: RunLoop.main)
            .sinkToLoadable { options.wrappedValue = $0 }
            .store(in: cancelBag)
        
    }
    
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest]) {
        let cancelBag = CancelBag()
        result.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        // Only need the basket token if the user is not signed in
        var basketToken: String?
        if !appState.value.userData.memberSignedIn {
            if let currentBasketToken = appState.value.userData.basket?.basketToken {
                basketToken = currentBasketToken
            } else {
                Fail(outputType: UserMarketingOptionsUpdateResponse.self, failure: UserServiceError.unableToProceedWithoutBasket)
                    .eraseToAnyPublisher()
                    .sinkToLoadable { result.wrappedValue = $0 }
                    .store(in: cancelBag)
                return
            }
        }
        
        webRepository
            .updateMarketingOptions(options: options, basketToken: basketToken)
            .flatMap({ result -> AnyPublisher<UserMarketingOptionsUpdateResponse, Error> in
                // we could try to do something clever like update the cached
                // values but since they are only used as a fallback if there
                // is a network problem this can be left as low priority future
                // extension
                return clearAllMarketingOptions(passThrough: result)
            })
            .eraseToAnyPublisher()
            .sinkToLoadable { result.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    private func stripToFieldErrors(from dictionayResult: [String: Any]) -> [String: [String]] {
        var fieldErrors: [String: [String]] = [:]
        for (key, value) in dictionayResult {
            if let value = value as? [String] {
                fieldErrors[key] = value
            }
        }
        return fieldErrors
    }
    
    /// Intended for when a member status changes (login/logout) or the member privileges of
    /// the access token fail
    private func clearMemberProfile<T>(passThrough: T) -> AnyPublisher<T, Error> {
        return dbRepository
            .clearMemberProfile()
            .flatMap { _ -> AnyPublisher<T, Error> in
                return Just(passThrough)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// Intended for when a member status changes (login/logout) or the member privileges of
    /// the access token fail
    private func clearAllMarketingOptions<T>(passThrough: T) -> AnyPublisher<T, Error> {
        return dbRepository
            .clearAllFetchedUserMarketingOptions()
            .flatMap { _ -> AnyPublisher<T, Error> in
                return Just(passThrough)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// The NetworkHandler code attempts to refresh the access token. If that fails this function
    /// checks is the error was an authentication problem and if so sets the user as no longer
    /// being signed in.
    private func checkMemberAuthenticationFailure<T>(for error: Error) -> AnyPublisher<T, Error> {
        if
            let error = error as? APIErrorResult,
            error.errorCode == 401
        {
            markUserSignedOut()
            return
                clearMemberProfile(passThrough: error)
                .flatMap({ errorValue -> AnyPublisher<T, Error> in
                    return clearAllMarketingOptions(passThrough: error)
                        .flatMap({ errorValue -> AnyPublisher<T, Error> in
                            return Fail(outputType: T.self, failure: errorValue)
                                .eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
        }
        return Fail(outputType: T.self, failure: error)
            .eraseToAnyPublisher()
    }
    
    private func markUserSignedOut() {
        if keychain["memberSignedIn"] == "facebook_login" {
            LoginManager().logOut()
        }
        appState.value.userData.memberSignedIn = false
        keychain["memberSignedIn"] = nil
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
    
}

struct StubUserService: UserServiceProtocol {

    func login(email: String, password: String) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func resetPasswordRequest(email: String) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func register(member: MemberProfile, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func logout() -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func getProfile(profile: LoadableSubject<MemberProfile>, filterDeliveryAddresses: Bool) { }
    
    func updateProfile(profile: LoadableSubject<MemberProfile>, firstname: String, lastname: String, mobileContactNumber: String) { }
    
    func addAddress(profile: LoadableSubject<MemberProfile>, address: Address) { }
    
    func updateAddress(profile: LoadableSubject<MemberProfile>, address: Address) { }
    
    func setDefaultAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) { }
    
    func removeAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) { }
    
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool) { }
    
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest]) { }
    
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) { }
    
}
