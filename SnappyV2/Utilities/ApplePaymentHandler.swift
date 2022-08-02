//
//  ApplePaymentHandler.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 25/07/2022.
//

import PassKit
import Frames
import OSLog
import SwiftUI

enum ApplePaymentError: Swift.Error {
    case failureToPresentPaymentController
    case emailOrPhoneNumberMissing
    case cardNotAuthorised
    case businessOrderIdNotReturned
    case makePaymentIsNil
}

extension ApplePaymentError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failureToPresentPaymentController:
            return "Failed to present payment controller"
        case .emailOrPhoneNumberMissing:
            return "Shipping email or phone number missing"
        case .cardNotAuthorised:
            return "Card was not authorised"
        case .businessOrderIdNotReturned:
            return "BusinessOrderId not returned, order failed"
        case .makePaymentIsNil:
            return ""
        }
    }
}

protocol ApplePaymentHandlerProtocol {
    typealias MakePaymentAction = (String?) async throws -> MakePaymentResponse
    
    func startApplePayment(basket: Basket, publicKey: String, merchantId: String, makePayment: @escaping MakePaymentAction) async throws -> Int?
}

class ApplePaymentHandler: NSObject, ApplePaymentHandlerProtocol {
    typealias PaymentCompletionHandler = (Result<Int, Error>) -> Void
    
    static let supportedNetworks: [PKPaymentNetwork] = [
        .masterCard,
        .visa,
        .JCB,
        .discover
    ]
    
    private var paymentController: PKPaymentAuthorizationController?
    private var paymentStatus = PKPaymentAuthorizationStatus.failure
    private var completionHandler: PaymentCompletionHandler?
    private var publicKey: String?
    private var error: Error?
    private var businessOrderId: Int?
    private var makePayment: MakePaymentAction?
    
    func startPayment(basket: Basket, publicKey: String, merchantId: String, makePayment: @escaping MakePaymentAction, completion: @escaping PaymentCompletionHandler) {
        self.makePayment = makePayment
        self.completionHandler = completion
        self.publicKey = publicKey
        
        // Create our payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = createPKPaymentSummary(basket: basket)
        paymentRequest.shippingContact = createShippingContact(basket: basket)
        paymentRequest.merchantIdentifier = merchantId
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "GB"
        paymentRequest.currencyCode = AppV2Constants.Business.currencyCode
        paymentRequest.requiredShippingContactFields = [.phoneNumber, .emailAddress]
        paymentRequest.supportedNetworks = ApplePaymentHandler.supportedNetworks
        
        // Display our payment request
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                Logger.checkout.info("Presented payment controller")
            } else {
                Logger.checkout.error("Failed to present payment controller")
                self.completionHandler!(.failure(ApplePaymentError.failureToPresentPaymentController))
            }
        })
    }
    
    private func createPKPaymentSummary(basket: Basket) -> [PKPaymentSummaryItem] {
        var paymentSummaryItems = [PKPaymentSummaryItem]()
        
        for item in basket.items {
            
            paymentSummaryItems.append(
                PKPaymentSummaryItem(
                    label: "\(item.menuItem.name) x \(item.quantity)",
                    amount: NSDecimalNumber(value: item.price * Double(item.quantity))
                )
            )
        }
        
        if let savings = basket.savings {
            for saving in savings {
                paymentSummaryItems.append(
                    PKPaymentSummaryItem(
                        label: saving.name,
                        amount: NSDecimalNumber(value: -saving.amount)
                    )
                )
            }
        }
        
        if let fees = basket.fees {
            for fee in fees {
                paymentSummaryItems.append(
                    PKPaymentSummaryItem(
                        label: fee.title,
                        amount: NSDecimalNumber(value: fee.amount)
                    )
                )
            }
        }
        
        if let tips = basket.tips, let tip = tips.first, tip.type == "driver"  {
            paymentSummaryItems.append(
                PKPaymentSummaryItem(
                    label: "Driver Tip",
                    amount: NSDecimalNumber(value: tip.amount)
                )
            )
        }
        
        if let coupon = basket.coupon, coupon.deductCost > 0 {
            paymentSummaryItems.append(
                PKPaymentSummaryItem(
                    label: coupon.name,
                    amount: NSDecimalNumber(value: -coupon.deductCost)
                )
            )
        }
        
        // Final line for total
        paymentSummaryItems.append(
            PKPaymentSummaryItem(
                label: "Snappy Shopper",
                amount: NSDecimalNumber(value: basket.orderTotal)
            )
        )
        
        return paymentSummaryItems
    }
    
    private func createShippingContact(basket: Basket) -> PKContact {
        let shippingContact = PKContact()
        
        if basket.fulfilmentMethod.type == .delivery {
            if let addresses = basket.addresses, let delivery = addresses.first(where: {$0.type == "delivery"}) {
                let shippingAddress = CNMutablePostalAddress()
                shippingAddress.city = delivery.town
                shippingAddress.postalCode = delivery.postcode
                if let street = delivery.addressLine1 {
                    shippingAddress.street = street
                }
                if let subLocality = delivery.addressLine2 {
                    shippingAddress.subLocality = subLocality
                }
                shippingContact.postalAddress = shippingAddress
            }
        }
        
        if let addresses = basket.addresses, let billing = addresses.first(where: {$0.type == "billing"}) {
            if let email = billing.email {
                shippingContact.emailAddress = email
            }
            if let telephone = billing.telephone {
                shippingContact.phoneNumber = CNPhoneNumber(stringValue: telephone)
            }
        }
        
        return shippingContact
    }
}

