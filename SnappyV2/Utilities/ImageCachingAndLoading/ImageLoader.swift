//
//  ImageLoader.swift
//  SnappyV2
//
//  Created by David Bage on 30/05/2022.
//
// From https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let urlString: String?
    private var cancellable: AnyCancellable?
    private var cache: ImageCache?
    private(set) var isLoading = false // tracks current status of loading
    
    init(urlString: String?, cache: ImageCache? = nil) {
        self.urlString = urlString
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading, let urlString = urlString, let url = URL(string: urlString) else { return } // exit early if image loading is already in process
        
        if let image = cache?[url] {
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
        // subscription lifecycle handling - update isLoading accordingly
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        image.map { cache?[url] = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
