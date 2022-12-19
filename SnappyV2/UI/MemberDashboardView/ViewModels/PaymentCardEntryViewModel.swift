//
//  PaymentCardEntryViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 24/08/2022.
//

import Foundation
import Checkout
import Combine

enum PaymentCardEntryViewModelError: Error {
    case missingBusinessProfileOrPublicKey
}

@MainActor
final class PaymentCardEntryViewModel: ObservableObject {
    typealias CheckoutComClient = (String, Checkout.Environment) -> CheckoutAPIServiceProtocol
    private let checkoutComClient: CheckoutComClient
    let container: DIContainer
    
    private let cardUtils: CardValidator
    private let paymentEvironment: PaymentGatewayMode
    @Published var creditCardName: String = ""
    @Published var creditCardNumber: String = ""
    @Published var creditCardExpiryMonth: String = ""
    @Published var creditCardExpiryYear: String = ""
    var creditCardExpiry: ExpiryDate?
    @Published var creditCardCVV: String = ""
    @Published var isUnvalidCardNumber: Bool = false
    @Published var isUnvalidCVV: Bool = false
    @Published var isUnvalidExpiry: Bool = false
    @Published var cardType: Card.Scheme?
    @Published var showCardCamera: Bool = false
    @Published var savingNewCard: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    var shownCardType: PaymentCardType? {
        switch cardType {
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
    
    private var memberProfile: MemberProfile?
    @Published var dismissView: Bool = false
    
    var isUnvalidCardName: Bool {
        creditCardName.isEmpty && creditCardNumber.isEmpty == false && creditCardCVV.isEmpty == false
    }
    
    var saveNewCardButtonDisabled: Bool {
        (creditCardName.isEmpty || creditCardNumber.isEmpty || creditCardExpiryMonth.isEmpty || creditCardExpiryYear.isEmpty || creditCardCVV.isEmpty) || (isUnvalidCardName || isUnvalidCardNumber || isUnvalidExpiry || isUnvalidCVV)
    }
    
    init(container: DIContainer, checkoutComClient: @escaping CheckoutComClient = { CheckoutAPIService(publicKey: $0, environment: $1) }) {
        self.checkoutComClient = checkoutComClient
        self.container = container
        self.memberProfile = container.appState.value.userData.memberProfile
        if let memberProfile = self.memberProfile {
            self.creditCardName = memberProfile.firstname + " " + memberProfile.lastname
        }
        
        if let paymentGateway = container.appState.value.userData.selectedStore.value?.paymentGateways?.first(where: { $0.name ==  "checkoutcom"}) {
            self.paymentEvironment = paymentGateway.mode
            self.cardUtils = CardValidator(environment: paymentEvironment == .live ? .production : .sandbox)
        } else if let  paymentGateway = self.container.appState.value.businessData.businessProfile?.paymentGateways.first(where: { $0.name ==  "checkoutcom"}) {
            self.paymentEvironment = paymentGateway.mode
            self.cardUtils = CardValidator(environment: paymentEvironment == .live ? .production : .sandbox)
        } else {
            self.cardUtils = CardValidator(environment: .sandbox)
            self.paymentEvironment = .sandbox
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
                do {
                    self.cardType = try? self.cardUtils.validateCompleteness(cardNumber: number).get().scheme
                    self.isUnvalidCardNumber = try self.cardUtils.validateCompleteness(cardNumber: number).get().isComplete == false
                } catch {
                    self.container.appState.value.errors.append(error)
                }
                
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
                    self.isUnvalidCVV = self.cardUtils.isValid(cvv: cvv, for: cardType) == false
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
                self.creditCardExpiry = try? self.cardUtils.validate(expiryMonth: month, expiryYear: year).get()
                self.isUnvalidExpiry = self.creditCardExpiry == nil
            }
            .store(in: &cancellables)
    }
    
    func areCardDetailsValid() -> Bool {
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
            self.container.appState.value.errors.append(error)
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
                paymentGateway.mode == .live ? .production : .sandbox)
            
            // Add phone number from member profile
            let phoneNumber = Phone(
                number: memberProfile?.mobileContactNumber,
                country: nil)
            
            // add address injected from EditAddressViewModel
            let address = Checkout.Address(
                addressLine1: address.addressLine1,
                addressLine2: nil,
                city: nil,
                state: nil,
                zip: address.postcode,
                country: Country(iso3166Alpha2: address.countryCode ?? "GB"))
            
            let cardTokenRequest = Card(
                number: creditCardNumber,
                expiryDate: ExpiryDate(
                    month: creditCardExpiry?.month ?? 0,
                    year: creditCardExpiry?.year ?? 0
                ),
                name: creditCardName,
                cvv: creditCardCVV,
                billingAddress: address,
                phone: phoneNumber)
            
            // Request the card token.
            return try await checkoutAPIClient.createCardToken(card: cardTokenRequest).token
        } else {
            throw PaymentCardEntryViewModelError.missingBusinessProfileOrPublicKey
        }
    }
}
