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
}

@MainActor
class PushNotificationViewModel: ObservableObject {
    let container: DIContainer
    let dismissPushNotificationViewHandler: () -> ()
    let notification: DisplayablePushNotification
    
    @Published var options: [PushNotificationOption] = []
    @Published var showCallInformationAlert = false
    
    private(set) var showTelephoneNumber = ""

    init(container: DIContainer, notification: DisplayablePushNotification, dismissPushNotificationViewHandler: @escaping ()->()) {
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
                        self.dismissPushNotificationViewHandler()
                    },
                    linkURL: link
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
                                self.dismissPushNotificationViewHandler()
                            } else {
                                // the most probable reason for tel:XXXX failing will
                                // be because the device does not support the calls,
                                // e.g. iPads & iPods
                                self.showTelephoneNumber = telephone
                                self.showCallInformationAlert = true
                            }
                        },
                        linkURL: url
                    )
                )
            }
        }
    }
    
    func dismissPushNotificationPrompt() {
        dismissPushNotificationViewHandler()
    }
    
}

