//
//  MockedSearchHistoryDBRepository.swift
//  SnappyV2Tests
//
//  Created by David Bage on 29/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedSearchHistoryDBRepository: Mock, SearchHistoryDBRepositoryProtocol {
    enum Action: Equatable {
        case fetchPostcode(postcodeString: String)
        case store(postcode: String)
        case fetchAllPostcodes
        case deletePostcode(postcodeString: String)
        case fetchMenuItemSearch(menuItemSearchString: String)
        case store(searchedMenuItem: String)
        case fetchAllMenuItemSearches
        case deleteMenuItemSearch(menuItemSearchString: String)
    }
    
    var actions = MockActions<Action>(expected: [])
    
    var fetchPostcode: Result<Postcode?, Error> = .success(Postcode.mockedData)
    var storePostcode: Result<Postcode?, Error> = .failure(MockError.valueNotSet)
    var fetchPostcodes: [Postcode]?
    var deletePostcode: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var fetchMenuItemSearch: Result<MenuItemSearch?, Error> = .success(.mockedData)
    var storeMenuItemSearch: Result<MenuItemSearch?, Error> = .failure(MockError.valueNotSet)
    var fetchAllMenuItemSearchQueries: [MenuItemSearch]?
    var deleteMenuItemSearch: Result<Bool, Error> = .failure(MockError.valueNotSet)
    
    func fetchPostcode(using postcodeString: String) -> AnyPublisher<SnappyV2.Postcode?, Error> {
        register(.fetchPostcode(postcodeString: postcodeString))
        return fetchPostcode.publish()
    }
    
    func store(postcode: String) -> AnyPublisher<SnappyV2.Postcode?, Error> {
        register(.store(postcode: postcode))
        return storePostcode.publish()
    }
    
    func fetchAllPostcodes() -> [Postcode]? {
        register(.fetchAllPostcodes)
        return [.mockedData]
    }
    
    func deletePostcode(postcodeString: String) -> AnyPublisher<Bool, Error> {
        register(.deletePostcode(postcodeString: postcodeString))
        return deletePostcode.publish()
    }
    
    func fetchMenuItemSearch(using menuItemSearchString: String) -> AnyPublisher<SnappyV2.MenuItemSearch?, Error> {
        register(.fetchMenuItemSearch(menuItemSearchString: menuItemSearchString))
        return fetchMenuItemSearch.publish()
    }
    
    func store(searchedMenuItem: String) -> AnyPublisher<SnappyV2.MenuItemSearch?, Error> {
        register(.store(searchedMenuItem: searchedMenuItem))
        return storeMenuItemSearch.publish()
    }
    
    func fetchAllMenuItemSearches() -> [SnappyV2.MenuItemSearch]? {
        register(.fetchAllMenuItemSearches)
        return [.mockedData]
    }
    
    func deleteMenuItemSearch(menuItemSearchString: String) -> AnyPublisher<Bool, Error> {
        register(.deleteMenuItemSearch(menuItemSearchString: menuItemSearchString))
        return deleteMenuItemSearch.publish()
    }
}
