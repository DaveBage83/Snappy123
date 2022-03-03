//
//  RemoteImageViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 03/03/2022.
//

import UIKit
import Combine
import SwiftUI

class RemoteImageViewModel: ObservableObject {
    let container: DIContainer
    private let imageURL: URL
    @Published var imageLoadRequest: Loadable<UIImage> = .notRequested
    @Published var image = AppV2Constants.Business.imagePlaceholder
    private var cancellables = Set<AnyCancellable>()
    
    var imageIsLoading: Bool {
        switch imageLoadRequest {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    init(container: DIContainer, imageURL: URL) {
        self.imageURL = imageURL
        self.container = container
        
        setupImageLoadRequest()
        loadImage()
    }
    
    func setupImageLoadRequest() {
        $imageLoadRequest
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                if let image = image.value {
                    self.image = Image(uiImage: image)
                } else {
                    self.image = Image.RemoteImage.placeholder
                }
            }
            .store(in: &cancellables)
    }
    
    func loadImage() {
        container.services.imageService
            .load(image: loadableSubject(\.imageLoadRequest), url: imageURL)
    }
}
