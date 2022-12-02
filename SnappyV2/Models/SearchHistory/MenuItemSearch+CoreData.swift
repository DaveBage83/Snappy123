//
//  MenuItemSearch+CoreData.swift
//  SnappyV2
//
//  Created by David Bage on 01/12/2022.
//

import Foundation
import CoreData

extension MenuItemSearch {
    init?(managedObject: MenuItemSearchMO) {
        self.init(
            timestamp: managedObject.timestamp ?? Date(),
            name: managedObject.name ?? "")
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> MenuItemSearchMO? {
        guard let storedMenuSearchItem = MenuItemSearchMO.insertNew(in: context) else { return nil }
        
        storedMenuSearchItem.timestamp = timestamp
        storedMenuSearchItem.name = name
        
        return storedMenuSearchItem
    }
}

extension MenuItemSearchMO {
    static func fetchRequest(name: String) -> NSFetchRequest<MenuItemSearchMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchAllMenuItemSearches() -> NSFetchRequest<MenuItemSearchMO> {
        let request = newFetchRequest()
        return request
    }
    
    static func fetchRequestForDeletion(name: String) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        request.predicate = NSPredicate(format: "name == %@", name)
        return request
    }
}

extension MenuItemSearchMO: ManagedEntity {}
