//
//  Dictionary+Extensions.swift
//  SnappyV2
//
//  Created by Kevin Palser on 20/02/2022.
//

import Foundation

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
            case (let v1 as [String: Any], let v2 as [String: Any]): if !(v1.isEqual(to: v2)) { return false }
            case (let v1 as Double, let v2 as Double) : if !(v1==v2) { return false }
            case (let v1 as Int, let v2 as Int) : if !(v1==v2) { return false }
            case (let v1 as String, let v2 as String): if !(v1==v2) { return false }
            case (let v1 as Bool, let v2 as Bool): if !(v1==v2) { return false }
            case (let v1 as Float, let v2 as Float): if !(v1==v2) { return false }
            
                // ... fill in with types that are known to you to be
                // wrapped by the 'Any' in the dictionaries
            default: return false
            }
        }
    return true
    }
}
