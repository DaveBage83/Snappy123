//
//  RetailStoreWebRepository.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Foundation
import Combine

protocol RetailStoreWebRepositoryProtocol {
    func loadRetailStores() -> AnyPublisher<RetailStoreResult, Error>
//    func loadRetailStoreDetail() -> AnyPublisher<[RetailStore.Detail], Error>
}

struct RetailStoreWebRepository: RetailStoreWebRepositoryProtocol {
    func loadRetailStores() -> AnyPublisher<RetailStoreResult, Error> {
        let searchStoresURL = URL(string: "https://api-staging.snappyshopper.co.uk/api/v2/en_GB/stores/search.json")!
        let parameters: [String: Any] = [
            "postcode": "DD1 3JA",
            "country": "UK",
            "platform": "ios",
            "deviceId": "string",
            "businessId": 15 // Move to constants file?
        ]
        
        let authenticator = NetworkAuthenticator.shared
        let api = NetworkHandler(authenticator: authenticator, debugTrace: true)
        
        return api.request(url: searchStoresURL, parameters: parameters)
    }
    
}
