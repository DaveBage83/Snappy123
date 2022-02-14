//
//  BasketServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class BasketServiceTests: XCTestCase {
    
    let appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedBasketWebRepository!
    var mockedDBRepo: MockedBasketDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: AddressService!

    override func setUp() {
        mockedWebRepo = MockedBasketWebRepository()
        mockedDBRepo = MockedBasketDBRepository()
        sut = AddressService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo
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
