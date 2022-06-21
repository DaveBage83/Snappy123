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
    
    func clearLastDeliveryOrderOnDevice() async throws
    func store(lastDeliveryOrderOnDevice: LastDeliveryOrderOnDevice) async throws
    func lastDeliveryOrderOnDevice() async throws -> LastDeliveryOrderOnDevice?
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
    
    func clearLastDeliveryOrderOnDevice() async throws {
        return try await persistentStore
            .update { context in
                try LastDeliveryOrderOnDeviceMO.delete(
                    fetchRequest: LastDeliveryOrderOnDeviceMO.newFetchRequestResult(),
                    in: context
                )
            }
            .singleOutput()
    }
    
    func store(lastDeliveryOrderOnDevice: LastDeliveryOrderOnDevice) async throws {
        return try await persistentStore
            .update { context in
                guard lastDeliveryOrderOnDevice.store(in: context) != nil else {
                    throw CheckoutServiceError.unablePersistLastDeliverOrder
                }
            }
            .singleOutput()
    }
    
    func lastDeliveryOrderOnDevice() async throws -> LastDeliveryOrderOnDevice? {
        return try await persistentStore
            .fetch(LastDeliveryOrderOnDeviceMO.fetchRequestLastDeliveryOrder) {
                LastDeliveryOrderOnDevice(managedObject: $0)
            }
            .map { $0.first }
            .singleOutput()
    }
    
}

// MARK: - Fetch Requests

extension LastDeliveryOrderOnDeviceMO {

    static var fetchRequestLastDeliveryOrder: NSFetchRequest<LastDeliveryOrderOnDeviceMO> {
        let request = newFetchRequest()
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        return request
    }

}
