//
//  View+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 11/01/2022.
//

import UIKit
import SwiftUI

// From: https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
