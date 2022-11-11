//
//  UserDefaults+Extensions.swift
//  SnappyV2
//
//  Created by Peter Whittle on 02/11/2022.
//

//Solution for monitoring updates to UserDefaults via combine. From https://betterprogramming.pub/observe-userdefaults-using-combine-in-swift-5-4177ae62360d

import Foundation

extension UserDefaults {
    
    @objc var userConfirmedSelectedChannel: Bool {
        get {
            return bool(forKey: "userConfirmedSelectedChannel")
        }
        set {
            set(newValue, forKey: "userConfirmedSelectedChannel")
        }
    }
    
}
