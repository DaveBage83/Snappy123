//
//  RetailStoreMenuDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 15/05/2022.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

class RetailStoreMenuDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: RetailStoreMenuDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = RetailStoreMenuDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
}

// MARK: - Methods in RetailStoreMenuDBRepositoryProtocol

final class RetailStoreMenuDBRepositoryProtocolTests: RetailStoreMenuDBRepositoryTests {
    
    // Adding stored results
    
    // MARK: - store(fetchResult:forStoreId:categoryId:fulfilmentMethod:fulfilmentDate:)
    
    func test_storeRetailStoreMenuFetchResult() throws {
        
        let fetch = RetailStoreMenuFetch.mockedDataFromAPI
        
        // fetch parameters
        let fetchStoreId = 910
        let fetchCategoryId = 0
        let fetchFulfilmentMethod: RetailStoreOrderMethodType = .delivery
        let fetchFulfilmentDate = "2021-05-15"
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: fetch.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
            fetchResult: fetch,
            forStoreId: fetchStoreId,
            categoryId: fetchCategoryId,
            fulfilmentMethod: .delivery,
            fulfilmentDate: fetchFulfilmentDate
        )
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let fetchWithTimeStamp = RetailStoreMenuFetch(
                        id: fetch.id,
                        name: fetch.name,
                        categories: fetch.categories,
                        menuItems: fetch.menuItems,
                        fetchStoreId: fetchStoreId,
                        fetchCategoryId: fetchCategoryId,
                        fetchFulfilmentMethod: fetchFulfilmentMethod,
                        fetchFulfilmentDate: fetchFulfilmentDate,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: fetchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - store(fetchResult:forStoreId:fulfilmentMethod:searchTerm:scope:itemsPagination:categoriesPagination:)
    
    func test_storeRetailStoreMenuGlobalSearchResult_whenNoScopeOrPaginationParams() throws {
        
        let search = RetailStoreMenuGlobalSearch.mockedDataFromAPI
        
        // fetch parameters
        let fetchStoreId = 1025
        let fetchFulfilmentMethod: RetailStoreOrderMethodType = .delivery
        let fetchSearchTerm = "Bag"
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: search.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
                fetchResult: search,
                forStoreId: fetchStoreId,
                fulfilmentMethod: fetchFulfilmentMethod,
                searchTerm: fetchSearchTerm,
                scope: nil,
                itemsPagination: nil,
                categoriesPagination: nil
            )
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let searchWithFetchFields = RetailStoreMenuGlobalSearch(
                        categories: resultValue?.categories,
                        menuItems: resultValue?.menuItems,
                        deals: resultValue?.deals,
                        noItemFoundHint: resultValue?.noItemFoundHint,
                        fetchStoreId: fetchStoreId,
                        fetchFulfilmentMethod: fetchFulfilmentMethod,
                        fetchSearchTerm: fetchSearchTerm,
                        fetchSearchScope: nil,
                        fetchTimestamp: resultValue?.fetchTimestamp,
                        fetchItemsLimit: nil,
                        fetchItemsPage: nil,
                        fetchCategoriesLimit: nil,
                        fetchCategoryPage: nil
                    )
                    result.assertSuccess(value: searchWithFetchFields)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func test_storeRetailStoreMenuGlobalSearchResult_whenScopeAndPaginationParams() throws {
        
        let search = RetailStoreMenuGlobalSearch.mockedDataFromAPI
        
        // fetch parameters
        let fetchStoreId = 1025
        let fetchFulfilmentMethod: RetailStoreOrderMethodType = .delivery
        let fetchSearchTerm = "Bag"
        let fetchScope = RetailStoreMenuGlobalSearchScope.items
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: search.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
                fetchResult: search,
                forStoreId: fetchStoreId,
                fulfilmentMethod: fetchFulfilmentMethod,
                searchTerm: fetchSearchTerm,
                scope: fetchScope,
                itemsPagination: (limit: 15, page: 2),
                categoriesPagination: nil
            )
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let searchWithFetchFields = RetailStoreMenuGlobalSearch(
                        categories: resultValue?.categories,
                        menuItems: resultValue?.menuItems,
                        deals: resultValue?.deals,
                        noItemFoundHint: resultValue?.noItemFoundHint,
                        fetchStoreId: fetchStoreId,
                        fetchFulfilmentMethod: fetchFulfilmentMethod,
                        fetchSearchTerm: fetchSearchTerm,
                        fetchSearchScope: fetchScope,
                        fetchTimestamp: resultValue?.fetchTimestamp,
                        fetchItemsLimit: 15,
                        fetchItemsPage: 2,
                        fetchCategoriesLimit: nil,
                        fetchCategoryPage: nil
                    )
                    result.assertSuccess(value: searchWithFetchFields)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // MARK: - store(fetchResult:forStoreId:menuItemIds:discountId:discountSectionId:fulfilmentMethod:)
    
    func test_storeRetailStoreMenuFetchNotBasedOnCategory() throws {
        
        let fetch = RetailStoreMenuFetch.mockedDataFromAPI
        
        // fetch parameters
        let fetchStoreId = 910
        let fetchMenuItemIds = [3206127, 2923969]
        let fetchFulfilmentMethod: RetailStoreOrderMethodType = .delivery
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: fetch.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
            fetchResult: fetch,
            forStoreId: fetchStoreId,
            menuItemIds: fetchMenuItemIds,
            discountId: nil,
            discountSectionId: nil,
            fulfilmentMethod: .delivery
        )
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let fetchWithTimeStamp = RetailStoreMenuFetch(
                        id: fetch.id,
                        name: fetch.name,
                        categories: fetch.categories,
                        menuItems: fetch.menuItems,
                        fetchStoreId: fetchStoreId,
                        fetchCategoryId: -1,
                        fetchFulfilmentMethod: fetchFulfilmentMethod,
                        fetchFulfilmentDate: nil,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: fetchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
    }
    
    // Removing stored results
    
    // MARK: - clearRetailStoreMenuFetch(forStoreId:categoryId:fulfilmentMethod:fulfilmentDate:)
    
//    func clearRetailStoreMenuFetch(
//        forStoreId: Int,
//        categoryId: Int,
//        fulfilmentMethod: RetailStoreOrderMethodType,
//        fulfilmentDate: String?
//    ) -> AnyPublisher<Bool, Error>
    
    func test_clearRetailStoreMenuFetch() throws {
        
        let fetch = RetailStoreMenuFetch.mockedData
        
        let timeSlotsFromAPI = RetailStoreTimeSlots.mockedAPIResponseData
        _ = RetailStoreTimeSlots.mockedPersistedDataWithCoordinates(basedOn: timeSlotsFromAPI)
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not details.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            fetch.store(in: context)
        }
        
//        let exp = XCTestExpectation(description: #function)
//        sut.clearRetailStoreMenuFetch(
//                forStoreId: Int,
//                categoryId: Int,
//                fulfilmentMethod: RetailStoreOrderMethodType,
//                fulfilmentDate: String?
//            )
//            .sinkToResult { result in
//                result.assertSuccess(value: true)
//                self.mockedStore.verify()
//                exp.fulfill()
//            }
//            .store(in: cancelBag)
//        wait(for: [exp], timeout: 0.5)

    }
    
