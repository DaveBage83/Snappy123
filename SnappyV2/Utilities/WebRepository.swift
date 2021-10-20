//
//  WebRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/09/2021.
//

import Foundation
import Combine

protocol WebRepository {
//    var session: URLSession { get }
    var baseURL: String { get }
//    var bgQueue: DispatchQueue { get }
    var networkHandler: NetworkHandler { get }
}

extension WebRepository {
    
    func call<Value>(endpoint: APICall) -> AnyPublisher<Value, Error>
        where Value: Decodable {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL, forDebug: networkHandler.debugTrace)
            return networkHandler.request(for: request)
        } catch let error {
            return Fail<Value, Error>(error: error).eraseToAnyPublisher()
        }
    }
    
}
