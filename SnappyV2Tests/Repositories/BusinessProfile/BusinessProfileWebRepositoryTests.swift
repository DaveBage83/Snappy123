//
//  BusinessProfileWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class BusinessProfileWebRepositoryTests: XCTestCase {
    
    private var sut: BusinessProfileWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = BusinessProfileWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = BusinessProfileWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - getProfile()
    
    func test_getProfile() throws {
        
        let data = BusinessProfile.mockedDataFromAPI
        
        try mock(.getProfile, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
    
        sut
            .getProfile()
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
