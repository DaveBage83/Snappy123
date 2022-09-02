//
//  PushNotificationWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 11/08/2022.
//

import Foundation
import Combine

protocol PushNotificationWebRepositoryProtocol: WebRepository {
    func registerDevice(request: PushNotificationDeviceRequest) async throws -> RegisterPushNotificationDeviceResult
}

struct PushNotificationWebRepository: PushNotificationWebRepositoryProtocol {

    var networkHandler: NetworkHandler
    var baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func registerDevice(request: PushNotificationDeviceRequest) async throws -> RegisterPushNotificationDeviceResult {

        var parameters: [String: Any] = [
            "deviceMessageId": request.deviceMessageToken,
            "businessId": AppV2Constants.Business.id,
            "platform": AppV2Constants.Client.platform,
            "systemVersion": AppV2Constants.Client.systemVersion,
            "deviceModel": AppV2Constants.Client.deviceModel
        ]
        if let appWhiteLabelProfileId = AppV2Constants.Business.appWhiteLabelProfileId {
            parameters["appWhiteLabelProfileId"] = appWhiteLabelProfileId
        }
        if let appVersion = AppV2Constants.Client.appVersion {
            parameters["appVersion"] = appVersion
        }
        if let oldDeviceMessageId = request.oldDeviceMessageToken {
            parameters["oldDeviceMessageId"] = oldDeviceMessageId
        }
        if let optOut = request.optOut {
            parameters["optOut"] = optOut.rawValue
        }
        if let fcmToken = request.firebaseCloudMessageToken {
            parameters["fcmToken"] = fcmToken
        }
        
        return try await call(endpoint: API.registerDevice(parameters)).singleOutput()
    }
}

extension PushNotificationWebRepository {
    enum API {
        case registerDevice([String: Any]?)
    }
}

extension PushNotificationWebRepository.API: APICall {
    var path: String {
        switch self {
        case .registerDevice:
            return "\(AppV2Constants.Client.languageCode)/registerDeviceIdentifier.json"
        }
    }
    
    var method: String {
        switch self {
        case .registerDevice:
            return "POST"
        }
    }
    
    var jsonParameters: [String : Any]? {
        switch self {
        case let .registerDevice(parameters):
            return parameters
        }
    }
}

