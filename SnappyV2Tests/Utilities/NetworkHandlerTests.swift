//
//  NetworkHandlerTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/10/2022.
//

import XCTest
import Foundation
@testable import SnappyV2

struct DummyWebRepositoryResult: Codable, Equatable {
    let status: Bool
    let message: String
}

protocol DummyWebRepositoryProtocol: WebRepository {
    func testRequest(email: String, postcode: String) async throws -> DummyWebRepositoryResult
}

struct DummyWebRepository: DummyWebRepositoryProtocol {
    
    let networkHandler: NetworkHandler
    let baseURL: String
    
    init(networkHandler: NetworkHandler, baseURL: String) {
        self.networkHandler = networkHandler
        self.baseURL = baseURL
    }
    
    func testRequest(email: String, postcode: String) async throws -> DummyWebRepositoryResult {
        
        let parameters: [String: Any] = [
            "email": email,
            "postcode": postcode
        ]
        
        return try await call(endpoint: API.testRequest(parameters)).singleOutput()
    }
}

// MARK: - Endpoints

extension DummyWebRepository {
    enum API {
        case testRequest([String: Any]?)
    }
}

extension DummyWebRepository.API: APICall {
    var path: String {
        switch self {
        case .testRequest:
            return AppV2Constants.Client.languageCode + "/test.json"
        }
    }
    var method: String {
        switch self {
        case .testRequest:
            return "POST"
        }
    }
    var jsonParameters: [String : Any]? {
        switch self {
        case let .testRequest(parameters):
            return parameters
        }
    }
}

class NetworkHandlerTests: XCTestCase {
    
    typealias API = DummyWebRepository.API
    typealias Mock = RequestMocking.MockedResponse
    
    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_eventLogging_whenNetworkError() async throws {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let parameters: [String: Any] = [
            "email": "james@hotmail.com",
            "postcode": "DD21RW"
        ]
        
        var logParameters: [String : Any]?
        
        let sut = makeSUT { parameters in
            logParameters = parameters
        }
        
        let dummyWebRepository = DummyWebRepository(
            networkHandler: sut,
            baseURL: "https://test.com/"
        )
        
        try mock(.testRequest(parameters), result: Result<DummyWebRepositoryResult, Error>.failure(networkError))
        do {
            let result = try await dummyWebRepository.testRequest(email: "test@test.com", postcode: "PA344AG")
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            if let logParameters {
                // cannot compare logParameters to another disctionary because there
                // is no guarantee on the order in request_params
                XCTAssertEqual(logParameters["url"] as? String, "https://test.com/es_US/test.json", file: #file, line: #line)
                XCTAssertEqual(logParameters["error"] as? String, "The operation couldn’t be completed. (NSURLErrorDomain error 1.)", file: #file, line: #line)
                XCTAssertTrue((logParameters["request_params"] as? String ?? "").contains("postcode:PA344AG"), file: #file, line: #line)
                XCTAssertTrue((logParameters["request_params"] as? String ?? "").contains("email:test@test.com"), file: #file, line: #line)
            } else {
                XCTFail("No error log parameters", file: #file, line: #line)
            }
        }
    }
    
    func test_eventLogging_whenAPIError() async throws {
        
        let apiError = APIErrorResult.mockedUnauthorized
        let parameters: [String: Any] = [
            "email": "james@hotmail.com",
            "postcode": "DD21RW"
        ]
        
        var logParameters: [String : Any]?
        
        let sut = makeSUT { parameters in
            logParameters = parameters
        }
        
        let dummyWebRepository = DummyWebRepository(
            networkHandler: sut,
            baseURL: "https://test.com/"
        )
        
        try mock(.testRequest(parameters), result: APIErrorResult.mockedUnauthorized)
        do {
            let result = try await dummyWebRepository.testRequest(email: "test@test.com", postcode: "PA344AG")
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            if let logParameters {
                // cannot compare logParameters to another disctionary because there
                // is no guarantee on the order in request_params
                XCTAssertEqual(logParameters["url"] as? String, "https://test.com/es_US/test.json", file: #file, line: #line)
                XCTAssertEqual(logParameters["error"] as? String, apiError.errorDisplay, file: #file, line: #line)
                XCTAssertTrue((logParameters["request_params"] as? String ?? "").contains("postcode:PA344AG"), file: #file, line: #line)
                XCTAssertTrue((logParameters["request_params"] as? String ?? "").contains("email:test@test.com"), file: #file, line: #line)
            } else {
                XCTFail("No error log parameters", file: #file, line: #line)
            }
        }
    }
    
    func makeSUT(apiErrorEventHandler: @escaping ([String : Any]) -> Void) -> NetworkHandler {
        
        let authenticator = NetworkAuthenticator(
            apiErrorEventHandler: apiErrorEventHandler
        )
        
        let sut = NetworkHandler(
            authenticator: authenticator,
            urlSessionConfiguration: URLSessionConfiguration.mockedResponsesOnly,
            debugTrace: false,
            apiErrorEventHandler: apiErrorEventHandler
        )
        
        return sut
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: "https://test.com/", result: result)
        RequestMocking.add(mock: mock)
    }
    
    private func mock(_ apiCall: API, result: APIErrorResult, httpCode: HTTPCode = 500) throws {
        let mock = try Mock(apiCall: apiCall, baseURL: "https://test.com/", apiErrorResult: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
    
}
