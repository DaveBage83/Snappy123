//
//  AppV2Constants.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/09/2021.
//

import Foundation

struct AppV2Constants {
    
    struct Business {
        static let id = 15
    }
    
    struct API {
        static let baseURL: String = "https://api-staging.snappyshopper.co.uk/api/v2/"
        static let authenticationURL: String = "oauth/token"
        static let clientId = "944d5b2d-a8d5-4fd0-ac40-91bd6cd2ad4d"
        static let clientSecret = "KPJQYTORajTsMJUUigX9MxtamIimNHdRNBrmKq9e"
        static let connectionTimeout: TimeInterval = 10.0
        static let debugTrace: Bool = true
    }

}
