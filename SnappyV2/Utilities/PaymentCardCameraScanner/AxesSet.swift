//
//  AxesSet.swift
//  
//
//  Created by Russell Warwick on 01/05/2021.
//

import UIKit

struct AxesSet: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension AxesSet {
    static let vertical = AxesSet(rawValue: 1 << 0)
    static let horizontal = AxesSet(rawValue: 1 << 1)
    static let both: AxesSet = [vertical, horizontal]
}
