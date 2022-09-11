//
//  NotificationContentViewModel.swift
//  Notification Content
//
//  Created by Kevin Palser on 26/08/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
final class NotificationContentViewModel: ObservableObject {
    
    @Published var url: URL?
    @Published var imageData: Data?
    
    func fetchImage(at url: URL) {
        self.url = url
        
        // No AsyncImage before iOS 15
        if #unavailable(iOSApplicationExtension 15.0) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                if error != nil || data == nil {
                    if let error = error {
                        Logger.pushNotification.error("NotificationContent failed to get image: \(error.localizedDescription)")
                    } else {
                        Logger.pushNotification.error("NotificationContent failed to get image data")
                    }
                } else if let data = data {
                    DispatchQueue.main.async {
                        self.imageData = data
                    }
                }
            }
            task.resume()
        }
    }
    
}
