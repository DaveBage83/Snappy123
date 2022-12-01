//
//  Postcode.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import CoreData

struct Postcode: Identifiable, Hashable {
    let id = UUID()
    let timestamp: Date
    let postcode: String
}
