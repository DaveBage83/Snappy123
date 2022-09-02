//
//  PushNotificationWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/08/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class PushNotificationWebRepositoryTests: XCTestCase {
    
    private var sut: PushNotificationWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = PushNotificationWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = PushNotificationWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - registerDevice(request:)
    func test_registerDevice() async throws {
        let data = RegisterPushNotificationDeviceResult.mockedData
        let request = PushNotificationDeviceRequest.mockedData
        
        var parameters: [String: Any] = [
            "deviceMessageId": request.deviceMessageToken,
            "businessId": AppV2Constants.Business.id,
            "platform": AppV2Constants.Client.platform,
            "systemVersion": AppV2Constants.Client.systemVersion,
            "deviceModel": AppV2Constants.Client.deviceModel
        ]
        if let appWhiteLabelProfileId = AppV2Constants.Business.appWhiteLabelProfileId {
            parameters["appWhiteLabelProfileId"] = appWhiteLabelProfileId
        }
        if let appVersion = AppV2Constants.Client.appVersion {
            parameters["appVersion"] = appVersion
        }
        if let oldDeviceMessageId = request.oldDeviceMessageToken {
            parameters["oldDeviceMessageId"] = oldDeviceMessageId
        }
        if let optOut = request.optOut {
            parameters["optOut"] = optOut.rawValue
        }
        if let fcmToken = request.firebaseCloudMessageToken {
            parameters["fcmToken"] = fcmToken
        }
        
        try mock(.registerDevice(parameters), result: .success(data))
        
        let result = try await sut.registerDevice(request: request)
        
        XCTAssertEqual(result, data)
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}

