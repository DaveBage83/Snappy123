//
//  ImageDBRepository.swift
//  SnappyV2
//
//  Created by David Bage on 07/11/2022.
//

import CoreData
import SwiftUI
import Combine
import UIKit

enum AsyncImageServiceError: Swift.Error, Equatable {
    case unableToPersistResult
    case invalidURL
}

protocol AsyncImageDBRepositoryProtocol {
    func store(image: UIImage, urlString: String) -> AnyPublisher<ImageDetails, Error>
    func fetchImage(urlString: String) -> AnyPublisher<ImageDetails?, Error>
    func clearImageData(urlString: String) -> AnyPublisher<Bool, Error>
}

struct AsyncImageDBRepository: AsyncImageDBRepositoryProtocol {
    let persistentStore: PersistentStore

    // Fetch an image from the db
    func fetchImage(urlString: String) -> AnyPublisher<ImageDetails?, Error> {
        let fetchRequest = CachedImageMO.imageDetailsFetchRequest(urlString: urlString)

        return persistentStore
            .fetch(fetchRequest) {
                ImageDetails(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }

    // Delete images that have expired
    func clearImageData(urlString: String) -> AnyPublisher<Bool, Error>  {
        persistentStore
            .update { context in
                try CachedImageMO.delete(
                    fetchRequest: CachedImageMO.fetchRequestResultForDeletion(urlString: urlString),
                    in: context)
                return true
            }
    }

    // Store images to db
    func store(image: UIImage, urlString: String) -> AnyPublisher<ImageDetails, Error> {
        return persistentStore
            .update { context in
                let imageDetails = ImageDetails(
                    image: image,
                    fetchURLString: urlString,
                    fetchTimestamp: Date().trueDate)

                guard let cachedImageMO = imageDetails.store(in: context) else {
                    throw AsyncImageServiceError.unableToPersistResult
                }

                return ImageDetails(managedObject: cachedImageMO)
            }
    }
}

extension CachedImageMO {
    static func fetchRequestResultForDeletion(urlString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()

        // match this functions parameters and also delete any
        // records that have expired
        
        let query = "timestamp < %@ AND id == %@"
        let arguments: [Any] = [
            // Use same expiry as store menu
            AppV2Constants.Business.retailStoreMenuCachedExpiry as NSDate,
            urlString
        ]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        return request
    }
    
    static func imageDetailsFetchRequest(urlString: String) -> NSFetchRequest<CachedImageMO> {
        let request = newFetchRequest()
        
        let query = "id == %@"
        let arguments: [Any] = [urlString]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        request.fetchLimit = 1
        
        return request
    }
}

extension CachedImageMO: ManagedEntity {}

struct ImageDetails: Equatable {
    // Populated for checking cached results not from
    // decoding an API response
    let image: UIImage?
    let fetchURLString: String
    let fetchTimestamp: Date?
}

extension ImageDetails {
    init(managedObject: CachedImageMO) {
        var cachedImage: UIImage?
        
        if let imageData = managedObject.contents, let uiImage = UIImage(data: imageData) {
            cachedImage = uiImage
        }
        
        let urlString = managedObject.id
        
        self.init(
            image: cachedImage,
            fetchURLString: urlString ?? "",
            fetchTimestamp: nil)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> CachedImageMO? {
        guard let cachedImage = CachedImageMO.insertNew(in: context) else { return nil }
        
        let data = image?.jpegData(compressionQuality: 1.0)
        cachedImage.contents = data
        cachedImage.timestamp = Date().trueDate
        cachedImage.id = fetchURLString
        
        return cachedImage
    }
}
