//
//  PushNotificationViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 04/09/2022.
//

import XCTest
@testable import SnappyV2

@MainActor
class PushNotificationViewModelTests: XCTestCase {

    func test_options_whenOnlyMessageText() {
        let simpleMessage = DisplayablePushNotification.mockedSimpleMessageData
        let sut = makeSUT(notification: simpleMessage)
        XCTAssertEqual(sut.notification, simpleMessage, file: #file, line: #line)
        XCTAssertEqual(sut.options.count, 0, file: #file, line: #line)
    }
    
    func test_options_whenAllOptionsMessageText() {
        let allOptionsMessage = DisplayablePushNotification.mockedAllOptionsMessageData
        let sut = makeSUT(notification: allOptionsMessage)
        XCTAssertEqual(sut.notification, allOptionsMessage, file: #file, line: #line)
        if sut.options.count == 2 {
            // link option
            let firstOption = sut.options[0]
            XCTAssertEqual(firstOption.title, Strings.PushNotifications.openLink.localized)
            XCTAssertEqual(firstOption.linkURL, allOptionsMessage.link, file: #file, line: #line)
            // call option
            let secondOption = sut.options[1]
            XCTAssertEqual(secondOption.title, Strings.PushNotifications.call.localized)
            let phoneNumber = "tel:" + String(allOptionsMessage.telephone!.filter{Set("0123456789").contains($0)})
            XCTAssertEqual(secondOption.linkURL, URL(string: phoneNumber)!, file: #file, line: #line)
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }
    
    func test_linkOptionHandlerWhenActionUsed_thenDismissCallHandler() {
        let linkedOptionMessage = DisplayablePushNotification.mockedLinkedOptionMessageData
        var handlerCalled = false
        let sut = makeSUT(notification: linkedOptionMessage) {
            handlerCalled = true
        }
        XCTAssertEqual(sut.notification, linkedOptionMessage, file: #file, line: #line)
        if sut.options.count == 1 {
            // link option
            let linkOption = sut.options[0]
            linkOption.action(true)
            XCTAssertEqual(linkOption.title, Strings.PushNotifications.openLink.localized, file: #file, line: #line)
            XCTAssertEqual(linkOption.linkURL, linkedOptionMessage.link, file: #file, line: #line)
            XCTAssertTrue(handlerCalled, file: #file, line: #line)
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }
    
    func test_telephoneHandlerWhenActionUsedAndCallSuccessful_thenDismissCallHandler() {
        let callOptionMessage = DisplayablePushNotification.mockedCallOptionMessageData
        var handlerCalled = false
        let sut = makeSUT(notification: callOptionMessage) {
            handlerCalled = true
        }
        XCTAssertEqual(sut.notification, callOptionMessage, file: #file, line: #line)
        if sut.options.count == 1 {
            // link option
            let callOption = sut.options[0]
            callOption.action(true)
            XCTAssertEqual(callOption.title, Strings.PushNotifications.call.localized)
            let phoneNumber = "tel:" + String(callOptionMessage.telephone!.filter{Set("0123456789").contains($0)})
            XCTAssertEqual(callOption.linkURL, URL(string: phoneNumber)!, file: #file, line: #line)
            XCTAssertTrue(handlerCalled, file: #file, line: #line)
            // A succesful call link action means no display alert for the number is required
            XCTAssertFalse(sut.showCallInformationAlert, file: #file, line: #line)
            XCTAssertEqual(sut.showTelephoneNumber, "", file: #file, line: #line)
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }
    
    func test_telephoneHandlerWhenActionUsedAndCallUnsuccessful_thenDisplayTelephone() {
        let callOptionMessage = DisplayablePushNotification.mockedCallOptionMessageData
        var handlerCalled = false
        let sut = makeSUT(notification: callOptionMessage) {
            handlerCalled = true
        }
        XCTAssertEqual(sut.notification, callOptionMessage, file: #file, line: #line)
        if sut.options.count == 1 {
            // link option
            let callOption = sut.options[0]
            callOption.action(false)
            XCTAssertEqual(callOption.title, Strings.PushNotifications.call.localized)
            let phoneNumber = "tel:" + String(callOptionMessage.telephone!.filter{Set("0123456789").contains($0)})
            XCTAssertEqual(callOption.linkURL, URL(string: phoneNumber)!, file: #file, line: #line)
            XCTAssertFalse(handlerCalled, file: #file, line: #line)
            // A failed call link (e.g. iPodTouch, iPad) action means a display alert
            // for the number is required
            XCTAssertTrue(sut.showCallInformationAlert, file: #file, line: #line)
            XCTAssertEqual(sut.showTelephoneNumber, callOptionMessage.telephone!, file: #file, line: #line)
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }

    func makeSUT(
        notification: DisplayablePushNotification,
        dismissPushNotificationViewHandler: @escaping ()->() = {}
    ) -> PushNotificationViewModel {
        let sut = PushNotificationViewModel(
            container: DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()),
            notification: notification,
            dismissPushNotificationViewHandler: dismissPushNotificationViewHandler
        )
        trackForMemoryLeaks(sut)
        return sut
    }

}

