//
//  CachedImageWebRepository.swift
//  SnappyV2
//
//  Created by David Bage on 08/11/2022.
//

import SwiftUI

protocol AsyncImageWebRepositoryProtocol: WebRepository {
    func fetch(_ urlRequest: URLRequest) async throws -> UIImage?
}

struct AsyncImageWebRepository: AsyncImageWebRepositoryProtocol {
    var baseURL: String
    var networkHandler: NetworkHandler
    
    var images: [URLRequest: LoaderStatus] = [:]
    
    func fetch(_ url: URL) async throws -> UIImage? {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }
    
    enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage? {
        if let status = images[urlRequest] {
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task: Task<UIImage?, Error> = Task {
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            let image = UIImage(data: imageData)
            return image
        }
        
        let image = try await task.value
        
        return image
    }
}
