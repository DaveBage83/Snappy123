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
import AppsFlyerLib
import Firebase
import Frames

// internal errors for the developers - needs to be Equatable for unit tests
// but extension to Equatble outside of this file causes a syntax error
enum UserServiceError: Swift.Error, Equatable {
    case unableToEstablishAppleIdentityToken
    case unknownFacebookLoginProblem
    case missingFacebookLoginPrivileges
    case missingFacebookLoginAccessToken
    case unknownGoogleLoginProblem
    case memberRequiredToBeSignedIn
    case memberDriverTypeRequired
    case unableToRegisterWhileMemberSignIn
    case unableToLogin
    case unableToRegister
    case unableToResetPasswordRequest([String: [String]])
    case unableToResetPassword
    case unableToLoginAfterResetingPassword(String)
    case unableToDecodeResponse(String)
    case unableToPersistResult
    case unableToProceedWithoutBasket
    case unableToProceedWithoutStoreSelection
    case invalidParameters([String])
    case networkError
    case mobileNumberAlreadyVerified // internal - view models should prevent this
    case unableToSendMobileVerificationCode
    case mobileNumberAlreadyVerifiedWithAnotherMember
    case unableToSendMobileVerificationCodeToSavedNumber
    case unkownError(String)
}

enum RegisteringFromScreenType: String {
    case unknown
    case startScreen = "start_screen"
    case accountTab = "account_tab"
    case billingCheckout = "billing_checkout"
    case webReferAFriend = "web_refer_friend"
    case freeDelivery = "free_delivery"
}

enum LoginType: String {
    case email
    case facebook
    case appleSignIn = "apple_sign_in"
    case googleSignIn = "google_sign_in"
}

enum LoginContext: Equatable {
    case outsideCheckout(LoginType)
    case atCheckout(LoginType)
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
        case .memberDriverTypeRequired:
            return "function requires a driver member"
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
        case let .unableToLoginAfterResetingPassword(errorMessage):
            return Strings.ResetPasswordCustom.unableToLoginAfterReset.localizedFormat(errorMessage)
        case let .unableToDecodeResponse(rawResponse):
            return "Unable to decode response: " + rawResponse
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        case .unableToProceedWithoutStoreSelection:
            return "Unable to proceed because of missing store selection"
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        case .networkError:
            return "There is a problem with the network"
        case .mobileNumberAlreadyVerified:
            return "The mobile number is already verified"
        case .unableToSendMobileVerificationCode:
            return Strings.VerifyMobileNumber.RequestCodeErrors.unableToSendMobileVerificationCode.localized
        case .mobileNumberAlreadyVerifiedWithAnotherMember:
            return Strings.VerifyMobileNumber.RequestCodeErrors.mobileNumberAlreadyVerifiedWithAnotherMember.localized
        case .unableToSendMobileVerificationCodeToSavedNumber:
            return Strings.VerifyMobileNumber.RequestCodeErrors.unableToSendMobileVerificationCodeToSavedNumber.localized
        case let .unkownError(description):
            return "Unknown error: \(description)"
        }
    }
}

protocol MemberServiceProtocol {
    func login(email: String, password: String, atCheckout: Bool) async throws
    func login(email: String, oneTimePassword: String, atCheckout: Bool) async throws
    
