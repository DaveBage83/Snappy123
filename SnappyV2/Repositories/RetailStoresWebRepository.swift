//
//  RetailStoresWebRepository.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Foundation
import Combine
import CoreLocation

protocol RetailStoresWebRepositoryProtocol: WebRepository {
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoresSearch, Error>
    func loadRetailStores(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch, Error>
    func loadRetailStoreDetails(storeId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails, Error>
    //func loadRetailStoreTimeSlots(storeId: Int, ) -> AnyPublisher<RetailStoreDetails, Error>
}

struct RetailStoresWebRepository: RetailStoresWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoresSearch, Error> {
        
        let parameters: [String: Any] = [
            "postcode": postcode,
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        return call(endpoint: API.searchByPostcode(parameters))
    }
    
    func loadRetailStores(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch, Error> {
        
        let parameters: [String: Any] = [
            "lat": location.latitude,
            "lng": location.longitude,
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        return call(endpoint: API.searchByLocation(parameters))
    }
    
    func loadRetailStoreDetails(storeId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails, Error> {
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "postcode": postcode,
            "country": "UK",
            "storeId": storeId
        ]
        
        return call(endpoint: API.retailStoreDetails(parameters))
    }
    
}

// MARK: - Endpoints

extension RetailStoresWebRepository {
    enum API {
        case searchByPostcode([String: Any]?)
        case searchByLocation([String: Any]?)
        case retailStoreDetails([String: Any]?)
    }
}

extension RetailStoresWebRepository.API: APICall {
    var path: String {
        switch self {
        case .searchByPostcode:
            return "en_GB/stores/search.json"
        case .searchByLocation:
            return "en_GB/stores/nearBy.json"
        case .retailStoreDetails:
            return "en_GB/stores/select.json"
        }
    }
    var method: String {
        switch self {
        case .searchByPostcode, .searchByLocation, .retailStoreDetails:
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
        }
    }
}
