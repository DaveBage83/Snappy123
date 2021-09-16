//
//  RetailStoreService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Foundation

protocol RetailStoreServiceProtocol {
    func loadRetailStores(postcode: String) -> [RetailStore]?
}

struct RetailStoreService: RetailStoreServiceProtocol {
    
    let webRepository: RetailStoreWebRepositoryProtocol
    
    init(webRepository: RetailStoreWebRepositoryProtocol) {
        self.webRepository = webRepository
    }
    
    func loadRetailStores(postcode: String) -> [RetailStore]? {
        webRepository.loadRetailStores()
        
        
        return []
    }
    
    
}
