//
//  MockedAsyncImageDBRepository.swift
//  SnappyV2Tests
//
//  Created by David Bage on 09/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedAsyncImageDBRepository: Mock, AsyncImageDBRepositoryProtocol {

    
    
    enum Action: Equatable {
        case store(image: UIImage, urlString: String)
        case fetchImage(urlString: String)
        case clearImageData(urlString: String)
        case clearAllStaleImages
    }
    
    var actions = MockActions<Action>(expected: [])
    
    var storeImage: Result<SnappyV2.ImageDetails, Error> = .failure(MockError.valueNotSet)
    var fetchImage: Result<SnappyV2.ImageDetails?, Error> = .failure(MockError.valueNotSet)
    var clearImage: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var clearAllStaleImages: Result<Bool, Error> = .failure(MockError.valueNotSet)
    
    func store(image: UIImage, urlString: String) -> AnyPublisher<SnappyV2.ImageDetails, Error>  {
        register(.store(image: image, urlString: urlString))
        return storeImage.publish()
    }
    
    func clearAllStaleImageData() -> AnyPublisher<Bool, Error> {
        register(.clearAllStaleImages)
        return clearAllStaleImages.publish()
    }
    
    func fetchImage(urlString: String) -> AnyPublisher<SnappyV2.ImageDetails?, Error> {
        register(.fetchImage(urlString: urlString))
        return fetchImage.publish()
    }
    
    func clearImageData(urlString: String) -> AnyPublisher<Bool, Error>  {
        register(.clearImageData(urlString: urlString))
        return clearImage.publish()
    }
}
