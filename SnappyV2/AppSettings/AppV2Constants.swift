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
        static let languageCode: String = {
            //return "en_GB"
            return Locale.autoupdatingCurrent.identifier.replacingOccurrences(
                of: "-",
                with: "_",
                options: .literal,
                range: nil
            )
        }()
    }
    
    struct Business {
        static let trueTimeCheckInterval: Double = 720
        static let id = 15
        static let operatingCountry = "UK"
        static let currencyCode = "GBP"
        static let defaultTimeZone = TimeZone(identifier: "Europe/London")
        // always attempt to fetch menu results before
        // checking for cache results that have not
        // expired
        static let attemptFreshMenuFetches = true
        // cached data that is one hour old
        static let retailStoreMenuCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: -1, to: Date().trueDate) ?? Date().trueDate
        }()
        static let addressesCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: -1, to: Date().trueDate) ?? Date().trueDate
        }()
        static let userCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: -1, to: Date().trueDate) ?? Date().trueDate
        }()
        static let standardDateStringFormat = "yyyy-MM-dd"
    }
    
    struct API {
        static let baseURL: String = "https://api-staging.snappyshopper.co.uk/api/v2/"
        static let authenticationURL: String = "oauth/token"
        static let signOutURL: String = AppV2Constants.Client.languageCode + "/auth/logout"
        static let clientId = "944d5b2d-a8d5-4fd0-ac40-91bd6cd2ad4d"
        static let clientSecret = "KPJQYTORajTsMJUUigX9MxtamIimNHdRNBrmKq9e"
        static let connectionTimeout: TimeInterval = 10.0
        #if DEBUG
        static let debugTrace: Bool = true
        #else
        static let debugTrace: Bool = false
        #endif
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
