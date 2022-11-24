//
//  AsyncImage.swift
//  SnappyV2
//
//  Created by David Bage on 30/05/2022.
//  Adapted from https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/

import SwiftUI

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    private let image: (UIImage) -> Image
    let container: DIContainer
    
    init(
        container: DIContainer,
        urlString: String?,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.image = image
        self.container = container
        _loader = StateObject(wrappedValue: ImageLoader(container: container, urlString: urlString))
    }
    
    var body: some View {
        content
            .onAppear {
                Task {
                    await loader.load()
                }
            }
    }
    
    private var content: some View {
        Group {
            // If image is loaded then show image...
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                // ... otherwise show placeholder image
                Image.Placeholders.productPlaceholder
                    .resizable()
            }
        }
    }
}
