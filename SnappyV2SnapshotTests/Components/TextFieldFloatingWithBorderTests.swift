//
//  TextFieldFloatingWithBorderTests.swift
//  SnappyV2SnapshotTests
//
//  Created by Henrik Gustavii on 26/01/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class TextFieldFloatingWithBorderTests: XCTestCase {

    func test_init() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> TextFieldFloatingWithBorder {
        TextFieldFloatingWithBorder("", text: .constant("Surname"), background: .white)
    }

}
