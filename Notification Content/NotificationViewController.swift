//
//  NotificationViewController.swift
//  Notification Content
//
//  Created by Kevin Palser on 18/11/2019.
//  Copyright © 2019 MTC Media. All rights reserved.
//

import SwiftUI
import UserNotifications
import UserNotificationsUI
import OSLog

// Approach of adding SwiftUI based on answers here:
// https://stackoverflow.com/questions/67597067/swiftui-in-a-notification-content-extension

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var container: UIView!
    
    private let notificationContentViewModel = NotificationContentViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingView = UIHostingController(
            rootView: NotificationContentView(
                viewModel: self.notificationContentViewModel
            )
        )
        container.addSubview(hostingView.view)
        // get the hosting view to match the size of the container view with
        // UIKit contraints for auto layout
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        hostingView.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        hostingView.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        hostingView.view.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        hostingView.view.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
    }
    
    func didReceive(_ notification: UNNotification) {
        
        // Example for future reference of the syntax to get other parts
        // of the notification message:
        //notificationContentViewModel.messageText = notification.request.content.body
        
        let content = notification.request.content

        if
            let urlImageString = content.userInfo["imageURL"] as? String,
            let url = URL(string: urlImageString)
        {
            notificationContentViewModel.fetchImage(at: url)
        } else {
            // the notification Category should not be set if there is no image
            Logger.pushNotification.error("NotificationContent without a valid imageURL")
        }
    }

}
