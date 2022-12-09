//
//  NotificationServiceTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 14/04/2022.
//

import Foundation
import Combine
@testable import SnappyV2
import XCTest

class NotificationServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var sut: NotificationService!
    
    override func setUp() {
        sut = NotificationService(
            appState: appState
        )
    }
    
    override func tearDown() {
        sut = nil
    }
}

