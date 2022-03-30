//
//  MarketingPreferencesViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 30/03/2022.
//

import Foundation
import Combine

class MarketingPreferencesViewModel: ObservableObject {
    private let container: DIContainer
    private let isCheckout: Bool
    
    @Published var marketingPreferencesUpdate: Loadable<UserMarketingOptionsUpdateResponse> = .notRequested
    
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
    @Published var marketingPreferencesFetch: Loadable<UserMarketingOptionsFetch> = .notRequested
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    
    private var cancellables = Set<AnyCancellable>()
    
    var marketingPreferencesAreLoading: Bool {
        switch marketingPreferencesFetch {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    init(container: DIContainer, isCheckout: Bool) {
        self.container = container
        self.isCheckout = isCheckout
        
        getMarketingPreferences()
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
            .map { preferencesFetch in
                return preferencesFetch.value?.marketingOptions
            }
            .assignWeak(to: \.marketingOptionsResponses, on: self)
            .store(in: &cancellables)
    }
    
    private func getMarketingPreferences() {
        #warning("Modifications pending on v2 endpoints re notificationsEnabled Bool. For now we set to true")
        container.services.userService.getMarketingOptions(options: loadableSubject(\.marketingPreferencesFetch), isCheckout: isCheckout, notificationsEnabled: true)
    }
    
    func updateMarketingPreferences() {
        let preferences = [
            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: emailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: directMailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: notificationMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: smsMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: telephoneMarketingEnabled.opted()),
        ]
                
        container.services.userService.updateMarketingOptions(result: loadableSubject(\.marketingPreferencesUpdate), options: preferences)
    }
}
