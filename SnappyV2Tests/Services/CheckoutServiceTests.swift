//
//  CheckoutServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 06/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class CheckoutServiceTests: XCTestCase {
    
    let appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedCheckoutWebRepository!
    var mockedDBRepo: MockedCheckoutDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: CheckoutService!

    override func setUp() {
        mockedWebRepo = MockedCheckoutWebRepository()
        mockedDBRepo = MockedCheckoutDBRepository()
        sut = CheckoutService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        subscriptions = Set<AnyCancellable>()
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}
