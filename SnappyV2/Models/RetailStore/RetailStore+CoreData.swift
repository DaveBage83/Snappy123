//
//  RetailStore+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 21/09/2021.
//

import Foundation
import CoreData

extension RetailStoresSearchMO: ManagedEntity { }
extension RetailStoreMO: ManagedEntity { }
extension RetailStoreLogoMO: ManagedEntity { }
extension RetailStoreProductTypeMO: ManagedEntity { }
extension RetailStoreProductTypeImageMO: ManagedEntity { }

extension RetailStoresSearch {
    
    init?(managedObject: RetailStoresSearchMO) {
        
        var storeProductTypes: [RetailStoreProductType]?
        var stores: [RetailStore]?
        
        if let productTypesFound = managedObject.productTypesFound {
            storeProductTypes = productTypesFound
                .toArray(of: RetailStoreProductTypeMO.self)
                .reduce(nil, { (productTypeArray, record) -> [RetailStoreProductType]? in
                    guard let productType = RetailStoreProductType(managedObject: record)
                    else { return productTypeArray }
                    var array = productTypeArray ?? []
                    array.append(productType)
                    return array
                })
        }
        
        if let storesFound = managedObject.storesFound {
            stores = storesFound
                .toArray(of: RetailStoreMO.self)
                .reduce(nil, { (storeArray, record) -> [RetailStore]? in
                    guard let store = RetailStore(managedObject: record)
                    else { return storeArray }
                    var array = storeArray ?? []
                    array.append(store)
                    return array
                })
        }
        
        self.init(storeProductTypes: storeProductTypes, stores: stores)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoresSearchMO? {
        
        guard let search = RetailStoresSearchMO.insertNew(in: context)
            else { return nil }
        
        var productTypesDictionary: [Int: RetailStoreProductTypeMO] = [:]
        
        if let productTypes = storeProductTypes {
            search.productTypesFound = NSSet(array: productTypes.compactMap({ productType -> RetailStoreProductTypeMO? in
                let productTypeMO = productType.store(in: context)
                if let productTypeMO = productTypeMO {
                    productTypesDictionary[Int(productTypeMO.id)] = productTypeMO
                }
                return productTypeMO
            }))
        }
        
        if let stores = stores {
            search.storesFound = NSSet(array: stores.compactMap({ retailStore -> RetailStoreMO? in
                let retailStoreMO = retailStore.store(in: context)
                if
                    let retailStoreMO = retailStoreMO,
                    let storeProductTypes = retailStore.storeProductTypes
                {
                    retailStoreMO.productTypes = NSOrderedSet(array: storeProductTypes.compactMap({ productTypeId -> RetailStoreProductTypeMO? in
                        return productTypesDictionary[productTypeId]
                    }))
                }
                return retailStoreMO
            }))
        }
        
        return search
    }
}

extension RetailStore {
    
    init?(managedObject: RetailStoreMO) {
        
        var storeLogo: [String : URL]?
        var storeProductTypes: [Int]?
        
        if let logos = managedObject.logoImages {
            storeLogo = logos
                .toArray(of: RetailStoreLogoMO.self)
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
        
        if
            let productTypes = managedObject.productTypes,
            let productTypesArray = productTypes.array as? [RetailStoreProductTypeMO]
        {
            storeProductTypes = productTypesArray
                .reduce(nil, { (intArray, record) -> [Int]? in
                    var array = intArray ?? []
                    array.append(Int(record.id))
                    return array
                })
        }
        
        self.init(
            id: Int(managedObject.id),
            storeName: managedObject.name ?? "",
            distance: managedObject.distance,
            storeLogo: storeLogo,
            storeProductTypes: storeProductTypes
        )

    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreMO? {
        
        guard let store = RetailStoreMO.insertNew(in: context)
            else { return nil }
        
        store.id = Int64(id)
        store.name = storeName
        store.distance = distance

        if let images = storeLogo {
            let storeLogoImages = images.compactMap({ (scale, url) -> RetailStoreLogoMO? in
                guard let logo = RetailStoreLogoMO.insertNew(in: context)
                else { return nil }
                logo.scale = scale
                logo.url = url
                return logo
            })
            
            if storeLogoImages.count != 0 {
                store.logoImages = NSSet(array: storeLogoImages)
            }
        }
        
        return store
    }
    
}

extension RetailStoreProductType {
    
    init?(managedObject: RetailStoreProductTypeMO) {
        
        var typeLogo: [String : URL]?
        
        if let images = managedObject.images {
            typeLogo = images
                .toArray(of: RetailStoreLogoMO.self)
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

        self.init(
            id: Int(managedObject.id),
            name: managedObject.name ?? "",
            image: typeLogo
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RetailStoreProductTypeMO? {
        
        guard let productType = RetailStoreProductTypeMO.insertNew(in: context)
            else { return nil }
        
        productType.id = Int64(id)
        productType.name = name

        if let imageArray = image {
            let productTypeImages = imageArray.compactMap({ (scale, url) -> RetailStoreProductTypeImageMO? in
                guard let image = RetailStoreProductTypeImageMO.insertNew(in: context)
                else { return nil }
                image.scale = scale
                image.url = url
                return image
            })
            
            if productTypeImages.count != 0 {
                productType.images = NSSet(array: productTypeImages)
            }
        }
        
        return productType
    }
    
}
