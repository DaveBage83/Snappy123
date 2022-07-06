//
//  UtilityMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/06/2022.
//

import Foundation

@testable import SnappyV2

extension ShimmedMentionMeCallHomeResponse {
    
    static let mockedData = ShimmedMentionMeCallHomeResponse(
        status: true,
        message: nil,
        requestUrl: nil,
        request: nil,
        openInBrowser: nil,
        applyCoupon: nil,
        postMessageEvent: nil
    )
    
}
