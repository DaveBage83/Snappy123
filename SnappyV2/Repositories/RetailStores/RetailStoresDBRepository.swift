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
    // adding time slots for a store to the database
    func store(storeTimeSlots: RetailStoreTimeSlots, forStoreId: Int, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error>
    
    // removing all search results
    func clearSearches() -> AnyPublisher<Bool, Error>
    
    // removing all detail results
    func clearRetailStoreDetails() -> AnyPublisher<Bool, Error>
    
    // removing all time slots results
    func clearRetailStoreTimeSlots() -> AnyPublisher<Bool, Error>
    
    // fetching search results
    func retailStoresSearch(forPostcode: String) -> AnyPublisher<RetailStoresSearch?, Error>
    func retailStoresSearch(forLocation: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error>
    func lastStoresSearch() -> AnyPublisher<RetailStoresSearch?, Error>
    
    // fetching detail results
    func retailStoreDetails(forStoreId: Int, postcode: String) -> AnyPublisher<RetailStoreDetails?, Error>
    
    // fetching time slot results
    func retailStoreTimeSlots(forStoreId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error>
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
                search?.latitude = NSNumber(value: coordinate.latitude)
                search?.longitude = NSNumber(value: coordinate.longitude)
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
    
    func store(storeTimeSlots: RetailStoreTimeSlots, forStoreId storeId: Int, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error> {
        return persistentStore
            .update { context in
                let timeSlots = storeTimeSlots.store(in: context)
                timeSlots?.storeId = Int64(storeId)
                if let location = location {
                    timeSlots?.latitude = NSNumber(value: location.latitude)
                    timeSlots?.longitude = NSNumber(value: location.longitude)
                } else {
                    timeSlots?.latitude = nil
                    timeSlots?.longitude = nil
                }
                return timeSlots.flatMap { RetailStoreTimeSlots(managedObject: $0) }
            }
    }
    
    func clearSearches() -> AnyPublisher<Bool, Error> {
        // More efficient but unsuited to unit testing
        // return persistentStore.delete(RetailStoresSearchMO.newFetchRequestResult())

        return persistentStore
            .update { context in
                
                try RetailStoresSearchMO.delete(
                    fetchRequest: RetailStoresSearchMO.newFetchRequestResult(),
                    in: context
                )
                
                return true
            }
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
        // More efficient but unsuited to unit testing
        //return persistentStore.delete(RetailStoreDetailsMO.newFetchRequestResult())

        return persistentStore
            .update { context in
                
                try RetailStoreDetailsMO.delete(
                    fetchRequest: RetailStoreDetailsMO.newFetchRequestResult(),
                    in: context
                )
                
                return true
            }
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
    
    func clearRetailStoreTimeSlots() -> AnyPublisher<Bool, Error> {
        // More efficient but unsuited to unit testing
        //return persistentStore.delete(RetailStoreTimeSlotsMO.newFetchRequestResult())
        
        return persistentStore
            .update { context in
                
                try RetailStoreTimeSlotsMO.delete(
                    fetchRequest: RetailStoreTimeSlotsMO.newFetchRequestResult(),
                    in: context
                )
                
                return true
            }
    }
    
    func retailStoreTimeSlots(forStoreId storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> AnyPublisher<RetailStoreTimeSlots?, Error> {
        
        let fetchRequest = RetailStoreTimeSlotsMO.fetchRequest(
            forStoreId: storeId,
            startDate: startDate,
            endDate: endDate,
            method: method,
            location: location
        )
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoreTimeSlots(managedObject: $0)
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
        // compare with a range rather than an specific cordinate values for two reasons
        // (1) potential float rounding errors invalidating the match
        // (2) location service results vary an exact positioning is not critical
        request.predicate = NSPredicate(
            format: "latitude > %f AND latitude < %f AND longitude > %f AND longitude < %f",
            location.latitude - 0.0002, location.latitude + 0.0002, location.longitude - 0.0002, location.longitude + 0.0002
        )
        request.fetchLimit = 1
        return request
    }
    
    static var fetchRequestLast: NSFetchRequest<RetailStoresSearchMO> {
        let request = newFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        return request
    }
    
}

extension RetailStoreDetailsMO {
    
    static func fetchRequest(forStoreId storeId: Int, usingPostcode postcode: String) -> NSFetchRequest<RetailStoreDetailsMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "id == %i AND searchPostcode == %@", storeId, postcode)
        request.fetchLimit = 1
        return request
    }
    
}

extension RetailStoreTimeSlotsMO {
    static func fetchRequest(forStoreId storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) -> NSFetchRequest<RetailStoreTimeSlotsMO> {
        let request = newFetchRequest()
        if
            let location = location,
            method == .delivery
        {
            // compare with a range rather than an specific cordinate values for two reasons
            // (1) potential float rounding errors invalidating the match
            // (2) location service results vary an exact positioning is not critical
            request.predicate = NSPredicate(
                format: "storeId == %i AND startDate == %@ AND endDate == %@ AND fulfilmentMethod == %@ AND latitude > %f AND latitude < %f AND longitude > %f AND longitude < %f",
                storeId,
                startDate as NSDate,
                endDate as NSDate,
                method.rawValue,
                location.latitude - 0.0002,
                location.latitude + 0.0002,
                location.longitude - 0.0002,
                location.longitude + 0.0002
            )
        } else {
            request.predicate = NSPredicate(format: "storeId == %i AND startDate == %@ AND endDate == %@ AND fulfilmentMethod == %@", storeId, startDate as NSDate, endDate as NSDate, method.rawValue)
        }
        request.fetchLimit = 1
        return request
    }
}
