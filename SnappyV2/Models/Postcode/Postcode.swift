//
//  Postcode.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import CoreData
import Combine

struct Postcode: Identifiable, Hashable {
    let id = UUID()
    let timestamp: Date
    let postcode: String
}

extension PostcodeMO {
    static func fetchRequest(postcode: String) -> NSFetchRequest<PostcodeMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "postcode == %@", postcode)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchAllPostcodes() -> NSFetchRequest<PostcodeMO> {
        let request = newFetchRequest()
        return request
    }
}

extension PostcodeMO: ManagedEntity {}
