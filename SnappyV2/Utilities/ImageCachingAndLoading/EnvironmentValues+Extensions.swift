//
//  EnvironmentValues+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 30/05/2022.
//

import SwiftUI

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}

// From https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
extension EnvironmentValues {
    var mainWindowSize: CGSize {
        get { self[MainWindowSizeKey.self] }
        set { self[MainWindowSizeKey.self] = newValue }
    }
}

private struct MainWindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}
