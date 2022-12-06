//
//  SearchHistoryDBRepository.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import Combine
import OSLog

enum SearchHistoryError: Swift.Error, Equatable {
    case unableToSave
}

protocol SearchHistoryDBRepositoryProtocol {
    // Postcode methods
    func fetchPostcode(using postcodeString: String) -> AnyPublisher<Postcode?, Error>
    func store(postcode: String) -> AnyPublisher<Postcode?, Error>
    func fetchAllPostcodes() -> [Postcode]?
    func deletePostcode(postcodeString: String) -> AnyPublisher<Bool, Error>
    
    // Searched menu item methods
    func fetchMenuItemSearch(using menuItemSearchString: String) -> AnyPublisher<MenuItemSearch?, Error>
    func store(searchedMenuItem: String) -> AnyPublisher<MenuItemSearch?, Error>
    func fetchAllMenuItemSearches() -> [MenuItemSearch]?
    func deleteMenuItemSearch(menuItemSearchString: String) -> AnyPublisher<Bool, Error>
}

struct SearchHistoryDBRepository: SearchHistoryDBRepositoryProtocol {
    let persistentStore: PersistentStore
    
    // MARK: - Postcode methods
    func fetchPostcode(using postcodeString: String) -> AnyPublisher<Postcode?, Error> {
        let fetchRequest = PostcodeMO.fetchRequest(postcode: postcodeString)
        return persistentStore
            .fetch(fetchRequest) {
                Postcode(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func fetchAllPostcodes() -> [Postcode]? {
        let fetchRequest = PostcodeMO.fetchAllPostcodes()
        var postcodes = [Postcode]()
        
        do {
            let storedResults = try persistentStore.fetch(fetchRequest)
            
            storedResults?.forEach { result in
                if let timestamp = result.timestamp, let postcode = result.postcode {
                    postcodes.append(Postcode(timestamp: timestamp, postcode: postcode))
                }
                
            }
     
            return postcodes
        } catch {
            Logger.searchHistoryStorage.info("No postcodes fetched: \(error)")
            return nil
        }
    }
    
    func deletePostcode(postcodeString: String) -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                try PostcodeMO.delete(
                    fetchRequest: PostcodeMO.fetchRequestForDeletion(postcode: postcodeString),
                    in: context)
                return true
            }
    }
    
    // Store postcode
    func store(postcode: String) -> AnyPublisher<Postcode?, Error> {
        let postcodes = fetchAllPostcodes()
        
        let trimmedPostcodeStrings = postcodes?.compactMap({ $0.postcode.removeWhitespace() })
        
        let searchedTrimmedString = postcode.removeWhitespace()
        
        // If there are no matching postcodes then we will save this one
        if trimmedPostcodeStrings?.contains(searchedTrimmedString) == false {
            // First check if we have more than the allowed number of postcodes in the db as specified by the AppConstants
            if let postcodes, postcodes.count > AppV2Constants.Business.maximumPostcodes {
                // If so, get the earliest saved one...
                let postcodeToDelete = postcodes.min(by: { $0.timestamp < $1.timestamp })?.postcode
                
                // ... and delete it
                if let postcodeToDelete {
                    let _ = deletePostcode(postcodeString: postcodeToDelete)
                }
            }
            
            return persistentStore
                .update { context in
                    let postcode = Postcode(timestamp: Date(), postcode: postcode)
                    return postcode.store(in: context).flatMap {
                        Postcode(managedObject: $0)
                    }
                }
        }
        return Fail(error: SearchHistoryError.unableToSave).eraseToAnyPublisher()
    }
    
    // MARK: - Searched menu item methods
    
    // Fetch searched menu item
    func fetchMenuItemSearch(using menuItemSearchString: String) -> AnyPublisher<MenuItemSearch?, Error> {
        let fetchRequest = MenuItemSearchMO.fetchRequest(name: menuItemSearchString)
        return persistentStore
            .fetch(fetchRequest) {
                MenuItemSearch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func fetchAllMenuItemSearches() -> [MenuItemSearch]? {
        let fetchRequest = MenuItemSearchMO.fetchAllMenuItemSearches()
        var searchedMenuItems = [MenuItemSearch]()
        
        do {
            let storedResults = try persistentStore.fetch(fetchRequest)
            
            storedResults?.forEach { result in
                if let timestamp = result.timestamp, let name = result.name {
                    searchedMenuItems.append(MenuItemSearch(timestamp: timestamp, name: name))
                }
                
            }
     
            return searchedMenuItems
        } catch {
            Logger.searchHistoryStorage.info("No menu items found fetched")
            return nil
        }
    }
    
    func deleteMenuItemSearch(menuItemSearchString: String) -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                try MenuItemSearchMO.delete(
                    fetchRequest: MenuItemSearchMO.fetchRequestForDeletion(name: menuItemSearchString),
                    in: context)
                return true
            }
    }
    
    // Store fetched menu item
    func store(searchedMenuItem: String) -> AnyPublisher<MenuItemSearch?, Error> {
        let searchedMenuItems = fetchAllMenuItemSearches()
        
        let trimmedSearchStrings = searchedMenuItems?.compactMap({ $0.name.removeWhitespace() })
        
        let searchedTrimmedString = searchedMenuItem.removeWhitespace()
        
        // If there are no matching menu item searches then we will save this one
        if let searchedMenuItems, let matchingSearchQuery = searchedMenuItems.filter({ $0.name == searchedMenuItem }).first {
            let _ = deleteMenuItemSearch(menuItemSearchString: matchingSearchQuery.name)
            return persistentStore
                .update { context in
                    let searchedMenuItem = MenuItemSearch(timestamp: Date(), name: searchedMenuItem)
                    return searchedMenuItem.store(in: context).flatMap {
                        MenuItemSearch(managedObject: $0)
                    }
                }
        } else {
            
            // First check if we have more than the allowed number of searches in the db as specified by the AppConstants
            if let searchedMenuItems, searchedMenuItems.count > AppV2Constants.Business.maximumPostcodes {
                // If so, get the earliest saved one...
                let searchedMenuItemToDelete = searchedMenuItems.min(by: { $0.timestamp < $1.timestamp })?.name
                
                // ... and delete it
                if let searchedMenuItemToDelete {
                    let _ = deleteMenuItemSearch(menuItemSearchString: searchedMenuItemToDelete)
                }
            }
            
            return persistentStore
                .update { context in
                    let searchedMenuItem = MenuItemSearch(timestamp: Date(), name: searchedMenuItem)
                    return searchedMenuItem.store(in: context).flatMap {
                        MenuItemSearch(managedObject: $0)
                    }
                }
        }
    }
}
