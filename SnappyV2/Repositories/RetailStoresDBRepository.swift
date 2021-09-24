//
//  RetailStoresDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/09/2021.
//

import CoreData
import Combine
import CoreLocation

protocol RetailStoresDBRepositoryProtocol {
    
    // adding a result to the database
    func store(searchResult: RetailStoresSearch, forPostode: String) -> AnyPublisher<RetailStoresSearch?, Error>
    func store(searchResult: RetailStoresSearch, location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error>
    
    // removing all search results
    func clearSearches() -> AnyPublisher<Bool, Error>
    
    // fetching search results
    func retailStoresSearch(forPostcode: String) -> AnyPublisher<RetailStoresSearch?, Error>
    func retailStoresSearch(forLocation: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error>
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
    
    func store(searchResult: RetailStoresSearch, location coordinate: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error> {
        return persistentStore
            .update { context in
                let search = searchResult.store(in: context)
                search?.lat = coordinate.latitude
                search?.long = coordinate.longitude
                return search.flatMap { RetailStoresSearch(managedObject: $0) }
            }
    }
    
    func clearSearches() -> AnyPublisher<Bool, Error> {
        return persistentStore.delete(RetailStoresSearchMO.newFetchRequestResult())
    }
    
    // fetching search results
    func retailStoresSearch(forPostcode postcode: String) -> AnyPublisher<RetailStoresSearch?, Error> {
        let fetchRequest = RetailStoresSearchMO.fetchRequest(usingPostcode: postcode)
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoresSearch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func retailStoresSearch(forLocation location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error> {
        let fetchRequest = RetailStoresSearchMO.fetchRequest(forLocation: location)
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoresSearch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Fetch Requests

extension RetailStoresSearchMO {
    
    static func fetchRequest(usingPostcode postcode: String) -> NSFetchRequest<RetailStoresSearchMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "postcode == %@", postcode)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchRequest(forLocation location: CLLocationCoordinate2D) -> NSFetchRequest<RetailStoresSearchMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "lat == %@ AND long == %@", location.latitude, location.longitude)
        request.fetchLimit = 1
        return request
    }
    
}
