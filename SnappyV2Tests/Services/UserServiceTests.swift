//
//  UserServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 10/02/2022.
//

import XCTest
import Combine
import AuthenticationServices
@testable import SnappyV2

// 3rd party
import KeychainAccess
import Firebase

class UserServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedUserWebRepository!
    var mockedDBRepo: MockedUserDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: UserService!
    let keychain = Keychain(service: Bundle.main.bundleIdentifier!)

    override func setUp() {
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedUserWebRepository()
        mockedDBRepo = MockedUserDBRepository()
        sut = UserService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState,
            eventLogger: mockedEventLogger
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
        keychain["memberSignedIn"] = nil
        keychain["driverV1Session"] = nil
    }
}

final class LoginByEmailAndPasswordTests: UserServiceTests {
    
    // MARK: - func login(email:password:)
    
    func test_successfulLoginByEmailPassword_whenNotAtCheckoutAndDeviceTokenEstablished_thenNotAtCheckoutEvents() async throws {

        let atCheckout = false
        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        appState.value.system.notificationDeviceToken = "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad"
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", password: "password321!", basketToken: nil, notificationDeviceToken: appState.value.system.notificationDeviceToken),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(.outside), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(.outside), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .success(LoginResult.mockedSuccessDataWithoutRegistering)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", password: "password321!", atCheckout: atCheckout)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulLoginByEmailPassword_whenAtCheckoutAndDeviceTokenNotEstablished_thenAtCheckoutEvents() async throws {

        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData
        appState.value.system.notificationDeviceToken = nil

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", password: "password321!", basketToken: nil, notificationDeviceToken: nil),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(.in), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(.in), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .success(LoginResult.mockedSuccessDataWithoutRegistering)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", password: "password321!", atCheckout: true)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulLoginByEmailPassword_whenBasketSet() async throws {

        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(
                email: "h.dover@gmail.com",
                password: "password321!",
                basketToken: appState.value.userData.basket?.basketToken,
                notificationDeviceToken: nil
            ),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(.outside), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(.outside), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .success(LoginResult.mockedSuccessDataWithoutRegistering)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", password: "password321!", atCheckout: false)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessfulLoginByEmailPassword() async throws {
        let failError = APIErrorResult.mockedUnauthorized
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "failme@gmail.com", password: "password321!", basketToken: nil, notificationDeviceToken: nil),
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .failure(failError)
        
