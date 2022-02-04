//
//  BasketWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class BasketWebRepositoryTests: XCTestCase {
    
    private var sut: BasketWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = BasketWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = BasketWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - 
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}