    // MARK: - clearGlobalSearch(forStoreId:fulfilmentMethod:searchTerm:scope:itemsPagination:categoriesPagination:)
    
//    func clearGlobalSearch(
//        forStoreId: Int,
//        fulfilmentMethod: RetailStoreOrderMethodType,
//        searchTerm: String,
//        scope: RetailStoreMenuGlobalSearchScope?,
//        itemsPagination: (limit: Int, page: Int)?,
//        categoriesPagination: (limit: Int, page: Int)?
//    ) -> AnyPublisher<Bool, Error>
    
    // MARK: - clearRetailStoreMenuItemsFetch(forStoreId:menuItemIds:discountId:discountSectionId:fulfilmentMethod:)
    
//    func clearRetailStoreMenuItemsFetch(
//        forStoreId: Int,
//        menuItemIds: [Int]?,
//        discountId: Int?,
//        discountSectionId: Int?,
//        fulfilmentMethod: RetailStoreOrderMethodType
//    ) -> AnyPublisher<Bool, Error>
    
    // fetching stored results
    
    // MARK: - retailStoreMenuFetch(forStoreId:categoryId:fulfilmentMethod:fulfilmentDate:)
    
//    func retailStoreMenuFetch(
//        forStoreId: Int,
//        categoryId: Int,
//        fulfilmentMethod: RetailStoreOrderMethodType,
//        fulfilmentDate: String?
//    ) -> AnyPublisher<RetailStoreMenuFetch?, Error>
    
    // MARK: - retailStoreMenuGlobalSearch(forStoreId:fulfilmentMethod:searchTerm:scope:itemsPagination:categoriesPagination:)
    
//    func retailStoreMenuGlobalSearch(
//        forStoreId: Int,
//        fulfilmentMethod: RetailStoreOrderMethodType,
//        searchTerm: String,
//        scope: RetailStoreMenuGlobalSearchScope?,
//        itemsPagination: (limit: Int, page: Int)?,
//        categoriesPagination: (limit: Int, page: Int)?
//    ) -> AnyPublisher<RetailStoreMenuGlobalSearch?, Error>
    
    // MARK: - retailStoreMenuItemsFetch(forStoreId:menuItemIds:discountId:discountSectionId:fulfilmentMethod:)
    
//    func retailStoreMenuItemsFetch(
//        forStoreId: Int,
//        menuItemIds: [Int]?,
//        discountId: Int?,
//        discountSectionId: Int?,
//        fulfilmentMethod: RetailStoreOrderMethodType
//    ) -> AnyPublisher<RetailStoreMenuFetch?, Error>

}
