//
//  PushNotificationsMarketingPreferenceViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 22/08/2022.
//

import UIKit
import Foundation
import Combine
import OSLog

@MainActor
class PushNotificationSettingsViewModel: ObservableObject {
    enum ViewContext {
        case checkout
        case settings
    }
    
    let container: DIContainer
    
    @Published var pushNotificationsDisabled: Bool
    @Published var allowPushNotificationMarketing: Bool

    private var cancellables = Set<AnyCancellable>()
    private let viewContext: ViewContext
    
    @Published var marketingPreferencesAreLoading = false
    
    @Published private(set) var error: Error?
    
    var useLargeTitles: Bool {
        viewContext == .settings
    }
    
    var pushNotificationMarketingText: String {
        return container.appState.value.businessData.businessProfile?.marketingText?.remoteNotificationIncludingMarketingButton ?? Strings.Settings.MarketingPrefs.overrideTitle.localized
    }
        
    init(container: DIContainer, viewContext: ViewContext, hideAcceptedMarketingOptions: Bool) {
        self.container = container
        self.viewContext = viewContext
        
        // in case the marketing status has yet to retrieved
        container.services.userPermissionsService.resolveStatus(for: .marketingPushNotifications, reconfirmIfKnown: false)
        
        self._pushNotificationsDisabled = .init(wrappedValue: container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] != .granted)
        self._allowPushNotificationMarketing = .init(wrappedValue: container.appState.value[keyPath: AppState.permissionKeyPath(for: .marketingPushNotifications)] == .granted)
                                                        
        setupPushNotificationBinding()
        setupMarketingPreferenceBinding()
    }
    
    private func saveAllowMarketingOverridePreference(allow: Bool) {
        UserDefaults.standard.set(allow, forKey: AppV2Constants.Business.allowMarketingKey)
    }
        
    private func setupPushNotificationBinding() {
        container.appState
            .updates(for: AppState.permissionKeyPath(for: .pushNotifications))
            .removeDuplicates()
            .sink { [weak self] status in
                guard let self = self else { return }
                self.pushNotificationsDisabled = status != .granted
            }
            .store(in: &cancellables)
    }
    
    private func setupMarketingPreferenceBinding() {
        container.appState
            .updates(for: AppState.permissionKeyPath(for: .marketingPushNotifications))
            .removeDuplicates()
            .sink { [weak self] status in
                let allow = status == .granted
                guard
                    let self = self,
                    self.allowPushNotificationMarketing != allow
                else { return }
                self.allowPushNotificationMarketing = allow
            }
            .store(in: &cancellables)
        
        $allowPushNotificationMarketing
            .dropFirst()
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] allow in
                guard let self = self else { return }
                self.container.services.userPermissionsService.setPushNotificationMarketingSelection(to: allow ? .optIn : .optOut)
            }
            .store(in: &cancellables)
    }
    
    func enableNotificationsTapped() {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            if self.container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] == .denied {
                self.container.appState.value.routing.urlToOpen = URL(string: UIApplication.openSettingsURLString)
            } else {
                self.container.appState.value.pushNotifications.showPushNotificationsEnablePromptView = true
            }
        }
    }
}
