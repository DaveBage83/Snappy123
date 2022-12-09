//
//  NotificationService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 13/04/2022.
//

import Foundation

protocol NotificationServiceProtocol {}

struct NotificationService: NotificationServiceProtocol {
    typealias NotificationStrings = Strings.ToastNotifications
    
    let appState: Store<AppState>
    
    
}

struct StubNotificationService: NotificationServiceProtocol {}
