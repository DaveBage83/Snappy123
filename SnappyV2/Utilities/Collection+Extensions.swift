//
//  Collection+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 27/07/2022.
//

import Foundation
// Adapted from https://stackoverflow.com/questions/34454532/how-add-separator-to-string-at-every-n-characters-in-swift
// Allows us to divide card string into batches of 4
extension Collection {

    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence,Index> {
        sequence(state: startIndex) { start in
            guard start < endIndex else { return nil }
            let end = index(start, offsetBy: maxLength, limitedBy: endIndex) ?? endIndex
            defer { start = end }
            return self[start..<end]
        }
    }

    func every(n: Int) -> UnfoldSequence<Element,Index> {
        sequence(state: startIndex) { index in
            guard index < endIndex else { return nil }
            defer { let _ = formIndex(&index, offsetBy: n, limitedBy: endIndex) }
            return self[index]
        }
    }

    var pairs: [SubSequence] { .init(unfoldSubSequences(limitedTo: 4)) }
}
