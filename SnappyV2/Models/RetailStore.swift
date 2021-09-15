//
//  RetailStore.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation

struct RetailStore {
    let id: Int
    let storeName: String
    let storeLogo: String? // Image URL
    let address1: String
    let address2: String?
    let town: String
    let postcode: String
    let telephone: String
    let longitude: Double
    let latitude: Double
    let paymentMethods: [PaymentMethod]
    
}

struct PaymentMethod {
    let id: Int
    let name: String
    let title: String
    let description: String?
}
