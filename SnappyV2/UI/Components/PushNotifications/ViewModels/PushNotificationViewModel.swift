//
//  PushNotificationViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/08/2022.
//

import Foundation

struct PushNotificationOption: Identifiable {
    let id = UUID()
    let title: String
    let action: (Bool) -> ()
    let linkURL: URL?
    let isViewOrder: Bool
    var loading: Bool
}

// Outcome to display after the PushNotificationView is dismissed
struct PushNotificationDismissDisplayAction: Equatable {
    let showOrder: PlacedOrder?
    // more actions can be added as required
}

@MainActor
class PushNotificationViewModel: ObservableObject {
    let container: DIContainer
    let dismissPushNotificationViewHandler: (PushNotificationDismissDisplayAction?) -> ()
    let notification: DisplayablePushNotification
    
    @Published var options: [PushNotificationOption] = []
    @Published var showCallInformationAlert = false
    
    private var orderToShow: PlacedOrder?
    private(set) var showTelephoneNumber = ""
    
    private func updateLoadingState(forOptionId optionId: UUID, to state: Bool) {
        for (index, option) in options.enumerated() where option.id == optionId {
            options[index].loading = state
            break
        }
    }

    init(container: DIContainer, notification: DisplayablePushNotification, dismissPushNotificationViewHandler: @escaping (PushNotificationDismissDisplayAction?)->()) {
        self.container = container
        self.notification = notification
        self.dismissPushNotificationViewHandler = dismissPushNotificationViewHandler
        
        // add the link option
        if let link = notification.link {
            options.append(
                PushNotificationOption(
                    title: Strings.PushNotifications.openLink.localized,
                    action: { [weak self] success in
                        guard let self = self else { return }
                        self.dismissPushNotificationViewHandler(nil)
                    },
                    linkURL: link,
                    isViewOrder: false,
                    loading: false
                )
            )
        }
        
        // add the call option
        if let telephone = notification.telephone {
            
            // strip non digit characters
            let digits = Set("0123456789")
            let phoneNumber = "tel:" + String(telephone.filter{digits.contains($0)})
            if let url = URL(string: phoneNumber) {
                options.append(
                    PushNotificationOption(
                        title: Strings.PushNotifications.call.localized,
                        action: { [weak self] success in
                            guard let self = self else { return }
                            if success {
                                self.dismissPushNotificationViewHandler(nil)
                            } else {
                                // the most probable reason for tel:XXXX failing will
                                // be because the device does not support the calls,
                                // e.g. iPads & iPods
                                self.showTelephoneNumber = telephone
                                self.showCallInformationAlert = true
                            }
                        },
                        linkURL: url,
                        isViewOrder: false,
                        loading: false
                    )
                )
            }
        }
        
        if notification.businessOrderId != nil && notification.hash != nil {
            options.append(
                PushNotificationOption(
                    title: Strings.PushNotifications.viewUpdatedOrder.localized,
                    action: { [weak self] success in
                        guard let self = self else { return }
                        if success {
                            var displayAction: PushNotificationDismissDisplayAction?
                            if let orderToShow = self.orderToShow {
                                displayAction = .init(showOrder: orderToShow)
                            }
                            self.dismissPushNotificationViewHandler(displayAction)
                        }
                    },
                    linkURL: nil,
                    isViewOrder: true,
                    loading: false
                )
            )
        }
    }
    
    func getOrder(forOption optionId: UUID) async -> Bool {
        if
            let businessOrderId = notification.businessOrderId,
            let hash = notification.hash
        {
            updateLoadingState(forOptionId: optionId, to: true)
            do {
                orderToShow = try await container.services.checkoutService.getOrder(
                    forBusinessOrderId: businessOrderId,
                    withHash: hash
                )
                return true
            } catch {
                container.appState.value.errors.append(error)
                updateLoadingState(forOptionId: optionId, to: false)
            }
        }
        return false
    }
    
    func dismissPushNotificationPrompt() {
        dismissPushNotificationViewHandler(nil)
    }
    
}

