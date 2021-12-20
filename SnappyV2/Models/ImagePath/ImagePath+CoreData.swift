//
//  ImagePath+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/10/2021.
//

import Foundation
import CoreData

extension ImagePathMO: ManagedEntity { }
extension ImageMO: ManagedEntity { }

extension ImagePathMO {
    
    static func dictionary(from images: NSOrderedSet?) -> [String : URL]? {
        
        var dictionaryResult: [String : URL]?
        
        if let images = images {
            dictionaryResult = images
                .toArray(of: ImagePathMO.self)
                .reduce(nil, { (dict, record) -> [String: URL]? in
                    guard
                        let scale = record.scale,
                        let url = record.url
                    else { return dict }
                    var dict = dict ?? [:]
                    dict[scale] = url
                    return dict
                })
        }
        
        return dictionaryResult
        
    }
    
    static func dictionary(from images: NSSet?) -> [String : URL]? {
        
        var dictionaryResult: [String : URL]?
        
        if let images = images {
            dictionaryResult = images
                .toArray(of: ImagePathMO.self)
                .reduce(nil, { (dict, record) -> [String: URL]? in
                    guard
                        let scale = record.scale,
                        let url = record.url
                    else { return dict }
                    var dict = dict ?? [:]
                    dict[scale] = url
                    return dict
                })
        }
        
        return dictionaryResult
        
    }
    
    static func arrayOfDictionaries(from images: NSOrderedSet?) -> [[String : URL]]? {
        
        var arrayResult: [[String : URL]]?
        
        if
            let images = images,
            let imagesArray = images.array as? [ImageMO]
        {
            arrayResult = imagesArray
                .reduce(nil, { (imageArray, imageRecord) -> [[String : URL]]? in
                    guard let dictionaryEntry = ImagePathMO.dictionary(from: imageRecord.imagePaths)
                    else { return imageArray }
                    var array = imageArray ?? []
                    array.append(dictionaryEntry)
                    return array
                })
        }
        
        return arrayResult
    }
    
    static func set(from images: [String : URL]?, in context: NSManagedObjectContext) -> NSSet? {
        
        var setResult: NSSet?
        
        if let images = images {
            setResult = NSSet(array: images.compactMap({ (scale, url) -> ImagePathMO? in
                guard let image = ImagePathMO.insertNew(in: context)
                else { return nil }
                image.scale = scale
                image.url = url
                return image
            }))
        }
        
        return setResult
        
    }
    
    static func orderedSet(from images: [String : URL]?, in context: NSManagedObjectContext) -> NSOrderedSet? {
        
        var setResult: NSOrderedSet?
        
        if let images = images {
            setResult = NSOrderedSet(array: images.compactMap({ (scale, url) -> ImagePathMO? in
                guard let image = ImagePathMO.insertNew(in: context)
                else { return nil }
                image.scale = scale
                image.url = url
                return image
            }))
        }
        
        return setResult
        
    }
    
    static func orderedSet(from images: [[String : URL]]?, in context: NSManagedObjectContext) -> NSOrderedSet? {
        
        var orderedSetResult: NSOrderedSet?
        
        if let images = images {
            orderedSetResult = NSOrderedSet(array: images.compactMap({ dictionaryEntry -> ImageMO? in
                guard
                    let imagePaths = ImagePathMO.set(from: dictionaryEntry, in: context),
                    let image = ImageMO.insertNew(in: context)
                else { return nil }
                image.imagePaths = imagePaths
                return image
            }))
        }
        
        return orderedSetResult
    }
    
}