    // Apple Sign In and Facebook Login automatically create a new member if there
    // was no corresponding account. The registeringFromScreen is set to help
    // record the route that the customer was captured.
    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) async throws
    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) async throws
    func loginWithGoogle(registeringFromScreen: RegisteringFromScreenType) async throws
    
    // Sends a password reset code to the member email. The recieved code along with
    // the new password is sent using the resetPassword method below.
    func resetPasswordRequest(email: String) async throws
    
    // Update password and can automatically sign in succesfully registering members
    // Notes:
    // resetToken - from the resetPasswordRequest and is required if the customer is not signed in
    // currentPassword - required when the resetToken is not supplied (general path when customer signed in)
    // email - always optional but required to sign in the member after the password has been changed
    func resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?, atCheckout: Bool) async throws
    
    // Automatically signs in succesfully registering members
    // Notes:
    // - default billing address can be set via member.defaultBillingAddress
    // - default delivery address can be set via the first delivery address in member.savedAddresses
    
    /// Following method returns a Bool to indicate if the user is already registered or not. If the user is registered, the API
    /// returns an error but we do not throw that error here - instead we automatically log the user in. We can use this Boolean
    /// to present an alert to the user to inform them that their account was found and that they have been logged in.
    func register(
        member: MemberProfileRegisterRequest,
        password: String,
        referralCode: String?,
        marketingOptions: [UserMarketingOptionResponse]?,
        atCheckout: Bool
    ) async throws -> Bool
    
    //* methods that require a member to be signed in *//
    func logout() async throws
    
    func restoreLastUser() async throws
    
    // When filterDeliveryAddresses is true the delivery addresses will be filtered for
    // the selected store. Use the parameter when a result is required during the
    // checkout flow.
    func getProfile(filterDeliveryAddresses: Bool, loginContext: LoginContext?) async throws
    
    // These address functions are designed to be used from the member account UI area
    // because they return the unfiltered delivery addresses
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) async throws
    func addAddress(address: Address) async throws
    func updateAddress(address: Address) async throws
    func setDefaultAddress(addressId: Int) async throws
    func removeAddress(addressId: Int) async throws
    
    func getSavedCards() async throws -> [MemberCardDetails]
    func saveNewCard(token: String) async throws
    func deleteCard(id: String) async throws
    
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) async
    func getPlacedOrder(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int) async
    
    func getDriverSessionSettings() async throws -> DriverSessionSettings
    
    func requestMobileVerificationCode() async throws -> Bool
    func checkMobileVerificationCode(verificationCode: String) async throws
    
    func checkRetailMembershipId() async throws -> CheckRetailMembershipIdResult
    func storeRetailMembershipId(retailMemberId: String) async throws
    
    //* methods where a signed in user is optional *//
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool) async throws -> UserMarketingOptionsFetch
    func updateMarketingOptions(options: [UserMarketingOptionRequest], channel: Int?) async throws -> UserMarketingOptionsUpdateResponse
    
    //* methods where a signed in user would not expected *//
    func checkRegistrationStatus(email: String) async throws -> CheckRegistrationResult
    func requestMessageWithOneTimePassword(email: String, type: OneTimePasswordSendType) async throws -> OneTimePasswordSendResult
}

struct UserService: MemberServiceProtocol {

    let webRepository: UserWebRepositoryProtocol
    let dbRepository: UserDBRepositoryProtocol
    let appState: Store<AppState>
    let eventLogger: EventLoggerProtocol
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    private let previousSessionWithoutAppDeletionKey = "previousSessionWithoutAppDeletion"
    private let memberSignedInKey = "memberSignedIn"
    private let driverV1SessionKey = "driverV1Session"
    
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
    
    func login(email: String, password: String, atCheckout: Bool) async throws {
        
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
        try await getProfile(filterDeliveryAddresses: false, loginContext: atCheckout ? .atCheckout(.email) : .outsideCheckout(.email))
        
        // Mark the user login state as "one_time_password" in the keychain
        keychain[memberSignedInKey] = "email"
        
        // invalidate the cached results
        guaranteeMainThread {
            appState.value.staticCacheData.mentionMeRefereeResult = nil
            appState.value.staticCacheData.mentionMeDashboardResult = nil
        }
    }
    
