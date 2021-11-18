//
//  BasketDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 31/10/2021.
//

import CoreData
import Combine

protocol BasketDBRepositoryProtocol {
    
    func clearBasket() -> AnyPublisher<Bool, Error>
    
    // adding a basket result to the database - unlike store functions in other
    // DBRepositories this has to return an unwrapped result or an error
    func store(basket: Basket) -> AnyPublisher<Basket, Error>

    func fetchBasket() -> AnyPublisher<Basket?, Error>
}

struct BasketDBRepository: BasketDBRepositoryProtocol {

    let persistentStore: PersistentStore
    
    func clearBasket() -> AnyPublisher<Bool, Error> {
        
        // More efficient but unsuited to unit testing
//        return persistentStore.delete(
//            BasketMO.fetchRequestResult()
//        )
        
        return persistentStore
            .update { context in
                
                try BasketMO.delete(
                    fetchRequest: BasketMO.fetchRequestResult(),
                    in: context
                )
                
                return true
            }
    }
    
    func store(basket: Basket) -> AnyPublisher<Basket, Error> {
        return persistentStore
            .update { context in
                
                guard let basketMO = basket.store(in: context) else {
                    throw RetailStoreMenuServiceError.unableToPersistResult
                }
                
                return Basket(managedObject: basketMO)
            }
    }
    
    func fetchBasket() -> AnyPublisher<Basket?, Error> {
        let fetchRequest = BasketMO.fetchRequestLast
        return persistentStore
            .fetch(fetchRequest) {
                Basket(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Fetch Requests

extension BasketMO {

    static func fetchRequestResult() -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        request.fetchLimit = 1
        return request
    }
    
    static var fetchRequestLast: NSFetchRequest<BasketMO> {
        let request = newFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        return request
    }

}
