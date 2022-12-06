//
//  MockedSearchHistoryService.swift
//  SnappyV2Tests
//
//  Created by David Bage on 29/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedSearchHistoryService: Mock, SearchHistoryServiceProtocol {
    enum Action: Equatable {
        case getPostcode(postcodeString: String)
        case storePostcode(postcodeString: String)
        case getAllPostcodes
        case getMenuItemSearch(menuItemSearchString: String)
        case storeMenuItemSearch(menuItemSearchString: String)
        case getAllMenuItemSearches
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func getPostcode(postcodeString: String) async -> Postcode? {
        register(.getPostcode(postcodeString: postcodeString))
        return nil
    }
    
    func storePostcode(postcodeString: String) async {
        register(.storePostcode(postcodeString: postcodeString))
    }
    
    func getAllPostcodes() async -> [SnappyV2.Postcode]? {
        register(.getAllPostcodes)
        return [.init(timestamp: Date(), postcode: "GU99EP")]
    }
    
    func getMenuItemSearch(menuItemSearchString: String) async -> SnappyV2.MenuItemSearch? {
        register(.getMenuItemSearch(menuItemSearchString: menuItemSearchString))
        return nil
    }
    
    func storeMenuItemSearch(menuItemSearchString: String) async {
        register(.storeMenuItemSearch(menuItemSearchString: menuItemSearchString))
    }
    
    func getAllMenuItemSearches() async -> [SnappyV2.MenuItemSearch]? {
        register(.getAllMenuItemSearches)
        return [.mockedData]
    }
}
