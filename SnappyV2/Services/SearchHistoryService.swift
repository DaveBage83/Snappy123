//
//  SearchHistoryService.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import Combine
import OSLog

protocol SearchHistoryServiceProtocol {
    // MARK: - Postcode methods
    func getPostcode(postcodeString: String) async -> Postcode?
    func storePostcode(postcodeString: String) async
    func getAllPostcodes() async -> [Postcode]?
    
    // MARK: - Menu item search methods
    func getMenuItemSearch(menuItemSearchString: String) async -> MenuItemSearch?
    func storeMenuItemSearch(menuItemSearchString: String) async
    func getAllMenuItemSearches() async -> [MenuItemSearch]?
}

struct SearchHistoryService: SearchHistoryServiceProtocol {
    let dbRepository: SearchHistoryDBRepositoryProtocol
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Postcode methods
    func getPostcode(postcodeString: String) async -> Postcode? {
        
        do {
            let postcode = try await dbRepository.fetchPostcode(using: postcodeString).singleOutput()
            return postcode
        } catch {
            Logger.searchHistoryStorage.error("Failed to fetch postcode")
            return nil
        }
    }
    
    func getAllPostcodes() async -> [Postcode]? {
        return dbRepository.fetchAllPostcodes()
    }
    
    func storePostcode(postcodeString: String) async {
        do {
            let _ = try await dbRepository.store(postcode: postcodeString).singleOutput()
        } catch {
            Logger.searchHistoryStorage.error("Failed to store postcode")
        }
    }
    
    // MARK: - Menu item search methods
    func getMenuItemSearch(menuItemSearchString: String) async -> MenuItemSearch? {
        
        do {
            let menuItemSearch = try await dbRepository.fetchMenuItemSearch(using: menuItemSearchString).singleOutput()
            return menuItemSearch
        } catch {
            Logger.searchHistoryStorage.error("Failed to fetch postcode")
            return nil
        }
    }
    
    func getAllMenuItemSearches() async -> [MenuItemSearch]? {
        return dbRepository.fetchAllMenuItemSearches()
    }
    
    func storeMenuItemSearch(menuItemSearchString: String) async {
        do {
            let _ = try await dbRepository.store(searchedMenuItem: menuItemSearchString).singleOutput()
        } catch {
            Logger.searchHistoryStorage.error("Failed to store postcode")
        }
    }
}

struct StubSearchHistoryService: SearchHistoryServiceProtocol {
    func getAllPostcodes() async -> [Postcode]? {
        return nil
    }
    
    func getPostcode(postcodeString: String) async -> Postcode? {
        return nil
    }
    
    func storePostcode(postcodeString: String) async {}
    
    func getMenuItemSearch(menuItemSearchString: String) async -> MenuItemSearch? {
        return nil
    }
    
    func storeMenuItemSearch(menuItemSearchString: String) async {}
    
    func getAllMenuItemSearches() async -> [MenuItemSearch]? {
        return nil
    }
}
