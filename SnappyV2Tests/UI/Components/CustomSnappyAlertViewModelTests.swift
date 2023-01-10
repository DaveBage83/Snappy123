//
//  CustomSnappyAlertViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 09/01/2023.
//

import Foundation

import XCTest
@testable import SnappyV2
import SwiftUI
import Combine

class CustomSnappyAlertViewModelTests: XCTestCase {
    
    func test_whenButtonsNotPresent_thenUseVerticalButtonStackIsFalse() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: nil)
        XCTAssertFalse(sut.useVerticalButtonStack)
    }
    
    func test_whenButtonsAREPresent_givenTextFieldIsNotPresentAndButtonsCountIsNotGreatThan2_thenUseVerticalButtonStackIsFalse() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [.init(title: "test", action: {})])
        XCTAssertFalse(sut.useVerticalButtonStack)
    }
    
    func test_whenButtonsAREPresent_givenLongButtonTextTrue_thenUseVerticalButtonStackIsTrue() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [.init(title: "testing1234", action: {})])
        XCTAssertTrue(sut.useVerticalButtonStack)
    }
    
    func test_whenButtonsAREPresent_givenTextFieldIsNotPresentAndButtonsCountISGreatThan2_thenUseVerticalButtonStackIsTrue() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [
            .init(title: "test", action: {}),
            .init(title: "test", action: {}),
            .init(title: "test", action: {})
        ])
        XCTAssertTrue(sut.useVerticalButtonStack)
    }
    
    func test_whenButtonsAREPresent_givenTextFieldISPresentAndButtonsCountIsNotGreaterThan1_thenUseVerticalButtonStackIsFalse() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            textField: .init(placeholder: "test", minCharacters: nil, submitButton: .init(title: "test")),
            buttons: [
            .init(title: "test", action: {})
        ])
        XCTAssertFalse(sut.useVerticalButtonStack)
    }
    
    func test_whenTextfieldNotPresent_thenInvalidFieldEntryIsFalse() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: nil)
        XCTAssertFalse(sut.invalidFieldEntry)
    }
    
    func test_whenTextfieldISPresent_givenNoMinCharacters_thenInvalidFieldEntryIsFalse() {
        let sut = makeSUT(title: "test", prompt: "test", textField: .init(placeholder: "test", minCharacters: nil, submitButton: nil), buttons: nil)
        XCTAssertFalse(sut.invalidFieldEntry)
    }
    
    func test_whenTextfieldISPresent_givenMinCharactersPresent_thenInvalidFieldEntryReactsAccordingly() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            textField: .init(placeholder: "test",
                             minCharacters: 4,
                             submitButton: nil),
            buttons: nil)
        XCTAssertTrue(sut.invalidFieldEntry)
        sut.textfieldContent = "123"
        XCTAssertTrue(sut.invalidFieldEntry)
        sut.textfieldContent = "1234"
        XCTAssertFalse(sut.invalidFieldEntry)
    }
    
    func test_whenButtonsAREPresent_givenTextFieldISPresentAndButtonsCountISGreaterThan1_thenUseVerticalButtonStackIsTrue() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            textField: .init(placeholder: "test", minCharacters: nil, submitButton: .init(title: "test")),
            buttons: [
                .init(title: "test", action: {}),
                .init(title: "test", action: {})
            ])
        XCTAssertTrue(sut.useVerticalButtonStack)
    }
    
    func test_whenButtonsNotPresent_thenTotalButtonsIs0() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: nil)
        XCTAssertEqual(sut.totalButtons, 0)
    }
    
    func test_whenButtonsAREPresent_givenNoTextfield_thenTotalButtonsIsTotalNumberOfActionButtons() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [
            .init(title: "test", action: {}),
            .init(title: "test", action: {})
        ])
        XCTAssertEqual(sut.totalButtons, 2)
    }
    
    func test_whenButtonsAREPresent_givenTextfieldISPresentAndHasSubmitButton_thenTotalButtonsIsTotalNumberOfActionButtonsPlusSubmitButton() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            textField: .init(placeholder: "test", minCharacters: nil, submitButton: .init(title: "Test")),
            buttons: [
            .init(title: "test", action: {}),
            .init(title: "test", action: {})
        ])
        XCTAssertEqual(sut.totalButtons, 3)
    }
    
    func test_whenButtonsAREPresent_givenTextfieldISPresentAndHasNOSubmitButton_thenTotalButtonsIsTotalNumberOfActionButtons() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            textField: .init(placeholder: "test", minCharacters: nil, submitButton: nil),
            buttons: [
            .init(title: "test", action: {}),
            .init(title: "test", action: {})
        ])
        XCTAssertEqual(sut.totalButtons, 2)
    }
    
    func test_whenNoButtons_thenNoActionButtonsTrue() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: nil)
        XCTAssertTrue(sut.noActionButtons)
    }
    
    func test_whenButtonsArrayEmpty_thenNoActionButtonsTrue() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [])
        XCTAssertTrue(sut.noActionButtons)
    }
    
    func test_whenButtonsArrayNotEmpty_thenNoActionButtonsTrue() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [.init(title: "test", action: {})])
        XCTAssertFalse(sut.noActionButtons)
    }
    
    func test_whenUseVerticalButtonStackTrue_givenButtonIndexDoesNotEqualOneLessThanTotalButtons_thenAddDividerIsTrue() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            buttons: [
                .init(title: "test", action: {}),
                .init(title: "test", action: {}),
                .init(title: "test", action: {})
            ])
        
        let addDivider = sut.addDivider(buttonIndex: 1)
        XCTAssertTrue(addDivider)
    }
    
    func test_whenUseVerticalButtonStackTrue_givenButtonIndexISEqualToOneLessThanTotalButtons_thenAddDividerIsFalse() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            buttons: [
                .init(title: "test", action: {}),
                .init(title: "test", action: {}),
                .init(title: "test", action: {})
            ])
        
        let addDivider = sut.addDivider(buttonIndex: 2)
        XCTAssertFalse(addDivider)
    }
    
    func test_whenUseVerticalButtonStackFalse_givenButtonIndexIS0ButTotalButtonsIsNot2_thenAddDividerIsFalse() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            buttons: [
                .init(title: "test", action: {})
            ])
        
        let addDivider = sut.addDivider(buttonIndex: 0)
        XCTAssertFalse(addDivider)
    }
    
    func test_whenUseVerticalButtonStackFalse_givenButtonIndexIS0ButTotalButtonsIS2_thenAddDividerIsFalse() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            buttons: [
                .init(title: "test", action: {}),
                .init(title: "test", action: {})
            ])
        
        let addDivider = sut.addDivider(buttonIndex: 0)
        XCTAssertTrue(addDivider)
    }
    
    func test_whenButtonTextMoreThan10Characters_thenLongButtonTextIsTrue() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [
            .init(title: "testing1234", action: {}),
            .init(title: "test", action: {})
        ])
        XCTAssertTrue(sut.longButtonText)
    }
    
    func test_whenButtonTextLessThan10Characters_thenLongButtonTextIsFalse() {
        let sut = makeSUT(title: "test", prompt: "test", buttons: [
            .init(title: "test", action: {}),
            .init(title: "test", action: {})
        ])
        XCTAssertFalse(sut.longButtonText)
    }
    
    func test_whenSubmitButtonTextMoreThan10Characters_thenLongButtonTextIsTrue() {
        let sut = makeSUT(
            title: "test",
            prompt: "test",
            textField: .init(placeholder: "test", minCharacters: nil, submitButton: .init(title: "testing12345")),
            buttons: [
                .init(title: "testing", action: {}),
                .init(title: "test", action: {})
            ])
        XCTAssertTrue(sut.longButtonText)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), title: String, prompt: String, textField: AlertTextField? = nil, buttons: [AlertActionButton]?) -> CustomSnappyAlertViewModel {
        let sut = CustomSnappyAlertViewModel(
            container: container,
            title: title,
            prompt: prompt,
            textField: textField,
            buttons: buttons)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
