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
            parameters: [
                "username": email,
                "password": password
            ]
        )
    }
    
}
