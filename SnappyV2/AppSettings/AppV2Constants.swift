//
//  AppV2Constants.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/09/2021.
//

import Foundation

struct AppV2Constants {
    
    struct Client {
        static let platform = "ios"
    }
    
    struct Business {
        static let id = 15
        static let operatingCountry = "UK"
        static let defaultTimeZone = TimeZone(identifier: "Europe/London")
        static let retailStoreMenuCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        }()
    }
    
    struct API {
        static let baseURL: String = "https://api-staging.snappyshopper.co.uk/api/v2/"
        static let authenticationURL: String = "oauth/token"
        static let clientId = "944d5b2d-a8d5-4fd0-ac40-91bd6cd2ad4d"
        static let clientSecret = "KPJQYTORajTsMJUUigX9MxtamIimNHdRNBrmKq9e"
        static let connectionTimeout: TimeInterval = 10.0
        static let debugTrace: Bool = true
        static let defaultTimeEncodingStrategy: JSONEncoder.DateEncodingStrategy = {
            return JSONEncoder.DateEncodingStrategy.custom { date, encoder in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                let stringData = formatter.string(from: date)
                var container = encoder.singleValueContainer()
                try container.encode(stringData)
            }
        }()
        static let defaultTimeDecodingStrategy: JSONDecoder.DateDecodingStrategy = {
            return JSONDecoder.DateDecodingStrategy.custom { decoder in
                let dateString = try decoder.singleValueContainer().decode(String.self)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = formatter.date(from: dateString) {
                    return date
                }
                throw APIError.dateDecoding(given: dateString, expectedFormat: formatter.dateFormat)
            }
        }()
    }

}