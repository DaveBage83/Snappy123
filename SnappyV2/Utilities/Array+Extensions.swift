//
//  Array+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 15/06/2022.
//
// From https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
