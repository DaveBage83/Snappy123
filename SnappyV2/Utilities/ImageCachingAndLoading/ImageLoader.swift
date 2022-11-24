//
//  ImageLoader.swift
//  SnappyV2
//
//  Created by David Bage on 30/05/2022.
//
//  Adapted from https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/

import SwiftUI

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let urlString: String?
    private(set) var isLoading = false // tracks current status of loading
    let container: DIContainer
    
    init(container: DIContainer, urlString: String?) {
        self.container = container
        self.urlString = urlString
    }

    func load() async {
        if let urlString {
            self.isLoading = true
            self.image = await container.services.imageService.loadImage(url: urlString)
            self.isLoading = false
        }
    }
}
