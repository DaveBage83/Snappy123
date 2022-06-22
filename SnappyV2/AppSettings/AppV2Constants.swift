//
//  AppV2Constants.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/09/2021.
//

import Foundation
import SwiftUI

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
    
    // Settings that can vary between busineses and app deployments
    struct Business {
        // Product card width and spacing stored here so that we can access globally for use in our bespoke grid view
        static let productCardWidth: CGFloat = 132
        static let productCardGridSpacing: CGFloat = 16
        
        static let trueTimeCheckInterval: Double = 720
        static let id = 15
        static let operatingCountry = "UK"
        static let currencyCode = "GBP"
        static let defaultTimeZone = TimeZone(identifier: "Europe/London")
        // always attempt to fetch menu results before
        // checking for cache results that have not
        // expired
        static let attemptFreshMenuFetches = true
        // cached data that is value: -X hour(s) old
        static let businessProfileCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: -24, to: Date().trueDate) ?? Date().trueDate
        }()
        static let addressesCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: -1, to: Date().trueDate) ?? Date().trueDate
        }()
        static let retailStoreMenuCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: -1, to: Date().trueDate) ?? Date().trueDate
        }()
        static let userCachedExpiry: Date = {
            return Calendar.current.date(byAdding: .hour, value: -1, to: Date().trueDate) ?? Date().trueDate
        }()
        static let imagePlaceholder = Image.RemoteImage.placeholder
        static let standardDateOnlyStringFormat = "yyyy-MM-dd"
        static let hourAndMinutesStringFormat = "HH:mm"
        static let appleAppIdentifier = "1089652370"
        // This cannot be brought in via the business profile API result because
        // the reversed version of this also needs to be added the plist:
        // https://developers.google.com/identity/sign-in/ios/start-integrating
        static let googleSignInClientId = "1040639359640-4flentbji5h21ki0jaluf7prjcl76g15.apps.googleusercontent.com"
    }
    
    struct Driver {
        // time window used that the driver app tries to collect coordinates
        // before sending them to our server
        static let locationSendInterval: TimeInterval = 10.0
        // the number of animation steps used to smooth movement when moving
        // the driver map pin
        static let animationRenderPoints = 10
        // used to fetch the status and location of the driver in case the
        // Pusher event has not returned any values for a while
        static let refreshInterval: TimeInterval = 60.0
    }
    
    struct API {
        #if DEBUG
        static let baseURL: String = "https://api-staging.snappyshopper.co.uk/api/v2/"
        #else
        static let baseURL: String = "https://api-orderingv2.snappyshopper.co.uk/api/v2/"
        #endif
        
        static let authenticationURL: String = "oauth/token"
        static let signOutURL: String = AppV2Constants.Client.languageCode + "/auth/logout.json"
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
        static let imageScaleFactor: String = {
            UIScreen.main.scale == 2.0 ? "xhdpi_2x" : "xxhdpi_3x"
        }()
    }
    
    struct EventsLogging {
        #if DEBUG
        static let appsFlyerSettings = AppsFlyerSettings(key: nil, debugLogs: false)
        #else
        static let appsFlyerSettings = AppsFlyerSettings(key: "pEsAXBtQk6j32NgALWr3wT", debugLogs: false)
        #endif
        
        #if DEBUG
        static let firebaseAnalyticsSettings = FirebaseAnalyticsSettings(enabled: false)
        #else
        static let firebaseAnalyticsSettings = FirebaseAnalyticsSettings(enabled: true)
        #endif
    }
}

struct AppsFlyerSettings {
    let key: String?
    let debugLogs: Bool
}

struct FirebaseAnalyticsSettings {
    let enabled: Bool
}
