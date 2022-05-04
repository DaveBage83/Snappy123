//
//  Color+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 04/05/2022.
//

import SwiftUI

extension Color {
    // This method converts a hex string to a Color, returning nil if the string is invalid
    init?(hex: String?) {
        guard let hex = hex else {
            return nil
        }

        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

extension Color {
    // These are the pre-defined opacity levels used in our Snappy designs
    enum Opacity: Double {
        case ten = 0.1
        case fifteen = 0.15
        case twenty = 0.2
        case thirty = 0.3
        case eighty = 0.8
        case ninety = 0.9
    }
    
    func withOpacity(_ opacity: Opacity) -> Color {
        self.opacity(opacity.rawValue)
    }
}
