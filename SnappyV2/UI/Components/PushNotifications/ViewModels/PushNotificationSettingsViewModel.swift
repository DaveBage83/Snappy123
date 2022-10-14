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
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.pushNotificationsDisabled = status != .granted
            }
            .store(in: &cancellables)
    }
    
    private func setupMarketingPreferenceBinding() {
        container.appState
            .updates(for: AppState.permissionKeyPath(for: .marketingPushNotifications))
            .dropFirst() // only interested in changes to the AppState value
            .removeDuplicates()
            .receive(on: RunLoop.main)
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
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] allow in
                guard let self = self else { return }
                self.container.services.userPermissionsService.setPushNotificationMarketingSelection(to: allow ? .optIn : .optOut)
            }
            .store(in: &cancellables)
    }
    
    func enableNotificationsTapped() {
        if container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] == .denied {
            container.appState.value.routing.urlToOpen = URL(string: UIApplication.openSettingsURLString)
        } else {
            container.appState.value.pushNotifications.showPushNotificationsEnablePromptView = true
        }
    }
}
