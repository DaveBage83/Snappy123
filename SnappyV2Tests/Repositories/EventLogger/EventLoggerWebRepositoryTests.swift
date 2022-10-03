//
//  EventLoggerWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/10/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class EventLoggerWebRepositoryTests: XCTestCase {
    
    private var sut: EventLoggerWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = EventLoggerWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = EventLoggerWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_pathGetIterableJWT() {
        XCTAssertEqual(API.getIterableJWT("joe@blogs.co.uk", nil).path, "\(AppV2Constants.Client.languageCode)/iterable/jwt.json?email=joe@blogs.co.uk", file: #file, line: #line)
        XCTAssertEqual(API.getIterableJWT(nil, "test me").path, "\(AppV2Constants.Client.languageCode)/iterable/jwt.json?userId=test%20me", file: #file, line: #line)
    }
    
    // MARK: - getIterableJWT(email:userId:)
    func test_getIterableJWT_givenInvalidEmail_throwError() async {
        do {
            let result = try await sut.getIterableJWT(email: "blah", userId: nil)
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            switch error {
            case EventLoggerError.invalidParameters:
                break
            default:
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
    }
    
    func test_getIterableJWT_givenBothEmailAndUserIdSet_throwError() async {
        do {
            let result = try await sut.getIterableJWT(email: "joe@blogs.co.uk", userId: "userId")
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            switch error {
            case EventLoggerError.invalidParameters:
                break
            default:
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
    }
    
    func test_getIterableJWT_givenNeitherEmailAndUserIdSet_throwError() async {
        do {
            let result = try await sut.getIterableJWT(email: nil, userId: nil)
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            switch error {
            case EventLoggerError.invalidParameters:
                break
            default:
                XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
            }
        }
    }
    
    func test_getIterableJWT_givenValidEmail() async throws {
        
        let data = IterableJWTResult.mockedData
        try mock(.getIterableJWT("joe@blogs.co.uk", nil), result: .success(data))
        
        do {
            let result = try await sut.getIterableJWT(email: "joe@blogs.co.uk", userId: nil)
            XCTAssertEqual(result.jwt, data.jwt, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}
