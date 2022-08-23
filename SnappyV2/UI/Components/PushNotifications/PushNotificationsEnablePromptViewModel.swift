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
        container.appState.value.businessData.businessProfile?.marketingText?.iosRemoteNotificationIntro ?? "<EMPTY>"
    }
    
    var ordersOnlyButtonTitle: String {
        container.appState.value.businessData.businessProfile?.marketingText?.remoteNotificationOrdersOnlyButton ?? "<ORDERS ONLY>"
    }
    
    var includingMarketingButtonTitle: String {
        container.appState.value.businessData.businessProfile?.marketingText?.remoteNotificationIncludingMarketingButton ?? "<Marketing>"
    }
    
    var noNotificationsButtonRequired: Bool {
        container.appState.value[keyPath: AppState.permissionKeyPath(for: .pushNotifications)] != .granted
    }
    
    var nonNotificationsButtonTitle: String {
        container.appState.value.businessData.businessProfile?.marketingText?.remoteNotificationNoneButton ?? "<None>"
    }
    
    @Published var error: Error?
    
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
