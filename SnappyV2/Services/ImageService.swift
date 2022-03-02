//
//  ImageService.swift
//  SnappyV2
//
//  Created by David Bage on 28/01/2022.
//

import Combine
import SwiftUI

protocol ImageServiceProtocol {
    func load(image: LoadableSubject<UIImage>, url: URL?)
}

struct ImageService: ImageServiceProtocol {
    
    let webRepository: ImageWebRepository
    
    init(webRepository: ImageWebRepository) {
        self.webRepository = webRepository
    }
    
    func load(image: LoadableSubject<UIImage>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested
            return
        }
        let cancelBag = CancelBag()
        image.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if let cachedImage = webRepository.loadImageFromCache(imageURL: url) {
            Just(cachedImage) // First check if the image exists in the cache
                .eraseToAnyPublisher()
                .sinkToLoadable {
                    image.wrappedValue = $0
                }
                .store(in: cancelBag)
        } else {
            webRepository.load(imageURL: url)
                .sinkToLoadable {
                    image.wrappedValue = $0
                }
                .store(in: cancelBag)
        }
    }
}

struct StubImageService: ImageServiceProtocol {
    func load(image: LoadableSubject<UIImage>, url: URL?) {}
}
