//
//  StandardAlertToastViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 19/12/2022.
//

import Foundation

import XCTest
@testable import SnappyV2
import SwiftUI
import Combine

enum TestError: Swift.Error, Equatable {
    case testError
}

extension TestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .testError:
            return "Test error triggered"
        }
    }
}

class StandardAlertToastViewModelTests: XCTestCase {
    func test_init_givenToastTypeError() {
        let sut = makeSUT(toastType: .error)
        
        XCTAssertFalse(sut.showAlert)
        XCTAssertEqual(sut.alertText, "")
        XCTAssertEqual(sut.toastType, .error)
    }
    
    func test_init_givenToastTypeSuccess() {
        let sut = makeSUT(toastType: .success)
        
        XCTAssertFalse(sut.showAlert)
        XCTAssertEqual(sut.alertText, "")
        XCTAssertEqual(sut.toastType, .success)
    }
    
    func test_whenLatestErrorInAppStateChanges_thenShowAlertTrueAndAlertTextTriggered() {
        let sut = makeSUT(toastType: .error)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "Error text set, showAlert true")
        
        sut.container.appState.value.errors.append(TestError.testError)
        
        sut.$alertText
            .dropFirst()
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.alertText, TestError.testError.localizedDescription)
        XCTAssertTrue(sut.showAlert)
    }
    
    func test_whenErrorsClearedFromAppState_thenShowAlertTrueAndAlertTextTriggered() {
        let sut = makeSUT(toastType: .error)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "Error text empty, showAlert false")
        
        sut.container.appState.value.errors.append(TestError.testError)
        sut.container.appState.value.errors = []
        
        sut.$alertText
            .dropFirst()
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.alertText, "")
        XCTAssertFalse(sut.showAlert)
    }
    
    func test_whenLatestSuccessToastInAppStateChanges_thenShowAlertTrueAndAlertTextTriggered() {
        let sut = makeSUT(toastType: .success)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "Success toast text set, showAlert true")
        
        let toast = SuccessToast(subtitle: "Test toast")
        
        sut.container.appState.value.successToasts.append(toast)
        
        sut.$alertText
            .dropFirst()
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.alertText, toast.subtitle)
        XCTAssertTrue(sut.showAlert)
    }
    
    func test_whenSuccessToastsClearedFromAppState_thenShowAlertTrueAndAlertTextTriggered() {
        let sut = makeSUT(toastType: .success)
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "Success toast empty, showAlert false")
        
        let toast = SuccessToast(subtitle: "Test toast")
        
        sut.container.appState.value.successToasts.append(toast)
        
        sut.container.appState.value.successToasts.append(toast)
        sut.container.appState.value.successToasts = []
        
        sut.$alertText
            .dropFirst()
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.alertText, "")
        XCTAssertFalse(sut.showAlert)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), toastType: ToastType) -> StandardAlertToastViewModel {
        let sut = StandardAlertToastViewModel(
            container: container,
            toastType: toastType,
            viewID: UUID())
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
