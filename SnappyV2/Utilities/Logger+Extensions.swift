//
//  Logger.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 13/03/2022.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    // Logging categories:
    static let product = Logger(subsystem: subsystem, category: "Product")
    static let stores = Logger(subsystem: subsystem, category: "Stores")
    static let checkout = Logger(subsystem: subsystem, category: "Checkout")
    static let basket = Logger(subsystem: subsystem, category: "Basket")
    static let fulfilmentTimeSlotSelection = Logger(subsystem: subsystem, category: "FulfilmentTimeSlotSelection")
    static let member = Logger(subsystem: subsystem, category: "member")
}
