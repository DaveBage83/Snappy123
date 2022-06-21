//
//  UserService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Combine
import Foundation
import AuthenticationServices
import OSLog

// 3rd Party
import KeychainAccess
import FacebookLogin
import GoogleSignIn

// internal errors for the developers - needs to be Equatable for unit tests
// but extension to Equatble outside of this file causes a syntax error
enum UserServiceError: Swift.Error, Equatable {
    case unableToEstablishAppleIdentityToken
    case unknownFacebookLoginProblem
    case missingFacebookLoginPrivileges
    case missingFacebookLoginAccessToken
    case unknownGoogleLoginProblem
    case memberRequiredToBeSignedIn
    case unableToRegisterWhileMemberSignIn
    case unableToLogin
    case unableToRegister
    case unableToResetPasswordRequest([String: [String]])
    case unableToResetPassword
    case unableToDecodeResponse(String)
    case unableToPersistResult
    case unableToProceedWithoutBasket
    case invalidParameters([String])
    case networkError
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
        case .missingFacebookLoginAccessToken:
            return "Facebook Login process did not return an access token"
        case .unknownGoogleLoginProblem:
            return "Missing in information in Google Sign In response"
        case .memberRequiredToBeSignedIn:
            return "function requires member to be signed in"
        case .unableToRegisterWhileMemberSignIn:
            return "function requires member to be signed out"
        case .unableToLogin:
            return "unsuccessful response or missing token"
        case .unableToRegister:
            return "function did not get a success result or token missing"
        case let .unableToResetPasswordRequest(fieldErrors):
            var fieldStrings: [String] = []
            for (key, values) in fieldErrors {
                fieldStrings.append( key + " (" + values.joined(separator: ", ") + ")")
            }
            return "Field Errors: \(fieldStrings.joined(separator: ", "))"
        case .unableToResetPassword:
            return "Unsuccesful password reset result"
        case let .unableToDecodeResponse(rawResponse):
            return "Unable to decode response: " + rawResponse
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        case .networkError:
            return "There is a problem with the network"
        }
    }
}

protocol UserServiceProtocol {
    func login(email: String, password: String) async throws
    func login(email: String, oneTimePassword: String) async throws
    
    // Apple Sign In and Facebook Login automatically create a new member if there
    // was no corresponding account. The registeringFromScreen is set to help
    // record the route that the customer was captured.
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) async throws
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) async throws
    func loginWithGoogle(registeringFromScreen: RegisteringFromScreenType) async throws
    
    // Sends a password reset code to the member email. The recieved code along with
    // the new password is sent using the resetPassword method below.
    func resetPasswordRequest(email: String) -> Future<Void, Error>
    
    // Update password and can automatically sign in succesfully registering members
    // Notes:
    // resetToken - from the resetPasswordRequest and is required if the customer is not signed in
    // currentPassword - required when the resetToken is not supplied (general path when customer signed in)
    // email - always optional but required to sign in the member after the password has been changed
    func resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?) async throws
    
    // Automatically signs in succesfully registering members
    // Notes:
    // - default billing address can be set via member.defaultBillingAddress
    // - default delivery address can be set via the first delivery address in member.savedAddresses
    func register(
        member: MemberProfileRegisterRequest,
        password: String,
        referralCode: String?,
        marketingOptions: [UserMarketingOptionResponse]?
    ) async throws
    
    //* methods that require a member to be signed in *//
    func logout() -> Future<Void, Error>
    
    func restoreLastUser() async throws
    
    // When filterDeliveryAddresses is true the delivery addresses will be filtered for
    // the selected store. Use the parameter when a result is required during the
    // checkout flow.
    func getProfile(filterDeliveryAddresses: Bool) -> Future<Void, Error>
    
    // These address functions are designed to be used from the member account UI area
    // because they return the unfiltered delivery addresses
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) -> Future<Void, Error>
    func addAddress(address: Address) -> Future<Void, Error>
    func updateAddress(address: Address) -> Future<Void, Error>
    func setDefaultAddress(addressId: Int) -> Future<Void, Error>
    func removeAddress(addressId: Int) -> Future<Void, Error>
    
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
    func getPlacedOrder(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int)
    
    //* methods where a signed in user is optional *//
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool) async throws -> UserMarketingOptionsFetch
    func updateMarketingOptions(options: [UserMarketingOptionRequest]) async throws -> UserMarketingOptionsUpdateResponse
    
    //* methods where a signed in user would not expected *//
    func checkRegistrationStatus(email: String) async throws -> CheckRegistrationResult
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult
}

