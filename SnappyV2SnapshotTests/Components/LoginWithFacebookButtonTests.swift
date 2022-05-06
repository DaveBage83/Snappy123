//
//  LoginWithFacebookButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 16/03/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class LoginWithFacebookButtonTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> LoginWithFacebookButton {
        LoginWithFacebookButton(viewModel: .init(container: .preview))
    }
}