        do {
            try await sut.login(email: "failme@gmail.com", password: "password321!", atCheckout: false)
            XCTFail("Unexpected login success", file: #file, line: #line)
        } catch {
            if let loginError = error as? APIErrorResult {
                XCTAssertEqual(loginError, failError, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }

}

final class LoginByEmailAndOneTimePasswordTests: UserServiceTests {
    
    // MARK: - func login(email: String, oneTimePassword: String) async throws -> Void
    
    func test_successfulLoginByEmailOneTimePassword_whenNotAtCheckoutAndDeviceTokenEstablished_thenNotAtCheckoutEvents() async {
        let atCheckout = false
        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        appState.value.system.notificationDeviceToken = "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad"
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83", basketToken: nil, notificationDeviceToken: appState.value.system.notificationDeviceToken),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(atCheckout ? .in : .outside), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(atCheckout ? .in : .outside), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .success(loginData)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83", atCheckout: atCheckout)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulLoginByEmailOneTimePassword_whenAtCheckoutAndDeviceTokenNotEstablished_thenAtCheckoutEvents() async {
        let atCheckout = true
        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83", basketToken: nil, notificationDeviceToken: nil),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(atCheckout ? .in : .outside), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(atCheckout ? .in : .outside), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .success(loginData)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83", atCheckout: atCheckout)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_successfulLoginByEmailOneTimePassword_whenBasketSet() async {
        
        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(
                email: "h.dover@gmail.com",
                oneTimePassword: "6B9A83",
                basketToken: appState.value.userData.basket?.basketToken,
                notificationDeviceToken: nil
            ),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(.outside), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(.outside), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .success(loginData)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83", atCheckout: false)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccessfulLoginByEmailOneTimePassword() async {
        
        let failError = APIErrorResult.mockedUnauthorized
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "failme@gmail.com", oneTimePassword: "6B9A83", basketToken: nil, notificationDeviceToken: nil),
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .failure(failError)
        
        do {
            try await sut.login(email: "failme@gmail.com", oneTimePassword: "6B9A83", atCheckout: false)
            XCTFail("Unexpected login success", file: #file, line: #line)
        } catch {
            if let loginError = error as? APIErrorResult {
                XCTAssertEqual(loginError, failError, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }

}

// Cannot add Apple Sign In unit tests because ASAuthorization instances cannot be manually created. Some
// suggestions like https://lukemjones.medium.com/testing-apple-sign-in-framework-a1eca21f1116 but they do not
// address this service layer approach and would require refactoring and moving responsibilities.
//final class AppleSignInTests: UserServiceTests {
//
//    // MARK: - func login(appleSignInAuthorisation:)
//
//}

// Cannot add Facebook Login In unit tests because LoginManager instances require realworld interaction.
//final class FacebookLoginTests: UserServiceTests {
//
//    // MARK: - func loginWithFacebook(registeringFromScreen: RegisteringFromScreenType)
//
//}

// Cannot add Google Sign In unit tests because GIDSignIn instances require realworld interaction.
//final class GoogleSignInTests: UserServiceTests {
//
//    // MARK: - func loginWithGoogle(registeringFromScreen: RegisteringFromScreenType)
//
//}

final class ResetPasswordRequestTests: UserServiceTests {
    
    // MARK: - func resetPasswordRequest(email:)
    
    func test_succesfulResetPasswordRequest_whenStanardResponse_returnSuccess() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordRequest(email: "cogin.waterman@me.com")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordRequestResponse = .success(Data.mockedSuccessData)
        
        do {
            try await sut.resetPasswordRequest(email: "cogin.waterman@me.com")
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }

    func test_unsuccesfulResetPasswordRequest_whenUnexpectedJSONResponse_returnError() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordRequest(email: "cogin.waterman@me.com")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordRequestResponse = .success(Data.mockedFailureData)
        
        do {
            try await sut.resetPasswordRequest(email: "cogin.waterman@me.com")
            XCTFail("Unexpected Reset Password Request success", file: #file, line: #line)
        } catch {
            if let loginError = error as? UserServiceError {
                XCTAssertEqual(loginError, UserServiceError.unableToResetPasswordRequest([:]), file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_succesfulResetPasswordRequest_whenNoJSONResponse_returnError() async {
        
        let data = Data.mockedNonJSONData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordRequest(email: "cogin.waterman@me.com")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordRequestResponse = .success(data)
        

        do {
            try await sut.resetPasswordRequest(email: "cogin.waterman@me.com")
            XCTFail("Unexpected Reset Password Request success", file: #file, line: #line)
        } catch {
            if let loginError = error as? UserServiceError {
                XCTAssertEqual(loginError, UserServiceError.unableToDecodeResponse(String(decoding: data, as: UTF8.self)), file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
}

final class PasswordAndSignInTests: UserServiceTests {
    
    // MARK: - resetPasswordAndSignIn(resetToken:logoutFromAll:password:atCheckout:)
    
    func test_succesfulResetPasswordAndSignIn_whenMemberNotSignedIn_resetSucces() async {
        let data = true
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordAndSignIn(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                password: "password1"
            ),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(.outside), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(.outside), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordAndSignInResponse = .success(data)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut
                .resetPasswordAndSignIn(
                    resetToken: "123456789abcdef",
                    logoutFromAll: false,
                    password: "password1",
                    atCheckout: false
                )
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        }
    }
    
    func test_unsuccesfulResetPasswordAndSignIn_whenMemberAlreadySignedIn_returnError() async {

        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        
        do {
            try await sut.resetPasswordAndSignIn(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                password: "password1",
                atCheckout: false
            )
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            if let loginError = error as? UserServiceError {
                XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedOut, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        }
    }
    
    func test_unsuccesfulResetPasswordAndSignIn_whenMemberNotSignedInButErrorReturned_returnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordAndSignIn(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                password: "password1"
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordAndSignInResponse = .failure(networkError)
        
        do {
            try await sut
                .resetPasswordAndSignIn(
                    resetToken: "123456789abcdef",
                    logoutFromAll: false,
                    password: "password1",
                    atCheckout: false
                )
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        }
    }
    
    func test_unsuccesfulResetPasswordAndSignIn_whenMemberNotSignedInWhenErrorReturnedFetchingMember_returnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let data = true
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordAndSignIn(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                password: "password1"
            ),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordAndSignInResponse = .success(data)
        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        
        do {
            try await sut
                .resetPasswordAndSignIn(
                    resetToken: "123456789abcdef",
                    logoutFromAll: false,
                    password: "password1",
                    atCheckout: false
                )
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            self.mockedEventLogger.verify()
        }
    }
}

final class RegisterTests: UserServiceTests {
    
    // MARK: - func register(member:password:referralCode:marketingOptions:)
    
    func test_succesfulRegister_whenMemberNotAlreadyRegistered_registerLoginSuccess() async {
        
        let memberRequest = MemberProfileRegisterRequest.mockedData
        let member = MemberProfile.mockedData
        let data = UserRegistrationResult.mockedSucess
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: memberRequest,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .setToken(to: data.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: member.uuid)])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .success(data)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        
        do {
            let userRegistered = try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil, atCheckout: false)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
            XCTAssertFalse(userRegistered)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_succesfulRegister_whenMemberAlreadyRegisteredWithSameEmailAndPasswordMatch_registerLoginSuccess() async {
        
        let memberRequest = MemberProfileRegisterRequest.mockedData
        let data = APIErrorResult.mockedMemberAlreadyRegistered
        let member = MemberProfile.mockedData
        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: memberRequest,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: memberRequest.emailAddress, password: "password", basketToken: nil, notificationDeviceToken: nil),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [
            .setCustomerID(profileUUID: member.uuid),
            .sendEvent(for: .login(.outside), with: .appsFlyer, params: [:]),
            .sendEvent(for: .login(.outside), with: .firebaseAnalytics, params: [AnalyticsParameterMethod : LoginType.email.rawValue])
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .failure(data)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedWebRepo.loginByEmailPasswordResponse = .success(loginData)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        
        do {
            let userRegistered = try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil, atCheckout: false)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
            XCTAssertTrue(userRegistered)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
    func test_unsuccesfulRegister_whenMemberAlreadyRegisteredWithSameEmailAndDifferentPassword_returnError() async {
        
        let registerError = APIErrorResult.mockedMemberAlreadyRegistered
        let loginError = APIErrorResult.mockedUnauthorized
        
        let memberRequest = MemberProfileRegisterRequest.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: memberRequest,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: memberRequest.emailAddress, password: "password", basketToken: nil, notificationDeviceToken: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .failure(registerError)
        mockedWebRepo.loginByEmailPasswordResponse = .failure(loginError)
        
        do {
            let _ = try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil, atCheckout: false)
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            if let error = error as? APIErrorResult {
                XCTAssertEqual(error, registerError, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }

    func test_unsuccesfulRegister_whenMemberAlreadySignedIn_returnError() async {
        
        let memberRequest = MemberProfileRegisterRequest.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        
        do {
            let _ = try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil, atCheckout: false)
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            if let loginError = error as? UserServiceError {
                XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedOut, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
}

final class ChangePasswordTests: UserServiceTests {

    func test_succesfulChangePassword_whenMemberSignedIn() async {

        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .changePassword(logoutFromAll: false, password: "password1", currentPassword: "oldpassword1")
        ])
        mockedWebRepo.changePasswordResponse = .success(UserSuccessResult.mockedSuccessData)

        do {
            try await sut.changePassword(
                logoutFromAll: false,
                password: "password1",
                currentPassword: "oldpassword1"
            )
        } catch {
            XCTFail("Unexpected error \(error)", file: #file, line: #line)
        }

        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccesfulChangePassword_whenMemberNotSigned_returnError() async {

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        do {
            try await sut.changePassword(
                logoutFromAll: false,
                password: "password1",
                currentPassword: "oldpassword1"
            )
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            if let resetPasswordError = error as? UserServiceError {
                XCTAssertEqual(resetPasswordError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }

        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccesfulChangePassword_whenMemberSignedIn_thenReturnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])

        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .changePassword(logoutFromAll: false, password: "password1", currentPassword: "oldpassword1")
        ])
        mockedWebRepo.changePasswordResponse = .failure(networkError)

        do {
            try await sut.changePassword(
                logoutFromAll: false,
                password: "password1",
                currentPassword: "oldpassword1"
            )
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }

        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
}

final class LogoutTests: UserServiceTests {
    
    // MARK: - func logout()
    
    func test_successfulLogout_whenDeviceTokenEstablished() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.system.notificationDeviceToken = "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad"
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .logout(basketToken: nil, notificationDeviceToken: appState.value.system.notificationDeviceToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .clearAllFetchedUserMarketingOptions,
            .clearLastDeliveryOrderOnDevice
        ])
        mockedEventLogger.actions = .init(expected: [.clearCustomerID])
        
        // Configuring responses from repositories
        mockedWebRepo.logoutResponse = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.logout()
            XCTAssertNil(self.appState.value.userData.memberProfile)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulLogout_whenBasketSetAndDeviceTokenNoteEstablished() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .logout(basketToken: appState.value.userData.basket?.basketToken, notificationDeviceToken: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .clearAllFetchedUserMarketingOptions,
            .clearLastDeliveryOrderOnDevice
        ])
        mockedEventLogger.actions = .init(expected: [.clearCustomerID])
        
        // Configuring responses from repositories
        mockedWebRepo.logoutResponse = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        UserDefaults.standard.userConfirmedSelectedChannel = true
        
        do {
            try await sut.logout()
            XCTAssertNil(self.appState.value.userData.memberProfile)
            XCTAssertFalse(UserDefaults.standard.userConfirmedSelectedChannel)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulLogout_whenNotSignedIn_expectedMemberRequiredToBeSignedInError() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        // Configuring responses from repositories
        mockedWebRepo.logoutResponse = .failure(UserServiceError.memberRequiredToBeSignedIn)
        
        do {
            try await sut.logout()
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            if let loginError = error as? UserServiceError {
                XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedEventLogger.verify()
        }
    }
    
}


final class GetProfileTests: UserServiceTests {
    
    // MARK: - func getProfile(profile:)
    @MainActor
    func test_successfulGetProfile_whenStoreNotSelected() async {
        
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: profile.uuid)])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: false, loginContext: nil)
            XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
			mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
        
    @MainActor
    func test_successfulGetProfile_whenStoreSelected() async {
        
        let profile = MemberProfile.mockedData
        let retailStore = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(retailStore)
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getProfile(storeId: retailStore.id)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: retailStore.id)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: profile.uuid)])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: true, loginContext: nil)
            XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
			mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    @MainActor
    func test_successfulGetProfile_whenNetworkErrorAndSavedProfile_returnProfile() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .memberProfile
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: profile.uuid)])

        // Configuring responses from repositories
        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.memberProfileResult = .success(profile)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: true, loginContext: nil)
            XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
			mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulGetProfile_whenNetworkErrorAndNoSavedProfile_returnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .memberProfile
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.memberProfileResult = .success(nil)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: false, loginContext: nil)
            XCTFail("Failed to hit expected error")
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
			mockedEventLogger.verify()
        }
    }
    
    func test_unsuccessfulGetProfile_whenNetworkErrorAndExpiredSavedOptions_returnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let profileFromAPI = MemberProfile.mockedData
        
        // Add a timestamp to the saved result that expired one hour ago
        let storedProfile = MemberProfile(
            uuid: profileFromAPI.uuid,
            firstname: profileFromAPI.firstname,
            lastname: profileFromAPI.lastname,
            emailAddress: profileFromAPI.emailAddress,
            type: profileFromAPI.type,
            referFriendCode: profileFromAPI.referFriendCode,
            referFriendBalance: profileFromAPI.referFriendBalance,
            numberOfReferrals: profileFromAPI.numberOfReferrals,
            mobileContactNumber: profileFromAPI.mobileContactNumber,
            mobileValidated: profileFromAPI.mobileValidated,
            acceptedMarketing: profileFromAPI.acceptedMarketing,
            defaultBillingDetails: profileFromAPI.defaultBillingDetails,
            savedAddresses: profileFromAPI.savedAddresses,
            fetchTimestamp: Calendar.current.date(byAdding: .hour, value: -1, to: AppV2Constants.Business.userCachedExpiry)
        )
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .memberProfile
        ])

