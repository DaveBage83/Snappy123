//
//  ImageWebRepository.swift
//  SnappyV2
//
//  Created by David Bage on 28/01/2022.
//

import Combine
import UIKit

protocol ImageWebRepositoryProtocol {
    func load(imageURL: URL) -> AnyPublisher<UIImage, Error>
    func loadImageFromCache(imageURL:URL) -> UIImage?
}

struct ImageWebRepository: ImageWebRepositoryProtocol {
    let cache = URLCache()
    let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    func load(imageURL: URL) -> AnyPublisher<UIImage, Error> {
        return download(rawImageURL: imageURL)
            .receive(on: RunLoop.main)
            .extractUnderlyingError()
            .eraseToAnyPublisher()
    }
    
    private func download(rawImageURL: URL, requests: [URLRequest] = []) -> AnyPublisher<UIImage, Error> {
        let urlRequest = URLRequest(url: rawImageURL)
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) in
                /// Store image data in cache using URLCache
                let cachedData = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedData, for: urlRequest)
                
                guard let image = UIImage(data: data)
                else { throw APIError.imageProcessing(requests + [urlRequest]) }
                
                return image
            }
            .eraseToAnyPublisher()
    }
    
    func loadImageFromCache(imageURL: URL) -> UIImage? {
        let request = URLRequest(url: imageURL)
        
        if let data = self.cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            return image
        }
        
        return nil
    }
}
