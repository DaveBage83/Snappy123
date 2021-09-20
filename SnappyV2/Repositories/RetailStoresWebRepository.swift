//
//  RetailStoresWebRepository.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Foundation
import Combine

protocol RetailStoresWebRepositoryProtocol: WebRepository {
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoreResult, Error>
//    func loadRetailStoreDetail() -> AnyPublisher<[RetailStore.Detail], Error>
}

struct RetailStoresWebRepository: RetailStoresWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func loadRetailStores(postcode: String) -> AnyPublisher<RetailStoreResult, Error> {
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
    
}