struct UserService: UserServiceProtocol {
    let webRepository: UserWebRepositoryProtocol
    let dbRepository: UserDBRepositoryProtocol
    let appState: Store<AppState>
    let eventLogger: EventLoggerProtocol
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    private var cancelBag = CancelBag()
    
    private let previousSessionWithoutAppDeletionKey = "previousSessionWithoutAppDeletion"
    private let memberSignedInKey = "memberSignedIn"
    
    init(webRepository: UserWebRepositoryProtocol, dbRepository: UserDBRepositoryProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
        
        // keychain entries persists after the app is deleted so have a sanity
        // test to remove any potentially stored member keychain states if the
        // user defaults state is lost
        let userDefaults: UserDefaults = UserDefaults.standard
        if userDefaults.object(forKey: previousSessionWithoutAppDeletionKey) as? Bool == nil {
            // clear states that should not be set after the app was deleted
            if appState.value.userData.memberProfile == nil {
                markUserSignedOut()
                webRepository.clearNetworkSession()
            }
            // set up for the next app session
            userDefaults.set(true, forKey: previousSessionWithoutAppDeletionKey)
        }
    }
    
    func login(email: String, password: String) async throws {
        
        let result = try await webRepository.login(
            email: email,
            password: password,
            basketToken: appState.value.userData.basket?.basketToken
        )
        
        if
            let token = result.token,
            result.success
        {
            // login endpoint call succeded so set the token
            webRepository.setToken(to: token)
        } else {
            // in theory the displayable APIErrorResult should be
            // thrown by the API before ever getting here
            throw UserServiceError.unableToLogin
        }
        
        // If we are here, we have a newly sign in user so we clear past marketing options
        let _ = try await dbRepository.clearAllFetchedUserMarketingOptions().singleOutput()
        
        // If we are here, we can retrieve a profile
        try await getProfile(filterDeliveryAddresses: false).singleOutput()
        
        // Mark the user login state as "one_time_password" in the keychain
        keychain[memberSignedInKey] = "email"
    }

