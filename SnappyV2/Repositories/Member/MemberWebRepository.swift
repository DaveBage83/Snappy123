//
//  MemberWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Foundation
import Combine

protocol MemberWebRepositoryProtocol: WebRepository {
    func login(email: String, password: String) -> AnyPublisher<Bool, Error>
    func logout() -> AnyPublisher<Bool, Error>
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error>
}

struct MemberWebRepository: MemberWebRepositoryProtocol {

    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        networkHandler.signIn(
            connectionTimeout: AppV2Constants.API.connectionTimeout,
            // TODO: add notification device paramters
            parameters: [
                "username": email,
                "password": password
            ]
        )
    }
    
    func logout() -> AnyPublisher<Bool, Error> {
        networkHandler.signOut(
            connectionTimeout: AppV2Constants.API.connectionTimeout,
            // TODO: add notification device paramters
            parameters: [:]
        )
    }
    
    func getProfile(storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        // required parameters
        var parameters: [String: Any] = [:]
        
        // one of the following paramters is expected
        if let storeId = storeId {
            parameters["storeId"] = storeId
        }
        return call(endpoint: API.getProfile(parameters))
    }
    
}

// MARK: - Endpoints

extension MemberWebRepository {
    enum API {
        case getProfile([String: Any]?)
    }
}

extension MemberWebRepository.API: APICall {
    var path: String {
        switch self {
        case .getProfile:
            return AppV2Constants.Client.languageCode + "/member/profile.json"
        }
    }
    var method: String {
        switch self {
        case .getProfile:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .getProfile(parameters):
            return parameters
        }
    }
}



