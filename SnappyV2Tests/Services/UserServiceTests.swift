//
//  UserServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 10/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class UserServiceTests: XCTestCase {
    
    let appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedUserWebRepository!
    var mockedDBRepo: MockedUserDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: UserService!

    override func setUp() {
        mockedWebRepo = MockedUserWebRepository()
        mockedDBRepo = MockedUserDBRepository()
        sut = UserService(
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
