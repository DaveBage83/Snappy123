//
//  ToastableViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 13/10/2022.
//

import XCTest
@testable import SnappyV2
import Combine

class ToastableViewModelTests: XCTestCase {
    func test_whenManageToastsOnDisappear_givenIsModalFalse_thenRemoveErrosAndViewIDsFromAppState() {
        let sut = makeSUT(isModal: false)
        let error = GenericError.somethingWrong
        sut.container.appState.value.errors = [error]
        let viewID = sut.id
        sut.container.appState.value.viewIDs = [viewID]
        sut.container.appState.value.successToastStrings = ["Test"]
        
        sut.manageToastsOnDisappear()
        
        XCTAssertEqual(sut.container.appState.value.errors.count, 0)
        XCTAssertEqual(sut.container.appState.value.viewIDs, [])
        XCTAssertEqual(sut.container.appState.value.successToastStrings, [])
        XCTAssertNil(sut.container.appState.value.latestError)
        XCTAssertNil(sut.container.appState.value.latestViewID)
    }
    
    func test_whenManageToastsOnDisappear_givenIsModalTrue_thenRemoveErrosAndViewIDsFromAppState() {
        let sut = makeSUT(isModal: true)
        let error = GenericError.somethingWrong
        sut.container.appState.value.errors = [error]
        let viewID = sut.id
        sut.container.appState.value.viewIDs = [viewID]
        sut.container.appState.value.successToastStrings = ["Test"]
        
        sut.manageToastsOnDisappear()
        
        let expectation = expectation(description: "Latest Error Set")
        
        var cancellables = Set<AnyCancellable>()
        
        sut.container.appState
            .dropFirst()
            .first()
            .map(\.latestError)
            .sink { error in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.container.appState.value.errors.count, 1)
        XCTAssertEqual(sut.container.appState.value.viewIDs, [])
        XCTAssertEqual(sut.container.appState.value.successToastStrings, ["Test"])
        XCTAssertEqual(sut.container.appState.value.latestError?.localizedDescription, error.localizedDescription)
        XCTAssertNil(sut.container.appState.value.latestViewID)
    }
    
    func test_whenManageToastsOnAppear_givenViewIDInAppStateDoesNotMatchCurrentViewID_thenClearToastsAndAppendViewID() {
        let sut = makeSUT(isModal: false)
        sut.container.appState.value.errors = [GenericError.somethingWrong]
        sut.container.appState.value.successToastStrings = ["Test"]
        sut.manageToastsOnAppear()
        
        XCTAssertEqual(sut.container.appState.value.viewIDs, [sut.id])
        XCTAssertEqual(sut.container.appState.value.latestViewID, sut.id)
        XCTAssertNil(sut.container.appState.value.latestError)
        XCTAssertNil(sut.container.appState.value.latestSuccessToast)
        XCTAssertEqual(sut.container.appState.value.successToastStrings, [])
        XCTAssertEqual(sut.container.appState.value.errors.count, 0)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), isModal: Bool) -> ToastableViewModel {
        let sut = ToastableViewModel(container: container, isModal: isModal)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
