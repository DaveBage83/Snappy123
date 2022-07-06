//
//  UtilityServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/06/2022.
//

import Foundation
import Combine
import XCTest

@testable import SnappyV2

class UtilityServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedUtilityWebRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: UtilityService!

    override func setUp() {
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedUtilityWebRepository()
        sut = UtilityService(
            webRepository: mockedWebRepo,
            eventLogger: mockedEventLogger
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedWebRepo = nil
        sut = nil
    }
}

final class SetDeviceTimeOffsetTests: UtilityServiceTests {
    
    func test_successfulSetDeviceTimeOffset_deviceTimeOffsetUpdated() {
        
        let timeResult = TrueTime.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getServerTime
        ])

        // Configuring responses from repositories

        mockedWebRepo.getServerTimeResponse = .success(timeResult)
        
        let deviceTimeOffsetBefore = Date.deviceTimeOffset
        let exp = XCTestExpectation(description: #function)
        sut.setDeviceTimeOffset()
        delay {
            // basic tests to check that the offset has been manipulated
            XCTAssertNotEqual(Date.deviceTimeOffset, 0, file: #file, line: #line)
            XCTAssertNotEqual(Date.deviceTimeOffset, deviceTimeOffsetBefore, file: #file, line: #line)
            self.mockedWebRepo.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }

// Pending stopping the setDeviceTimeOffset() being really called by the boot strap during testing
//    func test_unsuccessfulSetDeviceTimeOffset_deviceTimeOffsetNotUpdated() {
//
//        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
//
//        // Configuring expected actions on repositories
//
//        mockedWebRepo.actions = .init(expected: [
//            .getServerTime
//        ])
//
//        // Configuring responses from repositories
//
//        mockedWebRepo.getServerTimeResponse = .failure(networkError)
//
//        let deviceTimeOffsetBefore = Date.deviceTimeOffset
//        let exp = XCTestExpectation(description: #function)
//        sut.setDeviceTimeOffset()
//        delay {
//            // basic tests to check that the offset has NOT been manipulated
//            XCTAssertEqual(Date.deviceTimeOffset, deviceTimeOffsetBefore, file: #file, line: #line)
//            self.mockedWebRepo.verify()
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 2)
//    }
    
}

final class MentionMeCallHomeTests: UtilityServiceTests {
    
    func test_succesfulMentionMeCallHome_whenStanardResponse_returnSuccess() async {
        
        let data = ShimmedMentionMeCallHomeResponse.mockedData
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        mockedWebRepo.actions = .init(expected: [
            .mentionMeCallHome(requestType: .referee, businessOrderId: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.mentionMeCallHomeResponse = .success(data)
        
        do {
            let result = try await sut.mentionMeCallHome(requestType: .referee, businessOrderId: nil)
            XCTAssertEqual(result, data, file: #file, line: #line)
            mockedWebRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccesMentionMeCallHome_whenNetworkError_returnError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        // Configuring app prexisting states
        appState.value.userData.memberProfile = nil
        mockedWebRepo.actions = .init(expected: [
            .mentionMeCallHome(requestType: .referee, businessOrderId: nil)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.mentionMeCallHomeResponse = .failure(networkError)
        
        do {
            let result = try await sut.mentionMeCallHome(requestType: .referee, businessOrderId: nil)
            XCTFail("Unexpected result: \(result)", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
            mockedWebRepo.verify()
        }
    }
    
}
