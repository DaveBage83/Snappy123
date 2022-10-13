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
    var mockedUserDefaultsRepo: MockedUserPermissionsUserDefaultsRepository!
    var sut: UserPermissionsService!
    
    override func setUp() {
        mockedUserDefaultsRepo = MockedUserPermissionsUserDefaultsRepository()
    }

    override func tearDown() {
        mockedUserDefaultsRepo = nil
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    func test_noSideEffectOnInit() {
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {
            XCTFail(file: #file, line: #line)
        }
        delay {
            // We have had to remove the conformity of AppState to equatable
//            XCTAssertEqual(self.state.value, AppState(), file: #file, line: #line)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        mockedUserDefaultsRepo.verify()
    }
    
    // MARK: - Push
    
    #warning("Needs fixing - UNUserNotificationCenter needs extending with a protocol so it can be mocked")
//    func test_pushFirstResolveStatus() {
//        XCTAssertEqual(AppState().permissions.push, .unknown)
//        let exp = XCTestExpectation(description: #function)
//        mockedUserDefaultsRepo.actions = .init(expected: [.setUserChoseNoNotifications(to: false)])
//        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {
//            XCTFail(file: #file, line: #line)
//        }
//        sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
//        delay {
//            XCTAssertNotEqual(self.state.value.permissions.push, .unknown, file: #file, line: #line)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 2)
//        mockedUserDefaultsRepo.verify()
//    }
//
//    func test_pushSecondResolveStatus() {
//        XCTAssertEqual(AppState().permissions.push, .unknown)
//        let exp = XCTestExpectation(description: #function)
//        mockedUserDefaultsRepo.actions = .init(expected: [.setUserChoseNoNotifications(to: false)])
//        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {
//            XCTFail(file: #file, line: #line)
//        }
//        sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
//        delay {
//            self.sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
//            XCTAssertNotEqual(self.state.value.permissions.push, .unknown, file: #file, line: #line)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 2)
//        mockedUserDefaultsRepo.verify()
//    }
    
    func test_pushRequestPermissionNotDetermined() {
        state[\.permissions.push] = .notRequested
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {
            XCTFail(file: #file, line: #line)
        }
        sut.request(permission: .pushNotifications)
        delay {
            XCTAssertNotEqual(self.state.value.permissions.push, .unknown, file: #file, line: #line)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_pushRequestPermissionDenied() {
        state[\.permissions.push] = .denied
        let exp = XCTestExpectation(description: #function)
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {
            XCTAssertEqual(self.state.value.permissions.push, .denied, file: #file, line: #line)
            exp.fulfill()
        }
        sut.request(permission: .pushNotifications)
        wait(for: [exp], timeout: 0.5)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_authorizationStatusMapping() {
        XCTAssertEqual(UNAuthorizationStatus.notDetermined.map, .notRequested, file: #file, line: #line)
        XCTAssertEqual(UNAuthorizationStatus.provisional.map, .notRequested, file: #file, line: #line)
        XCTAssertEqual(UNAuthorizationStatus.denied.map, .denied, file: #file, line: #line)
        XCTAssertEqual(UNAuthorizationStatus.authorized.map, .granted, file: #file, line: #line)
        XCTAssertEqual(UNAuthorizationStatus(rawValue: 10)?.map, .notRequested, file: #file, line: #line)
    }
    
    func test_pushNotificationPreferencesRequired_whenUserChoseNoNotifications_returnFalse() {
        mockedUserDefaultsRepo.actions = .init(expected: [.userChoseNoNotifications])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userChoseNoNotificationsResponse = true
        XCTAssertFalse(sut.pushNotificationPreferencesRequired, file: #file, line: #line)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_pushNotificationPreferencesRequired_whenUserHasNotChoseNoNotificationsButHasAlreadyChosenMarketingPreference_returnFalse() {
        mockedUserDefaultsRepo.actions = .init(expected: [.userChoseNoNotifications, .userPushNotificationMarketingSelection])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userChoseNoNotificationsResponse = false
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .optIn
        XCTAssertFalse(sut.pushNotificationPreferencesRequired, file: #file, line: #line)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_pushNotificationPreferencesRequired_whenUserHasNotChoseNoNotificationsAndHasNotAlreadyChosenMarketingPreference_returnTrue() {
        mockedUserDefaultsRepo.actions = .init(expected: [.userChoseNoNotifications, .userPushNotificationMarketingSelection])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userChoseNoNotificationsResponse = false
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .undecided
        XCTAssertTrue(sut.pushNotificationPreferencesRequired, file: #file, line: #line)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_unsavedPushNotificationPreferences_whenUnsavedSelectionNotEqualToCurrentSelection_returnTrue() {
        mockedUserDefaultsRepo.actions = .init(expected: [.userPushNotificationMarketingSelection, .userPushNotificationMarketingRegisteredSelection])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .optIn
        mockedUserDefaultsRepo.userPushNotificationMarketingRegisteredSelectionResponse = .undecided
        XCTAssertTrue(sut.unsavedPushNotificationPreferences, file: #file, line: #line)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_unsavedPushNotificationPreferences_whenUnsavedSelectionEqualToCurrentSelection_returnFalse() {
        mockedUserDefaultsRepo.actions = .init(expected: [.userPushNotificationMarketingSelection, .userPushNotificationMarketingRegisteredSelection])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .optIn
        mockedUserDefaultsRepo.userPushNotificationMarketingRegisteredSelectionResponse = .optIn
        XCTAssertFalse(sut.unsavedPushNotificationPreferences, file: #file, line: #line)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_userDoesNotWantPushNotifications() {
        mockedUserDefaultsRepo.actions = .init(expected: [.userChoseNoNotifications])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userChoseNoNotificationsResponse = true
        XCTAssertTrue(sut.userDoesNotWantPushNotifications, file: #file, line: #line)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_userPushNotificationMarketingSelection() {
        mockedUserDefaultsRepo.actions = .init(expected: [.userPushNotificationMarketingSelection])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .optOut
        XCTAssertEqual(sut.userPushNotificationMarketingSelection, .optOut, file: #file, line: #line)
        mockedUserDefaultsRepo.verify()
    }

    func test_setUserDoesNotWantPushNotifications() {
        mockedUserDefaultsRepo.actions = .init(expected: [.setUserChoseNoNotifications(to: true)])
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.setUserChoseNoNotifications(to: true)
        mockedUserDefaultsRepo.verify()
    }

    func test_setSavedPushNotificationMarketingSelection() {
        mockedUserDefaultsRepo.actions = .init(
            expected: [
                .userPushNotificationMarketingSelection,
                .setUserPushNotificationMarketingRegisteredSelection(to: .optIn)
            ]
        )
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .optIn
        sut.setSavedPushNotificationMarketingSelection()
        mockedUserDefaultsRepo.verify()
    }
    
    func test_setPushNotificationMarketingSelection_whenNoChange() {
        mockedUserDefaultsRepo.actions = .init(
            expected: [
                .userPushNotificationMarketingSelection
            ]
        )
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .optIn
        sut.setPushNotificationMarketingSelection(to: .optIn)
        mockedUserDefaultsRepo.verify()
    }
    
    func test_setPushNotificationMarketingSelection_whenChange() {
        mockedUserDefaultsRepo.actions = .init(
            expected: [
                .userPushNotificationMarketingSelection,
                .setUserPushNotificationMarketingSelection(to: .optIn)
            ]
        )
        sut = UserPermissionsService(userDefaultsRepository: mockedUserDefaultsRepo, appState: state) {}
        mockedUserDefaultsRepo.userPushNotificationMarketingSelectionResponse = .optOut
        sut.setPushNotificationMarketingSelection(to: .optIn)
        mockedUserDefaultsRepo.verify()
    }
    
    // MARK: - Stub
    
    func test_stubUserPermissionsService() {
        let sut = StubUserPermissionsService()
        sut.request(permission: .pushNotifications)
        sut.resolveStatus(for: .pushNotifications, reconfirmIfKnown: true)
    }
}

