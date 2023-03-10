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
        firstOrder: false,
        paymentMethods: nil
    )
    
    static let mockedFirstCashData = DraftOrderResult(
        draftOrderId: 9999,
        businessOrderId: 6666,
        firstOrder: true,
        paymentMethods: nil
    )
    
    static let mockedCardData = DraftOrderResult(
        draftOrderId: 9999,
        businessOrderId: nil,
        firstOrder: false,
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

extension Data {
    
    static let mockedGlobalpaymentsProducerData = "{\n  \"isTestMode\" : true,\n  \"HPPProducerData\" : {\n    \"SHIPPING_CODE\" : \"PA34 4AG\",\n    \"BILLING_CODE\" : \"40|48\",\n    \"HPP_BILLING_STREET2\" : \"\",\n    \"HPP_BILLING_COUNTRY\" : \"826\",\n    \"HPP_CUSTOMER_PHONENUMBER_MOBILE\" : \"44|07923304512\",\n    \"OFFER_SAVE_CARD\" : \"1\",\n    \"HPP_CHALLENGE_REQUEST_INDICATOR\" : \"CHALLENGE_MANDATED\",\n    \"HPP_VERSION\" : \"2\",\n    \"SHA1HASH\" : \"664922523eae38b86c1d8c30d137bb130f0ab2e7\",\n    \"HPP_CUSTOMER_EMAIL\" : \"kevin.palser@gmail.com\",\n    \"status\" : \"success\",\n    \"HPP_BILLING_CITY\" : \"DUNDEE\",\n    \"HPP_SHIPPING_STREET1\" : \"SKILLS DEVELOPMENT SCOTLAND\",\n    \"HPP_SHIPPING_POSTALCODE\" : \"PA34 4AG\",\n    \"HPP_SHIPPING_STREET2\" : \"ALBANY STREET\",\n    \"HPP_SHIPPING_STREET3\" : \"\",\n    \"HPP_BILLING_STREET1\" : \"48 BALLUMBIE DRIVE\",\n    \"HPP_BILLING_POSTALCODE\" : \"DD4 0NP\",\n    \"TIMESTAMP\" : \"20220224163125\",\n    \"AUTO_SETTLE_FLAG\" : \"1\",\n    \"HPP_BILLING_STREET3\" : \"\",\n    \"SHIPPING_CO\" : \"826\",\n    \"HPP_ADDRESS_MATCH_INDICATOR\" : \"FALSE\",\n    \"AMOUNT\" : \"1258\",\n    \"BILLING_CO\" : \"826\",\n    \"PAYER_EXIST\" : \"0\",\n    \"HPP_SHIPPING_CITY\" : \"OBAN\",\n    \"ACCOUNT\" : \"3DS2\",\n    \"MERCHANT_ID\" : \"snappyshopperltd\",\n    \"ORDER_ID\" : \"MmM1ZmI1NWEtNjUyNmEyMw\",\n    \"CURRENCY\" : \"GBP\",\n    \"HPP_SHIPPING_COUNTRY\" : \"826\"\n  }\n}".data(using: .utf8) ?? Data()
    
}

extension Dictionary: Any where Key == String, Value == Any {
    
    static let mockedGlobalpaymentsHPPResponse = [
        "AUTHCODE" : "MTIzNDU=",
        "ECI" : "MDU=",
        "HPP_BILLING_STREET2" : "",
        "BILLING_CO" : "ODI2",
        "SHA1HASH" : "MzJmYjc4ZDZkOWJhZWM0NDM3MzIxNTQ0ZWE3ZWQ2ODY5OGViNzA5OA==",
        "HPP_CUSTOMER_EMAIL" : "a2V2aW4ucGFsc2VyQGdtYWlsLmNvbQ==",
        "MESSAGE" : "WyB0ZXN0IHN5c3RlbSBdIEFVVEhPUklTRUQ=",
        "CVNRESULT" : "TQ==",
        "AVSADDRESSRESULT" : "TQ==",
        "pas_uuid" : "NDI1NWY3ZTUtNzFmNy00NGU2LWIxYWYtODcxMWJmZTNkZGY0",
        "HPP_BILLING_CITY" : "RFVOREVF",
        "TIMESTAMP" : "MjAyMjAyMjQxNjMxMjU=",
        "ORDER_ID" : "TW1NMVptSTFOV0V0TmpVeU5tRXlNdw==",
        "HPP_BILLING_COUNTRY" : "ODI2",
        "HPP_SHIPPING_STREET3" : "",
        "HPP_SHIPPING_COUNTRY" : "ODI2",
        "PASREF" : "MTY0NTcyMDM3NDkzNDkzNDI=",
        "HPP_CHALLENGE_REQUEST_INDICATOR" : "Q0hBTExFTkdFX01BTkRBVEVE",
        "BILLING_CODE" : "NDB8NDg=",
        "MESSAGE_VERSION" : "Mi4xLjA=",
        "AUTHENTICATION_VALUE" : "QUFrQkJXaFFrUUFBQUFUcWdtQlZkQW9QRnd3PQ==",
        "HPP_BILLING_STREET3" : "",
        "ACCOUNT" : "M2RzMg==",
        "HPP_CUSTOMER_PHONENUMBER_MOBILE" : "NDR8MDc5MjMzMDQ1MTI=",
        "AVSPOSTCODERESULT" : "TQ==",
        "HPP_SHIPPING_STREET2" : "QUxCQU5ZIFNUUkVFVA==",
        "RESULT" : "MDA=",
        "status" : "c3VjY2Vzcw==",
        "XID" : "",
        "HPP_SHIPPING_POSTALCODE" : "UEEzNCA0QUc=",
        "HPP_BILLING_STREET1" : "NDggQkFMTFVNQklFIERSSVZF",
        "CAVV" : "",
        "SRD" : "b2wxcmdxRWVRUmR4Y3BYMw==",
        "DS_TRANS_ID" : "ODA5NjkzOWYtZTNjMy00M2FkLWJjYjctYmRjM2U0MmE0MDg5",
        "HPP_BILLING_POSTALCODE" : "REQ0IDBOUA==",
        "BATCHID" : "MTA1NjMxMw==",
        "HPP_SHIPPING_STREET1" : "U0tJTExTIERFVkVMT1BNRU5UIFNDT1RMQU5E",
        "HPP_SHIPPING_CITY" : "T0JBTg==",
        "AMOUNT" : "MTI1OA==",
        "MERCHANT_ID" : "c25hcHB5c2hvcHBlcmx0ZA==",
        "HPP_ADDRESS_MATCH_INDICATOR" : "RkFMU0U=",
        "SHIPPING_CO" : "ODI2",
        "SHIPPING_CODE" : "UEEzNCA0QUc="
    ]
    
}

extension ConfirmPaymentResponse {
    
    static let mockedData = ConfirmPaymentResponse(
        result: ShimmedPaymentResponse.mockedData
    )
    
}

extension MakePaymentResponse {
    
    static let mockedData3DSChallenge = MakePaymentResponse(
        gatewayData: GatewayData(
            id: "pay_lq7znmvow65efgyqxrbhlrm6wm",
            status: .pending,
            gateway: "checkoutcom",
            saveCard: false,
            paymentMethod: "card",
            approved: nil,
            _links: ThreeDSLinks(
                redirect: HREF(href: "https://api.sandbox.checkout.com/sessions-interceptor/sid_7dnawxhjnjpu3gj7y2fkuszwfa"),
                success: HREF(href: "https://v1-staging.snappyshopper.co.uk/takeaway/checkout/payment/?success=true&platform=ios&o=1970016"),
                failure: HREF(href: "https://v1-staging.snappyshopper.co.uk/takeaway/checkout/payment/?failure=true&platform=ios&o=1970016")
            )
        ),
        order: nil
    )
}

extension VerifyPaymentResponse {
    static let mockedData = VerifyPaymentResponse(
        draftOrderId: 1970016,
        businessOrderId: 3878,
        pointsEarned: 0,
        basketToken: "b9457d74d5754f2dd12f6f40ff65e978",
        message: "Payment confirmed"
    )
}

extension ShimmedPaymentResponse {
    
    static let mockedData = ShimmedPaymentResponse(
        status: true,
        message: "Payment confirmed",
        orderId: 1963469,
        businessOrderId: 2158,
        pointsEarned: 0,
        iterableUserEmail: nil
    )
    
}

extension PlacedOrderStatus {
    
    static let mockedData = PlacedOrderStatus(
        status: "Store Accepted / Picking"
    )
    
}

extension DriverLocation {
    
    static let mockedDataEnRoute = DriverLocation(
        orderId: 5978136,
        pusher: PusherConfiguration.mockedData,
        store: StoreLocation.mockedData,
        delivery: OrderDeliveryLocationAndStatus.mockedDataEnRoute,
        driver: DeliveryDriverLocationAndName.mockedData
    )
    
    static let mockedDataDelivered = DriverLocation(
        orderId: 5978136,
        pusher: PusherConfiguration.mockedData,
        store: StoreLocation.mockedData,
        delivery: OrderDeliveryLocationAndStatus.mockedDataDelivered,
        driver: DeliveryDriverLocationAndName.mockedData
    )
    
}

extension PusherConfiguration {
    
    static let mockedData = PusherConfiguration(
        clusterServer: "eu",
        appKey: "dd1506734a87e7be40d9"
    )
    
}

extension StoreLocation {
    
    static let mockedData = StoreLocation(
        latitude: 56.4087526,
        longitude: -5.4875930999999998
    )
    
}

extension OrderDeliveryLocationAndStatus {
    
    static let mockedDataEnRoute = OrderDeliveryLocationAndStatus(
        latitude: 37.3302,
        longitude: -122.0232,
        status: 5
    )
    
    static let mockedDataDelivered = OrderDeliveryLocationAndStatus(
        latitude: 37.3302,
        longitude: -122.0232,
        status: 2
    )

}

extension DeliveryDriverLocationAndName {
    
    static let mockedData = DeliveryDriverLocationAndName(
        name: "Kevin Driver",
        latitude: 37.331002310000002,
        longitude: -122.03077622000001
    )
    
}

extension LastDeliveryOrderOnDevice {
    
    static let mockedData = LastDeliveryOrderOnDevice(
        businessOrderId: 4290187,
        storeName: "Mace Dundee",
        storeContactNumber: "01382 12345445",
        deliveryPostcode: "DD2 1RW"
    )
    
}

extension DriverLocationMapParameters {
    
    static let mockedWithLastOrderData = DriverLocationMapParameters(
        businessOrderId: 4290187,
        driverLocation:  DriverLocation(
            orderId: 5978136,
            pusher: PusherConfiguration(
                clusterServer: "eu",
                appKey: "dd1506734a87e7be40d9"
            ),
            store: StoreLocation(
                latitude: 56.4087526,
                longitude: -5.4875930999999998
            ),
            delivery: OrderDeliveryLocationAndStatus.mockedDataEnRoute,
            driver: DeliveryDriverLocationAndName.mockedData
        ),
        lastDeliveryOrder: LastDeliveryOrderOnDevice.mockedData,
        placedOrder: nil
    )
    
    static let mockedWithPlacedOrderData = DriverLocationMapParameters(
        businessOrderId: PlacedOrder.mockedData.businessOrderId,
        driverLocation: DriverLocation.mockedDataEnRoute,
        lastDeliveryOrder: nil,
        placedOrder: PlacedOrder.mockedData
    )
    
}

extension CheckoutCardDetails {
    static let mockedCard = CheckoutCardDetails(
        number: "4242424242424242",
        expiryMonth: 05,
        expiryYear: 25,
        cvv: "100",
        cardName: "Some Name"
    )
}

extension CheckoutCom3DSURLs {
    static let mockedData = CheckoutCom3DSURLs(
        redirectUrl: URL(string: "https://www.snappyshopper.co.uk")!,
        successUrl: URL(string: "https://www.snappyshopper.co.uk")!,
        failUrl: URL(string: "https://www.snappyshopper.co.uk")!
    )
}

extension SetPreviousOrderedDeviceStateResult {
    static let mockedSuccessfullySet = SetPreviousOrderedDeviceStateResult(success: true)
    static let mockedUnsuccessfullySet = SetPreviousOrderedDeviceStateResult(success: false)
}
