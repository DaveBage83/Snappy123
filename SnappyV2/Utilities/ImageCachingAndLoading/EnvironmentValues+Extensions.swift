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
