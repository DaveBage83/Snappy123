//
//  APICall.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

// Adapted by Kevin Palser

import Foundation

protocol APICall {
    var path: String { get }
    var method: String { get }
    var jsonParameters: [String: Any]? { get }
//    var headers: [String: String]? { get }
//    func body() throws -> Data?
}

enum APIError: Swift.Error {
    case invalidURL
    case parameterEncoding(String)
    case dateDecoding(given: String, expectedFormat: String)
//    case httpCode(HTTPCode)
//    case unexpectedResponse
//    case imageProcessing([URLRequest])
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case let .parameterEncoding(description): return "Encoding Error: \(description)"
        case let .dateDecoding(given: value, expectedFormat: expectedFormat): return "Date Decoding Error: \(value) vs \(expectedFormat)"
//        case let .httpCode(code): return "Unexpected HTTP code: \(code)"
//        case .unexpectedResponse: return "Unexpected response from the server"
//        case .imageProcessing: return "Unable to load image"
        }
    }
}

extension APICall {
    func urlRequest(baseURL: String, forDebug debugTrace: Bool) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let parameters = jsonParameters {
            do {
                request.httpBody = try requestBodyFrom(parameters: parameters, forDebug: debugTrace)
            } catch {
                throw APIError.parameterEncoding(error.localizedDescription)
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}

typealias HTTPCode = Int
