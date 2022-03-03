//
//  BusinessProfileWebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import Foundation
import Combine

protocol BusinessProfileWebRepositoryProtocol: WebRepository {
    func getProfile() -> AnyPublisher<BusinessProfile, Error>
}

struct BusinessProfileWebRepository: BusinessProfileWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func getProfile() -> AnyPublisher<BusinessProfile, Error> {
        return call(endpoint: API.getProfile)
    }
}

// MARK: - Endpoints

extension BusinessProfileWebRepository {
    enum API {
        case getProfile
    }
}

extension BusinessProfileWebRepository.API: APICall {
    var path: String {
        switch self {
        case .getProfile:
            return AppV2Constants.Client.languageCode + "/business/\(AppV2Constants.Business.id).json"
        }
    }
    var method: String {
        switch self {
        case .getProfile:
            return "GET"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case .getProfile:
            return nil
        }
    }
}
