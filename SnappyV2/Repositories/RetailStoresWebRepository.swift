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
//    func loadRetailStoreDetail() -> AnyPublisher<[RetailStore.Detail], Error>
}

struct RetailStoresWebRepository: RetailStoresWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoresSearch, Error> {
        let searchStoresURL = URL(string: baseURL + "en_GB/stores/search.json")!
        let parameters: [String: Any] = [
            "postcode": postcode,
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        return networkHandler.request(url: searchStoresURL, parameters: parameters)
    }
    
    func loadRetailStores(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch, Error> {
        let searchStoresURL = URL(string: baseURL + "en_GB/stores/nearBy.json")!
        let parameters: [String: Any] = [
            "lat": location.latitude,
            "lng": location.longitude,
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": AppV2Constants.Business.id
        ]
        
        return networkHandler.request(url: searchStoresURL, parameters: parameters)
    }
    
}
