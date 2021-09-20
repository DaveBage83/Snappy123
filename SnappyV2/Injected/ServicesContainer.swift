//
//  ServicesContainer.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

extension DIContainer {
    struct Services {
        let retailStoresService: RetailStoresServiceProtocol
        //let imageService: String
        
        init(retailStoreService: RetailStoresServiceProtocol) {
            self.retailStoresService = retailStoreService
            //self.imagesService = imagesService
            //self.userPermissionsService = userPermissionsService
        }
        
        static var stub: Self {
            .init(retailStoreService: StubRetailStoresService() /*, imageService: ""*/)
        }
    }
    
    
}