        // Configuring responses from repositories
        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.memberProfileResult = .success(storedProfile)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: false, loginContext: nil)
            XCTFail("Failed to hit expected error")
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
			mockedEventLogger.verify()
        }
    }
}

final class RestoreLastUserTests: UserServiceTests {
    
    // MARK: - func restoreLastUser()
    
    func test_successfulRestoreLastUser_whenMemberSignedInKeychainNotNil() async {
        
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        keychain["memberSignedIn"] = "email"
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: nil)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        do {
            try await sut.restoreLastUser()
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulRestoreLastUser_whenMemberSignedInKeychainIsNil() async {
        
        let profile = MemberProfile.mockedData
        
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        
        keychain["memberSignedIn"] = nil
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [])
        mockedDBRepo.actions = .init(expected: [])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        do {
            try await sut.restoreLastUser()
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
}

final class UpdateProfileTests: UserServiceTests {
    
    // MARK: - func updateProfile(firstname:lastname:mobileContactNumber:)
    
    func test_updateProfile_whenStoreNotSelected() async {
                
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        let updatedProfile = MemberProfile.mockedUpdatedMockedData(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "07923442322")
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .updateProfile(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "07923442322")
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: updatedProfile, forStoreId: nil)
        ])
        
        // Configuring responses from repositories

        mockedWebRepo.updateProfileResponse = .success(updatedProfile)
        
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(updatedProfile)
        
        do {
            try await sut.updateProfile(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "07923442322")
            XCTAssertEqual(self.sut.appState.value.userData.memberProfile?.firstname, "Cogin")
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulUpdateProfile_whenUserNotSignedIn_returnError() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        do {
            try await sut.updateProfile(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "07923442322")
            XCTFail("Failed to reach expected error")
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}

final class AddAddressTests: UserServiceTests {
    // MARK: - func addAddress(profile:address)
    
    func test_successfulAddAddress_whenStoreNotSelected() async {
        
        let profile = MemberProfile.mockedData
        let address = Address.mockedNewDeliveryData
        let newProfile = MemberProfile.mockedAddAddressProfileResponse
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .addAddress(address: address)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: newProfile, forStoreId: nil)
        ])

        // Configuring responses from repositories

