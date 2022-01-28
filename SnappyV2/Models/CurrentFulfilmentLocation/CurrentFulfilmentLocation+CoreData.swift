//
//  CurrentFulfilmentLocation+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 27/01/2022.
//

import Foundation
import CoreData

extension CurrentFulfilmentLocationMO: ManagedEntity { }

extension FulfilmentLocation {
    init(managedObject: CurrentFulfilmentLocationMO) {
        self.init(
            country: managedObject.country ?? "",
            latitude: managedObject.latitude,
            longitude: managedObject.longitude,
            postcode: managedObject.postcode ?? ""
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> CurrentFulfilmentLocationMO? {
        
        guard let fulfilmentLocation = CurrentFulfilmentLocationMO.insertNew(in: context)
            else { return nil }
        
        fulfilmentLocation.postcode = postcode
        fulfilmentLocation.country = country
        fulfilmentLocation.latitude = latitude
        fulfilmentLocation.longitude = longitude
        
        return fulfilmentLocation
    }
}
