//
//  PushNotificationsHandlerTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 29/08/2022.
//

import XCTest
import Combine
import UserNotifications

@testable import SnappyV2

class PushNotificationsHandlerTests: XCTestCase {

    func test_isCenterDelegate() {
        let sut = makeSUT()
        let center = UNUserNotificationCenter.current()
        XCTAssertTrue(center.delegate === sut)
    }
    
    func test_userNotificationCenterWillPresent_whenRestoreNotFinished_thenAddToPostponedActions() {

        let notification = makeUNNotification(userInfo: ["someKey": "someValue"])
        
        let appState = Store<AppState>(AppState())
        let sut = makeSUT(appState: appState)
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        appState
            .map(\.postponedActions.pushNotifications)
            .filter { $0.isEmpty == false }
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.userNotificationCenter(UNUserNotificationCenter.current(), willPresent: notification) { _ in }
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(
            appState.value.postponedActions.pushNotifications[0],
            PushNotification(
                notification: notification,
                willPresentCompletionHandler: { _ in },
                response: nil,
                didReceiveCompletionHandler: nil
            )
        )
    }
    
    func test_userNotificationCenterDidReceive_whenRestoreNotFinished_thenAddToPostponedActions() {

        let response = makeUNNotificationResponse(userInfo: ["someKey": "someValue"])
        
        let appState = Store<AppState>(AppState())
        let sut = makeSUT(appState: appState)
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        appState
            .map(\.postponedActions.pushNotifications)
            .filter { $0.isEmpty == false }
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) { }
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(
            appState.value.postponedActions.pushNotifications[0],
            PushNotification(
                notification: nil,
                willPresentCompletionHandler: nil,
                response: response,
                didReceiveCompletionHandler: { }
            )
        )
    }
    
    func test_userNotificationCenterDidReceive_givenEmptyPayload_thenPassToIterable() {
        
        let response = makeUNNotificationResponse(userInfo: [:])
        
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        let sut = makeSUT(appState: appState)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) { }
        
        XCTAssertEqual(
            sut.lastResponsePassedToIterable,
            response
        )
    }
    
    func test_userNotificationCenterWillPresent_givenEmptyPayload_thenCompletionHandler() {
        
        let notification = makeUNNotification(userInfo: [:])
        
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), willPresent: notification) { presentationOptions in
            XCTAssertEqual(presentationOptions, UNNotificationPresentationOptions([]))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_setupRestoreFinishedBinding_givenIncomingPushNotoficationWhileNotRestored_thenActionAfterRestored() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "imageURL": "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png",
            "link": "https://www.snappyshopper.co.uk",
            "telephone": "0333 900 1250",
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())

        let sut = makeSUT(appState: appState)
        
        var didReceiveHandlerCalled = false
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            didReceiveHandlerCalled = true
        }
        
        XCTAssertEqual(
            appState.value.postponedActions.pushNotifications[0],
            PushNotification(
                notification: nil,
                willPresentCompletionHandler: nil,
                response: response,
                didReceiveCompletionHandler: { }
            )
        )

        let exp = XCTestExpectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        appState
            .map(\.postponedActions.pushNotifications)
            .receive(on: RunLoop.main)
            .sink { pushNotifications in
                if pushNotifications.isEmpty && didReceiveHandlerCalled {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)

        // trigger the postponed push notification
        appState.value.postponedActions.restoreFinished = true

        wait(for: [exp], timeout: 2.0)
        
        XCTAssertTrue(appState.value.postponedActions.pushNotifications.isEmpty)
    }

    func test_messagePayload_setDisplayableNotification() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "imageURL": "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png",
            "link": "https://www.snappyshopper.co.uk",
            "telephone": "0333 900 1250",
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            // Note: cannot compare with DisplayablePushNotification because of the UUID
            XCTAssertEqual(
                appState.value.pushNotifications.displayableNotification?.image,
                URL(string: "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png")!
            )
            XCTAssertEqual(
                appState.value.pushNotifications.displayableNotification?.message,
                "Simple message"
            )
            XCTAssertEqual(
                appState.value.pushNotifications.displayableNotification?.link,
                URL(string: "https://www.snappyshopper.co.uk")!
            )
            XCTAssertEqual(
                appState.value.pushNotifications.displayableNotification?.telephone,
                "0333 900 1250"
            )
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
    }
    
    func test_messagePayloadWithoutSource_onlySetDisplayableNotificationIfAppConfigAllows() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "imageURL": "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png",
            "link": "https://www.snappyshopper.co.uk",
            "telephone": "0333 900 1250"
        ]
        let notification = makeUNNotification(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), willPresent: notification) { _ in
            if AppV2PushNotificationConstants.checkNotificationSource {
                XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            } else {
                XCTAssertNotNil(appState.value.pushNotifications.displayableNotification)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_messagePayloadWithoutAlert_doNotSetDisplayableNotification() {
        let userInfo: [String: Any] = [
            "aps": [],
            "imageURL": "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png",
            "link": "https://www.snappyshopper.co.uk",
            "telephone": "0333 900 1250",
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_messagePayloadWithDriverLocationFlagWithDriverMemberAndOpenMap_doNotSetDisplayableNotificationNorDriverMapOpenNotification() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "driverLocation": true,
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        appState.value.userData.memberProfile = MemberProfile.mockedDataIsDriver
        appState.value.openViews.driverLocationMap = true
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertNil(appState.value.pushNotifications.driverMapOpenNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_messagePayloadWithDriverLocationFlagWithoutDriverMemberAndNotOpenMap_setDisplayableNotificationAndDriverMapOpenNotification() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "driverLocation": true,
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.openViews.driverLocationMap = false
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertTrue(appState.value.pushNotifications.driverMapOpenNotification?.data.isEqual(to: userInfo) ?? false)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_messagePayloadWithDriverUpdateFlagWithoutDriverInterfaceAndDriverMapclosed_doNotSetDisplayableNotification() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "driverUpdate": true,
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        appState.value.openViews.driverLocationMap = false
        appState.value.openViews.driverInterface = false
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertNil(appState.value.pushNotifications.driverNotification)
            XCTAssertNil(appState.value.pushNotifications.driverMapNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_messagePayloadWithDriverUpdateFlagWithDriverInterfaceOpen_setDisplayableNotificationAndDriverNotification() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "driverUpdate": true,
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        appState.value.openViews.driverLocationMap = false
        appState.value.openViews.driverInterface = true
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            XCTAssertNotNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertTrue(appState.value.pushNotifications.driverNotification?.data.isEqual(to: userInfo) ?? false)
            XCTAssertNil(appState.value.pushNotifications.driverMapNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_messagePayloadWithDriverUpdateFlagWithDriverLocationMapOpen_doNotSetDisplayableNotificationSetDriverMapNotification() {
        let userInfo: [String: Any] = [
            "aps": [
                "alert": [
                    "body": "Simple message"
                ]
            ],
            "driverUpdate": true,
            "sendSource": "main_server"
        ]
        let response = makeUNNotificationResponse(userInfo: userInfo)
        let appState = Store<AppState>(AppState())
        appState.value.postponedActions.restoreFinished = true
        appState.value.openViews.driverLocationMap = true
        appState.value.openViews.driverInterface = false
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.userNotificationCenter(UNUserNotificationCenter.current(), didReceive: response) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertNil(appState.value.pushNotifications.driverNotification)
            XCTAssertTrue(appState.value.pushNotifications.driverMapNotification?.data.isEqual(to: userInfo) ?? false)
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    
// Example syntax for when DeepLink functionality is added
//    func test_deepLinkPayload() {
//        let mockedHandler = MockedDeepLinksHandler(expected: [
//            .open(.showCountryFlag(alpha3Code: "USA"))
//        ])
//        sut = PushNotificationsHandler(deepLinksHandler: mockedHandler)
//        let exp = XCTestExpectation(description: #function)
//        let userInfo: [String: Any] = [
//            "aps": ["country": "USA"]
//        ]
//        sut.handleNotification(userInfo: userInfo) {
//            mockedHandler.verify()
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 2.0)
//    }
    
    func makeSUT(appState: Store<AppState> = Store<AppState>(AppState()), deepLinksHandler: DeepLinksHandlerProtocol = MockedDeepLinksHandler(expected: [])) -> PushNotificationsHandler {
        let sut = PushNotificationsHandler(appState: appState, deepLinksHandler: deepLinksHandler)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    // Based on accepted answer in: https://stackoverflow.com/questions/63512441/unit-testing-unusernotificationcenterdelegate-methods
    func makeUNNotification(userInfo: [String: Any]) -> UNNotification {
        // Create the notification content
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Test"
        notificationContent.userInfo = userInfo
        
        // Create a notification request with the content
        let notificationRequest = UNNotificationRequest(
            identifier: "test",
            content: notificationContent,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        // Use private method to create a UNNotification from the request - could never be used in release code
        let selector = NSSelectorFromString("notificationWithRequest:date:")
        let unmanaged = UNNotification.perform(selector, with: notificationRequest, with: Date())
        return unmanaged?.takeUnretainedValue() as! UNNotification
    }
    
    func makeUNNotificationResponse(userInfo: [String: Any]) -> UNNotificationResponse {
        // Use private method to create a UNNotificationResponse from the request - could never be used in release code
        let selector = NSSelectorFromString("responseWithNotification:actionIdentifier:")
        let unmanaged = UNNotificationResponse.perform(selector, with: makeUNNotification(userInfo: userInfo), with: "someindentifier")
        return unmanaged?.takeUnretainedValue() as! UNNotificationResponse
    }
}
