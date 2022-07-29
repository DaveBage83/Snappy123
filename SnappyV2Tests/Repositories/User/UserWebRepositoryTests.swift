//
//  UserWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 10/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class UserWebRepositoryTests: XCTestCase {
    
    private var sut: UserWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = UserWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = UserWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - login(email:password:)
    
    func testLoginEmailPassword() async throws {
        
        let data = LoginResult.mockedSuccessDataWithoutRegistering

        let parameters: [String: Any] = [
            "client_id" : AppV2Constants.API.clientId,
            "scope" : "*",
            "password" : "password1",
            "username" : "kevin.palser@me.com",
            "client_secret" : AppV2Constants.API.clientSecret,
            "grant_type" : "password"
        ]

        try mock(.login(parameters), result: .success(data))
        do {
            let result = try await sut
                .login(
                    email: parameters["username"] as! String,
                    password: parameters["password"] as! String,
                    basketToken: nil
                )
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - login(email:oneTimePassword:basketToken:)

    func testLoginOneTimePassword() async throws {
        
        let data = LoginResult.mockedSuccessDataWithoutRegistering

        let parameters: [String: Any] = [
            "provider": "apple",
            "registeringFromScreen": "account_tab",
            "scope": "*",
            "platform": AppV2Constants.Client.platform,
            "grant_type": "custom_request",
            "access_token": "eyJraWQiOiJmaDZCczhDIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm10Y21vYmlsZS5NeS1NaW5pLU1hcnQiLCJleHAiOjE2NTMxMTQ1NDcsImlhdCI6MTY1MzAyODE0Nywic3ViIjoiMDAxOTc4LjY4OTYzY2M3MGEyODQyNzE4ZTZkNWRmYjYwMjlkNzE1LjE3MDciLCJjX2hhc2giOiJNSmpMci01SmVlLXZvU1g5TE8tUGVnIiwiYXV0aF90aW1lIjoxNjUzMDI4MTQ3LCJub25jZV9zdXBwb3J0ZWQiOnRydWV9.XCiJ1jJx3JeQhCm2JZhnqeUoZyHbTlUx9RNQXVrGBnlQm9mKQNXsiGiY1d9bc09bRxmzcVvMG8T_lPAQZhhlNwk6Rojiglz1PtXFJbXDVzYWVTNa5o8Uhv20fM8mn_r_EowtqRVyCcWtJ4IK9BPc-4-foZXdhPMjWhED3HWKDWXGGejN3MWQhSzCDsXwFCp1cGXPr1ZaDseGtytHxfUnouFy9-7hUsOX4oEun8zo4y1VMeSPOmAGSwZD6D5Jrb6ebJZ1jsFkrwDnmvXI5AVj9NZxwn_YDwc2a-1_1PC4QQWZ4uNWR80OX1M9sps65mNK2ITUtJfbUcpTDFHnePS9tA",
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret
        ]

        try mock(.login(parameters), result: .success(data))
        do {
            let result = try await sut
                .login(
                    email: "kevin.palser@gmail.com",
                    oneTimePassword: "",
                    basketToken: nil
                )
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - login(appleSignInToken:username:firstname:lastname:basketToken:registeringFromScreen:)
    
    func testLoginAppleSignInToken() async throws {
        
        let data = LoginResult.mockedSuccessDataWithoutRegistering

        let parameters: [String: Any] = [
            "provider": "apple",
            "registeringFromScreen": "account_tab",
            "scope": "*",
            "platform": AppV2Constants.Client.platform,
            "grant_type": "custom_request",
            "access_token": "eyJraWQiOiJmaDZCczhDIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm10Y21vYmlsZS5NeS1NaW5pLU1hcnQiLCJleHAiOjE2NTMxMTQ1NDcsImlhdCI6MTY1MzAyODE0Nywic3ViIjoiMDAxOTc4LjY4OTYzY2M3MGEyODQyNzE4ZTZkNWRmYjYwMjlkNzE1LjE3MDciLCJjX2hhc2giOiJNSmpMci01SmVlLXZvU1g5TE8tUGVnIiwiYXV0aF90aW1lIjoxNjUzMDI4MTQ3LCJub25jZV9zdXBwb3J0ZWQiOnRydWV9.XCiJ1jJx3JeQhCm2JZhnqeUoZyHbTlUx9RNQXVrGBnlQm9mKQNXsiGiY1d9bc09bRxmzcVvMG8T_lPAQZhhlNwk6Rojiglz1PtXFJbXDVzYWVTNa5o8Uhv20fM8mn_r_EowtqRVyCcWtJ4IK9BPc-4-foZXdhPMjWhED3HWKDWXGGejN3MWQhSzCDsXwFCp1cGXPr1ZaDseGtytHxfUnouFy9-7hUsOX4oEun8zo4y1VMeSPOmAGSwZD6D5Jrb6ebJZ1jsFkrwDnmvXI5AVj9NZxwn_YDwc2a-1_1PC4QQWZ4uNWR80OX1M9sps65mNK2ITUtJfbUcpTDFHnePS9tA",
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret
        ]

        try mock(.login(parameters), result: .success(data))
        do {
            let result = try await sut
                .login(
                    appleSignInToken: parameters["access_token"] as! String,
                    username: nil,
                    firstname: nil,
                    lastname: nil,
                    basketToken: nil,
                    registeringFromScreen: .accountTab
                )
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - login(facebookAccessToken:registeringFromScreen:)
    
    func test_loginFacebookToken() async throws {
        
        let data = LoginResult.mockedSuccessDataWithoutRegistering

        let parameters: [String: Any] = [
            "provider" : "facebook",
            "registeringFromScreen" : "start_screen",
            "scope" : "*",
            "platform" : AppV2Constants.Client.platform,
            "grant_type" : "custom_request",
            "access_token" : "EAAJgTxPwHvEBAAk220gs4FUmSqrIMl4z0mF5mS1SHgZAlcPMDrB7QDlWS5JNL0LmfJmIlmsZBwLyiMg6ZBEFbOzCIIxxW9Q6Gq8D1jz223kXxtHYwbtEsbAVuEJozu3e9NVJMLScOWA8lQZB5afgCaQMuZBqK5QHdcMZCjfARr7bF4GEA01KUiQFfew53Ty5a6X2z3vqJp7t938Xkk1MJ6SXKGdzZCsSMGADPWgxqbZAUDxfY79rzZAYU",
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret
        ]

        try mock(.login(parameters), result: .success(data))
        do {
            let result = try await sut
                .login(
                    facebookAccessToken: parameters["access_token"] as! String,
                    basketToken: nil,
                    registeringFromScreen: .startScreen
                )
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }

    // MARK: - login(googleAccessToken:basketToken:registeringFromScreen:)
    
    func test_loginGoogleAccessToken() async throws {
        
        let data = LoginResult.mockedSuccessDataWithoutRegistering

        let parameters: [String: Any] = [
            "provider": "google",
            "registeringFromScreen": "account_tab",
            "scope": "*",
            "platform": AppV2Constants.Client.platform,
            "grant_type": "custom_request",
            "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjQ4NmYxNjQ4MjAwNWEyY2RhZjI2ZDkyMTQwMThkMDI5Y2E0NmZiNTYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMDQwNjM5MzU5NjQwLTRmbGVudGJqaTVoMjFraTBqYWx1ZjdwcmpjbDc2ZzE1LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiMTA0MDYzOTM1OTY0MC00ZmxlbnRiamk1aDIxa2kwamFsdWY3cHJqY2w3NmcxNS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjExMDQzMzYxOTI0MDk5NDYzNjExNCIsImVtYWlsIjoiYXBwc0BzbmFwcHlzaG9wcGVyLmNvLnVrIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJrV1Zqakt5WElvQTh0Zzd0ZS1LVG9RIiwibm9uY2UiOiJILVg1TGZWYnFJM053Q0FZWkZQVDl1TFhCNDRySjlTcG9IdVpob01nSkg0IiwibmFtZSI6IlNuYXBweSBTaG9wcGVyIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FBVFhBSnpBMHhSUXZCSDBCMjl5SE82WkVUSU1BZHhDWlQwU2ltaGNnZWRKPXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6IlNuYXBweSIsImZhbWlseV9uYW1lIjoiU2hvcHBlciIsImxvY2FsZSI6ImVuIiwiaWF0IjoxNjUzMDI3Nzg0LCJleHAiOjE2NTMwMzEzODR9.Z99zaQ3PTMUnXrfg2MNzAqlkm082Fiwhre0MEcwsLrDEjRcADrgMkD0agXgtRHQGHua5rNNlq5f_p4JtVRu2djJzkMOkKzuD0cvBXphvcsOT9PpWTfVSthuRf5QU9--ESGDKNWtCdrGRf2G54paWSKjdlfFgdP392foYHYhhSCYAVjRCJ2RkPmZRndzUBqhzmqY5wX9vAU37TaM2eRcaLRGQZF_258nzi_2cnQF74ROXJzN1YTlfZV3PhSsFB3cDlpv-EGrFDWAZjD1i_pPzaxZzJImE1c2K-pC4xvohJeV1c4TTKLr-lILhCKu2fUASf8qKJuHDWmqGACQ3Cc5_Sw",
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret
        ]

        try mock(.login(parameters), result: .success(data))
        do {
            let result = try await sut
                .login(
                    googleAccessToken: parameters["id_token"] as! String,
                    basketToken: nil,
                    registeringFromScreen: .accountTab
                )
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }

    // MARK: - logout()
    
    // TODO: uses network handler specific function - will need to rethink as moving boiler plate code does not fit use case
    // func logout() -> AnyPublisher<Bool, Error>
    
    // MARK: - resetPasswordRequest(email:)
    
    func test_resetPasswordRequest() throws {
        
        let data = Data.mockedSuccessData
        
        let parameters: [String: Any] = [
            "email": "cogin.waterman@me.com"
        ]
        
        try mock(.resetPasswordRequest(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .resetPasswordRequest(email: "cogin.waterman@me.com")
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - resetPassword(resetToken:logoutFromAll:password:currentPassword:)
    
    func test_resetPassword_whenTokenPresent_returnSuccess() throws {
        
        let data = UserSuccessResult.mockedSuccessData
        
        let parameters: [String: Any] = [
            "logoutFromAll": false,
            "password": "password1",
            "resetToken": "123456789abcdef"
        ]
        
        try mock(.resetPassword(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .resetPassword(resetToken: "123456789abcdef", logoutFromAll: false, password: "password1", currentPassword: nil)
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_resetPassword_whenNeitherTokenNorCurrentPasswordPresent_returnError() throws {
        
        let exp = XCTestExpectation(description: "Completion")

        sut
            .resetPassword(resetToken: nil, logoutFromAll: false, password: "password1", currentPassword: nil)
            .sinkToResult { result in
                result.assertFailure(UserServiceError.invalidParameters(["either resetToken or currentPassword must be set"]).localizedDescription)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - register(member:password:referralCode:marketingOptions:)
    
    func test_register() async throws {
        
        let member = MemberProfileRegisterRequest.mockedData
        let data = UserRegistrationResult.mockedSucess

        let parameters: [String: Any] = [
            "email": member.emailAddress,
            "password": "password1",
            "firstname": member.firstname,
            "lastname": member.lastname,
            "mobileContactNumber": member.mobileContactNumber ?? "",
            "referralCode": "AABBCC",
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "defaultBillingAddress": [
                "firstname": member.defaultBillingDetails?.firstName,
                "lastname": member.defaultBillingDetails?.lastName,
                "addressLine1": member.defaultBillingDetails?.addressLine1,
                "addressLine2": member.defaultBillingDetails?.addressLine2,
                "town": member.defaultBillingDetails?.town,
                "postcode": member.defaultBillingDetails?.postcode,
                "countryCode": member.defaultBillingDetails?.countryCode
            ],
            "defaultDeliveryAddress": [
                "addressLine1": member.savedAddresses?[0].addressLine1,
                "town": member.savedAddresses?[0].town,
                "postcode": member.savedAddresses?[0].postcode
            ],
            "marketingPreferences": [
                "email": "in",
                "sms": "out"
            ]
        ]

        try mock(.register(parameters), result: .success(data))
        do {
            let result = try await sut
                .register(
                    member: member,
                    password: "password1",
                    referralCode: "AABBCC",
                    marketingOptions: UserMarketingOptionResponse.mockedArrayData
                )
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - getProfile(storeId:)
    
    func test_getProfile() throws {
        
        let data = MemberProfile.mockedDataFromAPI

        let parameters: [String: Any] = [
            "storeId": 910
        ]

        try mock(.getProfile(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .getProfile(storeId: 910)
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - updateProfile(profile:firstname:lastname:mobileContactNumber:)
    
    func test_updateProfile() throws {
        
        let data = MemberProfile.mockedDataFromAPI

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "firstname": "Cogin",
            "lastname": "Waterman",
            "mobileContactNumber": "0789991234"
        ]

        try mock(.updateProfile(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .updateProfile(firstname: "Cogin", lastname: "Waterman", mobileContactNumber: "0789991234")
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - addAddress(storeId:address:)
    
    func test_addAddress() throws {
        
        let data = MemberProfile.mockedDataFromAPI

        try mock(.addAddress([:]), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .addAddress(address: Address.mockedNewDeliveryData)
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - updateAddress(storeId:address:)
    
    func test_updateAddress_givenAddressWithId_returnsProfile() throws {
        
        let data = MemberProfile.mockedDataFromAPI
        let address = Address.mockedKnownDeliveryData

        try mock(.updateAddress([:]), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.updateAddress(address: address).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_updateAddress_givenAddressWithNoId_returnInvalidParametersError() throws {
        
        let address = Address.mockedNewDeliveryData

        let exp = XCTestExpectation(description: "Completion")

        sut.updateAddress(address: address).sinkToResult { result in
            result.assertFailure(UserServiceError.invalidParameters(["address id not set"]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - setDefaultAddress(storeId:addressId:)
    
    func test_setDefaultAddress() throws {
        
        let data = MemberProfile.mockedDataFromAPI
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "addressId": 12345
        ]
        
        try mock(.setDefaultAddress(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.setDefaultAddress(addressId: 12345).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - test_removeAddress(storeId:addressId:)
    
    func test_removeAddress() throws {
        
        let data = MemberProfile.mockedDataFromAPI

        let parameters: [String: Any] = [
            "addressId": 123456
        ]

        try mock(.removeAddress(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .removeAddress(addressId: 123456)
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - getPastOrders(dateFrom:dateTo:status:page:limit:)
    
    func test_getPastOrders() throws {
        
        let data = [PlacedOrder.mockedData]
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "limit": 10
        ]

        try mock(.getPastOrders(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .getPastOrders(dateFrom: nil, dateTo: nil, status: nil, page: nil, limit: 10)
            .sinkToResult { result in
                XCTAssertTrue(result.isSuccess)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - getPlacedOrderDetails(forBusinessOrderId:)
    
    func test_getPlacedOrderDetails() throws {
        
        let data = PlacedOrder.mockedData
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "businessOrderId": 2106
        ]

        try mock(.getPlacedOrderDetails(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .getPlacedOrderDetails(forBusinessOrderId: 2106)
            .sinkToResult { result in
                XCTAssertTrue(result.isSuccess)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }

    // MARK: - getMarketingOptions(isCheckout:notificationsEnabled:basketToken:)
    
    func test_getMarketingOptions() async throws {
        
        let data = UserMarketingOptionsFetch.mockedDataFromAPI

        let parameters: [String: Any] = [
            "isCheckout": true,
            "notificationsEnabled": false,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]

        try mock(.getMarketingOptions(parameters), result: .success(data))

        let result = try await sut.getMarketingOptions(
                isCheckout: true,
                notificationsEnabled: false,
                basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
            )
        
        XCTAssertEqual(data, result, file: #file, line: #line)
    }
    
    // MARK: - updateMarketingOptions(options:basketToken:)
    
    func test_updateMarketingOptions_withoutBasketToken() async throws {

        let data = UserMarketingOptionsUpdateResponse.mockedData

        let parameters: [String: Any] = [
            "marketingOptions": UserMarketingOptionRequest.mockedArrayData
        ]

        try mock(.updateMarketingOptions(parameters), result: .success(data))

        let result = try await sut
            .updateMarketingOptions(
                options: UserMarketingOptionRequest.mockedArrayData,
                basketToken: nil
            )
        
        XCTAssertEqual(data, result, file: #file, line: #line)
    }
    
    func test_updateMarketingOptions_withBasketToken() async throws {

        let data = UserMarketingOptionsUpdateResponse.mockedData

        let parameters: [String: Any] = [
            "marketingOptions": UserMarketingOptionRequest.mockedArrayData,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]

        try mock(.updateMarketingOptions(parameters), result: .success(data))

        let result = try await sut
            .updateMarketingOptions(
                options: UserMarketingOptionRequest.mockedArrayData,
                basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
            )
        
        XCTAssertEqual(data, result, file: #file, line: #line)
    }
    
    // MARK: - checkRegistrationStatus(email:basketToken:)
    
    func test_checkRegistrationStatus() async throws {
        
        let data = CheckRegistrationResult.mockedData
        
        let parameters: [String: Any] = [
            "email": "XXXX@XXXXXX.XX",
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]

        try mock(.checkRegistrationStatus(parameters), result: .success(data))
        
        let result = try await sut.checkRegistrationStatus(email: "XXXX@XXXXXX.XX", basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911")
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - requestMessageWithOneTimePassword(email:type:)
    
    func test_requestMessageWithOneTimePassword() async throws {
        
        let data = OneTimePasswordSendResult.mockedData
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "email": "XXXX@XXXXXX.XX",
            "type": OneTimePasswordSendType.sms.rawValue
        ]

        try mock(.requestMessageWithOneTimePassword(parameters), result: .success(data))
        
        let result = try await sut.requestMessageWithOneTimePassword(email: "XXXX@XXXXXX.XX", type: .sms)
        XCTAssertEqual(result, data, file: #file, line: #line)
        
    }
    
    // MARK: - getDriverSessionSettings(withKnownV1SessionToken:)
    
    func test_getDriverSessionSettings() async throws {
        
        let data = DriverSessionSettings.mockedData
        
        let parameters: [String: Any] = [
            "sessionToken": "bf4714bebcfab642a877f6bf22de8acc"
        ]

        try mock(.getDriverSessionSettings(parameters), result: .success(data))
        
        let result = try await sut.getDriverSessionSettings(withKnownV1SessionToken: "bf4714bebcfab642a877f6bf22de8acc")
        XCTAssertEqual(result, data, file: #file, line: #line)
        
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
