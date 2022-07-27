//
//  Bool+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 27/07/2022.
//

import Foundation


// Converts Bool to Int for use when ordering arrays by a boolean value
// We use 0 for true and 1 for false

extension Bool {
    var intValue: Int {
        return self ? 0 : 1
    }
}
