//
//  MockedPersistentStore.swift
//  UnitTests
//
//  Created by Snappy shopper
//  Based upon work originally by Alexey Naumov.
//

// Adapted by Kevin Palser on 2021-10-17 so to be more scalable by not
// needing explicit cases in Action enum for fetchXXX operations. Also
// added delete case.

import CoreData
import Combine
@testable import SnappyV2

final class MockedPersistentStore: Mock, PersistentStore {
    struct ContextSnapshot: Equatable {
        let inserted: Int
        let updated: Int
        let deleted: Int
    }
    enum Action: Equatable {
        case count
        case fetch(String, ContextSnapshot)
        case update(ContextSnapshot)
        case delete(ContextSnapshot)
    }
    var actions = MockActions<Action>(expected: [])
    
    var countResult: Int = 0
    
    deinit {
        destroyDatabase()
    }
    
    // MARK: - count
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> {
        register(.count)
        return Just<Int>.withErrorType(countResult, Error.self).publish()
    }
    
    // MARK: - fetch
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<LazyList<V>, Error> {
        do {
            let context = container.viewContext
            context.reset()
            let result = try context.fetch(fetchRequest)
            
            register(.fetch(String(describing: T.self), context.snapshot))
            
            let list = LazyList<V>(count: result.count, useCache: true, { index in
                try map(result[index])
            })
            return Just<LazyList<V>>.withErrorType(list, Error.self).publish()
        } catch {
            return Fail<LazyList<V>, Error>(error: error).publish()
        }
    }
    
    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) -> [T]? where T : NSFetchRequestResult {
        return nil
    }
    
    // MARK: - update
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        do {
            let context = container.viewContext
            context.reset()
            let result = try operation(context)
            register(.update(context.snapshot))
            return Just(result).setFailureType(to: Error.self).publish()
        } catch {
            return Fail<Result, Error>(error: error).publish()
        }
    }
    
    // MARK: - delete
    
    func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> AnyPublisher<Bool, Error> {
        do {
            let context = container.viewContext
            context.reset()
            _ = try context.fetch(fetchRequest)
            register(.delete(context.snapshot))
            return Just(true).setFailureType(to: Error.self).publish()
        } catch {
            return Fail<Bool, Error>(error: error).publish()
        }
    }
    
    // MARK: -
    func preloadData(_ preload: (NSManagedObjectContext) throws -> Void) async throws {
        try await MainActor.run(body: {
            try preload(container.viewContext)
            if container.viewContext.hasChanges {
                try container.viewContext.save()
            }
            container.viewContext.reset()
        })
    }
    
    func preloadData(_ preload: (NSManagedObjectContext) throws -> Void) throws {
            try preload(container.viewContext)
            if container.viewContext.hasChanges {
                try container.viewContext.save()
            }
            container.viewContext.reset()
    }
    
    // MARK: - Database
    
    private let dbVersion = CoreDataStack.Version(CoreDataStack.Version.actual)
    
    private var dbURL: URL {
        guard let url = dbVersion.dbFileURL(.cachesDirectory, .userDomainMask)
            else { fatalError() }
        return url
    }
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: dbVersion.modelName)
        try? FileManager().removeItem(at: dbURL)
        let store = NSPersistentStoreDescription(url: dbURL)
        container.persistentStoreDescriptions = [store]
        let group = DispatchGroup()
        group.enter()
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("\(error)")
            }
            group.leave()
        }
        group.wait()
        container.viewContext.mergePolicy = NSOverwriteMergePolicy
        container.viewContext.undoManager = nil
        return container
    }()
    
    private func destroyDatabase() {
        try? container.persistentStoreCoordinator
            .destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try? FileManager().removeItem(at: dbURL)
    }
}

extension NSManagedObjectContext {
    var snapshot: MockedPersistentStore.ContextSnapshot {
        .init(inserted: insertedObjects.count,
              updated: updatedObjects.count,
              deleted: deletedObjects.count)
    }
}
