//
//  CheckoutDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 06/02/2022.
//

import CoreData
import Combine

protocol CheckoutDBRepositoryProtocol {
    func clearBasket() -> AnyPublisher<Bool, Error>
}

struct CheckoutDBRepository: CheckoutDBRepositoryProtocol {

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
    
}
