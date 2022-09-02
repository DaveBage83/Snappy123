//
//  AppDelegateTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 31/08/2022.
//

import XCTest
import UIKit
@testable import SnappyV2

final class AppDelegateTests: XCTestCase {
    
    private var sut: AppDelegate!
    
    override func setUp() {
        AppDelegate.orientationLock = UIInterfaceOrientationMask.all
        sut = AppDelegate()
    }

    func test_didFinishLaunching() {
        let eventsHandler = MockedSystemEventsHandler(expected: [])
        sut.systemEventsHandler = eventsHandler
        _ = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
        eventsHandler.verify()
    }
    
    func test_pushRegistration() {
        let eventsHandler = MockedSystemEventsHandler(expected: [
            .pushRegistration, .pushRegistration
        ])
        sut.systemEventsHandler = eventsHandler
        sut.application(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: Data())
        sut.application(UIApplication.shared, didFailToRegisterForRemoteNotificationsWithError: NSError.test)
        eventsHandler.verify()
    }
    
    func test_supportedInterfaceOrientationsFor() {
        AppDelegate.orientationLock = .landscape
        XCTAssertEqual(sut.application(UIApplication.shared, supportedInterfaceOrientationsFor: nil), .landscape)
    }
}
