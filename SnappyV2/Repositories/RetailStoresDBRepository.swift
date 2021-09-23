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
    func clearLastSearch() -> AnyPublisher<Bool, Error>
}

struct RetailStoresDBRepository: RetailStoresDBRepositoryProtocol {
    
    let persistentStore: PersistentStore
    
    func store(searchResult: RetailStoresSearch, forPostode postcode: String) -> AnyPublisher<RetailStoresSearch?, Error> {
        return persistentStore
            .update { context in
                let search = searchResult.store(in: context)
                search?.postcode = postcode
                return search.flatMap { RetailStoresSearch(managedObject: $0) }
            }
    }
    
    func store(searchResult: RetailStoresSearch, forCordinate coordinates: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error> {
        return persistentStore
            .update { context in
                let search = searchResult.store(in: context)
                search?.lat = coordinates.latitude
                search?.long = coordinates.longitude
                return search.flatMap { RetailStoresSearch(managedObject: $0) }
            }
    }
    
    func clearLastSearch() -> AnyPublisher<Bool, Error> {
        return persistentStore.delete(RetailStoresSearchMO.newFetchRequestResult())
    }
    
}
