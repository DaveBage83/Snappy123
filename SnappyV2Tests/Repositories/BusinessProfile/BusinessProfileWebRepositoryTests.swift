//
//  BusinessProfileWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
@testable import SnappyV2

final class BusinessProfileWebRepositoryTests: XCTestCase {
    
    private var sut: BusinessProfileWebRepository!
    
    typealias API = BusinessProfileWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        sut = BusinessProfileWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - getProfile()
    
    func test_getProfile() async throws {
        
        let data = BusinessProfile.mockedDataFromAPI
        
        try mock(.getProfile, result: .success(data))
        
        do {
            let result = try await sut.getProfile()
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
