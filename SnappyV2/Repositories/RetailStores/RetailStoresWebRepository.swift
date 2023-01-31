//
//  RetailStoresWebRepository.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Foundation
import Combine
import CoreLocation

// General Note:
// (a) Parameter requirement checking (PRC) could be at higher point in the call chain, e.g. in RetailStoresService
// public or helper methods. We could also try an map it to server responses. In the end we (Henrik|Kevin) decided
// to have it at this web repository level because:
// - parent calling methods might easily omit the checks if their implementation is updated
// - the web repository is nearer to the business logic and PRC is based on this logic
// - the server responses vary and don't always adhere to APIErrorResult structure or http codes

protocol RetailStoresWebRepositoryProtocol: WebRepository {
    func loadRetailStores(postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch, Error>
    func loadRetailStores(location: CLLocationCoordinate2D, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch, Error>
    func loadRetailStoreDetails(storeId: Int, postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoreDetails, Error>
    
    func loadRetailStoreTimeSlots(
        storeId: Int,
        startDate: Date,
        endDate: Date,
        method: RetailStoreOrderMethodType,
        location: CLLocationCoordinate2D?
    ) -> AnyPublisher<RetailStoreTimeSlots, Error>
    
    func futureContactRequest(email: String, postcode: String) async throws -> FutureContactRequestResponse
    
    func sendRetailStoreCustomerRating(orderId: Int, hash: String, rating: Int, comments: String?) async throws -> RetailStoreReviewResponse
}

struct RetailStoresWebRepository: RetailStoresWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func loadRetailStores(postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch, Error> {
        
        // See general note (a)
        if postcode.trimmingCharacters(in: .whitespaces).isEmpty {
            return Fail<RetailStoresSearch, Error>(error: RetailStoresServiceError.invalidParameters(["postcode empty"]))
                .eraseToAnyPublisher()
        }
        
        var parameters: [String: Any] = [
            "postcode": postcode,
            "country": AppV2Constants.Business.operatingCountry,
            "platform": AppV2Constants.Client.platform,
            "businessId": AppV2Constants.Business.id,
            "isFirstOrder": isFirstOrder
        ]
        
        if let deviceIdentifier = AppV2Constants.Client.deviceIdentifier {
            parameters["deviceId"] = deviceIdentifier
        }
        
        return call(endpoint: API.searchByPostcode(parameters))
    }
    
    func loadRetailStores(location: CLLocationCoordinate2D, isFirstOrder: Bool) -> AnyPublisher<RetailStoresSearch, Error> {
        
        var parameters: [String: Any] = [
            "lat": location.latitude,
            "lng": location.longitude,
            "country": AppV2Constants.Business.operatingCountry,
            "platform": AppV2Constants.Client.platform,
            "businessId": AppV2Constants.Business.id,
            "isFirstOrder": isFirstOrder
        ]
        
        if let deviceIdentifier = AppV2Constants.Client.deviceIdentifier {
            parameters["deviceId"] = deviceIdentifier
        }
        
        return call(endpoint: API.searchByLocation(parameters))
    }
    
    func loadRetailStoreDetails(storeId: Int, postcode: String, isFirstOrder: Bool) -> AnyPublisher<RetailStoreDetails, Error> {
        
        // See general note (a)
        if postcode.trimmingCharacters(in: .whitespaces).isEmpty {
            return Fail<RetailStoreDetails, Error>(error: RetailStoresServiceError.invalidParameters(["postcode empty"]))
                .eraseToAnyPublisher()
        }
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "postcode": postcode,
            "country": AppV2Constants.Business.operatingCountry,
            "storeId": storeId,
            "isFirstOrder": isFirstOrder
        ]
        
        return call(endpoint: API.retailStoreDetails(parameters))
    }
    
    func loadRetailStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots, Error> {
        
        // See general note (a)
        if method == .delivery && location == nil {
            return Fail<RetailStoreTimeSlots, Error>(error: RetailStoresServiceError.invalidParameters(["location (coordinate) required for delivery method"]))
                .eraseToAnyPublisher()
        }
        
        var parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "country": AppV2Constants.Business.operatingCountry,
            "storeId": storeId,
            "startDate": startDate,
            "endDate": endDate,
            "fulfilmentMethod": method.rawValue,
        ]
        
        if let location = location {
            parameters["latitude"] = location.latitude
            parameters["longitude"] = location.longitude
        }
        
        return call(endpoint: API.retailStoreTimeSlots(parameters))
        
    }
    
    func futureContactRequest(email: String, postcode: String) async throws -> FutureContactRequestResponse {
        
        let parameters: [String: Any] = [
            "email": email,
            "postcode": postcode
        ]
        
        return try await call(endpoint: API.futureContactRequest(parameters)).singleOutput()
    }
    
    func sendRetailStoreCustomerRating(orderId: Int, hash: String, rating: Int, comments: String?) async throws -> RetailStoreReviewResponse {
        
        var parameters: [String: Any] = [
            "orderId": orderId,
            "hash": hash,
            "starRating": rating
        ]
        
        if let comments = comments {
            parameters["comment"] = comments
        }
        
        return try await call(endpoint: API.customerRating(parameters)).singleOutput()
    }
    
}

// MARK: - Endpoints

extension RetailStoresWebRepository {
    enum API {
        case searchByPostcode([String: Any]?)
        case searchByLocation([String: Any]?)
        case retailStoreDetails([String: Any]?)
        case retailStoreTimeSlots([String: Any]?)
        case futureContactRequest([String: Any]?)
        case customerRating([String: Any]?)
    }
}

extension RetailStoresWebRepository.API: APICall {
    var path: String {
        switch self {
        case .searchByPostcode:
            return AppV2Constants.Client.languageCode + "/stores/search.json"
        case .searchByLocation:
            return AppV2Constants.Client.languageCode + "/stores/nearBy.json"
        case .retailStoreDetails:
            return AppV2Constants.Client.languageCode + "/stores/select.json"
        case .retailStoreTimeSlots:
            return AppV2Constants.Client.languageCode + "/stores/slots/list.json"
        case .futureContactRequest:
            return AppV2Constants.Client.languageCode + "/futureContactRequest.json"
        case .customerRating:
            return AppV2Constants.Client.languageCode + "/stores/review/new.json"
        }
    }
    var method: String {
        switch self {
        case .searchByPostcode, .searchByLocation, .retailStoreDetails, .retailStoreTimeSlots, .futureContactRequest, .customerRating:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .searchByPostcode(parameters):
            return parameters
        case let .searchByLocation(parameters):
            return parameters
        case let .retailStoreDetails(parameters):
            return parameters
        case let .retailStoreTimeSlots(parameters):
            return parameters
        case let .futureContactRequest(parameters):
            return parameters
        case let .customerRating(parameters):
            return parameters
        }
    }
}
