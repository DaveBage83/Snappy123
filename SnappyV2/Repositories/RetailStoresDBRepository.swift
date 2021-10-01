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
    
    // adding a store search result to the database
    func store(searchResult: RetailStoresSearch, forPostode: String) -> AnyPublisher<RetailStoresSearch?, Error>
    func store(searchResult: RetailStoresSearch, location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error>
    // adding details for a store to the database
    func store(storeDetails: RetailStoreDetails, forPostode: String) -> AnyPublisher<RetailStoreDetails?, Error>
    
    // removing all search results
    func clearSearches() -> AnyPublisher<Bool, Error>
    // removing all detail results
    func clearRetailStoreDetails() -> AnyPublisher<Bool, Error>
    
    // fetching search results
    func retailStoresSearch(forPostcode: String) -> AnyPublisher<RetailStoresSearch?, Error>
    func retailStoresSearch(forLocation: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error>
    func lastStoresSearch() -> AnyPublisher<RetailStoresSearch?, Error>
    // fetching detail results
    func retailStoreDetails(forStoreId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails?, Error>
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
                search?.lat = NSNumber(value: coordinate.latitude)
                search?.long = NSNumber(value: coordinate.longitude)
                return search.flatMap { RetailStoresSearch(managedObject: $0) }
            }
    }
    
    func store(storeDetails: RetailStoreDetails, forPostode postcode: String) -> AnyPublisher<RetailStoreDetails?, Error> {
        return persistentStore
            .update { context in
                let details = storeDetails.store(in: context)
                details?.searchPostcode = postcode
                return details.flatMap { RetailStoreDetails(managedObject: $0) }
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
    
    func lastStoresSearch() -> AnyPublisher<RetailStoresSearch?, Error> {
        let fetchRequest = RetailStoresSearchMO.fetchRequestLast
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoresSearch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func clearRetailStoreDetails() -> AnyPublisher<Bool, Error> {
        return persistentStore.delete(RetailStoreDetailsMO.newFetchRequestResult())
    }
    
    // fetching detail results
    func retailStoreDetails(forStoreId storeId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails?, Error> {
        let fetchRequest = RetailStoreDetailsMO.fetchRequest(forStoreId: storeId, usingPostcode: postcode)
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoreDetails(managedObject: $0)
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
    
    static var fetchRequestLast: NSFetchRequest<RetailStoresSearchMO> {
        let request = newFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        return request
    }
    
}

extension RetailStoreDetailsMO {
    
    static func fetchRequest(forStoreId storeId: Int, usingPostcode postcode: String) -> NSFetchRequest<RetailStoreDetailsMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "storeId == %@ AND searchPostcode == %@", storeId, postcode)
        request.fetchLimit = 1
        return request
    }
    
}
