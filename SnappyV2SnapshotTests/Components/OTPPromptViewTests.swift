//
//  OTPPromptViewTests.swift
//  SnappyV2SnapshotTests
//
//  Created by Henrik Gustavii on 20/07/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

@MainActor
class OTPPromptViewTests: XCTestCase {
    
    func _test_init() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _test_showCodeEntry() {
        let sut = makeSUT()
        sut.viewModel.showOTPCodePrompt = true
        
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> OTPPromptView {
        OTPPromptView(viewModel: .init(container: .preview, email: "email@domain.com", otpTelephone: "0987654321", isInCheckout: false, dismiss: {}))
    }
    
}

