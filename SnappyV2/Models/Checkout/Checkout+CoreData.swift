//
//  Checkout+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 24/05/2022.
//

import Foundation
import CoreData

extension LastDeliveryOrderOnDeviceMO: ManagedEntity { }

extension LastDeliveryOrderOnDevice {
    
    init(managedObject: LastDeliveryOrderOnDeviceMO) {
        self.init(
            businessOrderId: Int(managedObject.businessOrderId),
            storeName: managedObject.storeName,
            storeContactNumber: managedObject.storeContactNumber,
            deliveryPostcode: managedObject.deliveryPostcode
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> LastDeliveryOrderOnDeviceMO? {
        
        guard let lastDeliveryOrder = LastDeliveryOrderOnDeviceMO.insertNew(in: context)
            else { return nil }
        
        lastDeliveryOrder.businessOrderId = Int64(businessOrderId)
        lastDeliveryOrder.storeName = storeName
        lastDeliveryOrder.storeContactNumber = storeContactNumber
        lastDeliveryOrder.deliveryPostcode = deliveryPostcode

        return lastDeliveryOrder
    }
    
}
