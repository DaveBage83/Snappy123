//
//  RetailStoresWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 04/10/2021.
//

import XCTest
import Combine
import CoreLocation
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
            "platform": AppV2Constants.Client.platform,
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
            "platform": AppV2Constants.Client.platform,
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
        
        let location = CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)
        
        let parameters: [String: Any] = [
            "lat": location.latitude,
            "lng": location.longitude,
            "country": "UK",
            "platform": AppV2Constants.Client.platform,
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        try mock(.searchByLocation(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStores(location: location).sinkToResult { result in
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
    
    func test_loadRetailStoreTimeSlots() throws {
        let data = RetailStoreTimeSlots.mockedAPIResponseData
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let location = CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)
        
        let parameters: [String: Any] = [
            "storeId" : 30,
            "country" : "UK",
            "startDate" : formatter.string(from: data.startDate),
            "endDate" : formatter.string(from: data.endDate),
            "latitude" : location.latitude,
            "longitude" : location.longitude,
            "fulfilmentMethod" : "delivery",
            "businessId" : AppV2Constants.Business.id
        ]
        
        try mock(.retailStoreTimeSlots(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStoreTimeSlots(
            storeId: 30,
            startDate: data.startDate,
            endDate: data.endDate,
            method: .delivery,
            location: location
        ).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadRetailStoreTimeSlots_delivery_without_location() throws {
        let data = RetailStoreTimeSlots.mockedAPIResponseData
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let parameters: [String: Any] = [
            "storeId" : 30,
            "country" : "UK",
            "startDate" : formatter.string(from: data.startDate),
            "endDate" : formatter.string(from: data.endDate),
            "fulfilmentMethod" : "delivery",
            "businessId" : AppV2Constants.Business.id
        ]
        
        try mock(.retailStoreTimeSlots(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStoreTimeSlots(
            storeId: 30,
            startDate: data.startDate,
            endDate: data.endDate,
            method: .delivery,
            location: nil
        ).sinkToResult { result in
            result.assertFailure(RetailStoresServiceError.invalidParameters(["location (coordinate) required for delivery method"]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - futureContactRequest(email: String, postcode: String) async throws -> FutureContactRequestResponse
    
    func test_futureContactRequest() async throws {
        
        let data = FutureContactRequestResponse.mockedData
        
        let parameters: [String: Any] = [
            "email": "james@hotmail.com",
            "postcode": "DD21RW"
        ]
        
        try mock(.futureContactRequest(parameters), result: .success(data))
        do {
            let result = try await sut.futureContactRequest(email: "james@hotmail.com", postcode: "DD21RW")
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - sendRetailStoreCustomerRating(orderId:hash:rating:comments:)
    
    func test_sendRetailStoreCustomerRating() async throws {
        
        let review = RetailStoreReview.mockedData
        let data = RetailStoreReviewResponse.mockedData
        
        let parameters: [String: Any] = [
            "orderId": review.orderId,
            "hash": review.hash,
            "rating": 4,
            "comments": "some string"
        ]
        
        try mock(.customerRating(parameters), result: .success(data))
        do {
            let result = try await sut.sendRetailStoreCustomerRating(orderId: review.orderId, hash: review.hash, rating: 4, comments: "some string")
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
