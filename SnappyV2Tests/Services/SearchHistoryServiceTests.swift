//
//  SearchHistoryServiceTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 30/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class SearchHistoryServiceTests: XCTestCase {
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedDBRepo: MockedSearchHistoryDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: SearchHistoryService!

    override func setUp() {
        
        mockedEventLogger = MockedEventLogger()
        mockedDBRepo = MockedSearchHistoryDBRepository()
        sut = SearchHistoryService(dbRepository: mockedDBRepo)
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedDBRepo = nil
        sut = nil
    }
}

final class GetPostcodeTests: SearchHistoryServiceTests {
    func test_whenFetchAllPostcodes_thenAllPostcodesReturned() async {
        
        mockedDBRepo.actions = .init(expected: [
            .fetchAllPostcodes
        ])
        
        let postcodes = await sut.getAllPostcodes()
        mockedDBRepo.verify()
        XCTAssertEqual(postcodes, [.mockedData])
    }
    
    func test_whenFetchPostcode_thenAllPostcode() async {
        let postcodeString = Postcode.mockedData.postcode
        
        mockedDBRepo.actions = .init(expected: [
            .fetchPostcode(postcodeString: postcodeString)
        ])
        
        let postcode = await sut.getPostcode(postcodeString: postcodeString)
        mockedDBRepo.verify()
        XCTAssertEqual(postcode, .mockedData)
    }
}

final class StorePostcodeTests: SearchHistoryServiceTests {
    func test_whenStorePostcode_thenPostcodeStored() async {
        let postcodeString = Postcode.mockedData.postcode
        mockedDBRepo.actions = .init(expected: [
            .store(postcode: postcodeString)
        ])
        await sut.storePostcode(postcodeString: postcodeString)
        mockedDBRepo.verify()
    }
}

final class GetMenuItemSearchTests: SearchHistoryServiceTests {
    func test_whenFetchAllMenuItemSearches_thenAllMenuItemSearchesReturned() async {
        
        mockedDBRepo.actions = .init(expected: [
            .fetchAllMenuItemSearches
        ])
        
        let menuItemSearches = await sut.getAllMenuItemSearches()
        mockedDBRepo.verify()
        XCTAssertEqual(menuItemSearches, [.mockedData])
    }
    
    func test_whenFetchMenuItemSearch_thenFetchSearch() async {
        let menuItemString = MenuItemSearch.mockedData.name
        
        mockedDBRepo.actions = .init(expected: [
            .fetchMenuItemSearch(menuItemSearchString: menuItemString)
        ])
        
        let menuItemSearch = await sut.getMenuItemSearch(menuItemSearchString: menuItemString)
        mockedDBRepo.verify()
        XCTAssertEqual(menuItemSearch, .mockedData)
    }
}

final class StoreMenuItemSearchTests: SearchHistoryServiceTests {
    func test_whenStoreMenuItemSearc_thenMenuItemSearchStored() async {
        let menuItemString = MenuItemSearch.mockedData.name
        mockedDBRepo.actions = .init(expected: [
            .store(searchedMenuItem: menuItemString)
        ])
        await sut.storeMenuItemSearch(menuItemSearchString: menuItemString)
        mockedDBRepo.verify()
    }
}
