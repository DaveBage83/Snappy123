//
//  EventLoggerWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 28/09/2022.
//

import Foundation

// General Note:
// (a) Parameter requirement checking (PRC) could be at higher point in the call chain, e.g. in EventLogger
// public or helper methods. We could also try an map it to server responses. In the end we (Henrik|Kevin) decided
// to have it at this web repository level because:
// - parent calling methods might easily omit the checks if their implementation is updated
// - the web repository is nearer to the business logic and PRC is based on this logic
// - the server responses vary and don't always adhere to APIErrorResult structure or http codes

protocol EventLoggerWebRepositoryProtocol: WebRepository {
    func getIterableJWT(email: String?, userId: String?) async throws -> IterableJWTResult
}

struct EventLoggerWebRepository: EventLoggerWebRepositoryProtocol {

    var networkHandler: NetworkHandler
    var baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func getIterableJWT(email: String?, userId: String?) async throws -> IterableJWTResult {

        // See general note (a)
        var errors: [String] = []
        if let email = email, email.isEmail == false {
            errors.append("invalid email")
        }
        
        if email == nil && userId == nil {
            errors.append("neither email nor userId were set")
        } else if email != nil && userId != nil {
            errors.append("only email or userId need to be set, not both")
        }
        
        guard errors.count == 0 else { throw EventLoggerError.invalidParameters(errors) }
                
        return try await call(endpoint: API.getIterableJWT(email, userId)).singleOutput()
    }
}

extension EventLoggerWebRepository {
    enum API {
        case getIterableJWT(String?, String?)
    }
}

extension EventLoggerWebRepository.API: APICall {
    var path: String {
        switch self {
        case let .getIterableJWT(email, userId):
            var components = URLComponents()
            if let email = email {
                components.queryItems = [
                    URLQueryItem(name: "email", value: email)
                ]
            } else if let userId = userId {
                components.queryItems = [
                    URLQueryItem(name: "userId", value: userId)
                ]
            }
            return "\(AppV2Constants.Client.languageCode)/iterable/jwt.json" + (components.string ?? "")
        }
    }
    
    var method: String {
        switch self {
        case .getIterableJWT:
            return "GET"
        }
    }
    
    var jsonParameters: [String : Any]? {
        switch self {
        case .getIterableJWT:
            return nil
        }
    }
}
