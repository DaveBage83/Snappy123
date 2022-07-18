//
//  UtilityWebRepository.swift
//  SnappyV2
//
//  Created by David Bage on 19/01/2022.
//

import Foundation
import Combine

// General Note:
// (a) Parameter requirement checking (PRC) could be at higher point in the call chain, e.g. in UtilityService
// public or helper methods. We could also try an map it to server responses. In the end we (Henrik|Kevin) decided
// to have it at this web repository level because:
// - parent calling methods might easily omit the checks if their implementation is updated
// - the web repository is nearer to the business logic and PRC is based on this logic
// - the server responses vary and don't always adhere to APIErrorResult structure or http codes

protocol UtilityWebRepositoryProtocol: WebRepository {
    func getServerTime() -> AnyPublisher<TrueTime?, Error>
    func mentionMeCallHome(requestType: MentionMeRequest, businessOrderId: Int?) async throws -> ShimmedMentionMeCallHomeResponse
}

struct UtilityWebRepository: UtilityWebRepositoryProtocol {

    var networkHandler: NetworkHandler
    var baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func getServerTime() -> AnyPublisher<TrueTime?, Error> {
        return call(endpoint: API.getServerTime)
    }
    
    func mentionMeCallHome(requestType: MentionMeRequest, businessOrderId: Int?) async throws -> ShimmedMentionMeCallHomeResponse {
        
        // See general note (a)
        if businessOrderId == nil && (requestType == .consumerOrder || requestType == .offer) {
            throw UtilityServiceError.invalidParameters(["businessOrderId required"])
        }
        
        var parameters: [String: Any] = [
            "requestType": requestType.rawValue,
            "businessId": AppV2Constants.Business.id,
            "localeCode": AppV2Constants.Client.languageCode,
            "platform": AppV2Constants.Client.platform
        ]
        if let appWhiteLabelProfileId = AppV2Constants.Business.appWhiteLabelProfileId {
            parameters["appWhiteLabelProfileId"] = appWhiteLabelProfileId
        }
        if let userDeviceIdentifier = AppV2Constants.Client.userDeviceIdentifier {
            parameters["userDeviceIdentifier"] = userDeviceIdentifier
        }
        if let deviceType = AppV2Constants.Client.deviceType {
            parameters["deviceType"] = deviceType
        }
        if let appVersion = AppV2Constants.Client.appVersion {
            parameters["appVersion"] = "v" + appVersion
        }
        if let businessOrderId = businessOrderId {
            parameters["businessOrderId"] = businessOrderId
        }
        
        return try await call(endpoint: API.mentionMeCallHome(parameters)).singleOutput()
    }
}

extension UtilityWebRepository {
    enum API {
        case getServerTime
        case mentionMeCallHome([String: Any]?)
    }
}

extension UtilityWebRepository.API: APICall {
    var path: String {
        switch self {
        case .getServerTime:
            return "\(AppV2Constants.Client.languageCode)/serverTime.json"
        case .mentionMeCallHome:
            return "\(AppV2Constants.Client.languageCode)/mentionMe.json"
        }
    }
    
    var method: String {
        switch self {
        case .getServerTime:
            return "GET"
        case .mentionMeCallHome:
            return "POST"
        }
    }
    
    var jsonParameters: [String : Any]? {
        switch self {
        case .getServerTime:
            return nil
        case let .mentionMeCallHome(parameters):
            return parameters
        }
    }
}
