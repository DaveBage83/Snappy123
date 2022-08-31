//
//  PaymentCardEntryViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 24/08/2022.
//

import Foundation
import Frames
import Combine

enum PaymentCardEntryViewModelError: Error {
    case missingBusinessProfileOrPublicKey
}

@MainActor
final class PaymentCardEntryViewModel: ObservableObject {
    typealias CheckoutComClient = (String, Environment) -> CheckoutAPIClientProtocol
    private let checkoutComClient: CheckoutComClient
    let container: DIContainer
    
    private let cardUtils = CardUtils()
    @Published var creditCardName: String = ""
    @Published var creditCardNumber: String = ""
    @Published var creditCardExpiryMonth: String = ""
    @Published var creditCardExpiryYear: String = ""
    @Published var creditCardCVV: String = ""
    @Published var isUnvalidCardNumber: Bool = false
    @Published var isUnvalidCVV: Bool = false
    @Published var isUnvalidExpiry: Bool = false
    @Published var cardType: CardType?
    @Published var showCardCamera: Bool = false
    @Published var savingNewCard: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    var shownCardType: PaymentCardType? {
        switch cardType?.scheme {
        case .visa:
            return .visa
        case .mastercard:
            return .masterCard
        case .jcb:
            return .jcb
        case .discover:
            return .discover
        default:
            return nil
        }
    }
    var showVisaCard: Bool { (shownCardType == .visa || shownCardType == nil) }
    var showMasterCardCard: Bool { (shownCardType == .masterCard || shownCardType == nil) }
    var showJCBCard: Bool { (shownCardType == .jcb || shownCardType == nil) }
    var showDiscoverCard: Bool { (shownCardType == .discover || shownCardType == nil) }
    
    @Published var error: Error?
    private var memberProfile: MemberProfile?
    @Published var dismissView: Bool = false
    
    var isUnvalidCardName: Bool {
        creditCardName.isEmpty && creditCardNumber.isEmpty == false && creditCardCVV.isEmpty == false
    }
    
    var saveNewCardButtonDisabled: Bool {
        (creditCardName.isEmpty || creditCardNumber.isEmpty || creditCardExpiryMonth.isEmpty || creditCardExpiryYear.isEmpty || creditCardCVV.isEmpty) || (isUnvalidCardName || isUnvalidCardNumber || isUnvalidExpiry || isUnvalidCVV)
    }
    
    init(container: DIContainer, checkoutComClient: @escaping CheckoutComClient = { CheckoutAPIClient(publicKey: $0, environment: $1) }) {
        self.checkoutComClient = checkoutComClient
        self.container = container
        self.memberProfile = container.appState.value.userData.memberProfile
        if let memberProfile = self.memberProfile {
            self.creditCardName = memberProfile.firstname + " " + memberProfile.lastname
        }
        
        setupCreditCardNumber()
        setupCreditCardCVV()
        setupCreditCardExpiry()
    }
    
    func setupCreditCardNumber() {
        $creditCardNumber
            .receive(on: RunLoop.main)
            .sink { [weak self] number in
                guard let self = self else { return }
                if number.isEmpty { return }
                if !number.isEmpty && self.isUnvalidCardNumber { self.isUnvalidCardNumber = false }
                self.cardType = self.cardUtils.getTypeOf(cardNumber: number)
                self.isUnvalidCardNumber = self.cardUtils.isValid(cardNumber: number) == false
            }
            .store(in: &cancellables)
    }
    
    func setupCreditCardCVV() {
        $creditCardCVV
            .receive(on: RunLoop.main)
            .sink { [weak self] cvv in
                guard let self = self else { return }
                if !cvv.isEmpty && self.isUnvalidCVV { self.isUnvalidCVV = false }
                if let cardType = self.cardType {
                    self.isUnvalidCVV = self.cardUtils.isValid(cvv: cvv, cardType: cardType) == false
                }
            }
            .store(in: &cancellables)
    }
    
    func setupCreditCardExpiry() {
        Publishers.CombineLatest($creditCardExpiryMonth, $creditCardExpiryYear)
            .receive(on: RunLoop.main)
            .sink { [weak self] month, year in
                guard let self = self else { return }
                if month.isEmpty && year.isEmpty { return }
                if (!month.isEmpty && !year.isEmpty) && self.isUnvalidExpiry { self.isUnvalidExpiry = false }
                self.isUnvalidExpiry = self.cardUtils.isValid(expirationMonth: month, expirationYear: year) == false
            }
            .store(in: &cancellables)
    }
    
    func areCardDetailsValid() -> Bool {
        self.isUnvalidCardNumber = self.cardUtils.isValid(cardNumber: creditCardNumber) == false
        self.isUnvalidExpiry = self.cardUtils.isValid(expirationMonth: creditCardExpiryMonth, expirationYear: creditCardExpiryYear) == false
        if let cardType = self.cardType {
            self.isUnvalidCVV = self.cardUtils.isValid(cvv: creditCardCVV, cardType: cardType) == false
        }
        return isUnvalidCVV == false && isUnvalidExpiry == false && isUnvalidCardNumber == false && isUnvalidCardName == false
    }
    
    func showCardCameraTapped() {
        showCardCamera = true
    }
    
    func handleCardCameraReturn(name: String?, number: String?, expiry: String?) {
        creditCardName = name ?? ""
        creditCardNumber = number?.replacingOccurrences(of: " ", with: "") ?? ""
        creditCardExpiryMonth = String(expiry?.prefix(2) ?? "")
        creditCardExpiryYear = String(expiry?.suffix(2) ?? "")
    }
    
    func filterCardNumber(newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        if filtered != newValue {
            self.creditCardNumber = filtered
        }
    }
    
    func filterCardCVV(newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        if filtered != newValue {
            self.creditCardCVV = filtered
        }
    }
    
    func saveCardTapped(address: Address) async {
        guard areCardDetailsValid() else { return }
        savingNewCard = true
        
        do {
            let token = try await createCardToken(address: address)
            
            try await container.services.memberService.saveNewCard(token: token)
            
            savingNewCard = false
            dismissView = true
        } catch {
            self.error = error
            
            savingNewCard = false
            dismissView = true
        }
    }
    
    private func createCardToken(address: Address) async throws -> String {
        if let paymentGateway = container.appState.value.businessData.businessProfile?.paymentGateways.first(where: { $0.name == "checkoutcom"}),
            let publicKey = paymentGateway.fields?.first(where: { $0.0 == "publicKey"}),
            let publicKeyString = publicKey.1 as? String
        {
            // Create a CheckoutAPIClient instance with the public key.
            let checkoutAPIClient = self.checkoutComClient(publicKeyString,
                paymentGateway.mode == .live ? .live : .sandbox)
            
            // Add phone number from member profile
            let phoneNumber = CkoPhoneNumber(
                countryCode: nil,
                number: memberProfile?.mobileContactNumber)
            
            // add address injected from EditAddressViewModel
            let address = CkoAddress(
                addressLine1: address.addressLine1,
                addressLine2: nil,
                city: nil,
                state: nil,
                zip: address.postcode,
                country: address.countryCode)
            
            let cardTokenRequest = CkoCardTokenRequest(
                number: creditCardNumber,
                expiryMonth: creditCardExpiryMonth,
                expiryYear: creditCardExpiryYear,
                cvv: creditCardCVV,
                name: creditCardName,
                billingAddress: address,
                phone: phoneNumber)
            
            // Request the card token.
            return try await checkoutAPIClient.createCardToken(card: cardTokenRequest).token
        } else {
            throw PaymentCardEntryViewModelError.missingBusinessProfileOrPublicKey
        }
    }
}
