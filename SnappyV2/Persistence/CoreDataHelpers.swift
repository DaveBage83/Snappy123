//
//  CoreDataHelpers.swift
//  CountriesSwiftUI
//
//  Created by Snappy shopper
//  Based upon work originally by Alexey Naumov.
//

import CoreData
import Combine

// MARK: - ManagedEntity

protocol ManagedEntity: NSFetchRequestResult { }

extension ManagedEntity where Self: NSManagedObject {
    
    static var entityName: String {
        let nameMO = String(describing: Self.self)
        let suffixIndex = nameMO.index(nameMO.endIndex, offsetBy: -2)
        return String(nameMO[..<suffixIndex])
    }
    
    static func insertNew(in context: NSManagedObjectContext) -> Self? {
        return NSEntityDescription
            .insertNewObject(forEntityName: entityName, into: context) as? Self
    }
    
    static func delete(fetchRequest: NSFetchRequest<NSFetchRequestResult>, in context: NSManagedObjectContext) throws {
        
        // Some problems were encountered recording that a record had been deleted
        // for unit testing when using the batch deletion. The following link:
        // https://www.advancedswift.com/batch-delete-everything-core-data-swift/
        // provided some insights indicating that the context will not get deletion
        // counts with the batch approach. Unfortunately even the commented out
        // merge step below did not update the counts so we had to resort to single
        // managed object deletions
        
//        // Create a batch delete request for the fetch request
//        let deleteRequest = NSBatchDeleteRequest(
//            fetchRequest: fetchRequest
//        )
//
//        // Specify the result of the NSBatchDeleteRequest should be the
//        // NSManagedObject IDs for the deleted objects
//        deleteRequest.resultType = .resultTypeObjectIDs
//
//        // Perform the batch delete
//        let batchDelete = try context.execute(deleteRequest)
//            as? NSBatchDeleteResult
//
//        // For unit testing to get the delete count we need to merge
//        // the changes to record the number of deletions on the context
//
//        guard let deleteResult = batchDelete?.result
//            as? [NSManagedObjectID]
//            else { return }
//
//        let deletedObjects: [AnyHashable: Any] = [
//            NSDeletedObjectsKey: deleteResult
//        ]
//
//        // Merge the delete changes into the managed object context
//        NSManagedObjectContext.mergeChanges(
//            fromRemoteContextSave: deletedObjects,
//            into: [context]
//        )

        // Setting includesPropertyValues to false means
        // the fetch request will only get the managed
        // object ID for each object
        fetchRequest.includesPropertyValues = false

        // Perform the fetch request
        let objects = try context.fetch(fetchRequest)
            
        print("***** To Delete: \(objects.count)")

        
        // Delete the objects
        for object in objects {
            if let mo = object as? NSManagedObject {
                context.delete(mo)
            }
        }
    }
    
    static func newFetchRequest() -> NSFetchRequest<Self> {
        return .init(entityName: entityName)
    }
    
    static func newFetchRequestResult() -> NSFetchRequest<NSFetchRequestResult> {
        return .init(entityName: entityName)
    }
}

// MARK: - NSManagedObjectContext

extension NSManagedObjectContext {
    
    func configureAsReadOnlyContext() {
        automaticallyMergesChangesFromParent = true
        mergePolicy = NSRollbackMergePolicy
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
    }
    
    func configureAsUpdateContext() {
        mergePolicy = NSOverwriteMergePolicy
        undoManager = nil
    }
}

// MARK: - Misc

extension NSSet {
    func toArray<T>(of type: T.Type) -> [T] {
        allObjects.compactMap { $0 as? T }
    }
}

extension NSOrderedSet {
    func toArray<T>(of type: T.Type) -> [T] {
        array.compactMap { $0 as? T }
    }
}

