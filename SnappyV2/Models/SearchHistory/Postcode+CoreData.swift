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

extension PostcodeMO {
    static func fetchRequest(postcode: String) -> NSFetchRequest<PostcodeMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "postcode == %@", postcode)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchAllPostcodes() -> NSFetchRequest<PostcodeMO> {
        let request = newFetchRequest()
        return request
    }
    
    static func fetchRequestForDeletion(postcode: String) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        request.predicate = NSPredicate(format: "postcode == %@", postcode)
        return request
    }
}

extension PostcodeMO: ManagedEntity {}
