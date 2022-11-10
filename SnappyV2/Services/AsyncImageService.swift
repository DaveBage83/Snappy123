//
//  ImageService.swift
//  SnappyV2
//
//  Created by David Bage on 28/01/2022.
//

import Combine
import SwiftUI
import OSLog

protocol AsyncImageServiceProtocol {
    func loadImage(url: String) async -> UIImage
    func clearAllStaleData()
}

struct AsyncImageService: AsyncImageServiceProtocol {
    
    let webRepository: AsyncImageWebRepositoryProtocol
    let dbRepository: AsyncImageDBRepositoryProtocol
    
    let eventLogger: EventLoggerProtocol
    
    init(webRepository: AsyncImageWebRepositoryProtocol, dbRepository: AsyncImageDBRepositoryProtocol, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.eventLogger = eventLogger
    }
    
    func clearAllStaleData() {
        let _ = dbRepository.clearAllStaleImageData()
    }
    
    func loadImage(url: String) async -> UIImage {
        // Clear image from db if expired
        do {
            let _ = try await dbRepository.clearImageData(urlString: url).singleOutput()
        } catch {
            Logger.imageCache.info("No images to clear")
        }
        
        do {
            let imageDetails = try await dbRepository.fetchImage(urlString: url).singleOutput()
            
            // If image is found and imageDetails successfully retrieved, return it
            if let image = imageDetails?.image {
                Logger.imageCache.info("Image \(url) found in DB")
                return image
            } else {
                if let formattedURL =  URL(string: url) {
                    do {
                        // Fetch image from web repository
                        Logger.imageCache.info("Image \(url) not found in DB so fetching from web instead")
                        let image = try await webRepository.fetch(URLRequest(url: formattedURL))
                        // Try to store to db
                        if let image {
                            do {
                                let _ = try await dbRepository.store(image: image, urlString: url).singleOutput()
                                Logger.imageCache.info("Successfully stored image \(url) to DB")
                            } catch {
                                Logger.imageCache.error("Failed to store image \(url) to DB")
                            }
                            
                            return image
                        }
                        
                    } catch {
                        Logger.imageCache.error("Failed to fetch image \(url) although image URL present in DB")
                    }
                }
            }
        } catch {
            Logger.imageCache.info("Image \(url) not yet stored in DB")
        }
        
        // If we are here, then no image found in cache so we fetch from web
        Logger.imageCache.fault("Image \(url) not stored in DB and unable to fetch from web. Using placeholder image instead.")
        return UIImage(named: AppV2Constants.Business.placeholderImage) ?? UIImage()
    }
}

struct StubImageService: AsyncImageServiceProtocol {
    func clearAllStaleData() {}
    
    func loadImage(url: String) async -> UIImage {
        return UIImage(systemName: "star")!
    }
}
