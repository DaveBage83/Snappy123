//
//  RetailStoreService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation

protocol RetailStoresServiceProtocol {
    func searchRetailStores(postcode: String) -> AnyPublisher<Bool, Error>
}

struct RetailStoresService: RetailStoresServiceProtocol {
    
    let webRepository: RetailStoresWebRepositoryProtocol
    let dbRepository: RetailStoresDBRepositoryProtocol
    
    init(webRepository: RetailStoresWebRepositoryProtocol, dbRepository: RetailStoresDBRepositoryProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }
    
    func searchRetailStores(postcode: String) -> AnyPublisher<Bool, Error> {
        return webRepository.loadRetailStores(postcode: postcode)
            .flatMap({ retailStoreResult -> AnyPublisher<Bool, Error> in

                // populate the persitent store
                
                // simply emit true if at least one store found
                return Just(retailStoreResult.stores?.count ?? 0 != 0)
                      .setFailureType(to: Error.self)
                      .eraseToAnyPublisher()
                
            }).eraseToAnyPublisher()
    }
    
    
}

struct StubRetailStoresService: RetailStoresServiceProtocol {
    func searchRetailStores(postcode: String) -> AnyPublisher<Bool, Error> {
        return Just(true)
              .setFailureType(to: Error.self)
              .eraseToAnyPublisher()
    }
}
