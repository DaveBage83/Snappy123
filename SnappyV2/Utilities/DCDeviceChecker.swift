//
//  DCDevice+Extensions.swift
//  SnappyV2
//
//  Created by Kevin Palser on 18/01/2023.
//

import DeviceCheck
import OSLog

protocol DCDeviceCheckerProtocol {
    func getAppleDeviceToken() async -> String?
}

struct DCDeviceChecker: DCDeviceCheckerProtocol {
    // If the app settings permit, return the temporary token used by Apple to read or
    // set the developer account / device pair bits on the Apple servers.
    func getAppleDeviceToken() async -> String? {
        guard AppV2Constants.Business.serverDeviceChecking else { return nil }
        let currentDevice = DCDevice.current
        if currentDevice.isSupported {
            do {
                let tokenData = try await currentDevice.generateToken()
                return tokenData.base64EncodedString()
            } catch {
                Logger.deviceChecking.error("Failed to generate token error: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
