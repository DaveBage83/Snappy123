//
//  BusinessProfileWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import Foundation

protocol BusinessProfileWebRepositoryProtocol: WebRepository {
    func getProfile() async throws -> BusinessProfile
    func checkPreviousOrderedDeviceState(deviceCheckToken: String) async throws -> CheckPreviousOrderedDeviceStateResult
}

struct BusinessProfileWebRepository: BusinessProfileWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func getProfile() async throws -> BusinessProfile {
        try await call(endpoint: API.getProfile).singleOutput()
    }
    
    func checkPreviousOrderedDeviceState(deviceCheckToken: String) async throws -> CheckPreviousOrderedDeviceStateResult {
        let parameters: [String: Any] = [
            "deviceCheckToken": deviceCheckToken
        ]
        
        return try await call(endpoint: API.checkPreviousOrderedDeviceState(parameters)).singleOutput()
    }
}

// MARK: - Endpoints

extension BusinessProfileWebRepository {
    enum API {
        case getProfile
        case checkPreviousOrderedDeviceState([String: Any]?)
    }
}

extension BusinessProfileWebRepository.API: APICall {
    var path: String {
        switch self {
        case .getProfile:
            return AppV2Constants.Client.languageCode + "/business/\(AppV2Constants.Business.id).json"
        case .checkPreviousOrderedDeviceState:
            return "\(AppV2Constants.Client.languageCode)/device/\(AppV2Constants.Client.platform)/checkPreviousOrderedState.json"
        }
    }
    var method: String {
        switch self {
        case .getProfile:
            return "GET"
        case .checkPreviousOrderedDeviceState:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case .getProfile:
            return nil
        case let .checkPreviousOrderedDeviceState(parameters):
            return parameters
        }
    }
}
