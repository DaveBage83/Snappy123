//
//  MockedResponse.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 27/09/2021.
//
import Foundation
@testable import SnappyV2

extension RequestMocking {
    struct MockedResponse {
        let url: URL
        let result: Result<Data, Swift.Error>
        let httpCode: HTTPCode
        let headers: [String: String]
        let loadingTime: TimeInterval
        let customResponse: URLResponse?
    }
}

extension RequestMocking.MockedResponse {
    enum Error: Swift.Error {
        case failedMockCreation
    }
    
    init<T>(apiCall: APICall,
            baseURL: String,
            result: Result<T, Swift.Error>,
            httpCode: HTTPCode = 200,
            headers: [String: String] = ["Content-Type": "application/json"],
            dateEncoding: JSONEncoder.DateEncodingStrategy = AppV2Constants.API.defaultTimeEncodingStrategy,
            loadingTime: TimeInterval = 0.1
    ) throws where T: Encodable {
        guard let url = try apiCall.urlRequest(baseURL: baseURL, forDebug: true).url
            else { throw Error.failedMockCreation }
        self.url = url
        switch result {
        case let .success(value):
            if T.self == Data.self {
                self.result = .success(value as! Data)
            } else {
                let jsonEncoder = JSONEncoder()
                jsonEncoder.dateEncodingStrategy = dateEncoding
                self.result = .success(try jsonEncoder.encode(value))
            }
        case let .failure(error):
            self.result = .failure(error)
        }
        self.httpCode = httpCode
        self.headers = headers
        self.loadingTime = loadingTime
        customResponse = nil
    }
    
    init(
        apiCall: APICall,
        baseURL: String,
        apiErrorResult: APIErrorResult,
        httpCode: HTTPCode = 200,
        headers: [String: String] = ["Content-Type": "application/json"],
        dateEncoding: JSONEncoder.DateEncodingStrategy = AppV2Constants.API.defaultTimeEncodingStrategy,
        loadingTime: TimeInterval = 0.1
    ) throws {
        guard let url = try apiCall.urlRequest(baseURL: baseURL, forDebug: true).url
            else { throw Error.failedMockCreation }
        self.url = url
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = dateEncoding
        self.result = .success(try jsonEncoder.encode(apiErrorResult))
        self.httpCode = httpCode
        self.headers = headers
        self.loadingTime = loadingTime
        customResponse = nil
    }
    
    init(apiCall: APICall, baseURL: String, customResponse: URLResponse) throws {
        guard let url = try apiCall.urlRequest(baseURL: baseURL, forDebug: true).url
            else { throw Error.failedMockCreation }
        self.url = url
        result = .success(Data())
        httpCode = 200
        headers = [String: String]()
        loadingTime = 0
        self.customResponse = customResponse
    }
    
    init(url: URL, result: Result<Data, Swift.Error>) {
        self.url = url
        self.result = result
        httpCode = 200
        headers = [String: String]()
        loadingTime = 0
        customResponse = nil
    }
}
