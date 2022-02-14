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
    
    // TODO: uses network handler specific function - will need to rethink as movking boiler plate code does not fit use case
    // func login(email: String, password: String) -> AnyPublisher<Bool, Error>
    
//    func test_loginEmailPassword_givenCorrectUserNamePassword() throws {
//
//        let successResult = true
//
//        let parameters: [String: Any] = [
//            "username": "b.dover@gmail.com",
//            "password": "password321!"
//        ]
//
//        try mock(.getProfile(<#T##[String : Any]?#>), result: .success(successResult))
//        let exp = XCTestExpectation(description: "Completion")
//
//        sut.login(email: "b.dover@gmail.com", password: "password321!").sinkToResult { result in
//            result.assertSuccess(value: successResult)
//            exp.fulfill()
//        }.store(in: &subscriptions)
//
//        wait(for: [exp], timeout: 2)
//    }
    
    // MARK: - logout()
    
    // TODO: uses network handler specific function - will need to rethink as movking boiler plate code does not fit use case
    // func logout() -> AnyPublisher<Bool, Error>
    
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

    // MARK: - getMarketingOptions(isCheckout:notificationsEnabled:basketToken:)
    
    func test_getMarketingOptions() throws {
        
        let data = UserMarketingOptionsFetch.mockedDataFromAPI

        let parameters: [String: Any] = [
            "isCheckout": true,
            "notificationsEnabled": false,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]

        try mock(.getMarketingOptions(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .getMarketingOptions(
                isCheckout: true,
                notificationsEnabled: false,
                basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
            )
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - updateMarketingOptions(options:basketToken:)
    
    func test_updateMarketingOptions_withoutBasketToken() throws {

        let data = UserMarketingOptionsUpdateResponse.mockedData

        let parameters: [String: Any] = [
            "marketingOptions": UserMarketingOptionRequest.mockedArrayData
        ]

        try mock(.updateMarketingOptions(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .updateMarketingOptions(
                options: UserMarketingOptionRequest.mockedArrayData,
                basketToken: nil
            )
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_updateMarketingOptions_withBasketToken() throws {

        let data = UserMarketingOptionsUpdateResponse.mockedData

        let parameters: [String: Any] = [
            "marketingOptions": UserMarketingOptionRequest.mockedArrayData,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]

        try mock(.updateMarketingOptions(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut
            .updateMarketingOptions(
                options: UserMarketingOptionRequest.mockedArrayData,
                basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
            )
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}