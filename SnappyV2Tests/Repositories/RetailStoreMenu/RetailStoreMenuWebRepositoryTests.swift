//
//  RetailStoreMenuWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 15/05/2022.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

final class RetailStoreMenuWebRepositoryTests: XCTestCase {
    
    private var sut: RetailStoreMenuWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = RetailStoreMenuWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = RetailStoreMenuWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - loadRootRetailStoreMenuCategories(storeId:fulfilmentMethod:fulfilmentDate:)
    
    func test_loadRootRetailStoreMenuCategories() throws {
        let data = RetailStoreMenuFetch.mockedDataFromAPI
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": 910,
            "fulfilmentMethod": RetailStoreOrderMethodType.delivery.rawValue
        ]
        
        try mock(.rootMenu(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRootRetailStoreMenuCategories(storeId: 910, fulfilmentMethod: .delivery, fulfilmentDate: nil).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - loadRetailStoreMenuSubCategoriesAndItems(storeId:categoryId:fulfilmentMethod:fulfilmentDate:)
    
    func test_loadRetailStoreMenuSubCategoriesAndItems() throws {
        let data = RetailStoreMenuFetch.mockedDataFromAPI
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": 910,
            "categoryId": 1234,
            "fulfilmentMethod": RetailStoreOrderMethodType.delivery.rawValue
        ]
        
        try mock(.subCategoriesAndItems(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.loadRetailStoreMenuSubCategoriesAndItems(storeId: 910, categoryId: 1234, fulfilmentMethod: .delivery, fulfilmentDate: nil).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - globalSearch(storeId:fulfilmentMethod:searchTerm:scope:itemsPagination:categoriesPagination:)
    
    func test_globalSearch() throws {
        let data = RetailStoreMenuGlobalSearch.mockedDataFromAPI
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": 910,
            "fulfilmentMethod": RetailStoreOrderMethodType.delivery.rawValue,
            "searchTerm": "Bags"
        ]
        
        try mock(.globalSearch(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.globalSearch(storeId: 910, fulfilmentMethod: .delivery, searchTerm: "Bags", scope: nil, itemsPagination: nil, categoriesPagination: nil).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: -  getItems(storeId:fulfilmentMethod:menuItemIds:discountId:discountSectionId:)
    
    func test_getItems() throws {
        let data = RetailStoreMenuFetch.mockedDataFromAPI
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "storeId": 910,
            "fulfilmentMethod": RetailStoreOrderMethodType.delivery.rawValue,
            "menuItemIds": [123, 124]
        ]
        
        try mock(.getItems(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.getItems(storeId: 910, fulfilmentMethod: .delivery, menuItemIds: [123, 124], discountId: nil, discountSectionId: nil).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - getItem(request:)
     
     func test_getItem() async throws {
         
         let request = RetailStoreMenuItemRequest.mockedData
         let data = RetailStoreMenuItem.mockedData

         var parameters: [String: Any] = [
             "businessId": AppV2Constants.Business.id,
             "storeId": request.storeId,
             "itemId": request.itemId,
             "fulfilmentMethod": request.fulfilmentMethod.rawValue
         ]
         
         if let categoryId = request.categoryId {
             parameters["categoryId"] = categoryId
         }
         if let fulfilmentDate = request.fulfilmentDate {
             parameters["fulfilmentDate"] = fulfilmentDate
         }

         try mock(.getItem(parameters), result: .success(data))
         do {
             let result = try await sut.getItem(request: request)
             XCTAssertEqual(result, data, file: #file, line: #line)
         } catch {
             XCTFail("Unexpected error: \(error)", file: #file, line: #line)
         }
     }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
}
