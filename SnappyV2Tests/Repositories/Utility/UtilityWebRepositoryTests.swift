//
//  UtilityMockedData.swift
//  SnappyV2Tests
//
//  Created by David Bage on 24/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class UtilityWebRepositoryTests: XCTestCase {
    private var sut: UtilityWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = UtilityWebRepository.API
    typealias Mock = RequestMocking.MockedResponse
    
    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = UtilityWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/")
    }
    
    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - getServerTime()
    
    func test_getServerTime_returnServerTimeUTC() throws {
        let data = TrueTime(timeUTC: "2022-01-24T17:19:22+00:00")
        
        try mock(.getServerTime, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        
        sut.getServerTime()
            .sinkToResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - mentionMeCallHome(requestType:businessOrderId:)
    
    func test_mentionMeCallHome_returnShimmedMentionMeCallHomeResponse() async throws {

        let data = ShimmedMentionMeCallHomeResponse.mockedData

        var parameters: [String: Any] = [
            "requestType": MentionMeRequest.referee.rawValue,
            "businessId": AppV2Constants.Business.id,
            "localeCode": AppV2Constants.Client.languageCode,
            "platform": AppV2Constants.Client.platform,
            "businessOrderId": 99999
        ]
        if let appWhiteLabelProfileId = AppV2Constants.Business.appWhiteLabelProfileId {
            parameters["appWhiteLabelProfileId"] = appWhiteLabelProfileId
        }
        if let userDeviceIdentifier = AppV2Constants.Client.userDeviceIdentifier {
            parameters["userDeviceIdentifier"] = userDeviceIdentifier
        }
        if let deviceType = AppV2Constants.Client.deviceType {
            parameters["deviceType"] = deviceType
        }
        if let appVersion = AppV2Constants.Client.appVersion {
            parameters["appVersion"] = "v" + appVersion
        }

        try mock(.mentionMeCallHome(parameters), result: .success(data))
        do {
            let result = try await sut.mentionMeCallHome(
                requestType: .referee,
                businessOrderId: 99999
            )
            XCTAssertEqual(result, data, file: #file, line: #line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
}
