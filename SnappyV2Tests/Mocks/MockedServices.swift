//
//  MockedServices.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/10/2021.
//

import XCTest
@testable import SnappyV2

extension DIContainer.Services {
    static func mocked(retailStoreService: [MockedRetailStoreService.Action] = []) -> DIContainer.Services {
        .init(retailStoreService: MockedRetailStoreService(expected: retailStoreService))
    }
    
    
}

struct MockedRetailStoreService: Mock, RetailStoresServiceProtocol {
    enum Action: Equatable {
        case repeatLastSearch(search: RetailStoresSearch)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>) {
        //
    }
}
