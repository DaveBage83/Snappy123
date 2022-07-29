//
//  StringProtocol+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 27/07/2022.
//

import Foundation

// Adapted from https://stackoverflow.com/questions/34454532/how-add-separator-to-string-at-every-n-characters-in-swift
// Allows us to divide card string into batches of 4

extension StringProtocol where Self: RangeReplaceableCollection {

    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.every(n: n).reversed() {
            insert(contentsOf: separator, at: index)
        }
    }

    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        .init(unfoldSubSequences(limitedTo: n).joined(separator: separator))
    }
}
