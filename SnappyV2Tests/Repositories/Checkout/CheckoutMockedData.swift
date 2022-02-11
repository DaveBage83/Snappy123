//
//  CheckoutMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 10/02/2022.
//

import Foundation
@testable import SnappyV2

extension DraftOrderResult {

    static let mockedCashData = DraftOrderResult(
        draftOrderId: 9999,
        businessOrderId: 6666,
        paymentMethods: nil
    )
    
}

extension DraftOrderFulfilmentDetailsRequest {
    
    static let mockedData = DraftOrderFulfilmentDetailsRequest(
        time: DraftOrderFulfilmentDetailsTimeRequest.mockedData,
        place: nil
    )
    
}

extension DraftOrderFulfilmentDetailsTimeRequest {
    
    static let mockedData = DraftOrderFulfilmentDetailsTimeRequest(
        date: "2022-02-11",
        requestedTime: "11:45 - 12:00"
    )
    
}
