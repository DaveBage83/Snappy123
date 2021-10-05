//
//  RetailStoresWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 04/10/2021.
//

import XCTest
import Combine
@testable import SnappyV2

final class RetailStoresWebRepositoryTests: XCTestCase {
    
    private var sut: RetailStoresWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = RetailStoresWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = RetailStoresWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - loadRetailStores(postcode:)
    
    func test_loadRetailStores_postcode() throws {
        let data = RetailStoresSearch.mockedData
        
        let parameters: [String: Any] = [
            "postcode": "DD1 3JA",
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        try mock(.searchByPostcode(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStores(postcode: "DD1 3JA").sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - loadRetailStores(location:)
    
    // MARK: - loadRetailStoreDetails(storeId:, postcode:)
    
//    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoresSearch, Error>
//    func loadRetailStores(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch, Error>
//    func loadRetailStoreDetails(storeId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails, Error>

    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
