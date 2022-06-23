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
import KeychainAccess

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
    }
}

final class LoginByEmailAndPasswordTests: UserServiceTests {
    
    // MARK: - func login(email:password:)
    
    func test_successfulLoginByEmailPassword() async throws {

        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData

        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", password: "password321!", basketToken: nil),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: member.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .success(LoginResult.mockedSuccessDataWithoutRegistering)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", password: "password321!")
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
                basketToken: appState.value.userData.basket?.basketToken
            ),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: member.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .success(LoginResult.mockedSuccessDataWithoutRegistering)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", password: "password321!")
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
            .login(email: "failme@gmail.com", password: "password321!", basketToken: nil),
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .failure(failError)
        
        do {
            try await sut.login(email: "failme@gmail.com", password: "password321!")
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
    
    func test_successfulLoginByEmailOneTimePassword() async {
        
        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83", basketToken: nil),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: member.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .success(loginData)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83")
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
                basketToken: appState.value.userData.basket?.basketToken
            ),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: member.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .success(loginData)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83")
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
            .login(email: "failme@gmail.com", oneTimePassword: "6B9A83", basketToken: nil),
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .failure(failError)
        
        do {
            try await sut.login(email: "failme@gmail.com", oneTimePassword: "6B9A83")
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

final class ResetPasswordTests: UserServiceTests {
    
    // MARK: - resetPassword(resetToken:logoutFromAll:password:currentPassword:)
    
    func test_succesfulResetPassword_whenMemberNotSignedInAndNoEmail_resetSucces() async throws {
        
        let data = UserSuccessResult.mockedSuccessData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPassword(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                password: "password1",
                currentPassword: nil
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordResponse = .success(data)
                
        try await sut
            .resetPassword(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                email: nil,
                password: "password1",
                currentPassword: nil
            )
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_succesfulResetPassword_whenMemberNotSignedInAndEmail_resetSuccess() async throws {
        
        let member = MemberProfile.mockedData
        let data = UserSuccessResult.mockedSuccessData
        let loginData = LoginResult.mockedSuccessDataWithoutRegistering
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPassword(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                password: "password1",
                currentPassword: nil
            ),
            .login(email: "kevin.palser@gmail.com", password: "password1", basketToken: nil),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordResponse = .success(data)
        mockedWebRepo.loginByEmailPasswordResponse = .success(loginData)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        
        try await sut
            .resetPassword(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                email: "kevin.palser@gmail.com",
                password: "password1",
                currentPassword: nil
            )
        
        XCTAssertEqual(appState.value.userData.memberProfile, member, file: #file, line: #line)
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_succesfulResetPassword_whenMemberSignedInAndEmail_resetSucces() async throws {
        
        let data = UserSuccessResult.mockedSuccessData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPassword(
                resetToken: nil,
                logoutFromAll: false,
                password: "password1",
                currentPassword: "oldpassword1"
            )
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordResponse = .success(data)
        
        try await sut
            .resetPassword(
                resetToken: nil,
                logoutFromAll: false,
                email: "kevin.palser@gmail.com",
                password: "password1",
                currentPassword: "oldpassword1"
            )
        
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccesfulResetPassword_whenMemberNotSignedInAndNoResetToken_returnError() async throws {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        do {
            try await sut
                .resetPassword(
                    resetToken: nil,
                    logoutFromAll: false,
                    email: "kevin.palser@gmail.com",
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
    
    func test_unsuccesfulResetPassword_whenMemberNotSignedInAndFail_returnError() async throws {
                
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [])
        
        do {
            try await sut
                .resetPassword(
                    resetToken: nil,
                    logoutFromAll: false,
                    email: "kevin.palser@gmail.com",
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
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: member.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .success(data)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        
        do {
            try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
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
            .login(email: memberRequest.emailAddress, password: "password", basketToken: nil),
            .setToken(to: loginData.token!),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: member.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .failure(data)
        mockedWebRepo.getProfileResponse = .success(member)
        mockedWebRepo.loginByEmailPasswordResponse = .success(loginData)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        
        do {
            try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil)
            XCTAssertNotNil(appState.value.userData.memberProfile, file: #file, line: #line)
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
            .login(email: memberRequest.emailAddress, password: "password", basketToken: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .failure(registerError)
        mockedWebRepo.loginByEmailPasswordResponse = .failure(loginError)
        
        do {
            try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil)
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
            try await sut.register(member: memberRequest, password: "password", referralCode: nil, marketingOptions: nil)
            XCTFail("Expected error", file: #file, line: #line)
        } catch {
            if let loginError = error as? UserServiceError {
                XCTAssertEqual(loginError, UserServiceError.unableToRegisterWhileMemberSignIn, file: #file, line: #line)
            } else {
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
        self.mockedEventLogger.verify()
    }
    
}

final class LogoutTests: UserServiceTests {
    
    // MARK: - func logout()
    
    func test_successfulLogout() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .logout(basketToken: nil)
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
    
    func test_successfulLogout_whenBasketSet() async {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .logout(basketToken: appState.value.userData.basket?.basketToken)
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
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: profile.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])
        
        // Configuring responses from repositories
        
        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: false)
            XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
			mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
        
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
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: profile.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: true)
            XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
			mockedEventLogger.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
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
        mockedEventLogger.actions = .init(expected: [.setCustomerID(profileUUID: profile.uuid), .sendEvent(for: .login, with: .appsFlyer, params: [:])])

        // Configuring responses from repositories
        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.memberProfileResult = .success(profile)
        
        do {
            try await sut.getProfile(filterDeliveryAddresses: true)
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
            try await sut.getProfile(filterDeliveryAddresses: false)
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
            try await sut.getProfile(filterDeliveryAddresses: false)
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
                basketToken: nil // should be nil because member is signed in
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
                basketToken: basket.basketToken // should be nil because member is signed in
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
        let placedOrders = [PlacedOrder.mockedData]
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)])

        // Configuring responses from repositories

        mockedWebRepo.getPastOrdersResponse = .success(placedOrders)

        let exp = expectation(description: #function)
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrder]?>.notRequested)
        
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
        let placedOrders = [PlacedOrder.mockedData]
        
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
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrder]?>.notRequested)

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
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrder]?>.notRequested)

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
        
        let exp = expectation(description: #function)
        let order = BindingWithPublisher(value: Loadable<PlacedOrder>.notRequested)
        
        order.updatesRecorder
            .sink { updates in
                XCTAssertEqual(updates, [
                    .notRequested,
                    .isLoading(last: nil, cancelBag: CancelBag()),
                    .loaded(placedOrder)
                ])
                self.mockedWebRepo.verify()
                // should still check no db operation
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        await sut.getPlacedOrder(orderDetails: order.binding, businessOrderId: 123)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenNetworkError_thenReturnError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPlacedOrderDetails(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories

        mockedWebRepo.getPlacedOrderDetailsResponse = .failure(networkError)
        
        let exp = expectation(description: #function)
        let order = BindingWithPublisher(value: Loadable<PlacedOrder>.notRequested)

        order.updatesRecorder
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
        
        await sut.getPlacedOrder(orderDetails: order.binding, businessOrderId: 123)
        
        wait(for: [exp], timeout: 2)
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
