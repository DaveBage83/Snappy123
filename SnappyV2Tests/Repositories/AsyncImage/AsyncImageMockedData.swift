//
//  AsyncImageMockedData.swift
//  SnappyV2Tests
//
//  Created by David Bage on 09/11/2022.
//

import Foundation
import UIKit
@testable import SnappyV2

extension ImageDetails {
    static let mockedData = ImageDetails(
        image: UIImage(systemName: "star"),
        fetchURLString: "testURLString",
        fetchTimestamp: Date().trueDate) // safe to use for testing given thresholds
    
    static let mockedData2 = ImageDetails(
        image: UIImage(systemName: "star"),
        fetchURLString: "testURLString2",
        fetchTimestamp: Date().trueDate) // safe to use for testing given thresholds
    
    static let mockedDataExpiredCache = ImageDetails(
        image: UIImage(systemName: "star"),
        fetchURLString: "testURLString",
        fetchTimestamp: Calendar.current.date(byAdding: .hour, value: -10, to: Date())!)
    
    var recordsCount: Int {
        var count = 0
        
        if image != nil {
            count += 1
        }
        
        return count
    }
}