    func login(email: String, oneTimePassword: String, atCheckout: Bool) async throws {
        
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
        try await getProfile(filterDeliveryAddresses: false, loginContext: atCheckout ? .atCheckout(.email) : .outsideCheckout(.email))
        
        // Mark the user login state as "one_time_password" in the keychain
        keychain[memberSignedInKey] = "one_time_password"
        
        // invalidate the cached results
        appState.value.staticCacheData.mentionMeRefereeResult = nil
        appState.value.staticCacheData.mentionMeDashboardResult = nil
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
        try await getProfile(
            filterDeliveryAddresses: false,
            loginContext: registeringFromScreen == .billingCheckout ? .atCheckout(.appleSignIn) : .outsideCheckout(.appleSignIn)
        )
        
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
            
            try await getProfile(
                filterDeliveryAddresses: false,
                loginContext: registeringFromScreen == .billingCheckout ? .atCheckout(.facebook) : .outsideCheckout(.facebook)
            )
            keychain[memberSignedInKey] = "facebook_login"
            
            // invalidate the cached results
            guaranteeMainThread {
                appState.value.staticCacheData.mentionMeRefereeResult = nil
                appState.value.staticCacheData.mentionMeDashboardResult = nil
            }
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
                        with: GIDConfiguration(clientID: AppV2Constants.Business.googleSignInClientId),
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
            
            try await getProfile(
                filterDeliveryAddresses: false,
                loginContext: registeringFromScreen == .billingCheckout ? .atCheckout(.googleSignIn) : .outsideCheckout(.googleSignIn)
            )
            keychain[memberSignedInKey] = "google_sign_in"
        }
        
    }
               
    func resetPasswordRequest(email: String) async throws {
        
        let result = try await webRepository.resetPasswordRequest(email: email).singleOutput()
        var returnedError: Error?
        do {
            // since [String: Any] is not decodable the type Data needs to
            // be returned by the web repository and the JSON decoded here
            if let dictionayResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any] {
                if
                    let success = dictionayResult["success"] as? Bool,
                    success
                {
                    // registration endpoint call succeded
                    return
                } else {
                    returnedError = UserServiceError.unableToResetPasswordRequest(stripToFieldErrors(from: dictionayResult))
                }
            } else {
                returnedError = UserServiceError.unableToDecodeResponse(String(decoding: result, as: UTF8.self))
            }
        } catch {
            returnedError = UserServiceError.unableToDecodeResponse(String(decoding: result, as: UTF8.self))
        }
        
        if let returnedError = returnedError {
            throw returnedError
        }
    }
    
    func resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?, atCheckout: Bool) async throws  {
        
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
            var knownEmail = email
            if knownEmail == nil {
                knownEmail = webResult.email
            }
            if let email = knownEmail, appState.value.userData.memberProfile == nil {
                do {
                    try await login(email: email, password: password, atCheckout: atCheckout)
                } catch {
                    throw UserServiceError.unableToLoginAfterResetingPassword(error.localizedDescription)
                }
            }
        } else {
            throw UserServiceError.unableToResetPassword
        }
    }

    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?, atCheckout: Bool) async throws -> Bool {
        
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
                try await getProfile(filterDeliveryAddresses: false, loginContext: nil)
                
                // Mark the user login state as "email" in the keychain
                keychain[memberSignedInKey] = "email"

                // invalidate the cached results
                appState.value.staticCacheData.mentionMeRefereeResult = nil
                appState.value.staticCacheData.mentionMeDashboardResult = nil
            } else {
                throw UserServiceError.unableToRegister
            }
            
        } catch {
            // see OAPIV2-580, try to login a member where member
            // already registered is returned
            if let registerError = error as? APIErrorResult {
                if registerError.errorCode == 150001 {
                    do {
                        try await login(email: member.emailAddress, password: password, atCheckout: atCheckout)
                        return true
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
        return false
    }
    
    func logout() async throws {
        
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        do {
            let logoutResult = try await webRepository
                .logout(basketToken: appState.value.userData.basket?.basketToken)
                .singleOutput()
            // There should not ever be a case where the
            // API returns false instead of an error
            if logoutResult {
                let _ = try await dbRepository.clearMemberProfile().singleOutput()
                let _ = try await dbRepository.clearAllFetchedUserMarketingOptions().singleOutput()
                try await markUserSignedOutAndClearLastDeliveryOrder()
            }
        } catch {
            let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            throw error
        }
    }
    
    func restoreLastUser() async throws {
        guard keychain[memberSignedInKey] != nil else { return }
        
        do {
            try await getProfile(filterDeliveryAddresses: false, loginContext: nil)
        } catch {
            throw error
        }
    }
    
    private func setProfileEventUUID(to profileUUID: String) {
        eventLogger.setCustomerID(profileUUID: profileUUID)
    }
    
    private func sendLoginEvent(loginContext: LoginContext) {
        eventLogger.sendEvent(for: .login, with: .appsFlyer, params: [:])

        let appEvent: AppEvent
        let method: LoginType
        switch loginContext {
        case let .atCheckout(loginType):
            appEvent = .loginAtCheckout
            method = loginType
        case let .outsideCheckout(loginType):
            appEvent = .login
            method = loginType
        }
        
        eventLogger.sendEvent(for: appEvent, with: .firebaseAnalytics, params: [AnalyticsParameterMethod: method.rawValue])
    }
    
    func getProfile(filterDeliveryAddresses: Bool, loginContext: LoginContext?) async throws {
        let storeId = filterDeliveryAddresses ? appState.value.userData.selectedStore.value?.id : nil
        
        // We do not need to check if member is signed in here as getProfile() is only triggered with successful login
        
        var profile: MemberProfile?
        var profileFromAPI = true
        
        do {
            do {
                
                // first try to get the profile from the API
                profile = try await webRepository
                    .getProfile(storeId: storeId)
                    .ensureTimeSpan(requestHoldBackTimeInterval)
                    .singleOutput()
                
            } catch {
                if try await checkAndProcessMemberAuthenticationFailureASYNC(for: error) {
                    throw error
                } else {
                    // failed to fetch from the API so try to get a
                    // result from the persistent store
                    if
                        let memberResult = try await dbRepository.memberProfile(storeId: storeId).singleOutput(),
                        // check that the data is not too old
                        let fetchTimestamp = memberResult.fetchTimestamp,
                        fetchTimestamp > AppV2Constants.Business.userCachedExpiry
                    {
                        profile = memberResult
                        profileFromAPI = false
                    } else {
                        throw error
                    }
                }
            }
            
            guard let profile = profile else { return }
            
            if profileFromAPI {
                // need to remove the previous result in the
                // database and store a new value
                let _ = try await dbRepository.clearMemberProfile().singleOutput()
                let _ = try await dbRepository.store(memberProfile: profile, forStoreId: storeId).singleOutput()
            }
            
            Logger.member.info("Successfully retrieved profile")
            
            guaranteeMainThread {
                appState.value.userData.memberProfile = profile
            }
            
            setProfileEventUUID(to: profile.uuid)
            if let loginContext = loginContext {
                sendLoginEvent(loginContext: loginContext)
            }
			
        } catch {
            Logger.member.error("Failed to get user profile: \(error.localizedDescription)")
            throw error
        }

    }
    
    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) async throws {
        
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        do {
            let profile = try await webRepository
                .updateProfile(
                    firstname: firstname,
                    lastname: lastname,
                    mobileContactNumber: mobileContactNumber
                )
                .singleOutput()
            let _ = try await dbRepository.clearMemberProfile().singleOutput()
            let _ = try await dbRepository.store(memberProfile: profile, forStoreId: nil).singleOutput()
            appState.value.userData.memberProfile = profile
            Logger.member.log("Finished updating profile with \(firstname), \(lastname), \(mobileContactNumber)")
        } catch {
            let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            Logger.member.error("Failed to update profile \(error.localizedDescription)")
            throw error
        }
    }

    func addAddress(address: Address) async throws {
        
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        do {
            let profile = try await webRepository.addAddress(address: address).singleOutput()
            let _ = try await dbRepository.clearMemberProfile().singleOutput()
            let _ = try await dbRepository.store(memberProfile: profile, forStoreId: nil).singleOutput()
            appState.value.userData.memberProfile = profile
            Logger.member.log("Finished adding address")
        } catch {
            let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            Logger.member.error("Failed to add address \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateAddress(address: Address) async throws {
        
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        do {
            let profile = try await webRepository.updateAddress(address: address).singleOutput()
            let _ = try await dbRepository.clearMemberProfile().singleOutput()
            let _ = try await dbRepository.store(memberProfile: profile, forStoreId: nil).singleOutput()
            appState.value.userData.memberProfile = profile
            Logger.member.log("Successfully updated address")
        } catch {
            let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            Logger.member.error("Unable to update address: \(error.localizedDescription)")
            throw error
        }
    }
    
    func setDefaultAddress(addressId: Int) async throws {
        
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        do {
            let profile = try await webRepository.setDefaultAddress(addressId: addressId).singleOutput()
            let _ = try await dbRepository.clearMemberProfile().singleOutput()
            let _ = try await dbRepository.store(memberProfile: profile, forStoreId: nil).singleOutput()
            appState.value.userData.memberProfile = profile
            Logger.member.log("Finished setting default address")
        } catch {
            let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            Logger.member.error("Failed to set default address: \(error.localizedDescription)")
            throw error
        }
    }
    
    func removeAddress(addressId: Int) async throws {
        
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        do {
            let profile = try await webRepository.removeAddress(addressId: addressId).singleOutput()
            let _ = try await dbRepository.clearMemberProfile().singleOutput()
            let _ = try await dbRepository.store(memberProfile: profile, forStoreId: nil).singleOutput()
            appState.value.userData.memberProfile = profile
            Logger.member.log("Finished removing address")
        } catch {
            let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            Logger.member.error("Failed to remove address: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getSavedCards() async throws -> [MemberCardDetails] {
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        return try await webRepository.getSavedCards()
    }
    
    func saveNewCard(token: String) async throws {
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        _ = try await webRepository.saveNewCard(token: token)
    }
    
    func deleteCard(id: String) async throws {
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        
        _ = try await webRepository.deleteCard(id: id)
    }
    
    // Does not throw - error returned via the LoadableSubject
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) async {
        
        let cancelBag = CancelBag()
        pastOrders.wrappedValue = .isLoading(last: nil, cancelBag: cancelBag)
        
        guard appState.value.userData.memberProfile != nil else {
            pastOrders.wrappedValue = .failed(UserServiceError.memberRequiredToBeSignedIn)
            return
        }
        
        do {
            let placedOrder = try await webRepository
                .getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit)
                .ensureTimeSpan(requestHoldBackTimeInterval)
                .singleOutput()
            
            pastOrders.wrappedValue = .loaded(placedOrder)
        } catch {
            // always report the webRepository.getPlacedOrderDetails(forBusinessOrderId: businessOrderId)
            // error over subsequent internal errors
            do {
                let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            } catch {}
            pastOrders.wrappedValue = .failed(error)
        }
    }
    
    // Does not throw - error returned via the LoadableSubject
    func getPlacedOrder(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int) async {

        let cancelBag = CancelBag()
        orderDetails.wrappedValue = .isLoading(last: nil, cancelBag: cancelBag)
        
        guard appState.value.userData.memberProfile != nil else {
            orderDetails.wrappedValue = .failed(UserServiceError.memberRequiredToBeSignedIn)
            return
        }
        
        do {
            let placedOrder = try await webRepository
                .getPlacedOrderDetails(forBusinessOrderId: businessOrderId)
                .ensureTimeSpan(requestHoldBackTimeInterval)
                .singleOutput()
            
            orderDetails.wrappedValue = .loaded(placedOrder)
        } catch {
            // always report the webRepository.getPlacedOrderDetails(forBusinessOrderId: businessOrderId)
            // error over subsequent internal errors
            do {
                let _ = try await checkAndProcessMemberAuthenticationFailureASYNC(for: error)
            } catch {}
            orderDetails.wrappedValue = .failed(error)
        }
    }
    
    func getDriverSessionSettings() async throws -> DriverSessionSettings {
        if appState.value.userData.memberProfile == nil {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        if appState.value.userData.memberProfile?.type != .driver {
            throw UserServiceError.memberDriverTypeRequired
        }
        do {
            // The v1 session token is kept in the keychain and when known passed back to the server.
            // This is to minimise the need for the server to allocate new tokens. It will detect if
            // the token is still valid and if not return a new v1 session token.
            let driverSessionSettings = try await webRepository.getDriverSessionSettings(withKnownV1SessionToken: keychain[driverV1SessionKey])
            keychain[driverV1SessionKey] = driverSessionSettings.v1sessionToken
            return driverSessionSettings
        } catch {
            throw error
        }
    }
    
    // returns true if a dialog to enter the code can be shown
    func requestMobileVerificationCode() async throws -> Bool {
        if let memberProfile = appState.value.userData.memberProfile {
            if memberProfile.mobileValidated {
                throw UserServiceError.mobileNumberAlreadyVerified
            }
            let result = try await webRepository.requestMobileVerificationCode()
            
            if result.status {
                if let sentStatus = result.inviteVerificationStatus {
                    if sentStatus == .failed {
                        throw UserServiceError.unableToSendMobileVerificationCode
                    } else {
                        return true
                    }
                } else if let referFriendBalance = result.referFriendBalance {
                    // member already has a verified mobile number
                    try await updateMobileValidated(referFriendBalance: referFriendBalance)
                }
            } else {
                if result.message == "MOBILE_USED_WITH_INVITE" {
                    throw UserServiceError.mobileNumberAlreadyVerifiedWithAnotherMember
                } else {
                    throw UserServiceError.unableToSendMobileVerificationCodeToSavedNumber
                }
            }
            
        } else {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        return false
    }
    
    #warning("Waiting on https://snappyshopper.atlassian.net/browse/BGB-733")
    func checkMobileVerificationCode(verificationCode: String) async throws {
        if let memberProfile = appState.value.userData.memberProfile {
            if memberProfile.mobileValidated {
                throw UserServiceError.mobileNumberAlreadyVerified
            }
            let result = try await webRepository.checkMobileVerificationCode(verificationCode: verificationCode)
            
            //try await updateMobileValidated()
        } else {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
    }
    
    private func updateMobileValidated(referFriendBalance: Double) async throws {
        if let memberProfile = appState.value.userData.memberProfile {
            let updatedMemberProfile = MemberProfile(
                uuid: memberProfile.uuid,
                firstname: memberProfile.firstname,
                lastname: memberProfile.lastname,
                emailAddress: memberProfile.emailAddress,
                type: memberProfile.type,
                referFriendCode: memberProfile.referFriendCode,
                referFriendBalance: referFriendBalance,
                numberOfReferrals: memberProfile.numberOfReferrals,
                mobileContactNumber: memberProfile.mobileContactNumber,
                mobileValidated: true,
                acceptedMarketing: memberProfile.acceptedMarketing,
                defaultBillingDetails: memberProfile.defaultBillingDetails,
                savedAddresses: memberProfile.savedAddresses,
                fetchTimestamp: memberProfile.fetchTimestamp
            )
            
            appState.value.userData.memberProfile = updatedMemberProfile
            
            // need to remove the previous result in the
            // database and store a new value
            let _ = try await dbRepository.clearMemberProfile().singleOutput()
            let _ = try await dbRepository.store(memberProfile: updatedMemberProfile, forStoreId: nil).singleOutput()
        }
    }
    
    func checkRetailMembershipId() async throws -> CheckRetailMembershipIdResult {
        guard appState.value.userData.memberProfile != nil else {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        guard let basketToken = appState.value.userData.basket?.basketToken else {
            throw UserServiceError.unableToProceedWithoutBasket
        }
        let result = try await webRepository.checkRetailMembershipId(basketToken: basketToken)
        if result.status == false {
            throw UserServiceError.unkownError("checkRetailMembershipId status = false")
        }
        return result
    }
    
    func storeRetailMembershipId(retailMemberId: String) async throws {
        guard appState.value.userData.memberProfile != nil else {
            throw UserServiceError.memberRequiredToBeSignedIn
        }
        guard let basketToken = appState.value.userData.basket?.basketToken else {
            throw UserServiceError.unableToProceedWithoutBasket
        }
        guard let storeId = appState.value.userData.selectedStore.value?.id else {
            throw UserServiceError.unableToProceedWithoutStoreSelection
        }
        let result = try await webRepository.storeRetailMembershipId(
            storeId: storeId,
            basketToken: basketToken,
            retailMemberId: retailMemberId
        )
        if result.success == false {
            throw UserServiceError.unkownError("storeRetailMembershipId success = false")
        }
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
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], channel: Int? = nil) async throws -> UserMarketingOptionsUpdateResponse {
        
        // Only need the basket token if the user is not signed in
        var basketToken: String?
        if appState.value.userData.memberProfile == nil {
            if let currentBasketToken = appState.value.userData.basket?.basketToken {
                basketToken = currentBasketToken
            } else {
                throw UserServiceError.unableToProceedWithoutBasket
            }
        }
        
        let result = try await webRepository.updateMarketingOptions(options: options, basketToken: basketToken, channel: channel)
        
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
    private func checkAndProcessMemberAuthenticationFailureASYNC(for error: Error) async throws -> Bool {
        if
            let error = error as? APIErrorResult,
            error.errorCode == 401
        {
            try await markUserSignedOutAndClearLastDeliveryOrder()
            let _ = try await dbRepository.clearMemberProfile().singleOutput()
            let _ = try await dbRepository.clearAllFetchedUserMarketingOptions().singleOutput()
            return true
        }
        return false
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
        guaranteeMainThread {
            appState.value.userData.memberProfile = nil
        }
        eventLogger.clearCustomerID()
        keychain[memberSignedInKey] = nil
        // invalidate the cached results
        appState.value.staticCacheData.mentionMeRefereeResult = nil
        appState.value.staticCacheData.mentionMeDashboardResult = nil
    }
    
    private func markUserSignedOutAndClearLastDeliveryOrder() async throws {
        markUserSignedOut()
        // v1 does not clear this but if a user is signing out
        // it is reasonable to think they might not want the
        // delivery progress being shown to the next user
        try await dbRepository.clearLastDeliveryOrderOnDevice()
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
}

struct StubUserService: MemberServiceProtocol {

    func restoreLastUser() async throws { }

    func login(email: String, password: String, atCheckout: Bool) async throws { }
    
    func login(email: String, oneTimePassword: String, atCheckout: Bool) async throws { }

    func login(appleSignInAuthorisation: ASAuthorization, registeringFromScreen: RegisteringFromScreenType) async throws { }

    func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType) async throws { }
    
    func loginWithGoogle(registeringFromScreen: RegisteringFromScreenType) async throws { }

    func resetPasswordRequest(email: String) async throws { }

    func resetPassword(resetToken: String?, logoutFromAll: Bool, email: String?, password: String, currentPassword: String?, atCheckout: Bool) async throws { }

    func register(member: MemberProfileRegisterRequest, password: String, referralCode: String?, marketingOptions: [UserMarketingOptionResponse]?, atCheckout: Bool) async throws -> Bool {
        return false
    }

    func logout() async throws { }

    func getProfile(filterDeliveryAddresses: Bool, loginContext: LoginContext?) async throws { }

    func updateProfile(firstname: String, lastname: String, mobileContactNumber: String) async throws { }

    func addAddress(address: Address) async throws { }

    func updateAddress(address: Address) async throws { }

    func setDefaultAddress(addressId: Int) async throws { }

    func removeAddress(addressId: Int) async throws { }
    
    func getSavedCards() async throws -> [MemberCardDetails] { [] }
    
    func saveNewCard(token: String) async throws { }
    
    func deleteCard(id: String) async throws { }
    
    func getPastOrders(pastOrders: LoadableSubject<[PlacedOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) async { }
    
    func getPlacedOrder(orderDetails: LoadableSubject<PlacedOrder>, businessOrderId: Int) async { }
    
    func getDriverSessionSettings() async throws -> DriverSessionSettings {
        DriverSessionSettings(
            v1sessionToken: "String",
            endDriverShiftRestrictions: .none,
            canRefundItems: true,
            canRequestUnassignedOrders: true,
            automaticEnRouteDetection: true,
            appDriverStoreSettings: nil
        )
    }
    
    func checkRetailMembershipId() async throws -> CheckRetailMembershipIdResult {
        return CheckRetailMembershipIdResult(status: true, retailerHasMembership: true, placedOrdersWithRetailerMembership: 0, retailerMembershipId: nil)
    }
    
    func storeRetailMembershipId(retailMemberId: String) async throws { }
    
    func requestMobileVerificationCode() async throws -> Bool {
        return true
    }
    
    func checkMobileVerificationCode(verificationCode: String) async throws { }
    
    func getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool) async throws -> UserMarketingOptionsFetch {
        return UserMarketingOptionsFetch(marketingPreferencesIntro: nil, marketingPreferencesGuestIntro: nil, marketingOptions: nil, fetchIsCheckout: nil, fetchNotificationsEnabled: nil, fetchBasketToken: nil, fetchTimestamp: nil)
    }
    
    func updateMarketingOptions(options: [UserMarketingOptionRequest], channel: Int?) async throws -> UserMarketingOptionsUpdateResponse {
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
}
