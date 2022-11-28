//
//  Postcode+CoreData.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import CoreData

extension Postcode {
    init?(managedObject: PostcodeMO) {
        self.init(
            timestamp: managedObject.timestamp ?? Date(),
            postcode: managedObject.postcode ?? "")
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> PostcodeMO? {
        guard let storedPostcode = PostcodeMO.insertNew(in: context) else { return nil }
        
        storedPostcode.timestamp = timestamp
        storedPostcode.postcode = postcode
        
        return storedPostcode
    }
}
