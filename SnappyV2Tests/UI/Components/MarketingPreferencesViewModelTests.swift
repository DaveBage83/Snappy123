//
//  MarketingPreferencesViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 29/03/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2
import Combine

@MainActor
class MarketingPreferencesViewModelTests: XCTestCase {
    
    func test_init() async {
        let sut = makeSUT(viewContext: .checkout, hideAcceptedMarketingOptions: false)
        
        XCTAssertNil(sut.marketingPreferencesUpdate)
        XCTAssertFalse(sut.emailMarketingEnabled)
        XCTAssertFalse(sut.directMailMarketingEnabled)
        XCTAssertFalse(sut.notificationMarketingEnabled)
        XCTAssertFalse(sut.telephoneMarketingEnabled)
        XCTAssertFalse(sut.smsMarketingEnabled)
        XCTAssertNil(sut.marketingPreferencesFetch)
        XCTAssertNil(sut.marketingOptionsResponses)
    }
    
    func test_whenMarketingPreferencesFetched_thenCorrectValuesRetrieved() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getMarketingOptions(isCheckout: false, notificationsEnabled: true)]))
                                    
        let sut = makeSUT(container: container, viewContext: .checkout, hideAcceptedMarketingOptions: false)
        
        let expectation = expectation(description: "getMarketingOptions")
        var cancellables = Set<AnyCancellable>()

        sut.$marketingPreferencesFetch
            .collect(3)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.emailMarketingEnabled = true
        sut.telephoneMarketingEnabled = true
        
        let preferences = [
            UserMarketingOptionResponse(type: MarketingOptions.email.rawValue, text: "", opted: sut.emailMarketingEnabled.opted()),
            UserMarketingOptionResponse(type: MarketingOptions.directMail.rawValue, text: "", opted: sut.directMailMarketingEnabled.opted()),
            UserMarketingOptionResponse(type: MarketingOptions.notification.rawValue, text: "", opted: sut.notificationMarketingEnabled.opted()),
            UserMarketingOptionResponse(type: MarketingOptions.sms.rawValue, text: "", opted: sut.smsMarketingEnabled.opted()),
            UserMarketingOptionResponse(type: MarketingOptions.telephone.rawValue, text: "", opted: sut.telephoneMarketingEnabled.opted()),
        ]
        
        let marketingFetch = UserMarketingOptionsFetch(
            marketingPreferencesIntro: nil,
            marketingPreferencesGuestIntro: nil,
            marketingOptions: preferences,
            fetchIsCheckout: false,
            fetchNotificationsEnabled: true,
            fetchBasketToken: nil,
            fetchTimestamp: nil)
        
        await sut.getMarketingPreferences()
        
        sut.marketingPreferencesFetch = marketingFetch
        
        wait(for: [expectation], timeout: 2)
        
        let marketingOptionsResponses = [
            UserMarketingOptionResponse(type: MarketingOptions.email.rawValue, text: "", opted: .in),
            UserMarketingOptionResponse(type: MarketingOptions.directMail.rawValue, text: "", opted: .out),
            UserMarketingOptionResponse(type: MarketingOptions.notification.rawValue, text: "", opted: .out),
            UserMarketingOptionResponse(type: MarketingOptions.sms.rawValue, text: "", opted: .out),
            UserMarketingOptionResponse(type: MarketingOptions.telephone.rawValue, text: "", opted: .in)
        ]

        XCTAssertEqual(sut.marketingOptionsResponses, marketingOptionsResponses)
        
        container.services.verify(as: .user)
    }
    
    func test_whenAllMarketingOptionsAreDisabled_thenMarketingPrefsAllDeselectedTrue() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        sut.emailMarketingEnabled = false
        sut.directMailMarketingEnabled = false
        sut.notificationMarketingEnabled = false
        sut.smsMarketingEnabled = false
        sut.telephoneMarketingEnabled = false
        
        XCTAssertTrue(sut.marketingPrefsAllDeselected)
    }
    
    func test_whenAnyOneMarketingPrefIsEnabled_thenMarketingPrefsAllDeselectedFalse() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        sut.emailMarketingEnabled = true
        sut.directMailMarketingEnabled = false
        sut.notificationMarketingEnabled = false
        sut.smsMarketingEnabled = false
        sut.telephoneMarketingEnabled = false
        
        XCTAssertFalse(sut.marketingPrefsAllDeselected)
    }
    
    func test_whenUpdateMarketingPreferencesRequested_thenMarketingPreferencesUpdated() async {
        let preferences = [
            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: .in),
            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: .out),
            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: .out),
            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: .in),
            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: .out),
        ]
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.updateMarketingOptions(options: preferences)]))
                                    
        let sut = makeSUT(container: container, viewContext: .checkout, hideAcceptedMarketingOptions: false)

        sut.emailMarketingEnabled = true
        sut.smsMarketingEnabled = true
        
        await sut.updateMarketingPreferences()
        
        container.services.verify(as: .user)
    }
    
    func test_whenViewContextIsSettings_thenUseLargeTitlesIsTrue() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        XCTAssertTrue(sut.useLargeTitles)
    }
    
    func test_whenViewContextIsCheckout_thenUseLargeTitlesIsFalse() {
        let sut = makeSUT(viewContext: .checkout, hideAcceptedMarketingOptions: false)
        XCTAssertFalse(sut.useLargeTitles)
    }
    
    func test_whenViewContextIsSettings_thenShowMarketingPrefsPromptIsFalse() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        XCTAssertFalse(sut.showMarketingPrefsPrompt)
    }
    
    func test_whenViewContextIsCheckout_thenShowMarketingPrefsPromptIsTrue() {
        let sut = makeSUT(viewContext: .checkout, hideAcceptedMarketingOptions: false)
        XCTAssertTrue(sut.showMarketingPrefsPrompt)
    }
    
    func test_whenViewContextIsSettings_thenShowAllowMarketingToggleIsTrue() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        XCTAssertTrue(sut.showAllowMarketingToggle)
    }
    
    func test_whenViewContextIsCheckout_thenShowAllowMarketingToggleIsFalse() {
        let sut = makeSUT(viewContext: .checkout, hideAcceptedMarketingOptions: false)
        XCTAssertFalse(sut.showAllowMarketingToggle)
    }
    
    func test_whenViewContextIsSettings_thenShowMarketingPreferencesSubtitleIsTrue() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        XCTAssertTrue(sut.showMarketingPreferencesSubtitle)
    }
    
    func test_whenViewContextIsCheckout_thenShowMarketingPreferencesSubtitleIsFalse() {
        let sut = makeSUT(viewContext: .checkout, hideAcceptedMarketingOptions: false)
        XCTAssertFalse(sut.showMarketingPreferencesSubtitle)
    }
    
    func test_whenAllowMarketingOptionsIsTrue_thenMarketingOptionsDisabledIsFalse() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        sut.allowMarketing = true
        XCTAssertFalse(sut.marketingOptionsDisabled)
    }
    
    func test_whenAllowMarketingOptionsIsFalse_thenMarketingOptionsDisabledIsTrue() {
        let sut = makeSUT(viewContext: .settings, hideAcceptedMarketingOptions: false)
        sut.allowMarketing = false
        XCTAssertTrue(sut.marketingOptionsDisabled)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), viewContext: MarketingPreferencesViewModel.ViewContext, hideAcceptedMarketingOptions: Bool) -> MarketingPreferencesViewModel {
        let sut = MarketingPreferencesViewModel(container: container, viewContext: viewContext, hideAcceptedMarketingOptions: hideAcceptedMarketingOptions)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}