extension ApplePaymentHandler {
    func startApplePayment(basket: Basket, publicKey: String, merchantId: String, makePayment: @escaping MakePaymentAction) async throws -> Int? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) -> Void in
            startPayment(basket: basket, publicKey: publicKey, merchantId: merchantId, makePayment: makePayment) { result in
                switch result {
                case .success(_):
                    if let businessOrderId = self.businessOrderId {
                        continuation.resume(with: .success((businessOrderId)))
                    }
                case .failure(_):
                    if let error = self.error {
                        continuation.resume(with: .failure(error))
                    }
                }
            }
        }
    }
}

extension CheckoutAPIClient {
    func createApplePayToken(paymentData: Data) async throws -> CkoCardTokenResponse {
       return try await withCheckedThrowingContinuation { continuation in
            createApplePayToken(paymentData: paymentData) { result in
                continuation.resume(with: result)
            }
        }
    }
}

extension ApplePaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // Perform some very basic validation on the provided contact information
        if payment.shippingContact?.emailAddress == nil || payment.shippingContact?.phoneNumber == nil {
            self.error = ApplePaymentError.emailOrPhoneNumberMissing
            completion(.failure)
        } else {
            guard let publicKey = self.publicKey else { paymentStatus = .failure; return }
            
            #warning("Environment needs to change depending on debug or release versions")
            let checkoutAPIClient = CheckoutAPIClient(publicKey: publicKey, environment: .sandbox)
            let paymentData = payment.token.paymentData
            
            Task {
                do {
                    let tokenResponse = try await checkoutAPIClient.createApplePayToken(paymentData: paymentData)
                    
                    guard let makePayment = makePayment else { throw ApplePaymentError.makePaymentIsNil }
                    
                    let makePaymentResponse = try await makePayment(tokenResponse.token)
                    
                    // check if businessOrderId is returned for success
                    if let businessOrderId = makePaymentResponse.order?.businessOrderId {
                        self.businessOrderId = businessOrderId
                    } else {
                        self.error = ApplePaymentError.businessOrderIdNotReturned
                        paymentStatus = .failure
                    }
                    
                    paymentStatus = .success
                } catch {
                    self.error = error
                    paymentStatus = .failure
                }
                completion(paymentStatus)
            }
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            guaranteeMainThread {
                if self.paymentStatus == .success {
                    if let businessOrderId = self.businessOrderId {
                        self.completionHandler!(.success((businessOrderId)))
                    }
                } else {
                    if let error = self.error {
                        self.completionHandler!(.failure(error))
                    }
                }
            }
        }
    }
    
}
