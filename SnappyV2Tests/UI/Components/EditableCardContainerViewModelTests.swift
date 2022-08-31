//
//  EditableCardContainerViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 02/08/2022.
//

import XCTest
@testable import SnappyV2

class EditableCardContainerViewModelTests: XCTestCase {
    func test_whenEditActionNotNil_thenShowEditButtonIsTrue() {
        let sut = makeSUT(container: .preview, editAction: {}, deleteAction: nil)
        XCTAssertTrue(sut.showEditButton)
    }
    
    func test_whenEditActionIsNil_thenShowEditButtonIsFalse() {
        let sut = makeSUT(container: .preview, editAction: nil, deleteAction: nil)
        XCTAssertFalse(sut.showEditButton)
    }
    
    func test_whenDeleteActionNotNil_thenShowDeleteButtonIsTrue() {
        let sut = makeSUT(container: .preview, editAction: nil, deleteAction: {})
        XCTAssertTrue(sut.showDeleteButton)
    }
    
    func test_whenDeleteActionIsNil_thenShowDeleteButtonIsFalse() {
        let sut = makeSUT(container: .preview, editAction: nil, deleteAction: nil)
        XCTAssertFalse(sut.showDeleteButton)
    }
    
    func test_whenEditAndDeleteButtonsPresent_thenIncludeMiddleButtonDividerTrue() {
        let sut = makeSUT(container: .preview, editAction: {}, deleteAction: {})
        XCTAssertTrue(sut.includeMiddleButtonDivider)
    }
    
    func test_whenEditButtonOnlyPresent_thenIncludeMiddleButtonDividerFalse() {
        let sut = makeSUT(container: .preview, editAction: {}, deleteAction: nil)
        XCTAssertFalse(sut.includeMiddleButtonDivider)
    }
    
    func test_whenDeleteButtonOnlyPresent_thenIncludeMiddleButtonDividerFalse() {
        let sut = makeSUT(container: .preview, editAction: nil, deleteAction: {})
        XCTAssertFalse(sut.includeMiddleButtonDivider)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), editAction: (() -> Void)? = nil, deleteAction: (() -> Void)? = nil) -> EditableCardContainerViewModel {
        let sut = EditableCardContainerViewModel(
            container: container,
            editAction: editAction,
            deleteAction: deleteAction)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
