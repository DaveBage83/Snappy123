//
//  UtilityMockedData.swift
//  SnappyV2Tests
//
//  Created by David Bage on 24/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class UtilityWebRepositoryTests: XCTestCase {
    private var sut: UtilityWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = UtilityWebRepository.API
    typealias Mock = RequestMocking.MockedResponse
    
    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = UtilityWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/")
    }
    
    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_getServerTime_returnServerTimeUTC() throws {
        let data = TrueTime(timeUTC: "2022-01-24T17:19:22+00:00")
        
        try mock(.getServerTime, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.getServerTime()
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
}
