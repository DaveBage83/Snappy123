//
//  PushNotificationsEnablePromptViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 18/08/2022.
//

import Foundation

@MainActor
class PushNotificationsEnablePromptViewModel: ObservableObject {
    let container: DIContainer
    let dismissPushNotificationsEnablePromptView: () -> ()
    
    var introductionText: String {
        container.appState.value.businessData.businessProfile?.marketingText?.iosRemoteNotificationIntro ?? Strings.PushNotifications.defaultEnabledMessage.localized
    }
    
    var ordersOnlyButtonTitle: String {
        container.appState.value.businessData.businessProfile?.marketingText?.remoteNotificationOrdersOnlyButton ?? Strings.PushNotifications.defaultEnabledOrdersOnly.localized
    }
    
    var includingMarketingButtonTitle: String {
        container.appState.value.businessData.businessProfile?.marketingText?.remoteNotificationIncludingMarketingButton ?? Strings.PushNotifications.defaultEnabledIncludeMarketing.localized
    }
    
    var noNotificationsButtonRequired: Bool {
        container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] != .granted
    }
    
    var nonNotificationsButtonTitle: String {
        container.appState.value.businessData.businessProfile?.marketingText?.remoteNotificationNoneButton ?? Strings.PushNotifications.defaultEnabledNone.localized
    }
        
    func ordersOnlyTapped() {
        container.services.userPermissionsService.setPushNotificationMarketingSelection(to: .optOut)
        dismissPushNotificationsEnablePromptView()
    }
    
    func includeMarketingTapped() {
        container.services.userPermissionsService.setPushNotificationMarketingSelection(to: .optIn)
        dismissPushNotificationsEnablePromptView()
    }
    
    func noNotificationsTapped() {
        container.services.userPermissionsService.setUserDoesNotWantPushNotifications()
        dismissPushNotificationsEnablePromptView()
    }
    
    init(container: DIContainer, dismissPushNotificationViewHandler: @escaping ()->()) {
        self.container = container
        self.dismissPushNotificationsEnablePromptView = dismissPushNotificationViewHandler
    }
}
