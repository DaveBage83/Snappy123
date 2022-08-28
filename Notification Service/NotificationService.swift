//
//  NotificationService.swift
//  Notification Service
//
//  Created by Kevin Palser on 26/08/2022.
//

import UserNotifications
import OSLog

// 3rd party
import IterableAppExtensions

class NotificationService: ITBNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        var useHungrrrStyleImplementation = false
        if AppV2PushNotificationConstants.checkNotificationSource {
            if
                let sendSource = request.content.userInfo["sendSource"] as? String,
                sendSource.lowercased() == "main_server"
            {
                useHungrrrStyleImplementation = true
            }
        } else {
            useHungrrrStyleImplementation = true
        }
        
        if useHungrrrStyleImplementation {
            
            self.contentHandler = contentHandler
            bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
            
            if let bestAttemptContent = bestAttemptContent {
                
                // Modify the notification content here...
                
                // Apple example code line for reference:
                // bestAttemptContent.title = bestAttemptContent.title + "[modified]"
                
                if
                    let urlImageString = request.content.userInfo["thumbImageURL"] as? String,
                    let fileUrl = URL(string: urlImageString)
                {

                    let urlSession = URLSession(configuration: .default).dataTask(with: fileUrl) { (data, response, error) in
                        if error != nil || data == nil {
                            if let error = error {
                                Logger.pushNotification.error("NotificationService failed to get thumb image: \(error.localizedDescription)")
                            } else {
                                Logger.pushNotification.error("NotificationService failed to get thumb image data")
                            }
                        } else if
                            let data = data,
                            let attachment = UNNotificationAttachment.saveImageToDisk(
                                fileIdentifier: "image.jpg",
                                data: data,
                                options: nil
                            )
                        {
                            bestAttemptContent.attachments = [ attachment ]
                        }
                        contentHandler(bestAttemptContent)
                    }
                    urlSession.resume()
                } else {
                    contentHandler(bestAttemptContent)
                }
            }
        } else {
            // use the ITBNotificationServiceExtension code
            super.didReceive(request, withContentHandler: contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            if let fileURL = folderURL?.appendingPathComponent(fileIdentifier) {
                try data.write(to: fileURL, options: [])
                return try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL, options: options)
            }
        } catch {
            Logger.pushNotification.error("NotificationService failed to save thumb image data: \(error.localizedDescription)")
        }
        
        return nil
    }
}
