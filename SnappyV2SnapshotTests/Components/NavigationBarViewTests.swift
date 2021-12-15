//
//  NavigationBarViewTests.swift
//  SnappyV2SnapshotTests
//
//  Created by Henrik Gustavii on 02/12/2021.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class NavigationBarViewTests: XCTestCase {

    func test_init() {
        let sut = makeSUT()
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT() -> NavigationBarView {
        NavigationBarView(container: .preview, title: "ViewTitle", backButtonAction: {})
    }
}
