//
//  MockedRetailStoresWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 26/09/2021.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

final class MockedRetailStoresWebRepository: TestWebRepository, Mock, RetailStoresWebRepositoryProtocol {
    
    enum Action: Equatable {
        case loadRetailStores(postcode: String)
        case loadRetailStores(location: CLLocationCoordinate2D)
        case loadRetailStoreDetails(storeId: Int, postcode: String)
        case loadRetailStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?)
        case futureContactRequest(email: String, postcode: String)
        case sendRetailStoreCustomerRating(orderId: Int, hash: String, rating: Int, comments: String?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var loadRetailStoresByPostcodeResponse: Result<RetailStoresSearch, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoresByLocationResponse: Result<RetailStoresSearch, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoreDetailsResponse: Result<RetailStoreDetails, Error> = .failure(MockError.valueNotSet)
    var loadRetailStoreTimeSlotsResponse: Result<RetailStoreTimeSlots, Error> = .failure(MockError.valueNotSet)
    var futureContactRequestResponse: Result<FutureContactRequestResponse, Error> = .failure(MockError.valueNotSet)
    var sendRetailStoreCustomerRatingResponse: Result<RetailStoreReviewResponse, Error> = .failure(MockError.valueNotSet)
    
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoresSearch, Error> {
        register(.loadRetailStores(postcode: postcode))
        return loadRetailStoresByPostcodeResponse.publish()
    }
    
    func loadRetailStores(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch, Error> {
        register(.loadRetailStores(location: location))
        return loadRetailStoresByLocationResponse.publish()
    }
    
    func loadRetailStoreDetails(storeId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails, Error> {
        register(.loadRetailStoreDetails(storeId: storeId, postcode: postcode))
        return loadRetailStoreDetailsResponse.publish()
    }
    
    func loadRetailStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots, Error> {
        register(.loadRetailStoreTimeSlots(storeId: storeId, startDate: startDate, endDate: endDate, method: method, location: location))
        return loadRetailStoreTimeSlotsResponse.publish()
    }
    
    func futureContactRequest(email: String, postcode: String) async throws -> FutureContactRequestResponse {
        register(.futureContactRequest(email: email, postcode: postcode))
        switch futureContactRequestResponse {
        case let .failure(error):
            throw error
        case let .success(response):
            return response
        }
    }
    
    func sendRetailStoreCustomerRating(orderId: Int, hash: String, rating: Int, comments: String?) async throws -> RetailStoreReviewResponse {
        register(.sendRetailStoreCustomerRating(orderId: orderId, hash: hash, rating: rating, comments: comments))
        switch sendRetailStoreCustomerRatingResponse {
        case let .failure(error):
            throw error
        case let .success(response):
            return response
        }
    }
}
