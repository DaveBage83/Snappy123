//
//  AddressWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 16/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class AddressWebRepositoryTests: XCTestCase {
    
    private var sut: AddressWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = AddressWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = AddressWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - findAddresses(postcode:countryCode:)
    
    func test_findAddresses_givenValidPostcode_returnFetchedAddresses() throws {
        
        let data = FoundAddress.mockedArrayData
        
        let parameters: [String: Any] = [
            "postcode": "B38 9BB",
            "countryCode": "UK"
        ]
        
        try mock(.findAddresses(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.findAddresses(postcode: "B38 9BB", countryCode: "UK").sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_findAddresses_givenEmptyPostcode_returnInvalidParametersError() throws {
        let data = RetailStoresSearch.mockedData

        let parameters: [String: Any] = [
            "postcode": "",
            "countryCode": "UK"
        ]

        try mock(.findAddresses(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.findAddresses(postcode: "", countryCode: "UK").sinkToResult { result in
            result.assertFailure(AddressServiceError.invalidParameters(["postcode empty"]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_findAddresses_givenInvalidOrUknownPostcode_returnNilResult() throws {
        let data: [FoundAddress]? = nil

        let parameters: [String: Any] = [
            "postcode": "ZZ99 9ZZ",
            "countryCode": "UK"
        ]

        try mock(.findAddresses(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.findAddresses(postcode: "ZZ99 9ZZ", countryCode: "UK").sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - getCountries()
    
    func test_getCountries_whenServerHasCountries_returnFetchedCountries() throws {
        
        let data = AddressSelectionCountry.mockedArrayData
        
        try mock(.getCountries, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.getCountries().sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_getCountries_whenServerHasNoCountries_returnNilResult() throws {
        
        let data: [AddressSelectionCountry]? = nil
        
        try mock(.getCountries, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.getCountries().sinkToResult { result in
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
