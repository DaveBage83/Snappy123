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
    enum ViewContext {
        case checkout
        case settings
    }
    
    let container: DIContainer
    private let hideAcceptedMarketingOptions: Bool
    
    @Published var marketingPreferencesUpdate: UserMarketingOptionsUpdateResponse?
    
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
    @Published var marketingPreferencesFetch: UserMarketingOptionsFetch?
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    @Published var allowMarketing: Bool
    private var getMarketingPrefsTask: Task<Void, Never>?

    private var cancellables = Set<AnyCancellable>()
    private let viewContext: ViewContext
    
    @Published var marketingPreferencesAreLoading = false
        
    var marketingIntroText: String {
        marketingPreferencesFetch?.marketingPreferencesIntro ?? Strings.CheckoutDetails.MarketingPreferences.prompt.localized
    }
    
    var useLargeTitles: Bool {
        viewContext == .settings
    }
    
    var showMarketingPrefsPrompt: Bool {
        viewContext == .checkout
    }
    
    var showAllowMarketingToggle: Bool {
        viewContext == .settings
    }
    
    var showMarketingPreferencesSubtitle: Bool {
        viewContext == .settings
    }
    
    var marketingOptionsDisabled: Bool {
        allowMarketing == false && viewContext == .settings
    }
    
    
    var marketingPrefsAllDeselected: Bool {
        return (!emailMarketingEnabled && !directMailMarketingEnabled && !notificationMarketingEnabled && !smsMarketingEnabled && !telephoneMarketingEnabled)
    }
        
    init(container: DIContainer, viewContext: ViewContext, hideAcceptedMarketingOptions: Bool) {
        self.container = container
        self.hideAcceptedMarketingOptions = hideAcceptedMarketingOptions
        self.viewContext = viewContext
        
        let defaults = UserDefaults.standard
        
        self._allowMarketing = .init(initialValue: defaults.value(forKey: AppV2Constants.Business.allowMarketingKey) == nil ? true : defaults.bool(forKey: AppV2Constants.Business.allowMarketingKey))
        
        setupMarketingPreferences()
        setupMarketingOptionsResponses()
        setupAllowMarketingOverride()
        
        // If we are in settings viewContext and allowMarketing is false, we do not need to get prefs as we know they will be clear
        if allowMarketing || viewContext == .checkout {
            getMarketingPrefsTask = Task { [weak self] in
                guard let self = self else { return }
                await self.getMarketingPreferences()
            }
        }
    }
    
    deinit {
        getMarketingPrefsTask?.cancel()
    }
    
    private func saveAllowMarketingOverridePreference(allow: Bool) {
        UserDefaults.standard.set(allow, forKey: AppV2Constants.Business.allowMarketingKey)
    }
    
    private func setupAllowMarketingOverride() {
        $allowMarketing
            .receive(on: RunLoop.main)
            .sink { [weak self] allow in
                guard let self = self else { return }
                self.saveAllowMarketingOverridePreference(allow: allow)
                
                if allow == false {
                    self.deselectAllPreferences()
                }
            }
            .store(in: &cancellables)
    }
    
    private func deselectAllPreferences() {
        emailMarketingEnabled = false
        directMailMarketingEnabled = false
        notificationMarketingEnabled = false
        telephoneMarketingEnabled = false
        smsMarketingEnabled = false
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
    
    func getMarketingPreferences() async {
        do {
            self.marketingPreferencesAreLoading = true
            #warning("Modifications pending on v2 endpoints re notificationsEnabled Bool. For now we set to true")
            self.marketingPreferencesFetch = try await self.container.services.memberService.getMarketingOptions(isCheckout: self.hideAcceptedMarketingOptions, notificationsEnabled: true)
            self.marketingPreferencesAreLoading = false
        } catch {
            self.container.appState.value.errors.append(error)
            Logger.member.error("Failed to get marketing options - Error: \(error.localizedDescription)")
            self.marketingPreferencesAreLoading = false
        }
    }
    
    func updateMarketingPreferences(channelId: Int? = nil) async {
        let preferences = [
            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: emailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: directMailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: notificationMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: smsMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: telephoneMarketingEnabled.opted())
        ]
        
        do {
            marketingPreferencesUpdate = try await container.services.memberService.updateMarketingOptions(options: preferences, channel: channelId)
            
            if marketingPrefsAllDeselected == false {
                saveAllowMarketingOverridePreference(allow: true)
            }
            
        } catch {
            self.container.appState.value.errors.append(error)
            Logger.member.error("Failed to update marketing options - Error: \(error.localizedDescription)")
        }
    }
}