        mockedWebRepo.addAddressResponse = .success(newProfile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(newProfile)
        
        appState.value.userData.memberProfile = profile
        
        do {
            try await sut.addAddress(address: address)
            XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessAddAddress_whenUserNotSignedIn_returnError() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        do {
            try await sut.addAddress(address: Address.mockedNewDeliveryData)
            XCTFail("Failed to reach expected error", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    
    }
}

final class UpdateAddressTests: UserServiceTests {
    
    // MARK: - func updateAddress(profile:address:)
    
    func test_successfulUpdateAddress_whenStoreNotSelected() async {
        
        let profile = MemberProfile.mockedData

        // Configuring app prexisting states
        appState.value.userData.memberProfile = profile

        // Configuring responses from repositories
        
        let newProfile = MemberProfile.mockedUpdatedAddressProfile
        
        mockedWebRepo.actions = .init(expected: [
            .updateAddress(address: Address.addressToUpdate)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: newProfile, forStoreId: nil)
        ])
        
        mockedWebRepo.updateAddressResponse = .success(newProfile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(newProfile)
        
        do {
            try await sut.updateAddress(address: Address.addressToUpdate)
            XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessUpdateAddress_whenUserNotSignedIn_returnError() async {
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        do {
            try await sut.updateAddress(address: Address.mockedNewDeliveryData)
            XCTFail("Failed to reach expected error", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}

final class SetDefaultAddressTests: UserServiceTests {
    
    // MARK: - func setDefaultAddress(profile:addressId:)
    
    func test_successfulSetDefaultAddress() async {
        
        let profile = MemberProfile.mockedData

        // Configuring app prexisting states
        appState.value.userData.memberProfile = profile

        // Configuring responses from repositories
        
        let newProfile = MemberProfile.mockedDefaultAddressSetProfile
        
        mockedWebRepo.actions = .init(expected: [
            .setDefaultAddress(addressId: 127501)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: newProfile, forStoreId: nil)
        ])

        // Configuring responses from repositories
        
        mockedWebRepo.setDefaultAddressResponse = .success(newProfile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(newProfile)
        
        do {
            try await sut.setDefaultAddress(addressId: 127501)
            XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessSetDefaultAddress_whenUserNotSignedIn_returnError() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        do {
            try await sut.setDefaultAddress(addressId: 127501)
            XCTFail("Failed to reach expected error", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}

final class ReoveAddressTests: UserServiceTests {
    
    // MARK: - func removeAddress(profile:addressId)

    func test_successfulRemoveAddress() async {
                
        let profile = MemberProfile.mockedData

        // Configuring app prexisting states
        appState.value.userData.memberProfile = profile

        // Configuring responses from repositories
        
        let newProfile = MemberProfile.mockedRemoveAddressProfile
        
        mockedWebRepo.actions = .init(expected: [
            .removeAddress(addressId: 127501)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: newProfile, forStoreId: nil)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.removeAddressResponse = .success(newProfile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(newProfile)
        
        do {
            try await sut.removeAddress(addressId: 127501)
            XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessAddAddress_whenUserNotSignedIn_returnError() async {
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        do {
            try await sut.removeAddress(addressId: 127501)
            XCTFail("Failed to reach expected error", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}

final class GetSavedCardsTests: UserServiceTests {
    
    // MARK: - func getSavedCards()
    
    func test_whenGetSavedCardsCalled_thenSuccessfulReturn() async {
        let memberProfile = MemberProfile.mockedData
        let cardDetails = [MemberCardDetails.mockedData]
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = memberProfile
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [.getSavedCards])
        
        // Configuring responses from repositories
        mockedWebRepo.getSavedCardsResponse = .success(cardDetails)
        
        do {
            let result = try await sut.getSavedCards()
            
            XCTAssertEqual(result, cardDetails)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
    }
    
    func test_givenUserNotSignedIn_whenGetSavedCardsCalled_thenCorrectErrorReturned() async {
        
        do {
            let _ = try await sut.getSavedCards()
            
            XCTFail("Unexpected success")
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        mockedWebRepo.verify()
    }
}

final class SaveNewCardTests: UserServiceTests {
    // MARK: - func saveNewCard(token:)
    
    func test_whenSaveNewCardIsCalled_thenSuccessfulReturn() async {
        let memberProfile = MemberProfile.mockedData
        let token: String = "SomeToken"
        let cardDetails = MemberCardDetails.mockedData
        // Configuring app prexisting states
        appState.value.userData.memberProfile = memberProfile
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [.saveNewCard(token: token)])
        
        // Configuring responses from repositories
        mockedWebRepo.saveNewCardResponse = .success(cardDetails)
        
        do {
            try await sut.saveNewCard(token: token)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
    }
    
    func test_givenUserNotSignedIn_whenSaveNewCardIsCalled_thenCorrectErrorReturned() async {
        let token: String = "SomeToken"
        
        do {
            let _ = try await sut.saveNewCard(token: token)
            
            XCTFail("Unexpected success")
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        mockedWebRepo.verify()
    }
}

final class DeleteCardTests: UserServiceTests {
    // MARK: - fun deleteCard(id:)
    
    func test_whenDeleteCardIsCalled_thenSuccessfulReturn() async {
        let memberProfile = MemberProfile.mockedData
        let id: String = "SomeId"
        let cardDeleteResponse = CardDeleteResponse.mockedData
        // Configuring app prexisting states
        appState.value.userData.memberProfile = memberProfile
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [.deleteCard(id: id)])
        
        // Configuring responses from repositories
        mockedWebRepo.deleteCardResponse = .success(cardDeleteResponse)
        
        do {
            try await sut.deleteCard(id: id)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        mockedWebRepo.verify()
    }
    
    func test_givenUserNotSignedIn_whenDeleteCardIsCalled_thenCorrectErrorReturned() async {
        let id: String = "SomeId"
        
        do {
            let _ = try await sut.deleteCard(id: id)
            
            XCTFail("Unexpected success")
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        mockedWebRepo.verify()
    }
}

final class GetMarketingOptionsTests: UserServiceTests {
    
    // MARK: - func getMarketingOptions(options:isCheckout:notificationsEnabled:)

    func test_successfulGetMarketingOptions_whenNotAtCheckoutAndMemberSignedIn_returnOptions() async throws {
        let optionsFetchFromAPI = UserMarketingOptionsFetch.mockedDataFromAPI
        let optionsFetchStored = UserMarketingOptionsFetch(
            marketingPreferencesIntro: optionsFetchFromAPI.marketingPreferencesIntro,
            marketingPreferencesGuestIntro: optionsFetchFromAPI.marketingPreferencesGuestIntro,
            marketingOptions: optionsFetchFromAPI.marketingOptions,
            fetchIsCheckout: false,
            fetchNotificationsEnabled: false,
            fetchBasketToken: nil,
            fetchTimestamp: Date()
        )
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: nil
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearFetchedUserMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: nil
            ),
            .store(
                marketingOptionsFetch: optionsFetchFromAPI,
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: nil
            )
        ])

        // Configuring responses from repositories

        mockedWebRepo.getMarketingOptionsResponse = .success(optionsFetchFromAPI)
        mockedDBRepo.clearFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.storeMarketingOptionsFetchResult = .success(optionsFetchStored)

        let result = try await sut.getMarketingOptions(
            isCheckout: optionsFetchStored.fetchIsCheckout!,
            notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!
        )
        
        XCTAssertEqual(result, optionsFetchStored, file: #file, line: #line)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_unsuccessfulGetMarketingOptions_whenNotAtCheckoutAndMemberNotSignedIn_returnError() async throws {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        do {
            let result = try await sut.getMarketingOptions(
                isCheckout: false,
                notificationsEnabled: false
            )
            
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_successfulGetMarketingOptions_whenAtCheckoutWithBasketAndMemberNotSignedIn_returnOptions() async throws {

        let basket = Basket.mockedData
        
        let optionsFetchFromAPI = UserMarketingOptionsFetch.mockedDataFromAPI
        let optionsFetchStored = UserMarketingOptionsFetch(
            marketingPreferencesIntro: optionsFetchFromAPI.marketingPreferencesIntro,
            marketingPreferencesGuestIntro: optionsFetchFromAPI.marketingPreferencesGuestIntro,
            marketingOptions: optionsFetchFromAPI.marketingOptions,
            fetchIsCheckout: true,
            fetchNotificationsEnabled: false,
            fetchBasketToken: basket.basketToken,
            fetchTimestamp: Date()
        )
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        appState.value.userData.basket = basket
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearFetchedUserMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            ),
            .store(
                marketingOptionsFetch: optionsFetchFromAPI,
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getMarketingOptionsResponse = .success(optionsFetchFromAPI)
        mockedDBRepo.clearFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.storeMarketingOptionsFetchResult = .success(optionsFetchStored)

        let result = try await sut.getMarketingOptions(
            isCheckout: optionsFetchStored.fetchIsCheckout!,
            notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!
        )
        
        XCTAssertEqual(result, optionsFetchStored, file: #file, line: #line)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_successfulGetMarketingOptions_whenAtCheckoutWithBasketAndMemberSignedIn_returnOptions() async throws {
        
        let basket = Basket.mockedData
        
        let optionsFetchFromAPI = UserMarketingOptionsFetch.mockedDataFromAPI
        let optionsFetchStored = UserMarketingOptionsFetch(
            marketingPreferencesIntro: optionsFetchFromAPI.marketingPreferencesIntro,
            marketingPreferencesGuestIntro: optionsFetchFromAPI.marketingPreferencesGuestIntro,
            marketingOptions: optionsFetchFromAPI.marketingOptions,
            fetchIsCheckout: true,
            fetchNotificationsEnabled: false,
            fetchBasketToken: nil, // should not be passing token
            fetchTimestamp: Date()
        )
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = basket
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: nil // should not be passing token
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearFetchedUserMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: nil // should not be passing token
            ),
            .store(
                marketingOptionsFetch: optionsFetchFromAPI,
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: nil // should not be passing token
            )
        ])

        // Configuring responses from repositories
        mockedWebRepo.getMarketingOptionsResponse = .success(optionsFetchFromAPI)
        mockedDBRepo.clearFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.storeMarketingOptionsFetchResult = .success(optionsFetchStored)

        let result = try await sut.getMarketingOptions(
            isCheckout: optionsFetchStored.fetchIsCheckout!,
            notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!
        )
        
        XCTAssertEqual(result, optionsFetchStored, file: #file, line: #line)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_unsuccessfulGetMarketingOptions_whenAtCheckoutWithoutBasket_returnError() async throws {
        
        do {
            let result = try await sut.getMarketingOptions(
                isCheckout: true,
                notificationsEnabled: false
            )
            
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()

    }

    func test_successfulGetMarketingOptions_whenNetworkErrorAndSavedOptions_returnOptions() async throws {

        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let basket = Basket.mockedData
        let optionsFetchFromAPI = UserMarketingOptionsFetch.mockedDataFromAPI
        let optionsFetchStored = UserMarketingOptionsFetch(
            marketingPreferencesIntro: optionsFetchFromAPI.marketingPreferencesIntro,
            marketingPreferencesGuestIntro: optionsFetchFromAPI.marketingPreferencesGuestIntro,
            marketingOptions: optionsFetchFromAPI.marketingOptions,
            fetchIsCheckout: true,
            fetchNotificationsEnabled: false,
            fetchBasketToken: basket.basketToken,
            fetchTimestamp: Date()
        )
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        appState.value.userData.basket = basket
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .userMarketingOptionsFetch(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])

        // Configuring responses from repositories
        mockedWebRepo.getMarketingOptionsResponse = .failure(networkError)
        mockedDBRepo.userMarketingOptionsFetchResult = .success(optionsFetchStored)
        
        let result = try await sut.getMarketingOptions(
            isCheckout: true,
            notificationsEnabled: false
        )
        
        XCTAssertEqual(result, optionsFetchStored, file: #file, line: #line)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_unsuccessfulGetMarketingOptions_whenNetworkErrorAndNoSavedOptions_returnError() async throws {

        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let basket = Basket.mockedData
        let optionsFetchFromAPI = UserMarketingOptionsFetch.mockedDataFromAPI
        let optionsFetchStored = UserMarketingOptionsFetch(
            marketingPreferencesIntro: optionsFetchFromAPI.marketingPreferencesIntro,
            marketingPreferencesGuestIntro: optionsFetchFromAPI.marketingPreferencesGuestIntro,
            marketingOptions: optionsFetchFromAPI.marketingOptions,
            fetchIsCheckout: true,
            fetchNotificationsEnabled: false,
            fetchBasketToken: basket.basketToken,
            fetchTimestamp: Date()
        )

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        appState.value.userData.basket = basket

        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .userMarketingOptionsFetch(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])

        // Configuring responses from repositories
        mockedWebRepo.getMarketingOptionsResponse = .failure(networkError)
        mockedDBRepo.userMarketingOptionsFetchResult = .success(nil)

        do {
            let result = try await sut.getMarketingOptions(
                isCheckout: true,
                notificationsEnabled: false
            )
            
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_unsuccessfulGetMarketingOptions_whenNetworkErrorAndExpiredSavedOptions_returnError() async throws {

        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let basket = Basket.mockedData
        let optionsFetchFromAPI = UserMarketingOptionsFetch.mockedDataFromAPI

        // Add a timestamp to the saved result that expired one hour ago
        let optionsFetchStored = UserMarketingOptionsFetch(
            marketingPreferencesIntro: optionsFetchFromAPI.marketingPreferencesIntro,
            marketingPreferencesGuestIntro: optionsFetchFromAPI.marketingPreferencesGuestIntro,
            marketingOptions: optionsFetchFromAPI.marketingOptions,
            fetchIsCheckout: true,
            fetchNotificationsEnabled: false,
            fetchBasketToken: basket.basketToken,
            fetchTimestamp: Calendar.current.date(byAdding: .hour, value: -1, to: AppV2Constants.Business.userCachedExpiry)
        )

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        appState.value.userData.basket = basket

        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getMarketingOptions(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .userMarketingOptionsFetch(
                isCheckout: optionsFetchStored.fetchIsCheckout!,
                notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!,
                basketToken: basket.basketToken
            )
        ])

        // Configuring responses from repositories
        mockedWebRepo.getMarketingOptionsResponse = .failure(networkError)
        mockedDBRepo.userMarketingOptionsFetchResult = .success(optionsFetchStored)

        do {
            let result = try await sut.getMarketingOptions(
                isCheckout: true,
                notificationsEnabled: false
            )
            
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

}

final class GetDriverSessionSettingsTests: UserServiceTests {
    
    // MARK: - func getDriverSessionSettings()
    
    func test_successGetDriverSessionSettings_whenDriverMemberSignedInAndKnownSession_returnSettings() async throws {

        let settingsResponse = DriverSessionSettings.mockedData
        let knownSessionToken = "cf4614bebcfab642a877f6bf22de9eea"
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedDataIsDriver
        keychain["driverV1Session"] = knownSessionToken
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getDriverSessionSettings(withKnownV1SessionToken: knownSessionToken)
        ])

        // Configuring responses from repositories
        mockedWebRepo.getDriverSessionSettingsResponse = .success(settingsResponse)
        
        let result = try await sut.getDriverSessionSettings()
        
        XCTAssertEqual(result, settingsResponse, file: #file, line: #line)
        XCTAssertEqual(keychain["driverV1Session"], settingsResponse.v1sessionToken, file: #file, line: #line)
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successGetDriverSessionSettings_whenDriverMemberSignedInAndNoKnownSession_returnSettings() async throws {

        let settingsResponse = DriverSessionSettings.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedDataIsDriver
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .getDriverSessionSettings(withKnownV1SessionToken: nil)
        ])

        // Configuring responses from repositories
        mockedWebRepo.getDriverSessionSettingsResponse = .success(settingsResponse)
        
        let result = try await sut.getDriverSessionSettings()
        
        XCTAssertEqual(result, settingsResponse, file: #file, line: #line)
        XCTAssertEqual(keychain["driverV1Session"], settingsResponse.v1sessionToken, file: #file, line: #line)
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessGetDriverSessionSettings_whenCustomerMemberSigned_returnMemberError() async throws {

        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        do {
            let result = try await sut.getDriverSessionSettings()
            
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberDriverTypeRequired, file: #file, line: #line)
                // check that there were no unexpected repository actions
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
    }
    
    func test_unsuccessGetDriverSessionSettings_whenMemberNotSignedIn_returnMemberError() async throws {

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        do {
            let result = try await sut.getDriverSessionSettings()
            
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
                // check that there were no unexpected repository actions
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
    }
    
}

final class CheckRetailMembershipIdTests: UserServiceTests {
    
    // MARK: - func checkRetailMembershipId()
    
    func test_successfulCheckRetailMembershipId_givenRequiredAppStates_returnCheckRetailMembershipIdResult() async {
        
        let data = CheckRetailMembershipIdResult.mockedDataWithoutMembership
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .checkRetailMembershipId(basketToken: appState.value.userData.basket?.basketToken ?? "")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.checkRetailMembershipIdResponse = .success(data)
        
        do {
            let result = try await sut.checkRetailMembershipId()
            XCTAssertEqual(result, data, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulCheckRetailMembershipId_givenMissingMemberAppStates_throwError() async {

        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        
        do {
            let result = try await sut.checkRetailMembershipId()
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessfulCheckRetailMembershipId_givenMissingBasketAppStates_throwError() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        
        do {
            let result = try await sut.checkRetailMembershipId()
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessfulCheckRetailMembershipId_StatusFalse_throwError() async {
        
        let data = CheckRetailMembershipIdResult.mockedDataFailedStatus
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .checkRetailMembershipId(basketToken: appState.value.userData.basket?.basketToken ?? "")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.checkRetailMembershipIdResponse = .success(data)
        
        do {
            let result = try await sut.checkRetailMembershipId()
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.unkownError("checkRetailMembershipId status = false"), file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}

final class StoreRetailMembershipIdTests: UserServiceTests {
    
    // MARK: - func storeRetailMembershipId(retailMemberId:)
    
    func test_successStoreRetailMembershipId_givenRequiredAppStates() async {
        
        let retailMemberId = "20987654321"
        let data = StoreRetailMembershipIdResult.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .storeRetailMembershipId(
                storeId: appState.value.userData.selectedStore.value?.id ?? 0,
                basketToken: appState.value.userData.basket?.basketToken ?? "",
                retailMemberId: retailMemberId
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.storeRetailMembershipIdResponse = .success(data)
        
        do {
            try await sut.storeRetailMembershipId(retailMemberId: retailMemberId)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessStoreRetailMembershipId_givenMissingMemberAppStates_throwError() async {
        
        let retailMemberId = "20987654321"
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)

        do {
            try await sut.storeRetailMembershipId(retailMemberId: retailMemberId)
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessStoreRetailMembershipId_givenMissingBasketAppStates_throwError() async {
        
        let retailMemberId = "20987654321"
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)

        do {
            try await sut.storeRetailMembershipId(retailMemberId: retailMemberId)
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessStoreRetailMembershipId_givenMissingStoreSelectionAppStates_throwError() async {
        
        let retailMemberId = "20987654321"
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData

        do {
            try await sut.storeRetailMembershipId(retailMemberId: retailMemberId)
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.unableToProceedWithoutStoreSelection, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessStoreRetailMembershipId_StatusFalse_throwError() async {
        
        let retailMemberId = "20987654321"
        let data = StoreRetailMembershipIdResult.mockedDataWithFalseSuccess
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedDataWithRetailMembership)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .storeRetailMembershipId(
                storeId: appState.value.userData.selectedStore.value?.id ?? 0,
                basketToken: appState.value.userData.basket?.basketToken ?? "",
                retailMemberId: retailMemberId
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.storeRetailMembershipIdResponse = .success(data)
        
        do {
            try await sut.storeRetailMembershipId(retailMemberId: retailMemberId)
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.unkownError("storeRetailMembershipId success = false"), file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
}

final class RequestMobileVerificationCodeTests: UserServiceTests {
    
    // MARK: - func requestMobileVerificationCode()
    
    func test_successfulRequestMobileVerificationCode_whenReturnedStatusTrue_returnTrue() async {
        
        let requestResponse = RequestMobileVerificationCodeResult.mockedDataSent
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedDataMobileNotVerified
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .requestMobileVerificationCode
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.requestMobileVerificationCodeResponse = .success(requestResponse)
        
        do {
            let result = try await sut.requestMobileVerificationCode()
            XCTAssertTrue(result, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulRequestMobileVerificationCode_whenMemberAlreadyVerified_returnError() async {
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        do {
            let result = try await sut.requestMobileVerificationCode()
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.mobileNumberAlreadyVerified, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessfulRequestMobileVerificationCode_whenSendStatusFailed_returnError() async {
        
        let requestResponse = RequestMobileVerificationCodeResult.mockedDataSendFailed
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedDataMobileNotVerified
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .requestMobileVerificationCode
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.requestMobileVerificationCodeResponse = .success(requestResponse)
        
        do {
            let result = try await sut.requestMobileVerificationCode()
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.unableToSendMobileVerificationCode, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_successfulRequestMobileVerificationCode_whenServerFindsMemberVerified_updateLocalProfile() async {
        
        let requestResponse = RequestMobileVerificationCodeResult.mockedDataDetectedMemberAlreadyVerified
        
        // Configuring app prexisting states
        let memberProfile = MemberProfile.mockedDataMobileNotVerified
        let verifiedMemberProfile = MemberProfile(
            uuid: memberProfile.uuid,
            firstname: memberProfile.firstname,
            lastname: memberProfile.lastname,
            emailAddress: memberProfile.emailAddress,
            type: memberProfile.type,
            referFriendCode: memberProfile.referFriendCode,
            referFriendBalance: requestResponse.referFriendBalance ?? 0.0,
            numberOfReferrals: memberProfile.numberOfReferrals,
            mobileContactNumber: memberProfile.mobileContactNumber,
            mobileValidated: true,
            acceptedMarketing: memberProfile.acceptedMarketing,
            defaultBillingDetails: memberProfile.defaultBillingDetails,
            savedAddresses: memberProfile.savedAddresses,
            fetchTimestamp: memberProfile.fetchTimestamp
        )
        appState.value.userData.memberProfile = memberProfile
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .requestMobileVerificationCode
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: verifiedMemberProfile, forStoreId: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.requestMobileVerificationCodeResponse = .success(requestResponse)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(verifiedMemberProfile)
        
        do {
            let result = try await sut.requestMobileVerificationCode()
            XCTAssertFalse(result, file: #file, line: #line)
            let updatedMemberProfile = appState.value.userData.memberProfile
            XCTAssertEqual(updatedMemberProfile, verifiedMemberProfile, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulRequestMobileVerificationCode_whenNumberAlreadyVerifiedByAnotherMember_returnError() async {
        
        let requestResponse = RequestMobileVerificationCodeResult.mockedDataDetectedMobileAlreadyVerifiedWithOtherMember
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedDataMobileNotVerified
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .requestMobileVerificationCode
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.requestMobileVerificationCodeResponse = .success(requestResponse)
        
        do {
            let result = try await sut.requestMobileVerificationCode()
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.mobileNumberAlreadyVerifiedWithAnotherMember, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessfulRequestMobileVerificationCode_whenMemberNoSignedIn_returnError() async {
        
        do {
            let result = try await sut.requestMobileVerificationCode()
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}

final class CheckMobileVerificationCode: UserServiceTests {
    
    // MARK: - func checkMobileVerificationCode(verificationCode:)
    
    #warning("Waiting on https://snappyshopper.atlassian.net/browse/BGB-733")

    func test_successfulCheckMobileVerificationCode() async {
        let code = "A1234"
        let data = CheckMobileVerificationCodeResult.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedDataMobileNotVerified
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .checkMobileVerificationCode(verificationCode: code)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.checkMobileVerificationCodeResponse = .success(data)
        
        do {
            try await sut.checkMobileVerificationCode(verificationCode: code)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulCheckMobileVerificationCode_whenMemberAlreadyVerified_returnError() async {
        let code = "A1234"
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        
        do {
            try await sut.checkMobileVerificationCode(verificationCode: code)
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.mobileNumberAlreadyVerified, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessfulCheckMobileVerificationCode_whenMemberNoSignedIn_returnError() async {
        let code = "A1234"
        
        do {
            try await sut.checkMobileVerificationCode(verificationCode: code)
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? UserServiceError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}

final class UpdateMarketingOptionsTests: UserServiceTests {
    
    // MARK: - func updateMarketingOptions(result:options:)

    func test_successfulUpdateMarketingOptions_whenMemberSignedIn_returnUpdateResult() async throws {

        let marketingOptions = UserMarketingOptionRequest.mockedArrayData
        let updateResponse = UserMarketingOptionsUpdateResponse.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .updateMarketingOptions(
                options: marketingOptions,
                basketToken: nil, channel: nil // should be nil because member is signed in
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])

        // Configuring responses from repositories
        mockedWebRepo.updateMarketingOptionsResponse = .success(updateResponse)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let result = try await sut.updateMarketingOptions(
            options: marketingOptions
        )
        
        XCTAssertEqual(result, updateResponse, file: #file, line: #line)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_unsuccessfulUpdateMarketingOptions_whenMemberNotSignedInAndBasket_returnUpdateResult() async throws {

        let marketingOptions = UserMarketingOptionRequest.mockedArrayData
        let updateResponse = UserMarketingOptionsUpdateResponse.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        appState.value.userData.basket = basket
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .updateMarketingOptions(
                options: marketingOptions,
                basketToken: basket.basketToken, channel: nil // should be nil because member is signed in
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])

        // Configuring responses from repositories
        mockedWebRepo.updateMarketingOptionsResponse = .success(updateResponse)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)

        let result = try await sut.updateMarketingOptions(
            options: marketingOptions
        )
        
        XCTAssertEqual(result, updateResponse, file: #file, line: #line)
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }

    func test_unsuccessfulUpdateMarketingOptions_whenMemberNotSignedInAndNoBasket_returnError() async throws {

        let marketingOptions = UserMarketingOptionRequest.mockedArrayData

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        do {
            let result = try await sut.updateMarketingOptions(
                options: marketingOptions
            )
            
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            if let error = error as? UserServiceError {
                XCTAssertEqual(error, UserServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

final class GetPastOrdersTests: UserServiceTests {
    
    // MARK: - func getPastOrders(pastOrders:dateFrom:dateTo:status:page:limit:)
    
    func test_givenNoParams_whenCallingGetPastOrders_thenSuccessful() async {
        let placedOrders = [PlacedOrderSummary.mockedData]
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)])

        // Configuring responses from repositories

        mockedWebRepo.getPastOrdersResponse = .success(placedOrders)

        let exp = expectation(description: #function)
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrderSummary]?>.notRequested)
        
        orders.updatesRecorder
            .sink { updates in
                XCTAssertEqual(updates, [
                    .notRequested,
                    .isLoading(last: nil, cancelBag: CancelBag()),
                    .loaded(placedOrders)
                ])
                self.mockedWebRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        await sut.getPastOrders(pastOrders: orders.binding, dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_givenParams_whenCallingGetPastOrders_thenSuccessful() async {
        let placedOrders = [PlacedOrderSummary.mockedData]
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories
        
        let dateFrom = "Today"
        let dateTo = "Tomorrow"
        let status = "Status"
        let page = 1
        let limit = 2

        mockedWebRepo.actions = .init(expected: [.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit)])

        // Configuring responses from repositories

        mockedWebRepo.getPastOrdersResponse = .success(placedOrders)

        let exp = expectation(description: #function)
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrderSummary]?>.notRequested)

        orders.updatesRecorder
            .sink { updates in
                XCTAssertEqual(updates, [
                    .notRequested,
                    .isLoading(last: nil, cancelBag: CancelBag()),
                    .loaded(placedOrders)
                ])
                self.mockedWebRepo.verify()
                // should still check no db operation
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        await sut.getPastOrders(pastOrders: orders.binding, dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenNetworkError_thenReturnError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)])
        
        // Configuring responses from repositories

        mockedWebRepo.getPastOrdersResponse = .failure(networkError)
        
        let exp = expectation(description: #function)
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrderSummary]?>.notRequested)

        orders.updatesRecorder
            .sink { updates in
                XCTAssertEqual(updates, [
                    .notRequested,
                    .isLoading(last: nil, cancelBag: CancelBag()),
                    .failed(networkError)
                ])
                self.mockedWebRepo.verify()
                // should still check no db operation
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        await sut.getPastOrders(pastOrders: orders.binding, dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)
        
        wait(for: [exp], timeout: 2)
    }
}

final class GetPlacedOrderTests: UserServiceTests {
    
    // MARK: - getPlacedOrder(businessOrderId:)
    
    func test_givenNoParams_whenCallingGetPlacedOrder_thenSuccessful() async {
        let placedOrder = PlacedOrder.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPlacedOrderDetails(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories

        mockedWebRepo.getPlacedOrderDetailsResponse = .success(placedOrder)
        
        do {
            let result = try await sut.getPlacedOrder(businessOrderId: 123)
            XCTAssertEqual(result, placedOrder)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
        } catch {
            XCTFail("Failed to get order: \(error)")
        }
    }
    
    func test_whenNetworkError_thenReturnError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPlacedOrderDetails(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories

        mockedWebRepo.getPlacedOrderDetailsResponse = .failure(networkError)

        do {
            let _ = try await sut.getPlacedOrder(businessOrderId: 123)
            XCTFail("Unintentionally passed getPlacedOrder async func")
        } catch {
            XCTAssertEqual(error as NSError, networkError)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
        }
    }
}

final class CheckRegistrationStatusTests: UserServiceTests {
    
    // MARK: - checkRegistrationStatus(email:)
    
    func test_checkRegistrationStatus_whenNoBasket_thenReturnError() async {
        do {
            let result = try await sut.checkRegistrationStatus(email: "failme@gmail.com")
            XCTFail("Unexpected checkRegistrationStatus success: \(result)", file: #file, line: #line)
        } catch {
            if let userServiceError = error as? UserServiceError {
                XCTAssertEqual(userServiceError, UserServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_checkRegistrationStatus_whenBasket_thenSuccess() async {
        
        let checkRegistrationResult = CheckRegistrationResult.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .checkRegistrationStatus(
                email: "h.dover@gmail.com",
                basketToken: appState.value.userData.basket?.basketToken ?? ""
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.checkRegistrationStatusResponse = .success(checkRegistrationResult)
        
        do {
            let result = try await sut.checkRegistrationStatus(email: "h.dover@gmail.com")
            XCTAssertEqual(result, checkRegistrationResult, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_checkRegistrationStatus_whenNetworkError_thenReturnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .checkRegistrationStatus(
                email: "h.dover@gmail.com",
                basketToken: appState.value.userData.basket?.basketToken ?? ""
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.checkRegistrationStatusResponse = .failure(networkError)
        
        do {
            let result = try await sut.checkRegistrationStatus(email: "h.dover@gmail.com")
            XCTFail("Unexpected checkRegistrationStatus success: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

final class RequestMessageWithOneTimePasswordTests: UserServiceTests {
    
    // MARK: - requestMessageWithOneTimePassword(email:type:)
    
    func test_requestMessageWithOneTimePassword_whenResponse_thenSuccess() async {
        
        let oneTimePasswordSendResult = OneTimePasswordSendResult.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .requestMessageWithOneTimePassword(
                email: "h.dover@gmail.com",
                type: .sms
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.requestMessageWithOneTimePasswordResponse = .success(oneTimePasswordSendResult)
        
        do {
            let result = try await sut.requestMessageWithOneTimePassword(email: "h.dover@gmail.com", type: .sms)
            XCTAssertEqual(result, oneTimePasswordSendResult, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_requestMessageWithOneTimePassword_whenNetworkError_thenReturnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .requestMessageWithOneTimePassword(
                email: "h.dover@gmail.com",
                type: .sms
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.requestMessageWithOneTimePasswordResponse = .failure(networkError)
        
        do {
            let result = try await sut.requestMessageWithOneTimePassword(email: "h.dover@gmail.com", type: .sms)
            XCTFail("Unexpected requestMessageWithOneTimePassword success: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
}

final class SendForgetMemberCodeTests: UserServiceTests {
    func test_whenSendForgetCode_givenResponseIsSuccess_thenReturnSendForgetCodeResponse() async {
        
        let sendForgetCodeResult = ForgetMemberCodeRequestResult.mockedDataSuccess
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .sendForgetMemberCode
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.sendForgetMemberCodeResponse = .success(sendForgetCodeResult)

        do {
            let result = try await sut.sendForgetCode()
            XCTAssertEqual(result, sendForgetCodeResult, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
    }
    
    func test_whenSendForgetCode_givenResponseIsFail_thenThrowError() async {
        
        let sendForgetCodeResult = ForgetMemberCodeRequestResult.mockedDataFail
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .sendForgetMemberCode
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.sendForgetMemberCodeResponse = .success(sendForgetCodeResult)

        do {
            let _ = try await sut.sendForgetCode()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error.localizedDescription, sendForgetCodeResult.message)
        }
        self.mockedWebRepo.verify()
    }
}
