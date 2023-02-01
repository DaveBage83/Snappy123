//
//  SearchHistoryDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 30/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class SearchHistoryDBRepositoryTests: XCTestCase {
    var mockedStore: MockedPersistentStore!
    var sut: SearchHistoryDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = SearchHistoryDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
    
    func test_whenStorePostcode_thenPostcodeStored() throws {
        let postcode = Postcode.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 1, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            postcode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.store(postcode: postcode.postcode)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_whenFetchPostcode_thenPostcodeFetched() throws {
        let postcode = Postcode.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: PostcodeMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            postcode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.fetchPostcode(using: postcode.postcode)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_whenDeletePostcode_thenPostcodeDeleted() throws {
        let postcode = Postcode.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 0, updated: 0, deleted: 1))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            postcode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.deletePostcode(postcodeString: postcode.postcode)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_whenMenuItemSearch_thenMenuItemSearchStored() throws {
        let menuItemSearch = MenuItemSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 1, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            menuItemSearch.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.store(searchedMenuItem: menuItemSearch.name)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    
    func test_whenFetchMenuItemSearch_thenMenuItemSearchFetched() throws {
        let menuItemSearch = MenuItemSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: MenuItemSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            menuItemSearch.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.fetchMenuItemSearch(using: menuItemSearch.name)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_whenDeleteMenuItemSearch_thenMenuItemSearchDeleted() throws {
        let menuItemSearch = MenuItemSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 0, updated: 0, deleted: 1))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            menuItemSearch.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.deleteMenuItemSearch(menuItemSearchString: menuItemSearch.name)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_whenStoreMenuItemSearch_thenMenuItemSearchStored() throws {
        let menuItemSearch = MenuItemSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 1, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            menuItemSearch.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.store(searchedMenuItem: menuItemSearch.name)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
}
