//
//  UserPermissionsServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 05/09/2022.
//

import XCTest
import Combine

@testable import SnappyV2

class UserPermissionsServiceTests: XCTestCase {
    
    var state = Store<AppState>(AppState())
    var sut: UserPermissionsService!
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    func test_noSideEffectOnInit() {
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(appState: state) {
            XCTFail()
        }
        delay {
            XCTAssertEqual(self.state.value, AppState())
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - Push
    
    func test_pushFirstResolveStatus() {
        XCTAssertEqual(AppState().permissions.push, .unknown)
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(appState: state) {
            XCTFail()
        }
        sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
        delay {
            XCTAssertNotEqual(self.state.value.permissions.push, .unknown)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_pushSecondResolveStatus() {
        XCTAssertEqual(AppState().permissions.push, .unknown)
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(appState: state) {
            XCTFail()
        }
        sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
        delay {
            self.sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
            XCTAssertNotEqual(self.state.value.permissions.push, .unknown)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_pushRequestPermissionNotDetermined() {
        state[\.permissions.push] = .notRequested
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(appState: state) {
            XCTFail()
        }
        sut.request(permission: .pushNotifications)
        delay {
            XCTAssertNotEqual(self.state.value.permissions.push, .unknown)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_pushRequestPermissionDenied() {
        state[\.permissions.push] = .denied
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(appState: state) {
            XCTAssertEqual(self.state.value.permissions.push, .denied)
            exp.fulfill()
        }
        sut.request(permission: .pushNotifications)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_authorizationStatusMapping() {
        XCTAssertEqual(UNAuthorizationStatus.notDetermined.map, .notRequested)
        XCTAssertEqual(UNAuthorizationStatus.provisional.map, .notRequested)
        XCTAssertEqual(UNAuthorizationStatus.denied.map, .denied)
        XCTAssertEqual(UNAuthorizationStatus.authorized.map, .granted)
        XCTAssertEqual(UNAuthorizationStatus(rawValue: 10)?.map, .notRequested)
    }
    
    // MARK: - Stub
    
    func test_stubUserPermissionsService() {
        let sut = StubUserPermissionsService()
        sut.request(permission: .pushNotifications)
        sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
    }
}

