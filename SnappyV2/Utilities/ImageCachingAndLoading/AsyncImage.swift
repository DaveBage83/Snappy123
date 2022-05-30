//
//  AsyncImage.swift
//  SnappyV2
//
//  Created by David Bage on 30/05/2022.
//

import SwiftUI

struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (UIImage) -> Image

    init(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
           Group {
               if loader.isLoading {
                  ProgressView()
               } else if let image = loader.image {
                   Image(uiImage: image)
                       .resizable()
               } else {
                   placeholder
               }
           }
       }
}
