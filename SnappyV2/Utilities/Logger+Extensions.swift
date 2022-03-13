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
    static let checkout = Logger(subsystem: subsystem, category: "checkout")
}
