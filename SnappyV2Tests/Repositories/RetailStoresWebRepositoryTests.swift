//
//  RetailStoresWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 04/10/2021.
//

import XCTest
import Combine
@testable import SnappyV2
import CoreLocation

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
    
    func test_loadRetailStores_empty_postcode() throws {
        let data = RetailStoresSearch.mockedData
        
        let parameters: [String: Any] = [
            "postcode": "",
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        try mock(.searchByPostcode(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStores(postcode: "").sinkToResult { result in
            result.assertFailure(RetailStoresServiceError.invalidParameters(["postcode empty"]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - loadRetailStores(location:)
    
    func test_loadRetailStores_location() throws {
        let data = RetailStoresSearch.mockedData
        
        let parameters: [String: Any] = [
            "lat": 56.473358599999997,
            "lng": -3.0111853000000002,
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        try mock(.searchByLocation(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStores(location: CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - loadRetailStoreDetails(storeId:postcode:)
    
    func test_loadRetailStoreDetails() throws {
        let data = RetailStoreDetails.mockedData
        
        let parameters: [String: Any] = [
            "storeId": 30,
            "country": "UK",
            "postcode": "DD1 3JA",
            "businessId": AppV2Constants.Business.id
        ]
        
        try mock(.retailStoreDetails(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStoreDetails(storeId: 30, postcode: "DD1 3JA").sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadRetailStoreDetails_empty_postcode() throws {
        let data = RetailStoreDetails.mockedData
        
        let parameters: [String: Any] = [
            "storeId": 30,
            "country": "UK",
            "postcode": "",
            "businessId": AppV2Constants.Business.id
        ]
        
        try mock(.retailStoreDetails(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStoreDetails(storeId: 30, postcode: "").sinkToResult { result in
            result.assertFailure(RetailStoresServiceError.invalidParameters(["postcode empty"]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - loadRetailStoreTimeSlots(storeId:startDate:endDate:method:location:)
    
    func _test_loadRetailStoreTimeSlots() throws {
        let data = RetailStoreTimeSlots.mockedData
    }
    
    func _test_loadRetailStoreTimeSlots_delivery_without_location() throws {
        let data = RetailStoreTimeSlots.mockedData
    }
    
//    func loadRetailStoreTimeSlots(
//        storeId: Int,
//        startDate: Date,
//        endDate: Date,
//        method: RetailStoreOrderMethodType,
//        location: CLLocationCoordinate2D?
//    ) -> AnyPublisher<RetailStoreTimeSlots, Error>

    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
