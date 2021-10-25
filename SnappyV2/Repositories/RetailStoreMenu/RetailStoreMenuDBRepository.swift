//
//  RetailStoreMenuDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/10/2021.
//

import CoreData
import Combine

protocol RetailStoreMenuDBRepositoryProtocol {
    
    // adding a fetch result to the database
    func store(fetchResult: RetailStoreMenuFetch, forStoreId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<RetailStoreMenuFetch?, Error>
    
    // removing stored results
    func clearRetailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<Bool, Error>
    
    // fetching stored results
    func retailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<RetailStoreMenuFetch?, Error>

}

struct RetailStoreMenuDBMenuDBRepository: RetailStoreMenuDBRepositoryProtocol {

    let persistentStore: PersistentStore
    
    func store(fetchResult: RetailStoreMenuFetch, forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        return persistentStore
            .update { context in
                let fetch = fetchResult.store(in: context)
                fetch?.fetchStoreId = Int64(storeId)
                fetch?.fetchCategoryId = Int64(categoryId)
                fetch?.fetchFulfilmentMethod = fulfilmentMethod.rawValue
                return fetch.flatMap { RetailStoreMenuFetch(managedObject: $0) }
            }
    }
    
    func clearRetailStoreMenuFetch(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<Bool, Error> {
        return persistentStore.delete(
            RetailStoreMenuFetchMO.fetchRequestResult(
                forStoreId: storeId,
                categoryId: categoryId,
                fulfilmentMethod: fulfilmentMethod
            )
        )
    }
    
    func retailStoreMenuFetch(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        
        let fetchRequest = RetailStoreMenuFetchMO.fetchRequest(forStoreId: storeId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod)
        
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoreMenuFetch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
        
    }
    
}

// MARK: - Fetch Requests

extension RetailStoreMenuFetchMO {
    
    static func fetchRequestResult(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        request.predicate = NSPredicate(format: "fetchStoreId == %i AND fetchCategoryId == %i AND fetchFulfilmentMethod == %@", storeId, categoryId, fulfilmentMethod.rawValue)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchRequest(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: FulfilmentMethod) -> NSFetchRequest<RetailStoreMenuFetchMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "fetchStoreId == %i AND fetchCategoryId == %i AND fetchFulfilmentMethod == %@", storeId, categoryId, fulfilmentMethod.rawValue)
        request.fetchLimit = 1
        return request
    }
    
//    static func fetchRequest(forLocation location: CLLocationCoordinate2D) -> NSFetchRequest<RetailStoresSearchMO> {
//        let request = newFetchRequest()
//        request.predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", location.latitude, location.longitude)
//        request.fetchLimit = 1
//        return request
//    }
//
//    static var fetchRequestLast: NSFetchRequest<RetailStoresSearchMO> {
//        let request = newFetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
//        request.fetchLimit = 1
//        request.returnsObjectsAsFaults = false
//        return request
//    }
    
}

