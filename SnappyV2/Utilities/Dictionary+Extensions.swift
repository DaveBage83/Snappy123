//
//  Dictionary+Extensions.swift
//  SnappyV2
//
//  Created by Kevin Palser on 20/02/2022.
//

import Foundation

import FBSDKCoreKit

// Based on: https://stackoverflow.com/questions/39164964/how-to-check-if-two-string-any-are-identical
// Usable if the 'Any' values in your dict only wraps
// a few different types _that are known to you_.
// Return false also in case value cannot be successfully
// converted to some known type. This might yield a false negative.
extension Dictionary where Value: Any {
    func isEqual(to otherDict: [Key: Any]) -> Bool {
        guard self.count == otherDict.count else { return false }
        for (k1,v1) in self {
            guard let v2 = otherDict[k1] else { return false }
            switch (v1, v2) {
            case (let v1 as [[String: Any]], let v2 as [[String: Any]]):
                guard v1.count == v2.count else { return false }
                for (index, v1SubArray) in v1.enumerated() {
                    if !(v1SubArray.isEqual(to: v2[index])) {
                        return false
                    }
                }
            case (let v1 as [[AnyHashable: Any]], let v2 as [[AnyHashable: Any]]):
                guard v1.count == v2.count else { return false }
                for (index, v1SubArray) in v1.enumerated() {
                    if !(v1SubArray.isEqual(to: v2[index])) {
                        return false
                    }
                }
            case (let v1 as [[AppEvents.ParameterName: Any]], let v2 as [[AppEvents.ParameterName: Any]]):
                guard v1.count == v2.count else { return false }
                for (index, v1SubArray) in v1.enumerated() {
                    if !(v1SubArray.isEqual(to: v2[index])) {
                        return false
                    }
                }
            case (let v1 as [String: Any], let v2 as [String: Any]):
                if !(v1.isEqual(to: v2)) {
                    return false
                }
            case (let v1 as [AnyHashable: Any], let v2 as [AnyHashable: Any]):
                if !(v1.isEqual(to: v2)) {
                    return false
                }
            case (let v1 as [AppEvents.ParameterName: Any], let v2 as [AppEvents.ParameterName: Any]):
                if !(v1.isEqual(to: v2)) {
                    return false
                }
            case (let v1 as Double, let v2 as Double):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as Int, let v2 as Int):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as String, let v2 as String):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as Bool, let v2 as Bool):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as UUID, let v2 as UUID):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as Float, let v2 as Float):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as Int64, let v2 as Int64):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as Int32, let v2 as Int32):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as Int16, let v2 as Int16):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as [Int], let v2 as [Int]):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as [String], let v2 as [String]):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as [Double], let v2 as [Double]):
                if !(v1==v2) {
                    return false
                }
            case (let v1 as [UUID], let v2 as [UUID]):
                if !(v1==v2) {
                    return false
                }
            
                // ... fill in with types that are known to you to be
                // wrapped by the 'Any' in the dictionaries
            default:
                // Fall back on broad integer value matches irrespective
                // of the integer type. Common with Core Data, which
                // has to have Int16, Int32 or Int64
                var intMatchFound = false
                var v1Int: Int64?
                switch(v1) {
                case let v1 as Int16:
                    v1Int = Int64(v1)
                case let v1 as Int32:
                    v1Int = Int64(v1)
                case let v1 as Int64:
                    v1Int = v1
                default:
                    break
                }
                if let v1Int = v1Int {
                    switch(v1) {
                    case let v2 as Int16:
                        intMatchFound = v1Int == Int64(v2)
                    case let v2 as Int32:
                        intMatchFound = v1Int == Int64(v2)
                    case let v2 as Int64:
                        intMatchFound = v1Int == v2
                    default:
                        break
                    }
                }
                if intMatchFound == false {
                    return false
                }
            }
        }
        return true
    }
}
