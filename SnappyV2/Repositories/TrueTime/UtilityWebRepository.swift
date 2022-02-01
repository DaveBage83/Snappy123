//
//  UtilityWebRepository.swift
//  SnappyV2
//
//  Created by David Bage on 19/01/2022.
//

import Foundation
import Combine

protocol UtilityWebRepositoryProtocol: WebRepository {
    func getServerTime() -> AnyPublisher<TrueTime?, Error>
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
}

extension UtilityWebRepository {
    enum API {
        case getServerTime
    }
}

extension UtilityWebRepository.API: APICall {
    var path: String {
        return "\(AppV2Constants.Client.languageCode)/serverTime.json"
    }
    
    var method: String {
        return "GET"
    }
    
    var jsonParameters: [String : Any]? {
        return nil
    }
}