    func login(email: String, oneTimePassword: String) async throws {
        
        let result = try await webRepository.login(
            email: email,
            oneTimePassword: oneTimePassword,
            basketToken: appState.value.userData.basket?.basketToken
        )
        
        if
            let token = result.token,
            result.success
        {
            // login endpoint call succeded so set the token
            webRepository.setToken(to: token)
        } else {
            // in theory the displayable APIErrorResult should be
            // thrown by the API before ever getting here
            throw UserServiceError.unableToLogin
        }
        
        // If we are here, we have a newly sign in user so we clear past marketing options
        let _ = try await dbRepository.clearAllFetchedUserMarketingOptions().singleOutput()
        
        // If we are here, we can retrieve a profile
        try await getProfile(filterDeliveryAddresses: false).singleOutput()
        
        // Mark the user login state as "one_time_password" in the keychain
        keychain[memberSignedInKey] = "one_time_password"
    }
    
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) async throws {
        guard
            let appleIDCredential = appleSignInAuthorisation.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = appleIDCredential.identityToken
        else {
            throw UserServiceError.unableToEstablishAppleIdentityToken
        }
        
        let result = try await webRepository.login(
            appleSignInToken: String(decoding: identityToken, as: UTF8.self),
            // The following three values are only provided once by Apple and the
            // names may never be supplied. They are passed to the API if a new
            // member is being created as a result of the sign in to populate
            // critical record fields
            username: appleIDCredential.email,
            firstname: appleIDCredential.fullName?.givenName,
            lastname: appleIDCredential.fullName?.familyName,
            basketToken: appState.value.userData.basket?.basketToken,
            registeringFromScreen: registeringFromScreen
        )
        
        if
            let token = result.token,
            result.success
        {
            // login endpoint call succeded so set the token
            webRepository.setToken(to: token)
        } else {
            // in theory the displayable APIErrorResult should be
            // thrown by the API before ever getting here
            throw UserServiceError.unableToLogin
        }
        
        // If we are here, we have a newly sign in user so we clear past marketing options
        let _ = try await dbRepository.clearAllFetchedUserMarketingOptions().singleOutput()
        
        // If we are here, we can retrieve a profile
        try await getProfile(filterDeliveryAddresses: false).singleOutput()
        
        // Mark the user login state as "one_time_password" in the keychain
        keychain[memberSignedInKey] = "apple_sign_in"
    }
    
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) async throws {
        
        let loginManager = LoginManager()
        // calling the logout function first resolves potential problems when in
        // a confused state
        loginManager.logOut()
        
        var tokenString: String?
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                loginManager.logIn(
                    permissions: ["public_profile", "email"],
                    from: nil
                ) { (loginResult, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let loginResult = loginResult {
                        
                        if loginResult.isCancelled {
                            // The customer decided to abandon login so this will not
                            // recoreded as an error and the App State will remain
                            // unchanged.
                            continuation.resume()
                        } else  {
                            if loginResult.grantedPermissions.contains("email") && loginResult.grantedPermissions.contains("public_profile") {
                                if let facebookAccessToken = loginResult.token?.tokenString {
                                    tokenString = facebookAccessToken
                                    continuation.resume()
                                    
                                } else {
                                    continuation.resume(throwing: UserServiceError.missingFacebookLoginAccessToken)
                                }
                            } else {
                                continuation.resume(throwing: UserServiceError.missingFacebookLoginPrivileges)
                            }
                        }
                        
                    } else {
                        // Should never get here as either loginResult or error should be set
                        continuation.resume(throwing: UserServiceError.unknownFacebookLoginProblem)
                    }
                }
            }
        }
        
        if let tokenString = tokenString {
            
            let result = try await webRepository.login(
                facebookAccessToken: tokenString,
                basketToken: appState.value.userData.basket?.basketToken,
                registeringFromScreen: registeringFromScreen
            )
            
            if
                let token = result.token,
                result.success
            {
                // login endpoint call succeded so set the token
                webRepository.setToken(to: token)
            } else {
                // in theory the displayable APIErrorResult should be
                // thrown by the API before ever getting here
                throw UserServiceError.unableToLogin
            }
            
            try await getProfile(filterDeliveryAddresses: false).singleOutput()
            keychain[memberSignedInKey] = "facebook_login"
        }
    }
    
    func loginWithGoogle(registeringFromScreen: RegisteringFromScreenType) async throws {
        
        // calling the logout function first resolves potential problems when in
        // a confused state
        GIDSignIn.sharedInstance.signOut()
        
        // approach taken from Google's sample code
        guard let rootViewController = await UIApplication.shared.windows.first?.rootViewController else {
            Logger.member.error("There is no root view controller to attatch Google Login view")
            return
        }
        
        var tokenString: String?
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                guaranteeMainThread {
                    GIDSignIn.sharedInstance.signIn(
                        with: GIDConfiguration(clientID: AppV2Constants.Client.googleSignInClientId),
                        presenting: rootViewController
                    ) { user, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let signInUser = user {
                            signInUser.authentication.do { authentication, error in
                                if let error = error {
                                    continuation.resume(throwing: error)
                                } else if
                                    let authentication = authentication,
                                    let idToken = authentication.idToken
                                {
                                    tokenString = idToken
                                    continuation.resume()
                                    
                                } else {
                                    // Should never get here as either authentication or error should be set
                                    continuation.resume(throwing: UserServiceError.unknownGoogleLoginProblem)
                                }
                            }
                        } else {
                            // Should never get here as either user or error should be set
                            continuation.resume(throwing: UserServiceError.unknownGoogleLoginProblem)
                        }
                    }
                }
            }
        }
        
        if let tokenString = tokenString {
            
            let result = try await webRepository.login(
                googleAccessToken: tokenString,
                basketToken: appState.value.userData.basket?.basketToken,
                registeringFromScreen: registeringFromScreen
            )
            
            if
                let token = result.token,
                result.success
            {
                // login endpoint call succeded so set the token
                webRepository.setToken(to: token)
            } else {
                // in theory the displayable APIErrorResult should be
                // thrown by the API before ever getting here
                throw UserServiceError.unableToLogin
            }
            
            try await getProfile(filterDeliveryAddresses: false).singleOutput()
            keychain[memberSignedInKey] = "google_sign_in"
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
    
    func resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?) async throws  {
        
        if resetToken == nil && appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        let webResult = try await webRepository
            .resetPassword(
                resetToken: resetToken,
                logoutFromAll: logoutFromAll,
                password: password,
                currentPassword: currentPassword
            ).singleOutput()
        
        if webResult.success {
            // if the user in not logged, i.e they have used the password recovery option
            // then sign them in with the newly chosen password
            if let email = email, appState.value.userData.memberProfile == nil {
                try await login(email: email, password: password)
            }
        } else {
            throw UserServiceError.unableToResetPassword
        }
    }
    
    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) async throws {
        
        if appState.value.userData.memberProfile != nil {
            throw UserServiceError.unableToRegisterWhileMemberSignIn
        }
        
        do {
            
            let registeringWebResult = try await webRepository.register(
                member: member,
                password: password,
                referralCode: referralCode,
                marketingOptions: marketingOptions
            )
            
            if
                let token = registeringWebResult.token,
                registeringWebResult.success
            {
                // registration endpoint call succeded so set the token
                // and get the profile
                webRepository.setToken(to: token)
                
                // If we are here, we have a newly sign in user so we clear past marketing options
                let _ = try await dbRepository.clearAllFetchedUserMarketingOptions().singleOutput()
                
                // If we are here, we can retrieve a profile
                try await getProfile(filterDeliveryAddresses: false).singleOutput()
                
                // Mark the user login state as "email" in the keychain
                keychain[memberSignedInKey] = "email"

            } else {
                throw UserServiceError.unableToRegister
            }
            
        } catch {
            // see OAPIV2-580, try to login a member where member
            // already registered is returned
            if let registerError = error as? APIErrorResult {
                if registerError.errorCode == 150001 {
                    do {
                        try await login(email: member.emailAddress, password: password)
                    } catch {
                        // throw the original error rather than the
                        // login error code
                        throw registerError
                    }
                } else {
                    throw error
                }
            }
        }
    }
    
    func logout() -> Future<Void, Error> {
        return Future() { promise in
            
            if appState.value.userData.memberProfile == nil {
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository
                .logout(basketToken: appState.value.userData.basket?.basketToken)
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
    
    func restoreLastUser() async throws {
        guard keychain[memberSignedInKey] != nil else { return }
        
        do {
            try await getProfile(filterDeliveryAddresses: false).singleOutput()
        } catch {
            throw error
        }
    }
    
    func getProfile(filterDeliveryAddresses: Bool) -> Future<Void, Error> {
        let storeId = filterDeliveryAddresses ? appState.value.userData.selectedStore.value?.id : nil
        
        // We do not need to check if member is signed in here as getProfile() is only triggered with successful login
        
        return Future() { promise in
            
            webRepository
                .getProfile(storeId: storeId)
                .catch({ error -> AnyPublisher<MemberProfile, Error> in
                    return checkMemberAuthenticationFailure(for: error)
                })
                .ensureTimeSpan(requestHoldBackTimeInterval)
                    // convert the result to include a Bool indicating the
                    // source of the data
                .flatMap { memberResult -> AnyPublisher<(Bool, MemberProfile), Error> in
                    return Just<(Bool, MemberProfile)>.withErrorType((true, memberResult), Error.self)
                }
                .catch { error in
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
                }
                .flatMap { (fromWeb, profile) -> AnyPublisher<MemberProfile, Error> in
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
                }
                .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let err):
                            Logger.member.error("Failed to get user profile: \(err.localizedDescription)")
                            promise(.failure((err)))
                        case .finished:
                            Logger.member.info("Successfully retrieved profile")
                            
                        }
                    }, receiveValue: { profile in
                        appState.value.userData.memberProfile = profile
                        promise(.success(()))
                    })
                .store(in: cancelBag)
        }
    }
    
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) -> Future<Void, Error> {
        
        return Future() { promise in
            if appState.value.userData.memberProfile == nil {
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository
                .updateProfile(
                    firstname: firstname,
                    lastname: lastname,
                    mobileContactNumber: mobileContactNumber)
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
            
                .sink { completion in
                    switch completion {
                    case .finished:
                        Logger.member.log("Finished updating profile with \(firstname), \(lastname), \(mobileContactNumber)")
                        promise(.success(()))
                    case .failure(let err):
                        Logger.member.error("Failed to update profile \(err.localizedDescription)")
                        promise(.failure(err))
                    }
                } receiveValue: { profile in
                    appState.value.userData.memberProfile = profile
                }
                .store(in: cancelBag)
        }
    }

    func addAddress(address: Address) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            if appState.value.userData.memberProfile == nil {
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository.addAddress(address: address)
                .catch { error -> AnyPublisher<MemberProfile, Error> in
                    return checkMemberAuthenticationFailure(for: error)
                }
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
                .sink { completion in
                    switch completion {
                    case .finished:
                        Logger.member.log("Finished adding address")
                        promise(.success(()))
                    case .failure(let err):
                        Logger.member.error("Failed to add address \(err.localizedDescription)")
                        promise(.failure(err))
                    }
                } receiveValue: { profile in
                    appState.value.userData.memberProfile = profile
                }
                .store(in: cancelBag)
        }
    }
    
    func updateAddress(address: Address) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            if appState.value.userData.memberProfile == nil {
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository.updateAddress(address: address)
            
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
                    
                .sink { completion in
                    switch completion {
                    case .failure(let err):
                        Logger.member.error("Unable to update address: \(err.localizedDescription)")
                        promise(.failure(err))
                        
                    case.finished:
                        Logger.member.log("Successfully updated address")
                        promise(.success(()))
                    }
                } receiveValue: { profile in
                    appState.value.userData.memberProfile = profile
                }
                .store(in: cancelBag)
        }
    }
    
    func setDefaultAddress(addressId: Int) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            if appState.value.userData.memberProfile == nil {
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository.setDefaultAddress(addressId: addressId)
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
                .sink { completion in
                    switch completion {
                    case .finished:
                        Logger.member.log("Finished setting default address")
                        promise(.success(()))
                    case .failure(let err):
                        Logger.member.error("Failed to set default address: \(err.localizedDescription)")
                        promise(.failure(err))
                    }
                } receiveValue: { profile in
                    appState.value.userData.memberProfile = profile
                }
                .store(in: cancelBag)
        }
    }
    
    func removeAddress(addressId: Int) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            if appState.value.userData.memberProfile == nil {
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository.removeAddress(addressId: addressId)
            
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
                    
                .sink { completion in
                    switch completion {
                    case .finished:
                        Logger.member.log("Finished removing address")
                        promise(.success(()))
                    case .failure(let err):
                        Logger.member.error("Failed to remove address: \(err.localizedDescription)")
                        promise(.failure(err))
                    }
                } receiveValue: { profile in
                    appState.value.userData.memberProfile = profile
                }
                .store(in: cancelBag)
        }
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) {
        
        let cancelBag = CancelBag()
        pastOrders.wrappedValue.setIsLoading(cancelBag: cancelBag)
        

        if appState.value.userData.memberProfile == nil {
            Fail(outputType: [PlacedOrder]?.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { pastOrders.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit)
            .catch({ error -> AnyPublisher<[PlacedOrder]?, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
                .ensureTimeSpan(requestHoldBackTimeInterval)
                .eraseToAnyPublisher()
                .sinkToLoadable { pastOrders.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func getPlacedOrder(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int) {
        
        let cancelBag = CancelBag()
        orderDetails.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberProfile == nil {
            Fail(outputType: PlacedOrder.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { orderDetails.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getPlacedOrderDetails(forBusinessOrderId: businessOrderId)
            .catch({ error -> AnyPublisher<PlacedOrder, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .eraseToAnyPublisher()
            .sinkToLoadable { orderDetails.wrappedValue = $0 }
            .store(in: cancelBag)
        
    }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool) async throws -> UserMarketingOptionsFetch {
            var basketToken: String?
            if isCheckout {
                // Basket token is required if the member is not signed in because the
                // server is recording marketing options for that specific order.
                // Otherwise it should not be passed because it is against their member
                // preferences.
                if appState.value.userData.memberProfile == nil {
                    if let currentBasketToken = appState.value.userData.basket?.basketToken {
                        basketToken = currentBasketToken
                    }
                }
                // for isCheckout a basket should always exist even if not passed
                // as a request value
                if appState.value.userData.basket?.basketToken == nil {
                    throw UserServiceError.unableToProceedWithoutBasket
                }
            } else if appState.value.userData.memberProfile == nil {
                // the user should be signed in when not fetching options for checkout
                throw UserServiceError.memberRequiredToBeSignedIn
            }
            
        do {
            let result = try await webRepository.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken)
       
            try await Task.sleep(nanoseconds: UInt64(requestHoldBackTimeInterval) * 1_000_000_000)
            
            let _ = try await dbRepository.clearFetchedUserMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken)
            
            let finalResult = try await dbRepository.store(marketingOptionsFetch: result, isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken)
            
            return finalResult
        } catch {
            do {
                let result = try await dbRepository.userMarketingOptionsFetch(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken)
                
                if let optionsResult = result, let fetchTimeStamp = optionsResult.fetchTimestamp, fetchTimeStamp > AppV2Constants.Business.userCachedExpiry {
                    return optionsResult
                } else {
                    throw error
                }
            } catch {
                throw error
            }
        }
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest]) async throws -> UserMarketingOptionsUpdateResponse {
        
        // Only need the basket token if the user is not signed in
        var basketToken: String?
        if appState.value.userData.memberProfile == nil {
            if let currentBasketToken = appState.value.userData.basket?.basketToken {
                basketToken = currentBasketToken
            } else {
                throw UserServiceError.unableToProceedWithoutBasket
            }
        }
        
        let result = try await webRepository.updateMarketingOptions(options: options, basketToken: basketToken)
        
        return try await clearAllMarketingOptions(passThrough: result).singleOutput()
    }
    
    func checkRegistrationStatus(email: String) async throws -> CheckRegistrationResult {
        guard let basketToken = appState.value.userData.basket?.basketToken else {
            throw UserServiceError.unableToProceedWithoutBasket
        }
        return try await webRepository.checkRegistrationStatus(email: email, basketToken: basketToken)
    }
    
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult {
        return try await webRepository.requestMessageWithOneTimePassword(email: email, type: type)
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
            return clearMemberProfile(passThrough: error)
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
        switch keychain[memberSignedInKey] {
        case "facebook_login":
            LoginManager().logOut()
        case "google_sign_in":
            GIDSignIn.sharedInstance.signOut()
        default:
            break
        }
        // Clear the stored user login data
        appState.value.userData.memberProfile = nil
        keychain[memberSignedInKey] = nil
        // v1 does not clear this but if a user is signing out
        // it is reasonable to think they might not want the
        // delivery progress being shown to the next user
        Task {
            try await dbRepository.clearLastDeliveryOrderOnDevice()
        }
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
}

struct StubUserService: UserServiceProtocol {
    
    func restoreLastUser() async throws { }

    func login(email: String, password: String) async throws { }
    
    func login(email: String, oneTimePassword: String) async throws { }

    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) async throws { }

    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) async throws { }
    
    func loginWithGoogle(registeringFromScreen: RegisteringFromScreenType) async throws { }

    func resetPasswordRequest(email: String) -> Future<Void, Error> {
        stubFuture()
    }

    func resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?) async throws { }

    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) -> Future<Void, Error> {
        stubFuture()
    }
    
    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?) async throws { }

    func logout() -> Future<Void, Error> {
        stubFuture()
    }

    func getProfile(filterDeliveryAddresses: Bool) -> Future<Void, Error> {
        stubFuture()
    }

    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) -> Future<Void, Error> {
        stubFuture()
    }

    func addAddress(address: Address) -> Future<Void, Error> {
        stubFuture()
    }

    func updateAddress(address: Address) -> Future<Void, Error> {
        stubFuture()
    }

    func setDefaultAddress(addressId: Int) -> Future<Void, Error> {
        stubFuture()
    }

    func removeAddress(addressId: Int) -> Future<Void, Error> {
        stubFuture()
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) { }
    
    func getPlacedOrder(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int) { }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool) async throws -> UserMarketingOptionsFetch {
        return UserMarketingOptionsFetch(marketingPreferencesIntro: nil, marketingPreferencesGuestIntro: nil, marketingOptions: nil, fetchIsCheckout: nil, fetchNotificationsEnabled: nil, fetchBasketToken: nil, fetchTimestamp: nil)
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest]) async throws -> UserMarketingOptionsUpdateResponse {
        return UserMarketingOptionsUpdateResponse(email: .out, directMail: .out, notification: .out, telephone: .out, sms: .out)
    }

    func checkRegistrationStatus(email: String) async throws -> CheckRegistrationResult {
        CheckRegistrationResult(
            loginRequired: true,
            contacts: []
        )
    }
    
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult {
        OneTimePasswordSendResult(success: true, message: "SMS Sent")
    }
    
    private func stubFuture() -> Future<Void, Error> { Future { $0(.success(())) } }
}
