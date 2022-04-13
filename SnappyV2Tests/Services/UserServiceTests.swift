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

class UserServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedUserWebRepository!
    var mockedDBRepo: MockedUserDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: UserService!

    override func setUp() {
        mockedWebRepo = MockedUserWebRepository()
        mockedDBRepo = MockedUserDBRepository()
        sut = UserService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        subscriptions = Set<AnyCancellable>()
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

final class LoginByEmailAndPasswordTests: UserServiceTests {
    
    // MARK: - func login(email:password:)
    
    func test_successfulLoginByEmailPassword() {
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", password: "password321!", basketToken: nil),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .login(email: "h.dover@gmail.com", password: "password321!")
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // avoid always true warning and maintain check on result type
                    // not changing
                    let resultAny: Any = resultValue
                    XCTAssertEqual(resultAny is Void, true, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulLoginByEmailPassword_whenBasketSet() {
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
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .login(email: "h.dover@gmail.com", password: "password321!")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    // avoid always true warning and maintain check on result type
                    // not changing
                    let resultAny: Any = resultValue
                    XCTAssertEqual(resultAny is Void, true, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulLoginByEmailPassword() {
        
        let failError = APIErrorResult(errorCode: 401, errorText: "Unauthorized", errorDisplay: "Unauthorized", success: false)
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "failme@gmail.com", password: "password321!", basketToken: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailPasswordResponse = .failure(failError)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .login(email: "failme@gmail.com", password: "password321!")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? APIErrorResult {
                        XCTAssertEqual(loginError, failError, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }

}

final class LoginByEmailAndOneTimePasswordTests: UserServiceTests {
    
    // MARK: - func login(email: String, oneTimePassword: String) async throws -> Void
    
    func test_successfulLoginByEmailOneTimePassword() async {
        
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83", basketToken: nil),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .success(())
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83")
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_successfulLoginByEmailOneTimePassword_whenBasketSet() async {
        
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
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions,
            .clearMemberProfile,
            .store(memberProfile: member, forStoreId: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.loginByEmailOneTimePasswordResponse = .success(())
        mockedWebRepo.getProfileResponse = .success(member)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(member)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        do {
            try await sut.login(email: "h.dover@gmail.com", oneTimePassword: "6B9A83")
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        self.mockedWebRepo.verify()
        self.mockedDBRepo.verify()
    }
    
    func test_unsuccessfulLoginByEmailOneTimePassword() async {
        
        let failError = APIErrorResult(errorCode: 401, errorText: "Unauthorized", errorDisplay: "Unauthorized", success: false)
        
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

    }

}

// Cannot add Apple Pay Sign In unit tests because ASAuthorization instances cannot be manually created. Some
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


final class ResetPasswordRequestTests: UserServiceTests {
    
    // MARK: - func resetPasswordRequest(email:)
    
    func test_succesfulResetPasswordRequest_whenStanardResponse_returnSuccess() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordRequest(email: "cogin.waterman@me.com")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordRequestResponse = .success(Data.mockedSuccessData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPasswordRequest(email: "cogin.waterman@me.com")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    break
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccesfulResetPasswordRequest_whenUnexpectedJSONResponse_returnError() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordRequest(email: "cogin.waterman@me.com")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordRequestResponse = .success(Data.mockedFailureData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPasswordRequest(email: "cogin.waterman@me.com")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected Reset Password Request success", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.unableToResetPasswordRequest([:]), file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_succesfulResetPasswordRequest_whenNoJSONResponse_returnError() {
        
        let data = Data.mockedNonJSONData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .resetPasswordRequest(email: "cogin.waterman@me.com")
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordRequestResponse = .success(data)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPasswordRequest(email: "cogin.waterman@me.com")
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected Reset Password Request success", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.unableToDecodeResponse(String(decoding: data, as: UTF8.self)), file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
}

final class ResetPasswordTests: UserServiceTests {
    
    // MARK: - resetPassword(resetToken:logoutFromAll:password:currentPassword:)
    
    func test_succesfulResetPassword_whenMemberNotSignedInAndNoEmail_resetSucces() {
        
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPassword(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                email: nil,
                password: "password1",
                currentPassword: nil
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertNil(self.appState.value.userData.memberProfile)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_succesfulResetPassword_whenMemberNotSignedInAndEmail_resetSuccess() {
        
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
            ),
            .login(email: "kevin.palser@gmail.com", password: "password1", basketToken: nil),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.resetPasswordResponse = .success(data)
        mockedWebRepo.loginByEmailPasswordResponse = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPassword(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                email: "kevin.palser@gmail.com",
                password: "password1",
                currentPassword: nil
            )
        
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    break
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_succesfulResetPassword_whenMemberSignedInAndEmail_resetSucces() {
        
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPassword(
                resetToken: nil,
                logoutFromAll: false,
                email: "kevin.palser@gmail.com",
                password: "password1",
                currentPassword: "oldpassword1"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertNotNil(self.appState.value.userData.memberProfile)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccesfulResetPassword_whenMemberNotSignedInAndNoResetToken_returnError() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPassword(
                resetToken: nil,
                logoutFromAll: false,
                email: "kevin.palser@gmail.com",
                password: "password1",
                currentPassword: "oldpassword1"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected success", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccesfulResetPassword_whenMemberNotSignedInAndFail_returnError() {
        
        let data = UserSuccessResult.mockedFailureData
        
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .resetPassword(
                resetToken: "123456789abcdef",
                logoutFromAll: false,
                email: "kevin.palser@gmail.com",
                password: "password1",
                currentPassword: nil
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected success", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.unableToResetPassword, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
}

final class RegisterTests: UserServiceTests {
    
    // MARK: - func register(member:password:referralCode:marketingOptions:)
    
    func test_succesfulRegister_whenMemberNotAlreadyRegistered_registerLoginSuccess() {
        
        let member = MemberProfileRegisterRequest.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: member,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: member.emailAddress, password: "password", basketToken: nil),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .success(Data.mockedSuccessData)
        mockedWebRepo.loginByEmailPasswordResponse = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .register(member: member, password: "password", referralCode: nil, marketingOptions: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    break
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_succesfulRegister_whenMemberAlreadyRegisteredWithSameEmailAndPasswordMatch_registerLoginSuccess() {
        
        let member = MemberProfileRegisterRequest.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: member,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: member.emailAddress, password: "password", basketToken: nil),
            .getProfile(storeId: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .success(Data.mockedRegisterEmailAlreadyUsedData)
        mockedWebRepo.loginByEmailPasswordResponse = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .register(member: member, password: "password", referralCode: nil, marketingOptions: nil)
            .receive(on: RunLoop.main)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    break
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccesfulRegister_whenMemberAlreadyRegisteredWithSameEmailAndDifferentPassword_returnError() {
        
        let failError = APIErrorResult(errorCode: 401, errorText: "Unauthorized", errorDisplay: "Unauthorized", success: false)
        let registerErrorFields: [String: [String]] = ["email": ["The email has already been taken"]]
        let member = MemberProfileRegisterRequest.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: member,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: member.emailAddress, password: "password", basketToken: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .success(Data.mockedRegisterEmailAlreadyUsedData)
        mockedWebRepo.loginByEmailPasswordResponse = .failure(failError)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .register(member: member, password: "password", referralCode: nil, marketingOptions: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.unableToRegister(registerErrorFields), file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }

    func test_unsuccesfulRegister_whenMemberAlreadySignedIn_returnError() {
        
        let member = MemberProfileRegisterRequest.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        let exp = XCTestExpectation(description: #function)
        sut
            .register(member: member, password: "password", referralCode: nil, marketingOptions: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.unableToRegisterWhileMemberSignIn, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
}

final class LogoutTests: UserServiceTests {
    
    // MARK: - func logout()
    
    func test_successfulLogout() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .logout(basketToken: nil)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.logoutResponse = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .logout()
            .receive(on: RunLoop.main)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    // avoid always true warning and maintain check on result type
                    // not changing
                    let resultAny: Any = resultValue
                    XCTAssertEqual(resultAny is Void, true, file: #file, line: #line)
                    XCTAssertNil(self.appState.value.userData.memberProfile)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulLogout_whenBasketSet() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.userData.basket = Basket.mockedData
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .logout(basketToken: appState.value.userData.basket?.basketToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.logoutResponse = .success(true)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .logout()
            .receive(on: RunLoop.main)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    // avoid always true warning and maintain check on result type
                    // not changing
                    let resultAny: Any = resultValue
                    XCTAssertEqual(resultAny is Void, true, file: #file, line: #line)
                    XCTAssertNil(self.appState.value.userData.memberProfile)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulLogout_whenNotSignedIn_expectedMemberRequiredToBeSignedInError() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        // Configuring responses from repositories
        mockedWebRepo.logoutResponse = .failure(UserServiceError.memberRequiredToBeSignedIn)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .logout()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
}


final class GetProfileTests: UserServiceTests {
    
    // MARK: - func getProfile(profile:)
    
    func test_successfulGetProfile_whenStoreNotSelected() {
        
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
        
        // Configuring responses from repositories
        
        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        sut.getProfile(filterDeliveryAddresses: false)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulGetProfile_whenStoreSelected() {
        
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

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        sut.getProfile(filterDeliveryAddresses: true)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulGetProfile_whenNetworkErrorAndSavedProfile_returnProfile() {
        
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

        // Configuring responses from repositories
        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.memberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        sut.getProfile(filterDeliveryAddresses: false)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberProfile, MemberProfile.mockedData)
                case let .failure(error):
                    if let loginError = error as? UserServiceError {
                        XCTAssertEqual(loginError, UserServiceError.memberRequiredToBeSignedIn, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulGetProfile_whenNetworkErrorAndNoSavedProfile_returnError() {
        
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
        
        let exp = XCTestExpectation(description: #function)
        
        sut.getProfile(filterDeliveryAddresses: false)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Failed to hit expected error")
                case let .failure(error):
                    XCTAssertEqual(error as NSError, networkError)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulGetProfile_whenNetworkErrorAndExpiredSavedOptions_returnError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let profileFromAPI = MemberProfile.mockedData
        
        // Add a timestamp to the saved result that expired one hour ago
        let storedProfile = MemberProfile(
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
        
        let exp = XCTestExpectation(description: #function)
        sut.getProfile(filterDeliveryAddresses: false)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Failed to hit expected error")
                case let .failure(error):
                    XCTAssertEqual(error as NSError, networkError)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
}

final class UpdateProfileTests: UserServiceTests {
    
    // MARK: - func updateProfile(firstname:lastname:mobileContactNumber:)
    
    func test_updateProfile_whenStoreNotSelected() {
                
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
        
        let exp = XCTestExpectation(description: #function)
        
        sut.updateProfile(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "07923442322")
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTAssertEqual(self.sut.appState.value.userData.memberProfile?.firstname, "Cogin")
                case .failure:
                    XCTFail("Failed")
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulUpdateProfile_whenUserNotSignedIn_returnError() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        let exp = XCTestExpectation(description: #function)
        
        sut.updateProfile(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "07923442322")
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTFail("Failed to reach expected error")
                case .failure(let err):
                    XCTAssertEqual(err as! UserServiceError, UserServiceError.memberRequiredToBeSignedIn)
                }
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

final class AddAddressTests: UserServiceTests {
    // MARK: - func addAddress(profile:address)
    
    func test_successfulAddAddress_whenStoreNotSelected() {
        
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
        let exp = XCTestExpectation(description: #function)
        
        sut.addAddress(address: address)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
                case .failure:
                    XCTFail("Failed to add address")
                }
                exp.fulfill()
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessAddAddress_whenUserNotSignedIn_returnError() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        let exp = XCTestExpectation(description: #function)
        
        sut.addAddress(address: Address.mockedNewDeliveryData)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTFail("Failed to reach expected error")
                case .failure(let err):
                    XCTAssertEqual(err as! UserServiceError, UserServiceError.memberRequiredToBeSignedIn)
                }
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

final class UpdateAddressTests: UserServiceTests {
    
    // MARK: - func updateAddress(profile:address:)
    
    func test_successfulUpdateAddress_whenStoreNotSelected() {
        
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
        
        let exp = XCTestExpectation(description: #function)
        
        sut.updateAddress(address: Address.addressToUpdate)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
                case .failure:
                    XCTFail("Failed to add address")
                }
                exp.fulfill()
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessUpdateAddress_whenUserNotSignedIn_returnError() {
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil

        // Configuring responses from repositories
        let exp = XCTestExpectation(description: #function)
        
        sut.updateAddress(address: Address.addressToUpdate)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTFail("Failed to hit expected error")
                case .failure(let err):
                    XCTAssertEqual(err as! UserServiceError, UserServiceError.memberRequiredToBeSignedIn)
                }
                exp.fulfill()
                self.mockedWebRepo.verify()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

final class SetDefaultAddressTests: UserServiceTests {
    
    // MARK: - func setDefaultAddress(profile:addressId:)
    
    func test_successfulSetDefaultAddress() {
        
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
        
        let exp = XCTestExpectation(description: #function)
        
        sut.setDefaultAddress(addressId: 127501)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
                case .failure:
                    XCTFail("Failed to add address")
                }
                exp.fulfill()
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessSetDefaultAddress_whenUserNotSignedIn_returnError() {
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        
        // Configuring responses from repositories
        let exp = XCTestExpectation(description: #function)
        
        sut.setDefaultAddress(addressId: 127501)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTFail("Failed to hit expected error")
                case .failure(let err):
                    XCTAssertEqual(err as! UserServiceError, UserServiceError.memberRequiredToBeSignedIn)
                }
                exp.fulfill()
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

final class ReoveAddressTests: UserServiceTests {
    
    // MARK: - func removeAddress(profile:addressId)

    func test_successfulRemoveAddress() {
                
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
        
        let exp = XCTestExpectation(description: #function)
        
        sut.removeAddress(addressId: 127501)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberProfile, newProfile)
                case .failure:
                    XCTFail("Failed to add address")
                }
                exp.fulfill()
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessAddAddress_whenUserNotSignedIn_returnError() {
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        // Configuring responses from repositories
        let exp = XCTestExpectation(description: #function)
        
        sut.removeAddress(addressId: 127501)
            .sinkToResult { result in
                switch result {
                case .success:
                    XCTFail("Failed to hit expected error")
                case .failure(let err):
                    XCTAssertEqual(err as! UserServiceError, UserServiceError.memberRequiredToBeSignedIn)
                }
                exp.fulfill()
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
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
        
        let exp = XCTestExpectation(description: #function)

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
    
    func test_givenNoParams_whenCallingGetPastOrders_thenSuccessful() {
        let placedOrders = [PlacedOrder.mockedData]
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)])

        // Configuring responses from repositories

        mockedWebRepo.getPastOrdersResponse = .success(placedOrders)

        let exp = expectation(description: #function)
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrder]?>.notRequested)
        sut.getPastOrders(pastOrders: orders.binding, dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)
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
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_givenParams_whenCallingGetPastOrders_thenSuccessful() {
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
        sut.getPastOrders(pastOrders: orders.binding, dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit)
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
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenNetworkError_thenReturnError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)])

        // Configuring responses from repositories

        mockedWebRepo.getPastOrdersResponse = .failure(networkError)

        let exp = expectation(description: #function)
        let orders = BindingWithPublisher(value: Loadable<[PlacedOrder]?>.notRequested)
        sut.getPastOrders(pastOrders: orders.binding, dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: nil)
        orders.updatesRecorder
            .sink { updates in
                XCTAssertEqual(updates, [
                    .notRequested,
                    .isLoading(last: nil, cancelBag: CancelBag()),
                    .failed(networkError)
                ])
                self.mockedWebRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
}

final class GetPlacedOrderTests: UserServiceTests {
    
    // MARK: - getPlacedOrder(businessOrderId:)
    
    func test_givenNoParams_whenCallingGetPlacedOrder_thenSuccessful() {
        let placedOrder = PlacedOrder.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPlacedOrderDetails(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories

        mockedWebRepo.getPlacedOrderDetailsResponse = .success(placedOrder)
        
        let exp = expectation(description: #function)
        let order = BindingWithPublisher(value: Loadable<PlacedOrder>.notRequested)
        sut.getPlacedOrder(orderDetails: order.binding, businessOrderId: 123)
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
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_whenNetworkError_thenReturnError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = MemberProfile.mockedData

        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [.getPlacedOrderDetails(forBusinessOrderId: 123)])
        
        // Configuring responses from repositories

        mockedWebRepo.getPlacedOrderDetailsResponse = .failure(networkError)
        
        let exp = expectation(description: #function)
        let order = BindingWithPublisher(value: Loadable<PlacedOrder>.notRequested)
        sut.getPlacedOrder(orderDetails: order.binding, businessOrderId: 123)
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
