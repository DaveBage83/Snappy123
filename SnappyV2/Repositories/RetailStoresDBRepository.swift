//
//  RetailStoresDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/09/2021.
//

import Foundation
import Combine
import CoreLocation

protocol RetailStoresDBRepositoryProtocol {
    func store(searchResult: RetailStoresSearch, forPostode: String) -> AnyPublisher<RetailStoresSearch?, Error>
    func store(searchResult: RetailStoresSearch, forCordinate: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error>
}

struct RetailStoresDBRepository: RetailStoresDBRepositoryProtocol {
    
    let persistentStore: PersistentStore
    
    func store(searchResult: RetailStoresSearch, forPostode: String) -> AnyPublisher<RetailStoresSearch?, Error> {
        return persistentStore
            .update { context in
                let search = searchResult.store(in: context)
                return search.flatMap { RetailStoresSearch(managedObject: $0) }
            }
    }
    
    func store(searchResult: RetailStoresSearch, forCordinate: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error> {
        return persistentStore
            .update { context in
                let search = searchResult.store(in: context)
                return search.flatMap { RetailStoresSearch(managedObject: $0) }
            }
    }
    
}
