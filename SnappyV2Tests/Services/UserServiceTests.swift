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

final class LoginTests: UserServiceTests {
    
    // MARK: - func login(email:password:)
    
    func test_successfulLoginByEmailPassword() {
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "h.dover@gmail.com", password: "password321!")
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
                    XCTAssertEqual(self.appState.value.userData.memberSignedIn, true, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulLoginByEmailPassword() {
        
        let failError = APIErrorResult(errorCode: 401, errorText: "Unauthorized", errorDisplay: "Unauthorized", success: false)
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .login(email: "failme@gmail.com", password: "password321!")
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

        wait(for: [exp], timeout: 0.5)
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

final class RegisterTests: UserServiceTests {
    
    // MARK: - func register(member:password:referralCode:marketingOptions:)
    
    func test_succesfulRegister_whenMemberNotAlreadyRegistered_registerLoginSuccess() {
        
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: member,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: member.emailAddress, password: "password")
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearAllFetchedUserMarketingOptions
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.registerResponse = .success(Data.mockedRegisterSuccessData)
        mockedWebRepo.loginByEmailPasswordResponse = .success(true)
        mockedDBRepo.clearAllFetchedUserMarketingOptionsResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .register(member: member, password: "password", referralCode: nil, marketingOptions: nil)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberSignedIn, true, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_succesfulRegister_whenMemberAlreadyRegisteredWithSameEmailAndPasswordMatch_registerLoginSuccess() {
        
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: member,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: member.emailAddress, password: "password")
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
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.userData.memberSignedIn, true, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccesfulRegister_whenMemberAlreadyRegisteredWithSameEmailAndDifferentPassword_returnError() {
        
        let failError = APIErrorResult(errorCode: 401, errorText: "Unauthorized", errorDisplay: "Unauthorized", success: false)
        let registerErrorFields: [String: [String]] = ["email": ["The email has already been taken"]]
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        mockedWebRepo.actions = .init(expected: [
            .register(
                member: member,
                password: "password",
                referralCode: nil,
                marketingOptions: nil
            ),
            .login(email: member.emailAddress, password: "password")
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

        wait(for: [exp], timeout: 0.5)
    }

    func test_unsuccesfulRegister_whenMemberAlreadySignedIn_returnError() {
        
        let member = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
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

        wait(for: [exp], timeout: 0.5)
    }
    
}

final class LogoutTests: UserServiceTests {
    
    // MARK: - func logout()
    
    func test_successfulLogout() {
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .logout
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
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    // avoid always true warning and maintain check on result type
                    // not changing
                    let resultAny: Any = resultValue
                    XCTAssertEqual(resultAny is Void, true, file: #file, line: #line)
                    XCTAssertEqual(self.appState.value.userData.memberSignedIn, false, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulLogout_whenNotSignedIn_expectedMemberRequiredToBeSignedInError() {
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
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

        wait(for: [exp], timeout: 0.5)
    }
    
}


final class GetProfileTests: UserServiceTests {
    
    // MARK: - func getProfile(profile:)
    
    func test_successfulGetProfile_whenStoreNotSelected() {
        
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
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
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.getProfile(profile: memberProfile.binding, filterDeliveryAddresses: false)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulGetProfile_whenStoreSelected() {
        
        let profile = MemberProfile.mockedData
        let retailStore = RetailStoreDetails.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
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
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.getProfile(profile: memberProfile.binding, filterDeliveryAddresses: true)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulGetProfile_whenUserNotSignedIn_returnError() {

        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.getProfile(profile: memberProfile.binding, filterDeliveryAddresses: false)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.memberRequiredToBeSignedIn)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulGetProfile_whenNetworkErrorAndSavedProfile_returnProfile() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
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
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.getProfile(profile: memberProfile.binding, filterDeliveryAddresses: false)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulGetProfile_whenNetworkErrorAndNoSavedProfile_returnError() {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
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
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.getProfile(profile: memberProfile.binding, filterDeliveryAddresses: false)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
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
        appState.value.userData.memberSignedIn = true
        
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
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.getProfile(profile: memberProfile.binding, filterDeliveryAddresses: false)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}

final class UpdateProfileTests: UserServiceTests {
    
    // MARK: - func updateProfile(firstname:lastname:mobileContactNumber:)
    
    func test_successfulAddAddress_whenStoreNotSelected() {
        
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .updateProfile(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "0792344232")
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: nil)
        ])

        // Configuring responses from repositories

        mockedWebRepo.updateProfileResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.updateProfile(profile: memberProfile.binding, firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "0792344232")
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulUpdateProfile_whenUserNotSignedIn_returnError() {

        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.updateProfile(profile: memberProfile.binding, firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "0792344232")
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.memberRequiredToBeSignedIn)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}

final class AddAddressTests: UserServiceTests {
    
    // MARK: - func addAddress(profile:address)
    
    func test_successfulAddAddress_whenStoreNotSelected() {
        
        let profile = MemberProfile.mockedData
        let address = Address.mockedNewDeliveryData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .addAddress(address: address)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: nil)
        ])

        // Configuring responses from repositories

        mockedWebRepo.addAddressResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.addAddress(profile: memberProfile.binding, address: address)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessAddAddress_whenUserNotSignedIn_returnError() {

        let address = Address.mockedNewDeliveryData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.addAddress(profile: memberProfile.binding, address: address)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.memberRequiredToBeSignedIn)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}

final class UpdateAddressTests: UserServiceTests {
    
    // MARK: - func updateAddress(profile:address:)

    func test_successfulUpdateAddress_whenStoreNotSelected() {
        
        let profile = MemberProfile.mockedData
        let address = Address.mockedNewDeliveryData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .updateAddress(address: address)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: nil)
        ])

        // Configuring responses from repositories

        mockedWebRepo.updateAddressResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.updateAddress(profile: memberProfile.binding, address: address)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessUpdateAddress_whenUserNotSignedIn_returnError() {

        let address = Address.mockedNewDeliveryData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.updateAddress(profile: memberProfile.binding, address: address)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.memberRequiredToBeSignedIn)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}

final class SetDefaultAddressTests: UserServiceTests {
    
    // MARK: - func setDefaultAddress(profile:addressId:)
    
    func test_successfulSetDefaultAddress() {
        
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .setDefaultAddress(addressId: 12345)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: nil)
        ])

        // Configuring responses from repositories

        mockedWebRepo.setDefaultAddressResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.setDefaultAddress(profile: memberProfile.binding, addressId: 12345)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessSetDefaultAddress_whenUserNotSignedIn_returnError() {

        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.setDefaultAddress(profile: memberProfile.binding, addressId: 12345)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.memberRequiredToBeSignedIn)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}

final class ReoveAddressTests: UserServiceTests {
    
    // MARK: - func removeAddress(profile:addressId)
    
    func test_successfulRemoveAddress() {
        
        let profile = MemberProfile.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .removeAddress(addressId: 12345)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearMemberProfile,
            .store(memberProfile: profile, forStoreId: nil)
        ])

        // Configuring responses from repositories

        mockedWebRepo.removeAddressResponse = .success(profile)
        mockedDBRepo.clearMemberProfileResult = .success(true)
        mockedDBRepo.storeMemberProfileResult = .success(profile)
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.removeAddress(profile: memberProfile.binding, addressId: 12345)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(profile)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessAddAddress_whenUserNotSignedIn_returnError() {

        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let memberProfile = BindingWithPublisher(value: Loadable<MemberProfile>.notRequested)
        sut.removeAddress(profile: memberProfile.binding, addressId: 12345)
        memberProfile.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.memberRequiredToBeSignedIn)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}

final class GetMarketingOptionsTests: UserServiceTests {
    
    // MARK: - func getMarketingOptions(options:isCheckout:notificationsEnabled:)
    
    func test_successfulGetMarketingOptions_whenNotAtCheckoutAndMemberSignedIn_returnOptions() {
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
        appState.value.userData.memberSignedIn = true
        
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
        
        let exp = XCTestExpectation(description: #function)
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: optionsFetchStored.fetchIsCheckout!,
            notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(optionsFetchStored)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulGetMarketingOptions_whenNotAtCheckoutAndMemberNotSignedIn_returnError() {

        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: false,
            notificationsEnabled: false
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.memberRequiredToBeSignedIn)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulGetMarketingOptions_whenAtCheckoutWithBasketAndMemberNotSignedIn_returnOptions() {
        
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
        appState.value.userData.memberSignedIn = false
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
        
        let exp = XCTestExpectation(description: #function)
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: optionsFetchStored.fetchIsCheckout!,
            notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(optionsFetchStored)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulGetMarketingOptions_whenAtCheckoutWithBasketAndMemberSignedIn_returnOptions() {
        
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
        appState.value.userData.memberSignedIn = true
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
        
        let exp = XCTestExpectation(description: #function)
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: optionsFetchStored.fetchIsCheckout!,
            notificationsEnabled: optionsFetchStored.fetchNotificationsEnabled!
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(optionsFetchStored)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulGetMarketingOptions_whenAtCheckoutWithoutBasket_returnError() {

        let exp = XCTestExpectation(description: #function)
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: true,
            notificationsEnabled: false
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.unableToProceedWithoutBasket)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_successfulGetMarketingOptions_whenNetworkErrorAndSavedOptions_returnOptions() {
        
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
        appState.value.userData.memberSignedIn = false
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
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: true,
            notificationsEnabled: false
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(optionsFetchStored)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulGetMarketingOptions_whenNetworkErrorAndNoSavedOptions_returnError() {
        
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
        appState.value.userData.memberSignedIn = false
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
        
        let exp = XCTestExpectation(description: #function)
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: true,
            notificationsEnabled: false
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulGetMarketingOptions_whenNetworkErrorAndExpiredSavedOptions_returnError() {
        
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
        appState.value.userData.memberSignedIn = false
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
        let userMarketingOptionsFetch = BindingWithPublisher(value: Loadable<UserMarketingOptionsFetch>.notRequested)
        sut.getMarketingOptions(
            options: userMarketingOptionsFetch.binding,
            isCheckout: true,
            notificationsEnabled: false
        )
        userMarketingOptionsFetch.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(networkError)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}

final class UpdateMarketingOptionsTests: UserServiceTests {
    
    // MARK: - func updateMarketingOptions(result:options:)
    
    func test_successfulUpdateMarketingOptions_whenMemberSignedIn_returnUpdateResult() {
        
        let marketingOptions = UserMarketingOptionRequest.mockedArrayData
        let updateResponse = UserMarketingOptionsUpdateResponse.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = true
        
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
        
        let exp = XCTestExpectation(description: #function)
        let updateMarketingOptions = BindingWithPublisher(value: Loadable<UserMarketingOptionsUpdateResponse>.notRequested)
        sut.updateMarketingOptions(
            result: updateMarketingOptions.binding,
            options: marketingOptions
        )
        updateMarketingOptions.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(updateResponse)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulUpdateMarketingOptions_whenMemberNotSignedInAndBasket_returnUpdateResult() {
        
        let marketingOptions = UserMarketingOptionRequest.mockedArrayData
        let updateResponse = UserMarketingOptionsUpdateResponse.mockedData
        let basket = Basket.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
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
        
        let exp = XCTestExpectation(description: #function)
        let updateMarketingOptions = BindingWithPublisher(value: Loadable<UserMarketingOptionsUpdateResponse>.notRequested)
        sut.updateMarketingOptions(
            result: updateMarketingOptions.binding,
            options: marketingOptions
        )
        updateMarketingOptions.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(updateResponse)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulUpdateMarketingOptions_whenMemberNotSignedInAndNoBasket_returnError() {
        
        let marketingOptions = UserMarketingOptionRequest.mockedArrayData

        // Configuring app prexisting states
        appState.value.userData.memberSignedIn = false
        
        let exp = XCTestExpectation(description: #function)
        let updateMarketingOptions = BindingWithPublisher(value: Loadable<UserMarketingOptionsUpdateResponse>.notRequested)
        sut.updateMarketingOptions(
            result: updateMarketingOptions.binding,
            options: marketingOptions
        )
        updateMarketingOptions.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(UserServiceError.unableToProceedWithoutBasket)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.5)
    }
    
}
