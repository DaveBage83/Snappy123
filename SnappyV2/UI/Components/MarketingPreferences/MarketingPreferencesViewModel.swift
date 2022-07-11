//
//  MarketingPreferencesViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 30/03/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
class MarketingPreferencesViewModel: ObservableObject {
    let container: DIContainer
    private let isCheckout: Bool
    
    @Published var marketingPreferencesUpdate: UserMarketingOptionsUpdateResponse?
    
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
    @Published var marketingPreferencesFetch: UserMarketingOptionsFetch?
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var marketingPreferencesAreLoading = false
    
    @Published private(set) var error: Error?
    
    var marketingIntroText: String {
        marketingPreferencesFetch?.marketingPreferencesIntro ?? Strings.CheckoutDetails.MarketingPreferences.prompt.localized
    }
    
    init(container: DIContainer, isCheckout: Bool) {
        self.container = container
        self.isCheckout = isCheckout
        
        Task { [weak self] in
            guard let self = self else { return }
            await self.getMarketingPreferences()
        }
        
        setupMarketingPreferences()
        setupMarketingOptionsResponses()
    }
    
    private func setupMarketingOptionsResponses() {
        $marketingOptionsResponses
            .receive(on: RunLoop.main)
            .sink { [weak self] marketingResponses in
                guard let self = self else { return }
                
                // Set marketing properties
                self.emailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.email.rawValue }.first?.opted == .in
                self.directMailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.directMail.rawValue }.first?.opted == .in
                self.notificationMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.notification.rawValue }.first?.opted == .in
                self.smsMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.sms.rawValue }.first?.opted == .in
                self.telephoneMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.telephone.rawValue }.first?.opted == .in
            }
            .store(in: &cancellables)
    }
    
    private func setupMarketingPreferences() {
        $marketingPreferencesFetch
            .receive(on: RunLoop.main)
            .sink { [weak self] preferencesFetch in
                guard let self = self else { return }
                if let options = preferencesFetch?.marketingOptions {
                    self.marketingOptionsResponses = options
                }
            }
            .store(in: &cancellables)
    }
    
    private func getMarketingPreferences() async {
        do {
            self.marketingPreferencesAreLoading = true
            #warning("Modifications pending on v2 endpoints re notificationsEnabled Bool. For now we set to true")
            self.marketingPreferencesFetch = try await self.container.services.userService.getMarketingOptions(isCheckout: self.isCheckout, notificationsEnabled: true)
            self.marketingPreferencesAreLoading = false
        } catch {
            self.error = error
            Logger.member.error("Failed to get marketing options - Error: \(error.localizedDescription)")
            self.marketingPreferencesAreLoading = false
        }
    }
    
    func updateMarketingPreferences() async {
        let preferences = [
            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: emailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: directMailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: notificationMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: smsMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: telephoneMarketingEnabled.opted())
        ]
        
        do {
            marketingPreferencesUpdate = try await container.services.userService.updateMarketingOptions(options: preferences)
        } catch {
            self.error = error
            Logger.member.error("Failed to update marketing options - Error: \(error.localizedDescription)")
        }
    }
}
