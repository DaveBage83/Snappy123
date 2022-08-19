//
//  MemberDashboardMyDetailsViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 26/07/2022.
//

import Combine
import Foundation
import OSLog

enum GenericError: Swift.Error {
    case somethingWrong
}

extension GenericError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .somethingWrong:
            return GeneralStrings.Errors.generic.localized
        }
    }
}

@MainActor
class MemberDashboardMyDetailsViewModel: ObservableObject {
    @Published var showAddDeliveryAddressView = false
    @Published var profile: MemberProfile?
    @Published var showEditAddressView = false
    @Published var savedCardDetails = [MemberCardDetails]()
    
    private(set) var addressType: AddressType = .delivery
    var addressToEdit: Address?
    
    var noCards: Bool {
        savedCardDetails.isEmpty
    }
    
    var noBillingAddresses: Bool {
        billingAddresses.isEmpty
    }
    
    var noDeliveryAddresses: Bool {
        deliveryAddresses.isEmpty
    }
    
    var deliveryAddresses: [Address] {
        return sortedAddresses(profile?.savedAddresses?.filter {
            $0.type == .delivery
        } ?? [])
    }
        
    var billingAddresses: [Address] {
        return sortedAddresses(profile?.savedAddresses?.filter {
            $0.type == .billing
        } ?? [])
    }
    
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        self._profile = .init(initialValue: appState.value.userData.memberProfile)
        
        setupBindToProfile(with: appState)
    }
    
    // MARK: - Profile binding
    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                self.profile = profile
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Address sorting
    
    // First sort by default addresses, then alphabetically
    private func sortedAddresses(_ addresses: [Address]) -> [Address] {
        return addresses.sorted { (($0.isDefault == true).inverseIntValue, $0.addressName ?? "") < (($1.isDefault == true).inverseIntValue, $1.addressName ?? "") }
    }
    
    // MARK: - Button tap methods
    func addAddressTapped(addressType: AddressType) {
        self.addressType = addressType
        showAddDeliveryAddressView = true
    }
    
    func dismissAddDeliveryAddressView() {
        showAddDeliveryAddressView = false
    }
    
    func dismissEditAddressView() {
        showEditAddressView = false
    }
    
    func deleteAddressTapped(_ address: Address, didSetError: (Swift.Error) -> (), setLoading: (Bool) -> ()) async {
        setLoading(true)
        
        do {
            guard let addressID = address.id else {
                setLoading(false)
                throw GenericError.somethingWrong // If we are here, there is nothing useful we can tell the user so leave error generic
            }
            
            try await container.services.memberService.removeAddress(addressId: addressID)
            setLoading(false)
        } catch {
            setLoading(false)
            didSetError(error)
        }
    }
    
    func editAddressTapped(addressType: AddressType, address: Address) {
        self.addressToEdit = address
        self.addressType = addressType
        showEditAddressView = true
    }
    
    func onAppearTrigger() async {
        do {
            savedCardDetails = try await container.services.memberService.getSavedCards()
        } catch {
            Logger.member.error("Saved card details could not be retreived")
        }
    }
}
