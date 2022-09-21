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
            "messagingDeviceId": request.deviceMessageToken,
            "businessId": AppV2Constants.Business.id,
            "systemVersion": AppV2Constants.Client.systemVersion,
            "deviceModel": AppV2Constants.Client.deviceModel,
            // Larissa 2022-09-21: "had to add a name as it is not null in the db" so
            // just passing the deviceModel again
            "deviceName": AppV2Constants.Client.deviceModel
        ]
        if let appWhiteLabelProfileId = AppV2Constants.Business.appWhiteLabelProfileId {
            parameters["appWhiteLabelProfileId"] = appWhiteLabelProfileId
        }
        // 2022-09-21 Decision to use bundle over app version based on iOS team agreement
        // and sumerised by Henrik: "What helps us the most? Build version is more specific.
        // One app version can have several build versions."
        if let appVersion = AppV2Constants.Client.bundleVersion {
            parameters["appVersion"] = appVersion
        }
        if let oldDeviceMessageId = request.oldDeviceMessageToken {
            parameters["oldDeviceId"] = oldDeviceMessageId
        }
        if let optOut = request.optOut {
            parameters["promoConsentLevel"] = optOut.rawValue
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
            return "\(AppV2Constants.Client.languageCode)/device/\(AppV2Constants.Client.platform)/register.json"
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

