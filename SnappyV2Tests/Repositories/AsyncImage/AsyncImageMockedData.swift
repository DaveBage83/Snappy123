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
        image: UIImage(named: AppV2Constants.Business.placeholderImage)!,
        fetchURLString: "testURLString",
        fetchTimestamp: nil) // safe to use for testing given thresholds
    
    var recordsCount: Int {
        var count = 0
        
        if image != nil {
            count += 1
        }
        
        return count
    }
}
