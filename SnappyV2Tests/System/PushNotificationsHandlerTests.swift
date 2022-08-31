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

    func test_emptyPayload_didReceiveCompletionHandler() {
        let sut = makeSUT()
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: [:],
            willPresentCompletionHandler: nil
        ) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_emptyPayload_willPresentCompletionHandler() {
        let sut = makeSUT()
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: [:],
            willPresentCompletionHandler: { presentationOptions in
                XCTAssertEqual(presentationOptions, UNNotificationPresentationOptions([]))
                exp.fulfill()
            },
            didReceiveCompletionHandler: nil
        )
        wait(for: [exp], timeout: 0.1)
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
        let appState = Store<AppState>(AppState())
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
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
        wait(for: [exp], timeout: 0.1)
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
        let appState = Store<AppState>(AppState())
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
            if AppV2PushNotificationConstants.checkNotificationSource {
                XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            } else {
                XCTAssertNotNil(appState.value.pushNotifications.displayableNotification)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_messagePayloadWithoutAlert_doNotSetDisplayableNotification() {
        let userInfo: [String: Any] = [
            "aps": [],
            "imageURL": "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png",
            "link": "https://www.snappyshopper.co.uk",
            "telephone": "0333 900 1250",
            "sendSource": "main_server"
        ]
        let appState = Store<AppState>(AppState())
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
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
        let appState = Store<AppState>(AppState())
        appState.value.userData.memberProfile = MemberProfile.mockedDataIsDriver
        appState.value.openViews.driverLocationMap = true
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertNil(appState.value.pushNotifications.driverMapOpenNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
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
        let appState = Store<AppState>(AppState())
        appState.value.userData.memberProfile = MemberProfile.mockedData
        appState.value.openViews.driverLocationMap = false
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertTrue(appState.value.pushNotifications.driverMapOpenNotification?.isEqual(to: userInfo) ?? false)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
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
        let appState = Store<AppState>(AppState())
        appState.value.openViews.driverLocationMap = false
        appState.value.openViews.driverInterface = false
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertNil(appState.value.pushNotifications.driverNotification)
            XCTAssertNil(appState.value.pushNotifications.driverMapNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
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
        let appState = Store<AppState>(AppState())
        appState.value.openViews.driverLocationMap = false
        appState.value.openViews.driverInterface = true
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
            XCTAssertNotNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertTrue(appState.value.pushNotifications.driverNotification?.isEqual(to: userInfo) ?? false)
            XCTAssertNil(appState.value.pushNotifications.driverMapNotification)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
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
        let appState = Store<AppState>(AppState())
        appState.value.openViews.driverLocationMap = true
        appState.value.openViews.driverInterface = false
        
        let sut = makeSUT(appState: appState)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(
            userInfo: userInfo,
            willPresentCompletionHandler: nil
        ) {
            XCTAssertNil(appState.value.pushNotifications.displayableNotification)
            XCTAssertNil(appState.value.pushNotifications.driverNotification)
            XCTAssertTrue(appState.value.pushNotifications.driverMapNotification?.isEqual(to: userInfo) ?? false)
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
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
//        wait(for: [exp], timeout: 0.1)
//    }
    
    func makeSUT(appState: Store<AppState> = Store<AppState>(AppState()), deepLinksHandler: DeepLinksHandlerProtocol = MockedDeepLinksHandler(expected: [])) -> PushNotificationsHandler {
        let sut = PushNotificationsHandler(appState: appState, deepLinksHandler: deepLinksHandler)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
