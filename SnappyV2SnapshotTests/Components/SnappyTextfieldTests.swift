//
//  SnappyTextfieldTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 19/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class SnappyTextfieldTests: XCTestCase {
    func _testinit_standardTextFieldNoErrorNotDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: false, hasError: false, fieldType: .standardTextfield)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardTextFieldWithErrorNotDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: false, hasError: true, fieldType: .standardTextfield)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_standardTextFieldNoErrorIsDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: true, hasError: false, fieldType: .standardTextfield)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_secureTextFieldNoErrorNotDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: false, hasError: false, fieldType: .secureTextfield)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_secureTextFieldWithErrorNotDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: false, hasError: true, fieldType: .secureTextfield)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_secureTextFieldNoErrorIsDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: true, hasError: false, fieldType: .secureTextfield)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_labelTextFieldNoErrorNotDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: false, hasError: false, fieldType: .label)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_labelTextFieldWithErrorNotDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: false, hasError: true, fieldType: .label)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func _testinit_labelTextFieldNoErrorIsDisabledNoBgColor() {
        let sut = makeSUT(isDisabled: true, hasError: false, fieldType: .label)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }

    func makeSUT(isDisabled: Bool, hasError: Bool, bgColor: Color = .clear, fieldType: SnappyTextfield.FieldType) -> SnappyTextfield {
        SnappyTextfield(container: .preview, text: .constant(""), isDisabled: .constant(isDisabled), hasError: .constant(hasError), labelText: "Address", largeTextLabelText: nil, bgColor: bgColor, fieldType: fieldType)
    }
}
