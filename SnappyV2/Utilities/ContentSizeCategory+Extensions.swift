//
//  ContentSizeCategory+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 25/05/2022.
//

// This extension allows us to convert ContentSizeCateogry to and Int for
// the purposes of better accessibility layouts

import SwiftUI

extension ContentSizeCategory {
    var size: Int {
        switch self {
        case .extraSmall:
            return 1
        case .small:
            return 2
        case .medium:
            return 3
        case .large:
            return 4
        case .extraLarge:
            return 5
        case .extraExtraLarge:
            return 6
        case .extraExtraExtraLarge:
            return 7
        case .accessibilityMedium:
            return 8
        case .accessibilityLarge:
            return 9
        case .accessibilityExtraLarge:
            return 10
        case .accessibilityExtraExtraLarge:
            return 11
        case .accessibilityExtraExtraExtraLarge:
            return 12
        @unknown default:
            return 1
        }
    }
}
