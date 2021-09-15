//
//  ServicesContainer.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

extension DIContainer {
    struct Services {
        let retailStoreServices: String
        let imageService: String
        
        static var stub: Self {
            .init(retailStoreServices: "", imageService: "")
        }
    }
    
    
}
