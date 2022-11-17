//
//  PushNotificationViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 04/09/2022.
//

import XCTest
@testable import SnappyV2

@MainActor
final class PushNotificationViewModelTests: XCTestCase {

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
        if sut.options.count == 3 {
            // link option
            let firstOption = sut.options[0]
            XCTAssertEqual(firstOption.title, Strings.PushNotifications.openLink.localized)
            XCTAssertEqual(firstOption.linkURL, allOptionsMessage.link, file: #file, line: #line)
            // call option
            let secondOption = sut.options[1]
            XCTAssertEqual(secondOption.title, Strings.PushNotifications.call.localized)
            let phoneNumber = "tel:" + String(allOptionsMessage.telephone!.filter{Set("0123456789").contains($0)})
            XCTAssertEqual(secondOption.linkURL, URL(string: phoneNumber)!, file: #file, line: #line)
            // view updated order option
            let thirdOption = sut.options[2]
            XCTAssertEqual(thirdOption.title, Strings.PushNotifications.viewUpdatedOrder.localized)
            XCTAssertNil(thirdOption.linkURL, file: #file, line: #line)
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }
    
    func test_linkOptionHandlerWhenActionUsed_thenDismissCallHandler() {
        let linkedOptionMessage = DisplayablePushNotification.mockedLinkedOptionMessageData
        var handlerCalled = false
        let sut = makeSUT(notification: linkedOptionMessage) { displayAction in
            XCTAssertNil(displayAction, file: #file, line: #line)
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
        let sut = makeSUT(notification: callOptionMessage) { displayAction in
            XCTAssertNil(displayAction, file: #file, line: #line)
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
        let sut = makeSUT(notification: callOptionMessage) { displayAction in
            XCTAssertNil(displayAction, file: #file, line: #line)
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
    
    func test_viewUpdatedOrderHandlerWhenActionUsedAndFetchOrderSuccessful_thenDisplayActionHasTheOrder() async {
        let viewUpdatedOrderMessage = DisplayablePushNotification.mockedViewUpdatedOrderMessageData
        let order = PlacedOrder.mockedData
        var handlerCalled = false
        let checkoutService = MockedCheckoutService(expected: [
            .getOrder(forBusinessOrderId: viewUpdatedOrderMessage.businessOrderId ?? 0, withHash: viewUpdatedOrderMessage.hash ?? "")
        ])
        checkoutService.getOrderResult = .success(order)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let sut = makeSUT(notification: viewUpdatedOrderMessage, services: services) { displayAction in
            XCTAssertEqual(displayAction, PushNotificationDismissDisplayAction(showOrder: order), file: #file, line: #line)
            handlerCalled = true
        }
        XCTAssertEqual(sut.notification, viewUpdatedOrderMessage, file: #file, line: #line)
        if sut.options.count == 1 {
            // view order option
            let viewUpdatedOrderOption = sut.options[0]
            // set up the internal sut 'orderToShow' variable
            let getOrderSuccess = await sut.getOrder(forOption: viewUpdatedOrderOption.id)
            XCTAssertTrue(getOrderSuccess, file: #file, line: #line)
            // the sut internal 'orderToShow' variable is now used and comes through the 'displayAction' above
            viewUpdatedOrderOption.action(true)
            XCTAssertEqual(viewUpdatedOrderOption.title, Strings.PushNotifications.viewUpdatedOrder.localized)
            XCTAssertNil(viewUpdatedOrderOption.linkURL, file: #file, line: #line)
            XCTAssertTrue(handlerCalled, file: #file, line: #line)
            checkoutService.verify()
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }
    
    func test_viewUpdatedOrderHandlerWhenActionUsedAndFetchOrderUnsuccessful_thenDisplayActionOrderIsNil() {
        let viewUpdatedOrderMessage = DisplayablePushNotification.mockedViewUpdatedOrderMessageData
        var handlerCalled = false
        let sut = makeSUT(notification: viewUpdatedOrderMessage) { displayAction in
            XCTAssertNil(displayAction, file: #file, line: #line)
            handlerCalled = true
        }
        XCTAssertEqual(sut.notification, viewUpdatedOrderMessage, file: #file, line: #line)
        if sut.options.count == 1 {
            // view updated order option
            let viewUpdatedOrderOption = sut.options[0]
            viewUpdatedOrderOption.action(false)
            XCTAssertEqual(viewUpdatedOrderOption.title, Strings.PushNotifications.viewUpdatedOrder.localized)
            XCTAssertNil(viewUpdatedOrderOption.linkURL, file: #file, line: #line)
            XCTAssertFalse(handlerCalled, file: #file, line: #line)
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }
    
    func test_getOrder_whenNoBusinessOrderIdAndHashInNotification_thenReturnFalse() async {
        // use a notifaction that is not an order update
        let callOptionMessage = DisplayablePushNotification.mockedCallOptionMessageData
        let sut = makeSUT(notification: callOptionMessage)
        XCTAssertEqual(sut.notification, callOptionMessage, file: #file, line: #line)
        if sut.options.count == 1 {
            let callOptionMessageOption = sut.options[0]
            let getOrderSuccess = await sut.getOrder(forOption: callOptionMessageOption.id)
            XCTAssertFalse(getOrderSuccess, file: #file, line: #line)
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }
    
    func test_getOrder_whenNetworkError_thenReturnFalse() async {
        let viewUpdatedOrderMessage = DisplayablePushNotification.mockedViewUpdatedOrderMessageData
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let checkoutService = MockedCheckoutService(expected: [
            .getOrder(forBusinessOrderId: viewUpdatedOrderMessage.businessOrderId ?? 0, withHash: viewUpdatedOrderMessage.hash ?? "")
        ])
        checkoutService.getOrderResult = .failure(networkError)
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: checkoutService,
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let sut = makeSUT(notification: viewUpdatedOrderMessage, services: services)
        XCTAssertEqual(sut.notification, viewUpdatedOrderMessage, file: #file, line: #line)
        if sut.options.count == 1 {
            let viewUpdatedOrderOption = sut.options[0]
            let getOrderSuccess = await sut.getOrder(forOption: viewUpdatedOrderOption.id)
            XCTAssertFalse(getOrderSuccess, file: #file, line: #line)
            checkoutService.verify()
        } else {
            XCTFail("Incorrect number of options", file: #file, line: #line)
        }
    }

    func makeSUT(
        notification: DisplayablePushNotification,
        services: DIContainer.Services = .mocked(),
        dismissPushNotificationViewHandler: @escaping (PushNotificationDismissDisplayAction?)->() = { _ in }
    ) -> PushNotificationViewModel {
        let sut = PushNotificationViewModel(
            container: DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services),
            notification: notification,
            dismissPushNotificationViewHandler: dismissPushNotificationViewHandler
        )
        trackForMemoryLeaks(sut)
        return sut
    }

}

