//
//  MarketingPreferencesViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 12/03/2022.
//

import SwiftUI
import Combine

//class MarketingPreferencesViewModel: ObservableObject {
//    typealias Checkmark = Image.General.Checkbox
//    typealias MarketingStrings = Strings.CheckoutDetails.MarketingPreferences
//    
//    @Published var marketingPreferencesFetch: Loadable<UserMarketingOptionsFetch> = .notRequested
//    @Published var updateMarketingOptionsRequest: Loadable<UserMarketingOptionsUpdateResponse> = .notRequested
//    
//    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
//    @Published var userMarketingPreferences: UserMarketingOptionsUpdateResponse?
//    
//    @Published var emailMarketingEnabled = false
//    @Published var directMailMarketingEnabled = false
//    @Published var notificationMarketingEnabled = false
//    @Published var smsMarketingEnabled = false
//    @Published var telephoneMarketingEnabled = false
//    
//    let container: DIContainer
//    private var cancellables = Set<AnyCancellable>()
//    
//    var marketingPreferencesAreLoading: Bool {
//        switch marketingPreferencesFetch {
//        case .isLoading(last: _, cancelBag: _):
//            return true
//        default:
//            return false
//        }
//    }
//    
//    init(container: DIContainer) {
//        self.container = container
//        
//        getMarketingPreferences()
//        setupMarketingPreferences()
//        setupMarketingPreferencesUpdate()
//        setupMarketingOptionsResponses()
//    }
//    
//    func updateMarketingPrefs() {
//        updateMarketingPreferences()
//    }
//    
//    private func setupMarketingOptionsResponses() {
//        $marketingOptionsResponses
//            .receive(on: RunLoop.main)
//            .sink { [weak self] marketingResponses in
//                guard let self = self else { return }
//                // Set marketing properties
//                self.emailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.email.rawValue }.first?.opted == .in
//                self.directMailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.directMail.rawValue }.first?.opted == .in
//                self.notificationMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.notification.rawValue }.first?.opted == .in
//                self.smsMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.sms.rawValue }.first?.opted == .in
//                self.telephoneMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.telephone.rawValue }.first?.opted == .in
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func setupMarketingPreferences() {
//        $marketingPreferencesFetch
//            .map { preferencesFetch in
//                return preferencesFetch.value?.marketingOptions
//            }
//            .assignWeak(to: \.marketingOptionsResponses, on: self)
//            .store(in: &cancellables)
//    }
//    
//    private func setupMarketingPreferencesUpdate() {
//        $updateMarketingOptionsRequest
//            .sink(receiveValue: { [weak self] updatedPreferences in
//                guard let self = self else { return }
//                
//                if let updatedPreferences = updatedPreferences.value {
//                    self.userMarketingPreferences = updatedPreferences
//                }
//            })
//            .store(in: &cancellables)
//    }
//    
//    private func getMarketingPreferences() {
//        container.services.userService.getMarketingOptions(options: loadableSubject(\.marketingPreferencesFetch), isCheckout: true, notificationsEnabled: true)
//    }
//    
//    private func updateUserMarketingOptions(options: [UserMarketingOptionRequest]) {
//        container.services.userService.updateMarketingOptions(result: loadableSubject(\.updateMarketingOptionsRequest), options: options)
//    }
//    
//    func emailMarketingTapped() {
//        self.emailMarketingEnabled.toggle()
//    }
//    
//    func directMailMarketingTapped() {
//        self.directMailMarketingEnabled.toggle()
//    }
//    
//    func mobileNotificationsTapped() {
//        self.notificationMarketingEnabled.toggle()
//    }
//    
//    func smsMarketingTapped() {
//        self.smsMarketingEnabled.toggle()
//    }
//    
//    func telephoneMarketingTapped() {
//        self.telephoneMarketingEnabled.toggle()
//    }
//    
//    func preferenceSettings(type: MarketingOptions) -> MarketingPreferenceSettings {
//        switch type {
//        case .email:
//            return  MarketingPreferenceSettings(
//                image: emailMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
//                text: MarketingStrings.email.localized,
//                action: emailMarketingTapped)
//            
//        case .notification:
//            return MarketingPreferenceSettings(
//                image: directMailMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
//                text: MarketingStrings.notifications.localized,
//                action: directMailMarketingTapped)
//        case .sms:
//            return MarketingPreferenceSettings(
//                image: notificationMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
//                text: MarketingStrings.sms.localized,
//                action: mobileNotificationsTapped)
//        case .telephone:
//            return MarketingPreferenceSettings(
//                image: smsMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
//                text: MarketingStrings.telephone.localized,
//                action: smsMarketingTapped)
//        case .directMail:
//            return MarketingPreferenceSettings(
//                image: telephoneMarketingEnabled ? Checkmark.checked : Checkmark.unChecked,
//                text: MarketingStrings.directMail.localized,
//                action: telephoneMarketingTapped)
//        }
//    }
//    
//    private func updateMarketingPreferences() {
//        let preferences = [
//            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: emailMarketingEnabled.opted()),
//            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: directMailMarketingEnabled.opted()),
//            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: notificationMarketingEnabled.opted()),
//            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: smsMarketingEnabled.opted()),
//            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: telephoneMarketingEnabled.opted()),
//        ]
//        
//        updateUserMarketingOptions(options: preferences)
//    }
//}
