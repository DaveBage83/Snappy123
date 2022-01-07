//
//  LocalisationHelper.swift
//  SnappyV2
//
//  Created by David Bage on 06/01/2022.
//

import Foundation

public protocol SnappyString {
    var localized: String { get }
}

public protocol SnappyStringCustomisable {
    func localizedFormat(_ arguments: CVarArg...) -> String
}

public extension SnappyString where Self: RawRepresentable, Self.RawValue == String {
    
    var localized: String {
        return NSLocalizedString(rawValue, value: "**\(self)**", comment: "")
    }
}

public extension SnappyStringCustomisable where Self: RawRepresentable, Self.RawValue == String {
    func localizedFormat(_ arguments: CVarArg...) -> String {
        let localizedString = NSLocalizedString(rawValue, value: "**\(self)**", comment: "")
        return String(format: localizedString, arguments: arguments)
    }
}
