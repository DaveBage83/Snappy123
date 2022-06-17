//
//  Sequence+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/06/2022.
//

import Foundation

// From: https://www.swiftbysundell.com/articles/sorting-swift-collections/
extension Sequence {
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
}
