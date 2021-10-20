//
//  MockedServices.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/10/2021.
//

import XCTest
import CoreLocation
@testable import SnappyV2

extension DIContainer.Services {
    static func mocked(retailStoreService: [MockedRetailStoreService.Action] = []) -> DIContainer.Services {
        .init(retailStoreService: MockedRetailStoreService(expected: retailStoreService))
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (retailStoresService as? MockedRetailStoreService)?
            .verify(file: file, line: line)
    }
}

struct MockedRetailStoreService: Mock, RetailStoresServiceProtocol {
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D) {
        //
    }
    
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String) {
        //
    }
    
    enum Action: Equatable {
        case repeatLastSearch(search: RetailStoresSearch)
        case searchRetailStores(postcode: String)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>) {
        //
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String) {
        register(.searchRetailStores(postcode: postcode))
    }
}
